import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/audio_player/audio_player.dart';
import 'package:deemusiq/provider/audio_player/state.dart';
import 'package:deemusiq/provider/discord_provider.dart';
import 'package:deemusiq/provider/history/history.dart';
import 'package:deemusiq/provider/history/monthly_plays.dart';
import 'package:deemusiq/provider/metadata_plugin/core/scrobble.dart';
import 'package:deemusiq/provider/metadata_plugin/audio_source/quality_presets.dart';
import 'package:deemusiq/provider/metadata_plugin/metadata_plugin_provider.dart';
import 'package:deemusiq/provider/server/sourced_track_provider.dart';
import 'package:deemusiq/provider/skip_segments/skip_segments.dart';
import 'package:deemusiq/provider/scrobbler/scrobbler.dart';
import 'package:deemusiq/provider/user_preferences/user_preferences_provider.dart';
import 'package:deemusiq/services/audio_player/audio_player.dart';
import 'package:deemusiq/services/audio_player/audio_error_handler.dart';
import 'package:deemusiq/services/audio_player/data_saver.dart';
import 'package:deemusiq/services/ad_roll/ad_roll_service.dart';
import 'package:deemusiq/services/audio_services/audio_services.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/provider/history/recently_played.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

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
      subscribeToTrackChangeForAds(),
      subscribeToAdState(),
      subscribeToVolumeForAds(),
      subscribeToBufferingWatchdog(),
    ];

    // Toggling "Normalize volume" mid-track must apply/clear the gain now,
    // not at the next track boundary.
    ref.listen(userPreferencesProvider, (previous, next) {
      if (previous?.normalizeAudio == next.normalizeAudio) return;
      try {
        _applyLoudnessGain();
      } catch (e, stack) {
        AppLogger.reportError(e, stack, 'normalizeAudio change');
      }
    });

    // Data saver: shrink mpv's cache/demuxer budgets while active (a lite
    // stream needs little readahead) and restore them when it turns off.
    ref.listen(dataSaverActiveProvider, (previous, next) {
      next.whenData((active) => _applyCacheBudgets(active));
    });
    _applyCacheBudgets(DataSaverService.isActiveCached);

    ref.onDispose(() {
      _bufferingWatchdog?.cancel();
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

  /// Applies the mpv cache/demuxer budget for the current data-saver state,
  /// keeping the lossless demuxer bump (quality_presets listener) when the
  /// saver is off.
  void _applyCacheBudgets(bool lite) {
    try {
      final presets = ref.read(audioSourcePresetsProvider);
      final lossless = presets.presets
              .elementAtOrNull(presets.selectedStreamingContainerIndex)
          is DeeMusiqAudioSourceContainerPresetLossless;
      unawaited(audioPlayer.setCacheBudgets(lite: lite, lossless: lossless));
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'data saver cache budgets');
    }
  }

  StreamSubscription subscribeToPlaylist() {
    return audioPlayer.playlistStream.listen((mpvPlaylist) {
      try {
        if (audioPlayerState.activeTrack == null) return;
        _notificationService?.addTrack(audioPlayerState.activeTrack!);
        discord.updatePresence(audioPlayerState.activeTrack!);
        _applyLoudnessGain();
      } catch (e, stack) {
        AppLogger.reportError(e, stack);
      }
    });
  }

  /// Loudness normalization (Phase 4): a catalog track carrying `gainDb` in
  /// its DTO gets that gain applied as a volume adjustment; anything else
  /// (YouTube-sourced, unmeasured catalog) keeps the dynaudnorm catch-all.
  /// Gated by the "Normalize volume" preference.
  void _applyLoudnessGain() {
    final track = audioPlayerState.activeTrack;
    final enabled = preferences.normalizeAudio;
    final gainDb =
        track is DeeMusiqFullTrackObject && enabled ? track.gainDb : null;
    unawaited(audioPlayer.setTrackGainDb(gainDb));
  }

  /// Ad breaks happen at track boundaries: when the index changes and enough
  /// songs have been listened, the break is armed FIRST (overlay + watchdog
  /// via [AdRollService.beginBreak]), then playback pauses and the ad's audio
  /// is resolved+played on a dedicated ad player
  /// ([AdRollService.startAdPlayback]). A resolution failure or timeout
  /// aborts the break (reported as a skip) — the player is never left paused
  /// with no UI and no running timer.
  StreamSubscription subscribeToTrackChangeForAds() {
    return audioPlayer.currentIndexChangedStream.listen((_) async {
      try {
        // Consumes the ad pre-warmed at the 80% mark when one is ready, so a
        // due break starts AT the boundary instead of into the next track.
        final ad = await AdRollService.instance.takeAdBreakIfDue();
        if (ad == null) return;
        AdRollService.instance.beginBreak(wasPlaying: audioPlayer.isPlaying);
        await audioPlayer.pause();
        AdRollService.instance.setAdVolume(audioPlayer.volume);
        final audioPlaying = await AdRollService.instance.startAdPlayback(ref);
        if (audioPlaying) {
          AdRollService.instance.markAdStarted();
        } else {
          AdRollService.instance.abortBreak();
        }
      } catch (e, stack) {
        AppLogger.reportError(e, stack, 'ad break at track boundary');
      }
    });
  }

  /// Resume playback when an ad break ends (skip, abort or natural
  /// completion) — but only in the foreground, and only when playback was
  /// active before the break; a break ending in the background must not
  /// start music unprompted.
  StreamSubscription subscribeToAdState() {
    return AdRollService.instance.adStateStream.listen((adPlaying) async {
      if (adPlaying) return;
      if (!AdRollService.instance.shouldResumeAfterBreak) {
        AppLogger.log.i(
          'Ad break ended without resume (backgrounded or playback was '
          'not active before the break)',
        );
        return;
      }
      try {
        await audioPlayer.resume();
      } catch (e, stack) {
        AppLogger.reportError(e, stack, 'resume after ad break');
      }
    });
  }

  /// Ads follow the in-app volume: forward main-player volume changes to the
  /// ad player so a break never blares at 100% against a lowered volume.
  StreamSubscription subscribeToVolumeForAds() {
    return audioPlayer.volumeStream.listen((volume) {
      AdRollService.instance.setAdVolume(volume);
    });
  }

  Timer? _bufferingWatchdog;

  /// mpv's network-timeout bounds connects and read gaps, but a CDN that
  /// trickles (or silently stalls) leaves the player in `buffering` forever.
  /// Treat >15s of continuous buffering during playback as a network error
  /// so the AudioErrorHandler can retry/skip and the user gets a message.
  StreamSubscription subscribeToBufferingWatchdog() {
    return audioPlayer.bufferingStream.listen((buffering) {
      _bufferingWatchdog?.cancel();
      _bufferingWatchdog = null;
      if (!buffering || !audioPlayer.isPlaying) return;
      _bufferingWatchdog = Timer(const Duration(seconds: 15), () {
        if (!audioPlayer.isBuffering || !audioPlayer.isPlaying) return;
        AppLogger.log.w(
          'Buffering watchdog: stalled >15s while playing — '
          'routing to AudioErrorHandler as a network error',
        );
        unawaited(
          AudioErrorHandler.instance.handleError(
            TimeoutException(
              'Buffering stalled while playing',
              const Duration(seconds: 15),
            ),
            StackTrace.current,
            context: 'buffering watchdog',
          ),
        );
      });
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
          .scrobbleWith(
            track: audioPlayerState.activeTrack!,
            listenedMs: position.inMilliseconds,
            durationMs: audioPlayer.duration.inMilliseconds,
          );
      _lastScrobbled = uid;

      /// The [Track] from Playlist.getTracks doesn't contain artist images
      /// so we need to fetch them from the API
      var activeTrack = audioPlayerState.activeTrack!;
      if (activeTrack.artists.any((a) => a.images == null)) {
        final metadataPlugin = await ref.read(metadataPluginProvider.future);
        if (metadataPlugin == null) return;
        final artists = (await Future.wait(
          activeTrack.artists.map((artist) => metadataPlugin.artist
              .getArtist(artist.id)
              .then<DeeMusiqFullArtistObject?>((a) => a)
              .catchError((_) => null)),
        ))
            .whereType<DeeMusiqFullArtistObject>()
            .toList();
        activeTrack = activeTrack.copyWith(
          artists: artists
              .map((e) => DeeMusiqSimpleArtistObject.fromJson(e.toJson()))
              .toList(),
        );
      }

      await history.addTrack(activeTrack);

      // Monthly Top-50 offline cache: count the qualified play (same bar as
      // the scrobble above) so the playback cache keeps this month's
      // most-played tracks pinned. Local files are already on disk.
      if (activeTrack is! DeeMusiqLocalTrackObject) {
        ref.read(monthlyPlaysProvider.notifier).recordPlay(activeTrack.id);
      }

      // User improvement: local recently-played + streak (on-device only).
      try {
        final title = activeTrack.name;
        final artist = activeTrack.artists.isNotEmpty
            ? activeTrack.artists.first.name
            : 'Unknown artist';
        await ref.read(recentlyPlayedProvider.notifier).push(
              RecentPlay(
                trackId: activeTrack.id,
                title: title,
                artist: artist,
                playedAt: DateTime.now(),
              ),
            );
      } catch (e) {
        // Recently-played is a local convenience — a failure must never
        // break playback, but it is logged for diagnosis.
        AppLogger.log.w('Failed to record recently-played entry: $e');
      }
      // Backend listen telemetry (Gmail-linked users get smarter For You).
      // Best-effort: local tracks have no backend id and offline plays retry
      // on the next scrobble — never fail playback on analytics.
      try {
        if (WalletApiClient.instance.isConfigured &&
            activeTrack is! DeeMusiqLocalTrackObject) {
          await WalletApiClient.instance.scrobble(
            trackId: activeTrack.id,
            listenedMs: position.inMilliseconds,
            durationMs: audioPlayer.duration.inMilliseconds,
          );
        }
      } catch (e) {
        // Telemetry is best-effort (see above) — the failure is logged so
        // dropped listen counts are diagnosable.
        AppLogger.log.w('Backend scrobble failed: $e');
      }

      AdRollService.instance.onTrackListened();
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
          audioPlayerState.currentIndex == audioPlayerState.tracks.length - 1) {
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

      // Pre-fetch the ad decision so a due break starts AT the upcoming
      // boundary instead of seconds into the next track.
      unawaited(() async {
        try {
          await AdRollService.instance.prewarmAdBreak();
        } catch (e, stack) {
          AppLogger.reportError(e, stack, 'ad pre-warm');
        }
      }());

      try {
        await ref.read(
          sourcedTrackProvider(nextTrack).future,
        );
        unawaited(_warmNextTrackBytes(nextTrack));
      } catch (e, stack) {
        // Clear guard on error so it can be retried on the next position event
        _lastTrack = '';
        AppLogger.reportError(e, stack, '_onPositionForPrefetch');
      }
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
    }
  }

  /// Byte-warm the next track: pull it through the loopback server now so
  /// the source resolution and the cache write finish before the boundary —
  /// the boundary then serves the verified local copy with no network wait.
  /// Skipped when the current buffer is thin (<10s — the playing track needs
  /// the bandwidth), on a metered (mobile) connection, when the data saver
  /// is on (saving bytes is the whole point), or when the music cache is off
  /// (no cache write to warm). Opportunistic: playback does its own fetch at
  /// the boundary if this fails.
  Future<void> _warmNextTrackBytes(DeeMusiqFullTrackObject nextTrack) async {
    try {
      if (!preferences.cacheMusic || DeeMusiqMedia.serverPort <= 0) return;
      final bufferedAhead = audioPlayer.bufferedPosition - audioPlayer.position;
      if (bufferedAhead < const Duration(seconds: 10)) return;
      if (await DataSaverService.isActive()) return;
      final networks = await Connectivity().checkConnectivity();
      if (networks.contains(ConnectivityResult.mobile)) return;
      final client = HttpClient();
      try {
        final uri = Uri.parse(DeeMusiqMedia(nextTrack).uri);
        final request = await client
            .getUrl(uri)
            .timeout(const Duration(seconds: 15));
        final response =
            await request.close().timeout(const Duration(seconds: 15));
        // Drain fully: the loopback tees this body into the music cache.
        await response.drain<void>();
        AppLogger.log.d('byte-warm complete for ${nextTrack.id}');
      } finally {
        client.close(force: true);
      }
    } catch (e) {
      AppLogger.log.d('byte-warm for next track skipped: $e');
    }
  }

  String? _sourceForPlayerError() {
    final source = audioPlayer.currentSource;
    if (source != null && source.startsWith('http')) return source;

    final track = audioPlayerState.activeTrack;
    if (track is DeeMusiqFullTrackObject && DeeMusiqMedia.serverPort > 0) {
      return DeeMusiqMedia(track).uri;
    }
    return source;
  }

  StreamSubscription subscribeToPlayerError() {
    return audioPlayer.errorStream.listen((event) async {
      final stack = StackTrace.current;
      AppLogger.log.e('MediaKit player error: $event');
      AppLogger.reportError(event, stack, 'MediaKit player error');

      try {
        final unavailable = await PlaybackUnavailableError.resolve(
          event,
          source: _sourceForPlayerError(),
        );
        if (unavailable != null) {
          try {
            await audioPlayer.pause();
          } catch (pauseError, pauseStack) {
            AppLogger.reportError(
              pauseError,
              pauseStack,
              'Pause after unavailable playback',
            );
          }
        }

        final error = unavailable ??
            (event is Exception ? event : Exception(event.toString()));
        await AudioErrorHandler.instance.handleError(
          error,
          stack,
          context: 'MediaKit stream',
          canSkipTrack: unavailable == null,
        );
      } catch (error, errorStack) {
        AppLogger.reportError(
            error, errorStack, 'MediaKit player error handling');
      }
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
