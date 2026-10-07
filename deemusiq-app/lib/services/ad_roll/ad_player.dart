import 'dart:async';

import 'package:media_kit/media_kit.dart';
import 'package:deemusiq/services/logger/logger.dart';

/// Dedicated media_kit player for ad-break audio. The main player owns the
/// music queue and is only paused during a break — routing the ad through it
/// would clobber the playlist, so ads get their own player instance. Stream
/// resolution stays in [AdRollService.startAdPlayback], which goes through the
/// same audio-source plugin / YouTube engine pipeline as regular tracks.
class AdPlayer {
  Player? _player;
  StreamSubscription<bool>? _completedSub;
  StreamSubscription<String>? _errorSub;

  /// At most one of onCompleted / onError fires per [play] call.
  bool _settled = false;

  /// Starts playing [url]. Returns false when the stream failed to open —
  /// the caller then runs the break in timer-fallback mode.
  Future<bool> play(
    String url, {
    required void Function() onCompleted,
    required void Function(Object error) onError,
  }) async {
    await stop();
    _settled = false;
    final player = Player(
      configuration: const PlayerConfiguration(title: 'DeeMusiq Ad'),
    );
    _player = player;
    // Ads are short — a stalled CDN must error out (→ timer fallback)
    // instead of holding the interstitial open.
    final platform = player.platform;
    if (platform is NativePlayer) {
      try {
        await platform.setProperty('network-timeout', '30');
      } catch (e, stack) {
        AppLogger.reportError(e, stack, 'AdPlayer network-timeout');
      }
    }
    _completedSub = player.stream.completed.listen((completed) {
      if (!completed || _settled) return;
      _settled = true;
      onCompleted();
    });
    _errorSub = player.stream.error.listen((error) {
      if (_settled) return;
      _settled = true;
      onError(error);
    });
    try {
      await player.open(Media(url));
      return true;
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'AdPlayer.open');
      return false;
    }
  }

  Future<void> stop() async {
    await _completedSub?.cancel();
    await _errorSub?.cancel();
    _completedSub = null;
    _errorSub = null;
    final player = _player;
    _player = null;
    if (player == null) return;
    try {
      await player.dispose();
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'AdPlayer.dispose');
    }
  }
}
