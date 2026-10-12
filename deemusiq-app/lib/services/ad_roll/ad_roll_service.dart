import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/metadata_plugin/metadata_plugin_provider.dart';
import 'package:deemusiq/services/ad_roll/ad_player.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/services/wallet/payment_service.dart'
    show PaymentGatewayConfig;
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// Controls when ad breaks are inserted between tracks. Fetches ad inventory
/// from the DeeMusiq backend (GET /ads/next, authenticated) and shows the
/// [AdOverlay] interstitial while playback is paused.
///
/// ## Flow
/// 1. Every track that passes the scrobble threshold counts as one listened
///    song ([onTrackListened]); every [skipsPerSongCredit] consecutive skips
///    count as one more ([onTrackSkipped]) so skip-heavy sessions still reach
///    ad breaks.
/// 2. At the 80% mark of a track, [prewarmAdBreak] pre-fetches the ad
///    decision so a due break starts AT the boundary. At the boundary,
///    [takeAdBreakIfDue] consumes the pre-warmed ad (or fetches live),
///    sending an `exclude` list of ad ids already heard this session.
/// 3. The caller arms the break FIRST via [beginBreak] — the interstitial
///    appears and the watchdog timer starts before any source resolution —
///    then pauses playback and calls [startAdPlayback], which resolves the
///    ad's YouTube source through the app's audio-source plugin (bounded by
///    [_resolveTimeoutSeconds]) and plays it on a dedicated [AdPlayer] so
///    the paused music queue stays untouched. [markAdStarted] confirms real
///    playback: the break then ends via the player's completion event
///    ([onAdCompleted]) with the timer as stall watchdog. A resolution
///    failure or timeout ends the break immediately ([abortBreak]) — the
///    player is never left paused with no UI and no running timer.
/// 4. Skips and completions are reported back to the backend for impression
///    and outcome reporting — exactly once per serve, and a break
///    whose ad audio never played (open failure, mid-stream error, watchdog)
///    is reported as a skip, never as a completion. If the backend is
///    unreachable or has no inventory, the break is skipped silently —
///    playback is never interrupted by ad errors.
///
/// ## Interruptions & lifecycle
/// [pauseBreak]/[resumeBreak] freeze the ad timer AND the [AdPlayer] (phone
/// calls, headphone unplug, app backgrounding via [setAppForegrounded]).
/// Timer math tracks REMAINING time, so a paused break never counts down.
/// When the break ends while the app is backgrounded, music does NOT resume
/// ([shouldResumeAfterBreak]) — playback only restarts in the foreground,
/// and only if it was active when the break began.
///
/// ## Backend API
/// ```
/// GET  /ads/next?exclude=id1,id2   → { ad: { id, youtubeId, label, tagline,
///                                            skippable, durationSec } | null }
/// POST /ads/skip     { adId }
/// POST /ads/complete { adId }
/// ```
class AdRollService {
  AdRollService._();
  static final AdRollService instance = AdRollService._();

  static const _songsSinceLastAdKey = 'deemusiq_adroll_songs';
  static const _excludeKey = 'deemusiq_adroll_exclude';
  static const _excludeDateKey = 'deemusiq_adroll_exclude_date';

  /// Extra seconds the watchdog waits beyond the declared duration for the
  /// player to signal completion before ending the break itself — a stalled
  /// stream must not pin the interstitial open forever.
  static const int _watchdogSlackSeconds = 30;

  /// Bound on ad source resolution + stream open. The failover chain can run
  /// for minutes unbounded; a break whose audio cannot start within this
  /// window is aborted (reported as a skip) so music resumes.
  static const int _resolveTimeoutSeconds = 20;

  /// Songs between ad breaks (configurable). Default 5.
  int songsBetweenAds = 5;

  /// Consecutive skips that count as one listened song toward the ad counter.
  static const int skipsPerSongCredit = 3;

  /// Whether ads are enabled. Set from configuration in [init]: ads only
  /// exist when a backend is configured.
  bool enabled = false;

  int _songsSinceLastAd = 0;
  int _skipsSinceLastAd = 0;
  final Set<String> _excludeIds = {};

  bool _adPlaying = false;
  bool get isAdPlaying => _adPlaying;

  final _adStateController = StreamController<bool>.broadcast();
  Stream<bool> get adStateStream => _adStateController.stream;

  AdSlot? _currentAd;

  /// Ad decision fetched at the 80% mark of the current track, consumed by
  /// the next [takeAdBreakIfDue] call so a due break starts at the boundary.
  AdSlot? _prewarmedAd;

  /// Wall-clock break start. Pushed forward by the paused span on
  /// [resumeBreak] so [adElapsedSeconds] freezes while the break is paused.
  DateTime? _adStartedAt;

  /// When the running break timer fires (null while paused).
  DateTime? _timerDeadline;

  /// Remaining time captured when the break was paused; re-armed on resume.
  Duration _pausedRemaining = Duration.zero;

  bool _breakPaused = false;
  DateTime? _breakPausedAt;

  Timer? _adTimer;
  final AdPlayer _adPlayer = AdPlayer();

  /// Ad volume (0–100) following the main player's volume, applied when ad
  /// audio starts and on every volume change during the break.
  double _adVolumePercent = 100;

  /// Whether the app is in the foreground. Drives [pauseBreak]/[resumeBreak]
  /// on lifecycle changes and gates the post-break music resume.
  bool _appForegrounded = true;

  /// Whether music was playing when the current break began — the post-break
  /// resume only makes sense when it was.
  bool _wasPlayingBeforeBreak = false;

  /// Whether the current break's ad audio is actually playing. False after a
  /// mid-stream error — such breaks report as skips, not completions.
  bool _audioPlaying = false;

  /// One outcome report per serve, even if skip/completion/watchdog race.
  bool _outcomeReported = false;

  /// Initialize from persistent storage.
  Future<void> init() async {
    enabled = PaymentGatewayConfig.backendBaseUrl.isNotEmpty;
    final prefs = KVStoreService.sharedPreferences;
    _songsSinceLastAd = prefs.getInt(_songsSinceLastAdKey) ?? 0;
    if (prefs.getString(_excludeDateKey) != _today()) {
      // The exclude set is per-day: ads heard on earlier days must not keep
      // shrinking today's inventory into permanent no_ads_available.
      resetExclude();
    }
    final raw = prefs.getString(_excludeKey);
    if (raw != null) {
      try {
        _excludeIds.addAll((jsonDecode(raw) as List).cast<String>());
      } catch (e) {
        AppLogger.log.d('Ad roll exclude-ids parse failed: ${e.toString()}');
      }
    }
  }

  static String _today() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)}';
  }

  /// Call when a track passed the scrobble threshold (counted as listened).
  void onTrackListened() {
    if (!enabled) return;
    _songsSinceLastAd++;
    _persistCount();
  }

  /// Call when the user skips a track. Every [skipsPerSongCredit] consecutive
  /// skips add one song credit so rapid skipping cannot dodge ads forever.
  void onTrackSkipped() {
    if (!enabled) return;
    _skipsSinceLastAd++;
    if (_skipsSinceLastAd >= skipsPerSongCredit) {
      _skipsSinceLastAd = 0;
      _songsSinceLastAd++;
      _persistCount();
    }
  }

  /// Pre-fetch the ad decision at the 80% mark of the current track so a due
  /// break starts AT the boundary instead of seconds into the next track.
  /// Idempotent within one boundary cycle: repeated calls reuse the fetched
  /// ad. Does not consume the song counter — [takeAdBreakIfDue] does.
  Future<AdSlot?> prewarmAdBreak() async {
    if (!enabled || _adPlaying) return null;
    if (_songsSinceLastAd < songsBetweenAds) return null;
    return _prewarmedAd ??= await _fetchAdFromBackend();
  }

  /// Call at a track boundary. Returns the [AdSlot] to show when an ad break
  /// is due (and inventory is available), or null to continue normally.
  Future<AdSlot?> takeAdBreakIfDue() async {
    if (!enabled || _adPlaying) return null;
    if (_songsSinceLastAd < songsBetweenAds) return null;

    // Reset up front: when the backend has no inventory the break is skipped
    // silently instead of retrying (= one request per track) forever.
    _songsSinceLastAd = 0;
    _skipsSinceLastAd = 0;
    _persistCount();

    final ad = _prewarmedAd ?? await _fetchAdFromBackend();
    _prewarmedAd = null;
    if (ad == null) return null;

    _currentAd = ad;
    _excludeIds.add(ad.id);
    _persistExclude();
    return ad;
  }

  /// Fetch the next ad from the backend. Returns null if no ads available or
  /// the backend is unreachable.
  Future<AdSlot?> _fetchAdFromBackend() async {
    if (!WalletApiClient.instance.isConfigured) return null;

    try {
      final adJson = await WalletApiClient.instance
          .fetchNextAd(excludeIds: _excludeIds.toList());
      if (adJson == null) return null;

      final durationSec = (adJson['durationSec'] as num?)?.toInt() ?? 15;
      final skipAfterSec = (adJson['skipAfterSec'] as num?)?.toInt();
      return AdSlot(
        id: adJson['id'] as String,
        youtubeId: (adJson['youtubeId'] as String?) ?? '',
        label: (adJson['label'] as String?) ?? 'Advertisement',
        tagline: (adJson['tagline'] as String?) ?? '',
        skippable: (adJson['skippable'] as bool?) ?? true,
        durationSeconds: durationSec.clamp(5, 120),
        // Server-driven skip delay; defaults to 5s when the backend does not
        // send the field (older deploys), clamped inside the ad's duration.
        skipAfterSeconds: (skipAfterSec ?? 5).clamp(0, durationSec),
      );
    } catch (e) {
      AppLogger.log.w('AdRoll: backend fetch failed: ${e.toString()}');
      return null; // silent skip — never interrupt playback for ad errors
    }
  }

  /// Arms the break: the interstitial appears (adStateStream → true) and the
  /// watchdog timer starts BEFORE any source resolution. Resolution can run
  /// long through the failover chain — without this the app sat paused with
  /// no UI and no timer. [wasPlaying] records whether music was active so
  /// the post-break resume ([shouldResumeAfterBreak]) only fires when it
  /// makes sense.
  void beginBreak({required bool wasPlaying}) {
    final ad = _currentAd;
    if (ad == null || _adPlaying) return;
    _adPlaying = true;
    _wasPlayingBeforeBreak = wasPlaying;
    _audioPlaying = false;
    _outcomeReported = false;
    _breakPaused = false;
    _breakPausedAt = null;
    _adStartedAt = DateTime.now();
    // The watchdog covers the whole break from here: resolution +
    // (markAdStarted re-arms for playback) — never a state with no timer.
    _armTimer(Duration(seconds: ad.durationSeconds + _watchdogSlackSeconds));
    _adStateController.add(true);
  }

  /// Resolves the current ad's YouTube source to an audio stream through the
  /// app's audio-source plugin (the same engine pipeline tracks use) and
  /// plays it on the dedicated ad player, leaving the paused music queue
  /// untouched. The whole operation is bounded by [_resolveTimeoutSeconds];
  /// returns false on any failure or timeout — the caller then aborts the
  /// break ([abortBreak]) and resumes music.
  Future<bool> startAdPlayback(Ref ref) async {
    final ad = _currentAd;
    if (ad == null || ad.youtubeId.isEmpty) return false;
    try {
      return await _resolveAndPlayAd(ref, ad)
          .timeout(const Duration(seconds: _resolveTimeoutSeconds));
    } on TimeoutException {
      AppLogger.log.w(
        'AdRoll: source resolution/open timed out after '
        '${_resolveTimeoutSeconds}s — aborting break',
      );
      return false;
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'AdRoll: start ad playback');
      return false;
    }
  }

  Future<bool> _resolveAndPlayAd(Ref ref, AdSlot ad) async {
    final plugin = await ref.read(audioSourcePluginProvider.future);
    if (plugin == null) {
      AppLogger.log.w('AdRoll: no audio source plugin');
      return false;
    }
    final streams = await plugin.audioSource.streams(
      DeeMusiqAudioSourceMatchObject(
        id: ad.youtubeId,
        title: ad.label,
        artists: const [],
        duration: Duration(seconds: ad.durationSeconds),
        externalUri: 'ytsource:${ad.youtubeId}',
      ),
    );
    final url = _bestStreamUrl(streams);
    if (url == null) {
      AppLogger.log.w('AdRoll: no playable stream for ad ${ad.id}');
      return false;
    }
    // Resolution is bounded but not instant — the user may have skipped (or
    // the break otherwise ended) while it ran. Never start ad audio into a
    // break that is no longer expecting it.
    if (!_adPlaying || !identical(_currentAd, ad)) {
      AppLogger.log.w('AdRoll: break ended during resolution — stream discarded');
      return false;
    }
    final playing = await _adPlayer.play(
      url,
      onCompleted: onAdCompleted,
      onError: (error) {
        AppLogger.log.w('AdRoll: ad stream error: $error');
        onAdPlaybackError();
      },
    );
    if (!playing) return false;
    // Same guard after open (up to the ad player's own network timeout): a
    // skip/abort during open must not leave ad audio running.
    if (!_adPlaying || !identical(_currentAd, ad)) {
      AppLogger.log.w('AdRoll: break ended during stream open — stopping');
      await _adPlayer.stop();
      return false;
    }
    await _adPlayer.setVolume(_adVolumePercent);
    return true;
  }

  /// Highest-bitrate stream wins — ads are short, so start-up cost dominates
  /// and the extra bandwidth is negligible.
  static String? _bestStreamUrl(List<DeeMusiqAudioSourceStreamObject> streams) {
    DeeMusiqAudioSourceStreamObject? best;
    for (final stream in streams) {
      if (stream.url.isEmpty) continue;
      if (best == null || (stream.bitrate ?? 0) > (best.bitrate ?? 0)) {
        best = stream;
      }
    }
    return best?.url;
  }

  /// Confirms the ad's audio is actually playing (called after
  /// [startAdPlayback] succeeded). The break now ends on the player's
  /// completion event; the timer re-arms as a pure stall watchdog (declared
  /// duration + slack). Either way the break finishes even when the player
  /// sheet (and its overlay) is closed.
  void markAdStarted() {
    final ad = _currentAd;
    if (ad == null || !_adPlaying) return;
    _audioPlaying = true;
    _armTimer(Duration(seconds: ad.durationSeconds + _watchdogSlackSeconds));
  }

  /// Aborts the break after a resolution/open failure or timeout: the ad was
  /// never heard, so the outcome is a skip, never a completion — and music
  /// resumes (via the ad-state listener) instead of staying paused.
  void abortBreak() {
    if (!_adPlaying) return;
    _reportOutcome(completed: false);
  }

  /// Pauses the break: the [AdPlayer] pauses and the break timer freezes
  /// (remaining time is captured, not wall-clock). Used for phone-call /
  /// headphone-unplug interruptions and app backgrounding so the ad does not
  /// blare on and the interstitial countdown does not run out off-screen.
  void pauseBreak() {
    if (!_adPlaying || _breakPaused) return;
    _breakPaused = true;
    final now = DateTime.now();
    _breakPausedAt = now;
    final deadline = _timerDeadline;
    if (deadline != null) {
      final left = deadline.difference(now);
      _pausedRemaining = left.isNegative ? Duration.zero : left;
    }
    _adTimer?.cancel();
    _adTimer = null;
    _timerDeadline = null;
    unawaited(_adPlayer.pause());
  }

  /// Resumes a paused break: the timer re-arms with the remaining time
  /// captured at [pauseBreak] and the [AdPlayer] resumes.
  void resumeBreak() {
    if (!_adPlaying || !_breakPaused) return;
    _breakPaused = false;
    final pausedAt = _breakPausedAt;
    _breakPausedAt = null;
    final startedAt = _adStartedAt;
    if (startedAt != null && pausedAt != null) {
      // Push the start forward by the paused span so adElapsedSeconds does
      // not count the pause.
      _adStartedAt = startedAt.add(DateTime.now().difference(pausedAt));
    }
    _armTimer(_pausedRemaining);
    unawaited(_adPlayer.resume());
  }

  /// Lifecycle hook: backgrounding pauses the break, foregrounding resumes
  /// it. No-op when no break is running.
  void setAppForegrounded(bool foregrounded) {
    if (_appForegrounded == foregrounded) return;
    _appForegrounded = foregrounded;
    if (!_adPlaying) return;
    if (foregrounded) {
      resumeBreak();
    } else {
      pauseBreak();
    }
  }

  /// Whether music should resume when the current break ends: only in the
  /// foreground, and only when playback was active before the break —
  /// otherwise a break ending in the background would start music
  /// unprompted.
  bool get shouldResumeAfterBreak => _appForegrounded && _wasPlayingBeforeBreak;

  /// Follows the main player's volume (0–1) so ads never blare at 100%
  /// against a lowered in-app volume. Applied live during ad playback and
  /// remembered for the next break.
  void setAdVolume(double zeroToOne) {
    _adVolumePercent = zeroToOne.clamp(0.0, 1.0) * 100;
    if (_adPlaying && _audioPlaying && !_breakPaused) {
      unawaited(_adPlayer.setVolume(_adVolumePercent));
    }
  }

  /// The ad's audio stream failed mid-break. The interstitial is already up,
  /// so the break still runs out the remaining declared duration — but the
  /// outcome is reported as a skip: a partially/never heard ad is not a paid
  /// completion.
  void onAdPlaybackError() {
    final ad = _currentAd;
    if (ad == null || !_adPlaying) return;
    _audioPlaying = false;
    unawaited(_adPlayer.stop());
    // The slack no longer applies — only the declared duration remains.
    final remaining = Duration(seconds: ad.durationSeconds - adElapsedSeconds);
    if (_breakPaused) {
      _pausedRemaining = remaining;
      return;
    }
    _armTimer(remaining);
  }

  /// The user skipped the current ad.
  void onSkipAd() {
    _reportOutcome(completed: false);
  }

  /// The ad audio played to its natural end (player completion event).
  void onAdCompleted() {
    _reportOutcome(completed: _audioPlaying);
  }

  /// Stall watchdog elapsed. The ad audio was never fully heard, so the
  /// honest outcome is a skip.
  void _onTimerElapsed() {
    _reportOutcome(completed: false);
  }

  /// Arms (or re-arms) the break timer. Never zero-length: a break must
  /// always have a live deadline while it is running.
  void _armTimer(Duration duration) {
    _adTimer?.cancel();
    final clamped = duration < const Duration(seconds: 1)
        ? const Duration(seconds: 1)
        : duration;
    _timerDeadline = DateTime.now().add(clamped);
    _adTimer = Timer(clamped, _onTimerElapsed);
  }

  void _reportOutcome({required bool completed}) {
    if (_outcomeReported) return;
    _outcomeReported = true;
    final adId = _currentAd?.id;
    _endAd();
    if (adId == null) return;
    final report = completed
        ? WalletApiClient.instance.reportAdComplete(adId)
        : WalletApiClient.instance.reportAdSkip(adId);
    unawaited(
      report.catchError((Object e) {
        AppLogger.log.d('AdRoll: outcome report failed: ${e.toString()}');
      }),
    );
  }

  void _endAd() {
    _adTimer?.cancel();
    _adTimer = null;
    _timerDeadline = null;
    _adPlaying = false;
    _audioPlaying = false;
    _breakPaused = false;
    _breakPausedAt = null;
    _pausedRemaining = Duration.zero;
    _currentAd = null;
    _prewarmedAd = null;
    _adStartedAt = null;
    unawaited(_adPlayer.stop());
    _adStateController.add(false);
  }

  /// The currently-playing ad, or null.
  AdSlot? get currentAd => _currentAd;

  /// Seconds since the current ad started (0 when no ad is playing). Lets the
  /// overlay show correct progress when (re)opened mid-ad. Frozen while the
  /// break is paused ([pauseBreak]).
  int get adElapsedSeconds {
    final startedAt = _adStartedAt;
    if (startedAt == null || !_adPlaying) return 0;
    final end = (_breakPaused ? _breakPausedAt : null) ?? DateTime.now();
    final elapsed = end.difference(startedAt).inSeconds;
    return elapsed < 0 ? 0 : elapsed;
  }

  @visibleForTesting
  set debugCurrentAd(AdSlot? ad) => _currentAd = ad;

  @visibleForTesting
  set debugPrewarmedAd(AdSlot? ad) => _prewarmedAd = ad;

  /// Milliseconds left on the break timer (the frozen remainder while
  /// paused). Test hook for the pause/resume timer math.
  @visibleForTesting
  int get debugTimerRemainingMs {
    if (_breakPaused) return _pausedRemaining.inMilliseconds;
    final deadline = _timerDeadline;
    if (deadline == null) return 0;
    final left = deadline.difference(DateTime.now()).inMilliseconds;
    return left < 0 ? 0 : left;
  }

  void _persistCount() {
    KVStoreService.sharedPreferences.setInt(
      _songsSinceLastAdKey,
      _songsSinceLastAd,
    );
  }

  void _persistExclude() {
    KVStoreService.sharedPreferences
      ..setString(_excludeKey, jsonEncode(_excludeIds.toList()))
      ..setString(_excludeDateKey, _today());
  }

  /// Resets the exclude set (e.g. on new session / app restart).
  void resetExclude() {
    _excludeIds.clear();
    _persistExclude();
  }

  void dispose() {
    _adTimer?.cancel();
    unawaited(_adPlayer.stop());
    _adStateController.close();
  }
}

/// An ad fetched from the backend, ready to be shown as an interstitial.
class AdSlot {
  final String id; // backend ad ID (used for exclude tracking)
  final String youtubeId; // 11-char YouTube video ID
  final String label; // shown in the player UI
  final String tagline; // short tagline
  final bool skippable;
  final int durationSeconds;

  /// Seconds before the skip button unlocks. Server-driven via `skipAfterSec`
  /// in the /ads/next payload; defaults to 5 when the field is absent.
  final int skipAfterSeconds;

  const AdSlot({
    required this.id,
    required this.youtubeId,
    required this.label,
    required this.tagline,
    required this.skippable,
    required this.durationSeconds,
    this.skipAfterSeconds = 5,
  });

  /// The full YouTube watch URL (resolved by the YouTube engine to audio-only).
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$youtubeId';
}
