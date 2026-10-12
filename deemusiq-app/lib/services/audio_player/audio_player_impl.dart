part of 'audio_player.dart';

final audioPlayer = DeeMusiqAudioPlayer();

class DeeMusiqAudioPlayer extends AudioPlayerInterface
    with DeeMusiqAudioPlayersStreams {
  Future<void> pause() async {
    try {
      await _mkPlayer.pause();
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'pause() failed');
      rethrow;
    }
  }

  Future<void> resume() async {
    try {
      await _mkPlayer.play();
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'resume() failed');
      await AudioErrorHandler.instance.handleError(
        e,
        stack,
        context: 'resume()',
        canSkipTrack: false,
      );
    }
  }

  Future<void> stop() async {
    try {
      await _mkPlayer.stop();
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'stop() failed');
      rethrow;
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _mkPlayer.seek(position);
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'seek() failed');
      rethrow;
    }
  }

  /// Volume is between 0 and 1
  Future<void> setVolume(double volume) async {
    assert(volume >= 0 && volume <= 1);
    try {
      userVolume = volume;
      await _applyEffectiveVolume();
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'setVolume() failed');
      rethrow;
    }
  }

  /// Applies user volume × per-track loudness gain to mpv. The product is
  /// clamped to [0, 1] — normalization may attenuate but never pushes past
  /// full user volume.
  Future<void> _applyEffectiveVolume() {
    final gainDb = trackGainDb;
    final linear = gainDb == null ? 1.0 : loudnessGainLinear(gainDb);
    final effective = (userVolume * linear).clamp(0.0, 1.0);
    return _mkPlayer.setVolume(effective * 100);
  }

  /// Per-track loudness normalization for catalog tracks carrying `gainDb`.
  /// Pass null on tracks without a measurement: mpv's dynaudnorm stays the
  /// catch-all there (YouTube-sourced tracks have no catalog loudness).
  Future<void> setTrackGainDb(double? gainDb) async {
    try {
      trackGainDb = gainDb;
      if (gainDb != null) {
        AppLogger.log.d('track gain: ${gainDb.toStringAsFixed(1)} dB');
      }
      await _applyEffectiveVolume();
      await _mkPlayer.setAudioNormalization(
        _audioNormalizationEnabled && gainDb == null,
      );
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'setTrackGainDb() failed');
      rethrow;
    }
  }

  bool _audioNormalizationEnabled = false;

  Future<void> setSpeed(double speed) async {
    try {
      await _mkPlayer.setRate(speed);
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'setSpeed() failed');
      rethrow;
    }
  }

  Future<void> setPitch(double pitch) async {
    try {
      await _mkPlayer.nativePlayer.setProperty('pitch-correction', pitch.toString());
    } catch (e, stack) {
      AppLogger.log.w('Error setting pitch: $e');
      AppLogger.reportError(e, stack, 'setPitch() failed');
      rethrow;
    }
  }

  Future<void> setAudioDevice(mk.AudioDevice device) async {
    try {
      await _mkPlayer.setAudioDevice(device);
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'setAudioDevice() failed');
      rethrow;
    }
  }

  Future<void> dispose() async {
    AudioErrorHandler.instance.dispose();
    try {
      await _mkPlayer.dispose();
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'dispose() failed');
      rethrow;
    }
  }

  // Playlist related

  Future<void> openPlaylist(
    List<mk.Media> tracks, {
    bool autoPlay = true,
    int initialIndex = 0,
  }) async {
    assert(tracks.isNotEmpty);
    assert(initialIndex <= tracks.length - 1);
    try {
      await _mkPlayer.open(
        mk.Playlist(tracks, index: initialIndex),
        play: autoPlay,
      );
    } catch (e, stack) {
      AppLogger.log.e('openPlaylist failed: $e');
      AppLogger.reportError(e, stack, 'openPlaylist()');
      await AudioErrorHandler.instance.handleError(
        e,
        stack,
        context: 'openPlaylist (${tracks.length} tracks)',
        canSkipTrack: tracks.length > 1,
        maxRetries: 3,
      );
    }
  }

  List<String> get sources {
    return _mkPlayer.state.playlist.medias.map((e) => e.uri).toList();
  }

  String? get currentSource {
    if (_mkPlayer.state.playlist.index == -1) return null;
    return _mkPlayer.state.playlist.medias
        .elementAtOrNull(_mkPlayer.state.playlist.index)
        ?.uri;
  }

  String? get nextSource {
    if (loopMode == PlaylistMode.loop &&
        _mkPlayer.state.playlist.index ==
            _mkPlayer.state.playlist.medias.length - 1) {
      return sources.first;
    }

    return _mkPlayer.state.playlist.medias
        .elementAtOrNull(_mkPlayer.state.playlist.index + 1)
        ?.uri;
  }

  String? get previousSource {
    if (loopMode == PlaylistMode.loop && _mkPlayer.state.playlist.index == 0) {
      return sources.last;
    }

    return _mkPlayer.state.playlist.medias
        .elementAtOrNull(_mkPlayer.state.playlist.index - 1)
        ?.uri;
  }

  int get currentIndex => _mkPlayer.state.playlist.index;

  Future<void> skipToNext() async {
    try {
      // Advancing the queue mid-ad corrupts the break bookkeeping — every
      // transport surface (notification, connect route, tray, player UI)
      // funnels through here, so the guard lives at the choke point.
      if (AdRollService.instance.isAdPlaying) {
        AppLogger.log.i('skipToNext ignored — ad break in progress');
        return;
      }
      AdRollService.instance.onTrackSkipped();
      await _mkPlayer.next();
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'skipToNext() failed');
      rethrow;
    }
  }

  Future<void> skipToPrevious() async {
    try {
      if (AdRollService.instance.isAdPlaying) {
        AppLogger.log.i('skipToPrevious ignored — ad break in progress');
        return;
      }
      AdRollService.instance.onTrackSkipped();
      await _mkPlayer.previous();
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'skipToPrevious() failed');
      rethrow;
    }
  }

  Future<void> jumpTo(int index) async {
    try {
      await _mkPlayer.jump(index);
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'jumpTo($index) failed');
      rethrow;
    }
  }

  Future<void> addTrack(mk.Media media) async {
    try {
      await _mkPlayer.add(media);
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'addTrack() failed');
      rethrow;
    }
  }

  Future<void> addTrackAt(mk.Media media, int index) async {
    try {
      await _mkPlayer.insert(index, media);
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'addTrackAt($index) failed');
      rethrow;
    }
  }

  Future<void> removeTrack(int index) async {
    try {
      await _mkPlayer.remove(index);
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'removeTrack($index) failed');
      rethrow;
    }
  }

  Future<void> moveTrack(int from, int to) async {
    try {
      await _mkPlayer.move(from, to);
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'moveTrack($from, $to) failed');
      rethrow;
    }
  }

  Future<void> clearPlaylist() async {
    try {
      await _mkPlayer.stop();
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'clearPlaylist() failed');
      rethrow;
    }
  }

  Future<void> setShuffle(bool shuffle) async {
    try {
      await _mkPlayer.setShuffle(shuffle);
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'setShuffle() failed');
      rethrow;
    }
  }

  Future<void> setLoopMode(PlaylistMode loop) async {
    try {
      await _mkPlayer.setPlaylistMode(loop);
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'setLoopMode() failed');
      rethrow;
    }
  }

  Future<void> setAudioNormalization(bool normalize) async {
    try {
      _audioNormalizationEnabled = normalize;
      // dynaudnorm is the catch-all for tracks WITHOUT a measured gain — a
      // catalog track playing with its DTO gainDb must not get double-
      // normalized, so the filter comes off while a gain is applied.
      await _mkPlayer.setAudioNormalization(
        normalize && trackGainDb == null,
      );
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'setAudioNormalization() failed');
      rethrow;
    }
  }

  Future<void> setDemuxerBufferSize(int sizeInBytes) async {
    try {
      await _mkPlayer.setDemuxerBufferSize(sizeInBytes);
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'setDemuxerBufferSize() failed');
      rethrow;
    }
  }

  /// Data-saver cache budgets (see [CustomPlayer.setCacheBudgets]).
  Future<void> setCacheBudgets({required bool lite, bool lossless = false}) async {
    try {
      await _mkPlayer.setCacheBudgets(lite: lite, lossless: lossless);
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'setCacheBudgets() failed');
      rethrow;
    }
  }

  // ── Crossfade & gapless (Spotify-style) ─────────────────────────────────

  Future<void> setCrossfade(Duration duration) async {
    try {
      await _mkPlayer.setCrossfade(duration);
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'setCrossfade() failed');
      rethrow;
    }
  }

  Future<void> setGaplessPlayback(bool enabled) async {
    try {
      await _mkPlayer.setGaplessPlayback(enabled);
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'setGaplessPlayback() failed');
      rethrow;
    }
  }

  Future<void> setReplayGain(String mode) async {
    try {
      await _mkPlayer.setReplayGain(mode);
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'setReplayGain() failed');
      rethrow;
    }
  }
}
