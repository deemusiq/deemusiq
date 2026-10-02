import 'dart:async';
import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';

/// Rolling count of how often each track was played during the current
/// calendar month (`yyyy-mm`, local time). Pure value type — all rollover and
/// ordering logic lives here so it can be unit-tested with an injected clock.
class MonthlyPlaysState {
  final String month;
  final Map<String, int> plays;

  /// Epoch-ms of the last counted play per track; tie-breaks equal counts so
  /// the leaderboard favours what the user listened to most recently.
  final Map<String, int> lastPlayedMs;

  const MonthlyPlaysState({
    required this.month,
    required this.plays,
    required this.lastPlayedMs,
  });

  factory MonthlyPlaysState.current(DateTime now) => MonthlyPlaysState(
        month: monthKey(now),
        plays: const {},
        lastPlayedMs: const {},
      );

  static String monthKey(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    return '${date.year}-$m';
  }

  /// A new month starts a fresh leaderboard — last month's counters are
  /// dropped entirely (they no longer drive cache pinning).
  MonthlyPlaysState rolloverIfNeeded(DateTime now) {
    return monthKey(now) == month ? this : MonthlyPlaysState.current(now);
  }

  MonthlyPlaysState recordPlay(String trackId, DateTime now) {
    final base = rolloverIfNeeded(now);
    final plays = Map<String, int>.from(base.plays);
    final lastPlayed = Map<String, int>.from(base.lastPlayedMs);
    plays[trackId] = (plays[trackId] ?? 0) + 1;
    lastPlayed[trackId] = now.millisecondsSinceEpoch;

    // Bound the leaderboard so the persisted blob stays small even for
    // listeners with very diverse months: only the top slice is kept.
    if (plays.length > MonthlyPlaysNotifier.maxTrackedTracks) {
      final keep = _sortedEntries(plays, lastPlayed)
          .take(MonthlyPlaysNotifier.maxTrackedTracks)
          .map((e) => e.key)
          .toSet();
      plays.removeWhere((key, _) => !keep.contains(key));
      lastPlayed.removeWhere((key, _) => !keep.contains(key));
    }
    return MonthlyPlaysState(
      month: base.month,
      plays: plays,
      lastPlayedMs: lastPlayed,
    );
  }

  /// Most-played first; equal counts ordered by most recent play.
  List<MapEntry<String, int>> get leaderboard =>
      _sortedEntries(plays, lastPlayedMs);

  Set<String> topTrackIds(int n) =>
      leaderboard.take(n).map((e) => e.key).toSet();

  static List<MapEntry<String, int>> _sortedEntries(
    Map<String, int> plays,
    Map<String, int> lastPlayed,
  ) {
    final entries = plays.entries.toList();
    entries.sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      if (byCount != 0) return byCount;
      return (lastPlayed[b.key] ?? 0).compareTo(lastPlayed[a.key] ?? 0);
    });
    return entries;
  }

  String toJsonString() => jsonEncode({
        'month': month,
        'plays': plays,
        'lastPlayed': lastPlayedMs,
      });

  static MonthlyPlaysState? fromJsonString(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final month = decoded['month'];
      if (month is! String || month.isEmpty) return null;
      Map<String, int> parseCounts(Object? value) {
        if (value is! Map) return {};
        return {
          for (final entry in value.entries)
            if (entry.value is num)
              entry.key.toString(): (entry.value as num).toInt(),
        };
      }

      final plays = parseCounts(decoded['plays']);
      if (plays.isEmpty) return null;
      return MonthlyPlaysState(
        month: month,
        plays: plays,
        lastPlayedMs: parseCounts(decoded['lastPlayed']),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Tracks the user's qualified plays for the current month and exposes the
/// Top-50 leaderboard that pins audio in the playback cache (see
/// `evictMusicCacheDir` in `provider/server/routes/playback.dart`). Plays are
/// counted from the same "qualified play" hook as scrobbling
/// (`AudioPlayerStreamListeners._onPositionForScrobble`), persisted to the
/// KV store so the counters survive restarts, and reset on month rollover.
class MonthlyPlaysNotifier extends StateNotifier<MonthlyPlaysState> {
  static const storageKey = 'deemusiq_monthly_plays';

  /// How many of the month's most-played tracks keep their audio pinned in
  /// the on-phone cache.
  static const topPinnedCount = 50;

  /// Upper bound of distinct tracks kept in the persisted leaderboard.
  static const maxTrackedTracks = 500;

  final DateTime Function() _clock;

  MonthlyPlaysNotifier({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        super(_initialState(clock ?? DateTime.now));

  static MonthlyPlaysState _initialState(DateTime Function() clock) {
    try {
      final raw = KVStoreService.sharedPreferences.getString(storageKey);
      final restored = MonthlyPlaysState.fromJsonString(raw);
      if (restored != null) return restored.rolloverIfNeeded(clock());
    } catch (_) {}
    return MonthlyPlaysState.current(clock());
  }

  void recordPlay(String trackId) {
    if (trackId.isEmpty) return;
    state = state.recordPlay(trackId, _clock());
    unawaited(_persist());
  }

  /// Track ids whose cached audio files are excluded from eviction. Re-checks
  /// the month on every call, so a queue that keeps playing across a month
  /// boundary starts the new month's leaderboard (and drops the old pins)
  /// without a restart.
  Set<String> pinnedTrackIds() {
    final rolled = state.rolloverIfNeeded(_clock());
    if (!identical(rolled, state)) {
      state = rolled;
      unawaited(_persist());
    }
    return state.topTrackIds(topPinnedCount);
  }

  Future<void> _persist() async {
    try {
      await KVStoreService.sharedPreferences
          .setString(storageKey, state.toJsonString());
    } catch (_) {}
  }
}

final monthlyPlaysProvider =
    StateNotifierProvider<MonthlyPlaysNotifier, MonthlyPlaysState>(
  (ref) => MonthlyPlaysNotifier(),
);
