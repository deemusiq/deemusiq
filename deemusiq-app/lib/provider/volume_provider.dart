
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/services/audio_player/audio_player.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';

class VolumeProvider extends Notifier<double> {
  VolumeProvider();

  @override
  build() {
    final persisted = _sanitize(KVStoreService.volume);
    audioPlayer.setVolume(persisted);
    return persisted;
  }

  /// M6: LAN peers (Connect) can push arbitrary doubles here — clamp to the
  /// [0, 1] platform range and reject non-finite values before they reach
  /// the player (mpv would happily amplify >100%) or get persisted.
  static double _sanitize(double volume) {
    if (volume.isNaN || volume.isInfinite) return 1.0;
    return volume.clamp(0.0, 1.0);
  }

  Future<void> setVolume(double volume) async {
    final clamped = _sanitize(volume);
    state = clamped;
    await audioPlayer.setVolume(clamped);
    KVStoreService.setVolume(clamped);
  }
}

final volumeProvider =
    NotifierProvider<VolumeProvider, double>(() => VolumeProvider());
