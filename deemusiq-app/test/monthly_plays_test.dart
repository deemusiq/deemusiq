import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deemusiq/provider/history/monthly_plays.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';

void main() {
  group('MonthlyPlaysState', () {
    test('monthKey formats yyyy-mm', () {
      expect(
        MonthlyPlaysState.monthKey(DateTime(2026, 10, 1)),
        '2026-10',
      );
      expect(
        MonthlyPlaysState.monthKey(DateTime(2026, 12, 31, 23, 59)),
        '2026-12',
      );
    });

    test('recordPlay increments the per-track counter', () {
      final now = DateTime(2026, 10, 5, 12);
      var state = MonthlyPlaysState.current(now);
      state = state.recordPlay('track-a', now);
      state = state.recordPlay('track-a', now.add(const Duration(minutes: 3)));
      state = state.recordPlay('track-b', now);

      expect(state.plays['track-a'], 2);
      expect(state.plays['track-b'], 1);
    });

    test('month rollover drops the previous month entirely', () {
      final october = DateTime(2026, 10, 31, 23, 59);
      var state = MonthlyPlaysState.current(october);
      state = state.recordPlay('track-a', october);
      state = state.recordPlay('track-a', october);

      // Mid-queue month boundary: the next play lands in the new month.
      final november = DateTime(2026, 11, 1, 0, 0);
      state = state.recordPlay('track-b', november);

      expect(state.month, '2026-11');
      expect(state.plays, {'track-b': 1});
      expect(state.lastPlayedMs.containsKey('track-a'), isFalse);
    });

    test('leaderboard orders by count, ties broken by most recent play', () {
      final base = DateTime(2026, 10, 10, 8);
      var state = MonthlyPlaysState.current(base);
      state = state.recordPlay('a', base);
      state = state.recordPlay('b', base.add(const Duration(minutes: 1)));
      state = state.recordPlay('c', base.add(const Duration(minutes: 2)));
      state = state.recordPlay('b', base.add(const Duration(minutes: 3)));
      // a and c tie at 1 play — c was played more recently.

      expect(
        state.leaderboard.map((e) => e.key).toList(),
        ['b', 'c', 'a'],
      );
    });

    test('topTrackIds caps at n', () {
      final base = DateTime(2026, 10, 1);
      var state = MonthlyPlaysState.current(base);
      for (var i = 0; i < 60; i++) {
        state = state.recordPlay('track-$i', base.add(Duration(minutes: i)));
      }
      expect(state.topTrackIds(50), hasLength(50));
    });

    test('leaderboard stays bounded for diverse months', () {
      final base = DateTime(2026, 10, 1);
      var state = MonthlyPlaysState.current(base);
      for (var i = 0; i < 800; i++) {
        state = state.recordPlay('track-$i', base.add(Duration(seconds: i)));
      }
      expect(
        state.plays.length,
        lessThanOrEqualTo(MonthlyPlaysNotifier.maxTrackedTracks),
      );
    });

    test('JSON round-trips and survives a restart', () {
      final now = DateTime(2026, 10, 20, 18, 30);
      var state = MonthlyPlaysState.current(now);
      state = state.recordPlay('track-a', now);
      state = state.recordPlay('track-a', now);
      state = state.recordPlay('track-b', now);

      final restored =
          MonthlyPlaysState.fromJsonString(state.toJsonString());
      expect(restored, isNotNull);
      expect(restored!.month, state.month);
      expect(restored.plays, state.plays);
      expect(restored.lastPlayedMs, state.lastPlayedMs);
    });

    test('fromJsonString rejects corrupt payloads', () {
      expect(MonthlyPlaysState.fromJsonString(null), isNull);
      expect(MonthlyPlaysState.fromJsonString(''), isNull);
      expect(MonthlyPlaysState.fromJsonString('not json'), isNull);
      expect(MonthlyPlaysState.fromJsonString('{"plays":{}}'), isNull);
      expect(MonthlyPlaysState.fromJsonString('{"month":"2026-10"}'), isNull);
    });
  });

  group('MonthlyPlaysNotifier persistence', () {
    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      await KVStoreService.initialize();
    });

    test('counters persist across app restarts', () async {
      var now = DateTime(2026, 10, 15, 10);
      final notifier = MonthlyPlaysNotifier(clock: () => now);
      notifier.recordPlay('track-a');
      notifier.recordPlay('track-a');
      notifier.recordPlay('track-b');
      // Flush the fire-and-forget persistence.
      await Future<void>.delayed(Duration.zero);

      final restarted = MonthlyPlaysNotifier(clock: () => now);
      expect(restarted.state.plays, {'track-a': 2, 'track-b': 1});
      expect(restarted.pinnedTrackIds(), {'track-a', 'track-b'});
    });

    test('a restart in a new month starts over', () async {
      final october = DateTime(2026, 10, 31, 20);
      final notifier = MonthlyPlaysNotifier(clock: () => october);
      notifier.recordPlay('track-a');
      await Future<void>.delayed(Duration.zero);

      final november = DateTime(2026, 11, 2, 9);
      final restarted = MonthlyPlaysNotifier(clock: () => november);
      expect(restarted.state.month, '2026-11');
      expect(restarted.state.plays, isEmpty);
    });

    test('pinnedTrackIds is capped at the Top-50', () async {
      var now = DateTime(2026, 10, 3);
      final notifier = MonthlyPlaysNotifier(clock: () => now);
      for (var i = 0; i < 70; i++) {
        notifier.recordPlay('track-$i');
        now = now.add(const Duration(minutes: 1));
      }
      expect(notifier.pinnedTrackIds(), hasLength(50));
    });

    test('empty track ids are ignored', () {
      final notifier = MonthlyPlaysNotifier(clock: DateTime.now);
      notifier.recordPlay('');
      expect(notifier.state.plays, isEmpty);
    });
  });
}
