import 'dart:async';
import 'dart:convert';

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
/// 3. The caller pauses playback and calls [markAdStarted]; the service owns
///    the countdown and fires [onAdCompleted] when the ad ends, so the break
///    finishes even when the player sheet (and its overlay) is closed.
/// 4. Skips and completions are reported back to the backend for impression
///    and campaign-spend accounting. If the backend is unreachable or has no
///    inventory, the break is skipped silently — playback is never interrupted
///    by ad errors.
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

  /// Songs between ad breaks (configurable). Default 6.
  int songsBetweenAds = 6;

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

  /// Initialize from persistent storage.
  Future<void> init() async {
    enabled = PaymentGatewayConfig.backendBaseUrl.isNotEmpty;
    final prefs = KVStoreService.sharedPreferences;
    _songsSinceLastAd = prefs.getInt(_songsSinceLastAdKey) ?? 0;
    final raw = prefs.getString(_excludeKey);
    if (raw != null) {
      try {
        _excludeIds.addAll((jsonDecode(raw) as List).cast<String>());
      } catch (e) {
        AppLogger.log.d('Ad roll exclude-ids parse failed: ${e.toString()}');
      }
    }
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

  /// Call when the ad break starts (after pausing playback). The service owns
  /// the countdown so the break completes even with no overlay on screen.
  void markAdStarted() {
    final ad = _currentAd;
    if (ad == null) return;
    _adPlaying = true;
    _adStartedAt = DateTime.now();
    _adTimer?.cancel();
    _adTimer = Timer(Duration(seconds: ad.durationSeconds), onAdCompleted);
    _adStateController.add(true);
  }

  /// The user skipped the current ad.
  void onSkipAd() {
    final adId = _currentAd?.id;
    _endAd();
    if (adId != null) {
      unawaited(
        WalletApiClient.instance.reportAdSkip(adId).catchError((Object e) {
          AppLogger.log.d('AdRoll: skip report failed: ${e.toString()}');
        }),
      );
    }
  }

  /// The ad finished playing naturally.
  void onAdCompleted() {
    final adId = _currentAd?.id;
    _endAd();
    if (adId != null) {
      unawaited(
        WalletApiClient.instance.reportAdComplete(adId).catchError((Object e) {
          AppLogger.log.d('AdRoll: completion report failed: ${e.toString()}');
        }),
      );
    }
  }

  void _endAd() {
    _adTimer?.cancel();
    _adTimer = null;
    _adPlaying = false;
    _currentAd = null;
    _adStartedAt = null;
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
    KVStoreService.sharedPreferences.setString(
      _excludeKey,
      jsonEncode(_excludeIds.toList()),
    );
  }

  /// Resets the exclude set (e.g. on new session / app restart).
  void resetExclude() {
    _excludeIds.clear();
    _persistExclude();
  }

  void dispose() {
    _adTimer?.cancel();
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
