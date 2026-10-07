import 'dart:async';
import 'dart:convert';

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
/// 2. At the next track boundary, [takeAdBreakIfDue] asks the backend for an
///    ad once [songsBetweenAds] songs have accumulated, sending an `exclude`
///    list of ad ids already heard this session.
/// 3. The caller pauses playback and calls [startAdPlayback], which resolves
///    the ad's YouTube source through the app's audio-source plugin (the same
///    engine pipeline tracks use) and plays it on a dedicated [AdPlayer] so
///    the paused music queue stays untouched. [markAdStarted] then arms the
///    lifecycle: a real playback ends the break via the player's completion
///    event ([onAdCompleted]); when no stream could be opened the declared
///    `durationSec` timer runs the break out instead.
/// 4. Skips and completions are reported back to the backend for impression
///    and outcome reporting — exactly once per serve, and a break
///    whose ad audio never played (open failure, mid-stream error, watchdog)
///    is reported as a skip, never as a completion. If the backend is
///    unreachable or has no inventory, the break is skipped silently —
///    playback is never interrupted by ad errors.
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
  DateTime? _adStartedAt;
  Timer? _adTimer;
  final AdPlayer _adPlayer = AdPlayer();

  /// Whether the current break's ad audio is actually playing. False in
  /// timer-fallback mode and after a mid-stream error — such breaks report
  /// as skips, not completions.
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

    final ad = await _fetchAdFromBackend();
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
      return AdSlot(
        id: adJson['id'] as String,
        youtubeId: (adJson['youtubeId'] as String?) ?? '',
        label: (adJson['label'] as String?) ?? 'Advertisement',
        tagline: (adJson['tagline'] as String?) ?? '',
        skippable: (adJson['skippable'] as bool?) ?? true,
        durationSeconds: durationSec.clamp(5, 120),
      );
    } catch (e) {
      AppLogger.log.w('AdRoll: backend fetch failed: ${e.toString()}');
      return null; // silent skip — never interrupt playback for ad errors
    }
  }

  /// Resolves the current ad's YouTube source to an audio stream through the
  /// app's audio-source plugin (the same engine pipeline tracks use) and
  /// plays it on the dedicated ad player, leaving the paused music queue
  /// untouched. Returns false when no playable stream could be opened — the
  /// caller then starts the break in timer-fallback mode.
  Future<bool> startAdPlayback(Ref ref) async {
    final ad = _currentAd;
    if (ad == null || ad.youtubeId.isEmpty) return false;
    try {
      final plugin = await ref.read(audioSourcePluginProvider.future);
      if (plugin == null) {
        AppLogger.log.w('AdRoll: no audio source plugin — timer fallback');
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
      return await _adPlayer.play(
        url,
        onCompleted: onAdCompleted,
        onError: (error) {
          AppLogger.log.w('AdRoll: ad stream error: $error');
          onAdPlaybackError();
        },
      );
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'AdRoll: start ad playback');
      return false;
    }
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

  /// Call when the ad break starts (after pausing playback and attempting
  /// [startAdPlayback]). With [audioPlaying] true the break ends on the
  /// player's completion event and the timer only acts as a stall watchdog;
  /// otherwise the declared-duration timer runs the break out. Either way the
  /// break finishes even when the player sheet (and its overlay) is closed.
  void markAdStarted({bool audioPlaying = false}) {
    final ad = _currentAd;
    if (ad == null) return;
    _adPlaying = true;
    _adStartedAt = DateTime.now();
    _audioPlaying = audioPlaying;
    _outcomeReported = false;
    _adTimer?.cancel();
    _adTimer = Timer(
      Duration(
        seconds: audioPlaying
            ? ad.durationSeconds + _watchdogSlackSeconds
            : ad.durationSeconds,
      ),
      _onTimerElapsed,
    );
    _adStateController.add(true);
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
    _adTimer?.cancel();
    final remaining = ad.durationSeconds - adElapsedSeconds;
    _adTimer = Timer(
      Duration(seconds: remaining < 1 ? 1 : remaining),
      _onTimerElapsed,
    );
  }

  /// The user skipped the current ad.
  void onSkipAd() {
    _reportOutcome(completed: false);
  }

  /// The ad audio played to its natural end (player completion event).
  void onAdCompleted() {
    _reportOutcome(completed: _audioPlaying);
  }

  /// Timer fallback (no playable stream) or stall watchdog. In both cases the
  /// ad audio was never fully heard, so the honest outcome is a skip.
  void _onTimerElapsed() {
    _reportOutcome(completed: false);
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
    _adPlaying = false;
    _audioPlaying = false;
    _currentAd = null;
    _adStartedAt = null;
    unawaited(_adPlayer.stop());
    _adStateController.add(false);
  }

  /// The currently-playing ad, or null.
  AdSlot? get currentAd => _currentAd;

  /// Seconds since the current ad started (0 when no ad is playing). Lets the
  /// overlay show correct progress when (re)opened mid-ad.
  int get adElapsedSeconds {
    final startedAt = _adStartedAt;
    if (startedAt == null) return 0;
    return DateTime.now().difference(startedAt).inSeconds;
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

  const AdSlot({
    required this.id,
    required this.youtubeId,
    required this.label,
    required this.tagline,
    required this.skippable,
    required this.durationSeconds,
  });

  /// The full YouTube watch URL (resolved by the YouTube engine to audio-only).
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$youtubeId';
}
