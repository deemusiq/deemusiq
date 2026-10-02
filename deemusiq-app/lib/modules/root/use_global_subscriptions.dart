import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/collections/routes.dart';
import 'package:deemusiq/components/dialogs/confirm_download_dialog.dart';
import 'package:deemusiq/extensions/color_scheme.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/audio_player/audio_player.dart';
import 'package:deemusiq/provider/database/database.dart';
import 'package:deemusiq/provider/download_manager_provider.dart';
import 'package:deemusiq/provider/server/routes/connect.dart';
import 'package:deemusiq/services/audio_player/audio_player.dart';
import 'package:deemusiq/services/audio_player/audio_error_handler.dart';
import 'package:deemusiq/services/connectivity_adapter.dart';
import 'package:deemusiq/services/queue/playback_queue.dart';
import 'package:deemusiq/services/auth/biometric_lock.dart';
import 'package:deemusiq/utils/service_utils.dart';

DateTime? _lastConnectivityToastTime;

void useGlobalSubscriptions(WidgetRef ref) {
  final context = useContext();
  final theme = Theme.of(context);
  final connectRoutes = ref.watch(serverConnectRoutesProvider);

  useEffect(() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ServiceUtils.checkForUpdates(context, ref);
    });

    // Surface audio errors as user-visible toasts so "nothing happens" on
    // playback failure is actually visible to the user.
    AudioErrorHandler.instance.onUserMessage =
        (String message, AudioErrorSeverity severity) {
      if (!context.mounted) return;
      final color = severity == AudioErrorSeverity.error
          ? theme.colorScheme.destructive
          : severity == AudioErrorSeverity.warning
              ? theme.colorScheme.chart3
              : null;
      final foreground = color == null
          ? null
          : severity == AudioErrorSeverity.warning
              ? Colors.black
              : theme.colorScheme.onDestructive;
      showToast(
        context: context,
        location: ToastLocation.topRight,
        builder: (ctx, overlay) {
          return SurfaceCard(
            fillColor: color,
            filled: color != null,
            child: Basic(
              leading: Icon(
                severity == AudioErrorSeverity.error
                    ? DeeMusiqIcons.error
                    : DeeMusiqIcons.info,
                color: foreground,
                size: 14,
              ),
              title: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      );
    };

    AudioErrorHandler.instance.onPlaybackUnavailable = (error) async {
      final track = ref.read(audioPlayerProvider).activeTrack;
      if (track is! DeeMusiqFullTrackObject ||
          (error.trackId.isNotEmpty && track.id != error.trackId)) {
        return AudioUnavailableAction.retry;
      }

      final dialogContext = rootNavigatorKey.currentContext;
      if (dialogContext == null || !dialogContext.mounted) {
        return AudioUnavailableAction.retry;
      }

      final confirmed = await showDialog<bool>(
        context: dialogContext,
        builder: (_) => ConfirmDownloadDialog(
          message:
              'This track is temporarily unavailable. Download it to this device to keep listening.',
          acceptLabel: dialogContext.l10n.download,
        ),
      );
      if (confirmed != true) return AudioUnavailableAction.retry;

      ref.read(downloadManagerProvider.notifier).addToQueue(track);
      return AudioUnavailableAction.downloadQueued;
    };

    StreamSubscription? audioPlayerSubscription;
    bool pausedByStream = false;

    final subscriptions = [
      ConnectionCheckerService.instance.onConnectivityChanged
          .listen((connected) async {
        audioPlayerSubscription?.cancel();

        /// Pausing or resuming based on connectivity to avoid MPV skipping
        /// audio while retrying to connect
        if (audioPlayer.currentIndex >= 0) {
          if (connected && audioPlayer.isPaused && pausedByStream) {
            await audioPlayer.resume();
            pausedByStream = false;
          } else if (!connected && audioPlayer.isPlaying) {
            if ((audioPlayer.bufferedPosition - const Duration(seconds: 1)) <=
                audioPlayer.position) {
              await audioPlayer.pause();
              pausedByStream = true;
            } else {
              audioPlayerSubscription =
                  audioPlayer.positionStream.listen((position) async {
                if (ConnectionCheckerService.instance.isConnectedSync) return;

                final bufferedPosition =
                    audioPlayer.bufferedPosition - const Duration(seconds: 1);
                final duration =
                    audioPlayer.duration - const Duration(seconds: 1);

                if (bufferedPosition <= position || position >= duration) {
                  audioPlayer.pause();
                  pausedByStream = true;
                }
              });
            }
          }
        }

        // Show notification for connection related issues
        if (!context.mounted) return;

        final now = DateTime.now();
        if (_lastConnectivityToastTime != null &&
            now.difference(_lastConnectivityToastTime!) <
                const Duration(seconds: 5)) {
          return;
        }
        _lastConnectivityToastTime = now;

        showToast(
          context: context,
          location: ToastLocation.bottomCenter,
          builder: (context, overlay) {
            if (connected) {
              return SurfaceCard(
                child: Basic(
                  leading: const Icon(DeeMusiqIcons.wifi),
                  title: Text(context.l10n.connection_restored),
                ),
              );
            }

            return SurfaceCard(
              fillColor: theme.colorScheme.destructive,
              filled: true,
              child: Basic(
                leading: Icon(
                  DeeMusiqIcons.noWifi,
                  color: theme.colorScheme.onDestructive,
                ),
                trailing: Text(
                  context.l10n.you_are_offline,
                  style: TextStyle(
                    color: theme.colorScheme.onDestructive,
                  ),
                ),
              ),
            );
          },
        );
      }),
      connectRoutes.connectClientStream.listen((clientOrigin) {
        if (!context.mounted) return;
        showToast(
          context: context,
          location: ToastLocation.topRight,
          builder: (context, overlay) {
            return SurfaceCard(
              fillColor: theme.colorScheme.chart3,
              filled: true,
              child: Basic(
                leading: const Icon(
                  DeeMusiqIcons.error,
                  color: Colors.black,
                ),
                title: Text(
                  context.l10n.connect_client_alert(clientOrigin),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            );
          },
        );
      })
    ];

    final lifecycleWatcher = LifecycleWatcher(ref: ref);
    WidgetsBinding.instance.addObserver(lifecycleWatcher);

    return () {
      WidgetsBinding.instance.removeObserver(lifecycleWatcher);
      AudioErrorHandler.instance.onUserMessage = null;
      AudioErrorHandler.instance.onPlaybackUnavailable = null;
      for (final subscription in subscriptions) {
        subscription.cancel();
      }
    };
  }, []);
}

class LifecycleWatcher extends WidgetsBindingObserver {
  final WidgetRef ref;
  LifecycleWatcher({required this.ref});

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    // Fingerprint lock grace window: background timestamp drives re-lock.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      BiometricLockService.instance.markBackgrounded();
    } else if (state == AppLifecycleState.resumed) {
      BiometricLockService.instance.markForegrounded();
    }
    if (state == AppLifecycleState.paused) {
      final audioState = ref.read(audioPlayerProvider);
      final tracks = audioState.tracks;
      if (tracks.isNotEmpty) {
        await PlaybackQueue.saveQueue(
          ref.read(databaseProvider),
          tracks,
          currentIndex: audioState.currentIndex,
        );
      }
    } else if (state == AppLifecycleState.resumed) {
      final currentTracks = ref.read(audioPlayerProvider).tracks;
      if (currentTracks.isEmpty) {
        final saved = await PlaybackQueue.loadQueue(ref.read(databaseProvider));
        if (saved != null && saved.tracks.isNotEmpty) {
          await ref.read(audioPlayerProvider.notifier).load(
            saved.tracks,
            initialIndex: saved.currentIndex,
            autoPlay: true,
          );
        }
      }
    }
  }
}
