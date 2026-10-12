import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deemusiq/services/ad_roll/ad_roll_service.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/services/logger/logger.dart';

AdSlot testAd({int durationSeconds = 15, int skipAfterSeconds = 5}) => AdSlot(
      id: 'ad-test',
      youtubeId: 'dQw4w9WgXcQ',
      label: 'Test Ad',
      tagline: 'a tagline',
      skippable: true,
      durationSeconds: durationSeconds,
      skipAfterSeconds: skipAfterSeconds,
    );

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    AppLogger.initialize(false);
    SharedPreferences.setMockInitialValues({});
    await KVStoreService.initialize();
  });

  final service = AdRollService.instance;

  tearDown(() {
    service.setAppForegrounded(true);
    service.abortBreak();
    service.debugCurrentAd = null;
    service.debugPrewarmedAd = null;
    service.enabled = false;
    service.songsBetweenAds = 5;
  });

  group('break arming (beginBreak first)', () {
    test('beginBreak arms overlay state and watchdog before resolution',
        () async {
      service.debugCurrentAd = testAd();
      final states = <bool>[];
      final sub = service.adStateStream.listen(states.add);
      addTearDown(sub.cancel);

      service.beginBreak(wasPlaying: true);
      // Broadcast-stream events land on the event queue, not synchronously.
      await Future<void>.delayed(Duration.zero);

      // The interstitial goes up immediately — no waiting on resolution.
      expect(service.isAdPlaying, isTrue);
      expect(states, [true]);
      // Watchdog armed from the start: declared 15s + 30s slack.
      expect(service.debugTimerRemainingMs, greaterThan(40000));
      expect(service.shouldResumeAfterBreak, isTrue);
    });

    test('abortBreak ends the break (skip outcome) so music can resume',
        () async {
      service.debugCurrentAd = testAd();
      final states = <bool>[];
      final sub = service.adStateStream.listen(states.add);
      addTearDown(sub.cancel);

      service.beginBreak(wasPlaying: true);
      service.abortBreak();
      // Broadcast-stream events land on the event queue, not synchronously.
      await Future<void>.delayed(Duration.zero);

      expect(service.isAdPlaying, isFalse);
      expect(states, [true, false]);
      expect(service.currentAd, isNull);
      expect(service.debugTimerRemainingMs, 0);
    });
  });

  group('pauseBreak/resumeBreak timer math', () {
    test('the break timer freezes while paused and resumes from the remainder',
        () async {
      service.debugCurrentAd = testAd(durationSeconds: 15);
      service.beginBreak(wasPlaying: true);
      service.markAdStarted();

      await Future<void>.delayed(const Duration(milliseconds: 1200));
      service.pauseBreak();
      final frozenRemaining = service.debugTimerRemainingMs;
      final frozenElapsed = service.adElapsedSeconds;
      expect(frozenRemaining, lessThan(45000));
      expect(frozenRemaining, greaterThan(40000));

      await Future<void>.delayed(const Duration(milliseconds: 1000));
      // Paused: neither the remaining time nor the visible elapsed moves.
      expect(service.debugTimerRemainingMs, frozenRemaining);
      expect(service.adElapsedSeconds, frozenElapsed);

      service.resumeBreak();
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      expect(service.debugTimerRemainingMs, lessThan(frozenRemaining - 800));
      expect(service.adElapsedSeconds, greaterThan(frozenElapsed));
    });

    test('backgrounding pauses the break, foregrounding resumes it', () async {
      service.debugCurrentAd = testAd();
      service.beginBreak(wasPlaying: true);

      service.setAppForegrounded(false);
      expect(service.shouldResumeAfterBreak, isFalse);
      final frozen = service.debugTimerRemainingMs;
      await Future<void>.delayed(const Duration(milliseconds: 800));
      expect(service.debugTimerRemainingMs, frozen);

      service.setAppForegrounded(true);
      expect(service.shouldResumeAfterBreak, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 600));
      expect(service.debugTimerRemainingMs, lessThan(frozen));
    });
  });

  group('watchdog after a mid-stream error', () {
    test('the remaining declared duration (not the slack) runs the break out',
        () async {
      service.debugCurrentAd = testAd(durationSeconds: 5);
      final ended = Completer<void>();
      final sub = service.adStateStream.listen((playing) {
        if (!playing && !ended.isCompleted) ended.complete();
      });
      addTearDown(sub.cancel);

      service.beginBreak(wasPlaying: true);
      service.markAdStarted();
      service.onAdPlaybackError();

      // Remaining ≈ 5s declared − ~0 elapsed: the break ends within seconds
      // even though the watchdog slack was 30s.
      await ended.future.timeout(const Duration(seconds: 10));
      expect(service.isAdPlaying, isFalse);
    });
  });

  group('ad decision pre-warm', () {
    test('takeAdBreakIfDue consumes the pre-warmed ad once', () async {
      service.enabled = true;
      service.songsBetweenAds = 1;
      service.onTrackListened();
      final ad = testAd();
      service.debugPrewarmedAd = ad;

      final taken = await service.takeAdBreakIfDue();

      expect(identical(taken, ad), isTrue);
      expect(service.currentAd, isNotNull);

      // Consumed: the next due check fetches live — the backend is
      // unconfigured in tests, so that returns null.
      service.onTrackListened();
      expect(await service.takeAdBreakIfDue(), isNull);
    });

    test('prewarm is a no-op when disabled or not due', () async {
      expect(await service.prewarmAdBreak(), isNull);
      service.enabled = true;
      service.songsBetweenAds = 100;
      expect(await service.prewarmAdBreak(), isNull);
    });
  });

  test('AdSlot defaults skipAfterSeconds to 5 and keeps server values', () {
    expect(testAd().skipAfterSeconds, 5);
    const custom = AdSlot(
      id: 'a',
      youtubeId: 'b',
      label: 'c',
      tagline: 'd',
      skippable: true,
      durationSeconds: 30,
      skipAfterSeconds: 12,
    );
    expect(custom.skipAfterSeconds, 12);
  });
}
