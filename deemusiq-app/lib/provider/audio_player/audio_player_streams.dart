import 'dart:async';
import 'dart:math';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/audio_player/audio_player.dart';
import 'package:deemusiq/provider/audio_player/state.dart';
import 'package:deemusiq/provider/discord_provider.dart';
import 'package:deemusiq/provider/history/history.dart';
import 'package:deemusiq/provider/metadata_plugin/core/scrobble.dart';
import 'package:deemusiq/provider/metadata_plugin/metadata_plugin_provider.dart';
import 'package:deemusiq/provider/server/sourced_track_provider.dart';
import 'package:deemusiq/provider/skip_segments/skip_segments.dart';
import 'package:deemusiq/provider/scrobbler/scrobbler.dart';
import 'package:deemusiq/provider/user_preferences/user_preferences_provider.dart';
import 'package:deemusiq/services/audio_player/audio_player.dart';
import 'package:deemusiq/services/audio_player/audio_error_handler.dart';
import 'package:deemusiq/services/audio_services/audio_services.dart';
import 'package:deemusiq/services/logger/logger.dart';

class AudioPlayerStreamListeners {
  final Ref ref;
  AudioServices? _notificationService;
  AudioPlayerStreamListeners(this.ref) {
    AudioServices.create(ref, ref.read(audioPlayerProvider.notifier)).then(
      (value) {
        _notificationService = value;
        AppLogger.log.i('AudioServices created and ready');
      },
    ).catchError((e, stack) {
      AppLogger.log.e('AudioServices.create failed: $e');
      AppLogger.reportError(e, stack, 'AudioServices.create');
    });

    // ── Single position subscription shared across all position-based
    //     listeners to avoid creating duplicate mpv stream subscriptions.
    //     Each handler has its own sentinel/guard to avoid duplicate work.
    final positionSub = audioPlayer.positionStream.listen((position) {
      _onPositionForSkipSponsor(position);
      _onPositionForScrobble(position);
      _onPositionForPrefetch(position);
    });

    final subscriptions = [
      subscribeToPlaylist(),
      positionSub,
      subscribeToPlayerError(),
      subscribeToUserMessages(),
    ];

    ref.onDispose(() {
      for (final subscription in subscriptions) {
        subscription.cancel();
      }
    });
  }

  ScrobblerNotifier get scrobbler => ref.read(scrobblerProvider.notifier);
  UserPreferences get preferences => ref.read(userPreferencesProvider);
  DiscordNotifier get discord => ref.read(discordProvider.notifier);
  AudioPlayerState get audioPlayerState => ref.read(audioPlayerProvider);
  PlaybackHistoryActions get history =>
      ref.read(playbackHistoryActionsProvider);

  StreamSubscription subscribeToPlaylist() {
    return audioPlayer.playlistStream.listen((mpvPlaylist) {
      try {
        if (audioPlayerState.activeTrack == null) return;
        _notificationService?.addTrack(audioPlayerState.activeTrack!);
        discord.updatePresence(audioPlayerState.activeTrack!);
      } catch (e, stack) {
        AppLogger.reportError(e, stack);
      }
    });
  }

  void _onPositionForSkipSponsor(Duration position) async {
    try {
      final currentSegments = await ref.read(segmentProvider.future);

      if (currentSegments?.segments.isNotEmpty != true ||
          position < const Duration(seconds: 3)) {
        return;
      }

      final trackDuration = audioPlayer.duration;
      if (trackDuration == Duration.zero) return;

      for (final segment in currentSegments!.segments) {
        final seconds = position.inSeconds;

        if (seconds < segment.start || seconds >= segment.end) continue;

        final seekTarget = segment.end + 1;
        final clampedTarget = seekTarget >= trackDuration.inSeconds
            ? trackDuration.inSeconds - 1
            : seekTarget;
        if (clampedTarget < 0) return;

        await audioPlayer.seek(Duration(seconds: clampedTarget));
      }
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
    }
  }

  String? _lastScrobbled;
  void _onPositionForScrobble(Duration position) async {
    try {
      final uid = audioPlayerState.activeTrack is DeeMusiqLocalTrackObject
          ? (audioPlayerState.activeTrack as DeeMusiqLocalTrackObject).path
          : audioPlayerState.activeTrack?.id;

      /// According to Listenbrainz and Last.fm, a scrobble should be sent
      /// after 4 minutes of listening or 50% of the track duration,
      /// whichever is less.
      final minimumListenTime = min(audioPlayer.duration.inSeconds ~/ 2, 240);

      if (audioPlayerState.activeTrack == null ||
          _lastScrobbled == uid ||
          position.inSeconds < minimumListenTime ||
          audioPlayer.duration == Duration.zero ||
          position == Duration.zero) {
        return;
      }

      scrobbler.scrobble(audioPlayerState.activeTrack!);
      ref
          .read(metadataPluginScrobbleProvider.notifier)
          .scrobble(audioPlayerState.activeTrack!);
      _lastScrobbled = uid;

      /// The [Track] from Playlist.getTracks doesn't contain artist images
      /// so we need to fetch them from the API
      var activeTrack = audioPlayerState.activeTrack!;
      if (activeTrack.artists.any((a) => a.images == null)) {
        final metadataPlugin = await ref.read(metadataPluginProvider.future);
        if (metadataPlugin == null) return;
        final artists = (await Future.wait(
          activeTrack.artists.map((artist) =>
              metadataPlugin.artist.getArtist(artist.id).catchError((_) => null)),
        )).whereType<DeeMusiqFullArtistObject>().toList();
        activeTrack = activeTrack.copyWith(
          artists: artists
              .map((e) => DeeMusiqSimpleArtistObject.fromJson(e.toJson()))
              .toList(),
        );
      }

      await history.addTrack(activeTrack);
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
    }
  }

  String _lastTrack = ''; // used to prevent multiple calls to the same track
  void _onPositionForPrefetch(Duration event) async {
    final percentProgress =
        (event.inSeconds / max(audioPlayer.duration.inSeconds, 1)) * 100;
    try {
      if (percentProgress < 80 ||
          audioPlayerState.currentIndex == -1 ||
          audioPlayerState.currentIndex ==
              audioPlayerState.tracks.length - 1) {
        return;
      }
      final nextTrack = audioPlayerState.tracks
          .elementAtOrNull(audioPlayerState.currentIndex + 1);

      if (nextTrack == null ||
          _lastTrack == nextTrack.id ||
          nextTrack is DeeMusiqLocalTrackObject) {
        return;
      }

      if (nextTrack is! DeeMusiqFullTrackObject) {
        AppLogger.log.w(
          '_onPositionForPrefetch: nextTrack is not DeeMusiqFullTrackObject, type=${nextTrack.runtimeType}',
        );
        return;
      }

      // Set guard immediately to prevent concurrent fetches of the same track
      _lastTrack = nextTrack.id;
      try {
        await ref.read(
          sourcedTrackProvider(nextTrack).future,
        );
      } catch (e, stack) {
        // Clear guard on error so it can be retried on the next position event
        _lastTrack = '';
        AppLogger.reportError(e, stack, '_onPositionForPrefetch');
      }
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
    }
  }

  StreamSubscription subscribeToPlayerError() {
    return audioPlayer.errorStream.listen((event) {
      AppLogger.log.e('MediaKit player error: $event');
      AppLogger.reportError(event, StackTrace.current, 'MediaKit player error');
      AudioErrorHandler.instance.handleError(
        event is Exception ? event : Exception(event.toString()),
        StackTrace.current,
        context: 'MediaKit stream',
        canSkipTrack: true,
      );
    });
  }

  /// Subscribes to user-facing messages from the audio pipeline.
  /// These are routed to the AudioErrorHandler for UI display (toasts, etc.).
  StreamSubscription subscribeToUserMessages() {
    return audioPlayer.userMessageStream.listen((message) {
      AppLogger.log.i('[UserMessage] $message');
      // The message is already routed through the error handler's onUserMessage
      // callback by the CustomPlayer. This stream provides an additional hook
      // for any provider-level side effects.
    });
  }
}

final audioPlayerStreamListenersProvider =
    Provider<AudioPlayerStreamListeners>(AudioPlayerStreamListeners.new);
