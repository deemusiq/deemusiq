import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/services/logger/logger.dart';

/// Data saver modes: off, always on, or on only when the connection is
/// metered (cellular — the same `ConnectivityResult.mobile` signal the
/// byte-warm prefetch uses).
enum DataSaverMode {
  off,
  on,
  autoOnMetered;

  static DataSaverMode fromName(String? name) {
    for (final mode in values) {
      if (mode.name == name) return mode;
    }
    return off;
  }
}

/// Persists and evaluates the data-saver preference. When active, playback
/// prefers lite renditions (catalog `liteUrl`), the lowest-bitrate YouTube
/// stream, smaller mpv cache budgets, and skips the next-track byte prefetch.
class DataSaverService {
  static const _key = 'dataSaverMode';

  /// Last probed metered state, refreshed by [isActive] and the
  /// [dataSaverActiveProvider] connectivity listener. Lets synchronous hot
  /// paths (playback cache identity) read the current value without an await.
  static bool _meteredCache = false;

  static DataSaverMode get mode =>
      DataSaverMode.fromName(KVStoreService.sharedPreferences.getString(_key));

  static Future<void> setMode(DataSaverMode mode) async {
    await KVStoreService.sharedPreferences.setString(_key, mode.name);
    AppLogger.log.i('Data saver mode set to: ${mode.name}');
  }

  /// Pure mode evaluation — the single decision point, unit-tested directly.
  static bool isActiveFor(DataSaverMode mode, {required bool metered}) {
    return switch (mode) {
      DataSaverMode.off => false,
      DataSaverMode.on => true,
      DataSaverMode.autoOnMetered => metered,
    };
  }

  /// Fresh evaluation: reads the stored mode and (for auto) probes the
  /// network. Use in async resolution paths.
  static Future<bool> isActive([DataSaverMode? mode]) async {
    final m = mode ?? DataSaverService.mode;
    if (m != DataSaverMode.autoOnMetered) {
      return isActiveFor(m, metered: false);
    }
    try {
      final networks = await Connectivity().checkConnectivity();
      _meteredCache = networks.contains(ConnectivityResult.mobile);
    } catch (e, stack) {
      // A failed probe must not silently disable the saver — keep the last
      // known state and log.
      AppLogger.log.w('Data saver connectivity probe failed: $e');
      AppLogger.reportError(e, stack, 'DataSaverService.isActive');
    }
    return isActiveFor(m, metered: _meteredCache);
  }

  /// Synchronous last-known value (uses the cached metered probe).
  static bool get isActiveCached =>
      isActiveFor(mode, metered: _meteredCache);

  /// Test hook: preset the metered cache so [isActiveCached] is deterministic.
  static void debugSetMetered(bool metered) {
    _meteredCache = metered;
  }
}

/// The lowest-bitrate entry of [items] (null-safe on missing bitrates), or
/// null for an empty list. The data-saver mirror of the ad player's
/// "highest bitrate wins" pick (`AdRollService._bestStreamUrl`).
T? lowestBitrateOf<T>(Iterable<T> items, double? Function(T item) bitrate) {
  T? best;
  for (final item in items) {
    final candidate = bitrate(item);
    if (best == null ||
        (candidate ?? double.infinity) < (bitrate(best) ?? double.infinity)) {
      best = item;
    }
  }
  return best;
}

/// Reactive wrapper over [DataSaverService.mode] so settings and playback
/// rebuild on change.
class DataSaverModeNotifier extends Notifier<DataSaverMode> {
  @override
  DataSaverMode build() => DataSaverService.mode;

  Future<void> setMode(DataSaverMode mode) async {
    await DataSaverService.setMode(mode);
    state = mode;
  }
}

final dataSaverModeProvider =
    NotifierProvider<DataSaverModeNotifier, DataSaverMode>(
  DataSaverModeNotifier.new,
);

/// Whether the saver is currently in effect. Re-emits on mode changes and
/// (in auto mode) on connectivity changes.
final dataSaverActiveProvider = StreamProvider<bool>((ref) async* {
  final mode = ref.watch(dataSaverModeProvider);
  yield await DataSaverService.isActive(mode);
  if (mode != DataSaverMode.autoOnMetered) return;
  await for (final _ in Connectivity().onConnectivityChanged) {
    yield await DataSaverService.isActive(DataSaverService.mode);
  }
});
