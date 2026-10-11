import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:deemusiq/services/kv_store/encrypted_kv_store.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/wallet/payment_service.dart'
    show PaymentGatewayConfig;
import 'package:deemusiq/services/integrity/integrity_service.dart';
import 'package:deemusiq/services/wallet/device_identity.dart';
import 'package:deemusiq/services/wallet/secure_channel.dart';
import 'package:uuid/uuid.dart';

/// One day of server-side listening history (`GET /me/history`).
///
/// `track` is the standard metadata-plugin track DTO, so it is kept as a raw
/// map and handed to the same mapper every other track source uses.
class ServerListenEntry {
  final String day;
  final int listenedMs;
  final int? durationMs;
  final bool skipped;
  final String source;
  final Map<String, dynamic> track;

  const ServerListenEntry({
    required this.day,
    required this.listenedMs,
    required this.durationMs,
    required this.skipped,
    required this.source,
    required this.track,
  });

  factory ServerListenEntry.fromJson(Map json) => ServerListenEntry(
        day: json["day"] as String,
        listenedMs: (json["listenedMs"] as num?)?.toInt() ?? 0,
        durationMs: (json["durationMs"] as num?)?.toInt(),
        skipped: json["skipped"] == true,
        source: (json["source"] as String?) ?? "app",
        track: Map<String, dynamic>.from(json["track"] as Map),
      );
}

/// One point of the per-day listening chart.
class ListenDayTotal {
  final String day;
  final int listenedMs;

  const ListenDayTotal({required this.day, required this.listenedMs});

  factory ListenDayTotal.fromJson(Map json) => ListenDayTotal(
        day: json["day"] as String,
        listenedMs: (json["listenedMs"] as num?)?.toInt() ?? 0,
      );
}

/// A ranked track in the stats response.
class ListenTopTrack {
  final int listenedMs;
  final int days;
  final Map<String, dynamic> track;

  const ListenTopTrack({
    required this.listenedMs,
    required this.days,
    required this.track,
  });

  factory ListenTopTrack.fromJson(Map json) => ListenTopTrack(
        listenedMs: (json["listenedMs"] as num?)?.toInt() ?? 0,
        days: (json["days"] as num?)?.toInt() ?? 0,
        track: Map<String, dynamic>.from(json["track"] as Map),
      );
}

/// A ranked artist in the stats response (already folded from its tracks).
class ListenTopArtist {
  final String id;
  final String name;
  final int listenedMs;
  final int tracks;

  const ListenTopArtist({
    required this.id,
    required this.name,
    required this.listenedMs,
    required this.tracks,
  });

  factory ListenTopArtist.fromJson(Map json) => ListenTopArtist(
        id: json["id"] as String,
        name: (json["name"] as String?) ?? "",
        listenedMs: (json["listenedMs"] as num?)?.toInt() ?? 0,
        tracks: (json["tracks"] as num?)?.toInt() ?? 0,
      );
}

/// Server-side listening totals (`GET /me/stats`).
class ServerListenStats {
  final int days;

  /// Distinct track-DAYS listened (skips excluded). NOT raw play events: the
  /// server's ListenHistory is unique per (user, track, UTC day).
  final int listens;

  /// The same count with short skips added back.
  final int listensIncludingSkips;

  /// Total listened time in ms, excluding skips.
  final int listenedMs;
  final List<ListenDayTotal> byDay;
  final List<ListenTopTrack> topTracks;
  final List<ListenTopArtist> topArtists;

  const ServerListenStats({
    required this.days,
    required this.listens,
    required this.listensIncludingSkips,
    required this.listenedMs,
    required this.byDay,
    required this.topTracks,
    required this.topArtists,
  });

  factory ServerListenStats.fromJson(Map json) => ServerListenStats(
        days: (json["days"] as num?)?.toInt() ?? 0,
        listens: (json["listens"] as num?)?.toInt() ?? 0,
        listensIncludingSkips:
            (json["listensIncludingSkips"] as num?)?.toInt() ?? 0,
        listenedMs: (json["listenedMs"] as num?)?.toInt() ?? 0,
        byDay: ((json["byDay"] as List<dynamic>? ?? const []))
            .map((raw) => ListenDayTotal.fromJson(raw as Map))
            .toList(),
        topTracks: ((json["topTracks"] as List<dynamic>? ?? const []))
            .map((raw) => ListenTopTrack.fromJson(raw as Map))
            .toList(),
        topArtists: ((json["topArtists"] as List<dynamic>? ?? const []))
            .map((raw) => ListenTopArtist.fromJson(raw as Map))
            .toList(),
      );

  Duration get totalTime =>
      Duration(milliseconds: listenedMs);
}

/// The account's saved queue + resume position (`GET /me/playback`).
class RemotePlaybackState {
  final List<Map<String, dynamic>> queue;
  final String? currentTrackId;
  final int positionMs;
  final bool playing;

  /// Ids the server filtered out (taken down / unpublished). The caller should
  /// prune these rather than render a row it cannot play.
  final List<String> droppedTrackIds;
  final DateTime? updatedAt;

  /// True when the stored state is older than the server's staleness window.
  final bool stale;

  const RemotePlaybackState({
    required this.queue,
    required this.currentTrackId,
    required this.positionMs,
    required this.playing,
    required this.droppedTrackIds,
    required this.updatedAt,
    required this.stale,
  });

  factory RemotePlaybackState.fromJson(Map json) => RemotePlaybackState(
        queue: ((json["queue"] as List<dynamic>? ?? const []))
            .map((raw) => Map<String, dynamic>.from(raw as Map))
            .toList(),
        currentTrackId: json["currentTrackId"] as String?,
        positionMs: (json["positionMs"] as num?)?.toInt() ?? 0,
        playing: json["playing"] == true,
        droppedTrackIds:
            ((json["droppedTrackIds"] as List<dynamic>? ?? const []))
                .cast<String>(),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"] as String),
        stale: json["stale"] == true,
      );

  /// Nothing worth resuming: no queue, or the server filtered all of it out.
  bool get isEmpty => queue.isEmpty;

  Duration get resumeAt => Duration(milliseconds: positionMs);
}

/// A playlist this account collaborates on (`GET /shared`).
class SharedPlaylist {
  final String id;
  final String title;
  final String? description;
  final String? coverUrl;

  /// "owner" or "editor" — decides whether destructive actions are offered.
  final String myRole;

  const SharedPlaylist({
    required this.id,
    required this.title,
    required this.description,
    required this.coverUrl,
    required this.myRole,
  });

  factory SharedPlaylist.fromJson(Map json) => SharedPlaylist(
        id: json["id"] as String,
        title: (json["title"] as String?) ?? "",
        description: json["description"] as String?,
        coverUrl: json["coverUrl"] as String?,
        myRole: (json["myRole"] as String?) ?? "editor",
      );

  bool get canEdit => myRole == "owner" || myRole == "editor";

  /// Only an owner may reshare or rename.
  bool get isOwner => myRole == "owner";
}

/// A pending share invitation (`GET /invites`).
class PlaylistInvite {
  final String playlistId;
  final String title;
  final String? description;
  final DateTime invitedAt;

  const PlaylistInvite({
    required this.playlistId,
    required this.title,
    required this.description,
    required this.invitedAt,
  });

  factory PlaylistInvite.fromJson(Map json) => PlaylistInvite(
        playlistId: json["playlistId"] as String,
        title: (json["title"] as String?) ?? "",
        description: json["description"] as String?,
        invitedAt: DateTime.parse(json["invitedAt"] as String),
      );
}

/// The onboarding taste profile (`GET/PUT /recommendations/preferences`).
class TasteProfile {
  final List<String> genres;
  final List<String> artistIds;

  /// Decade bucket like "2010s", or null for no preference.
  final String? era;

  /// When false the engine ignores this profile (the user declined
  /// personalisation). It is still stored, so the choice can be reversed.
  final bool personalizationEnabled;

  /// ISO alpha-2 region used for the regional leaderboards/charts, or null
  /// for the global board.
  final String? region;

  const TasteProfile({
    this.genres = const [],
    this.artistIds = const [],
    this.era,
    this.personalizationEnabled = true,
    this.region,
  });

  factory TasteProfile.fromJson(Map json) => TasteProfile(
        genres: ((json["genres"] as List<dynamic>? ?? const []))
            .map((e) => e as String)
            .toList(),
        artistIds: ((json["artistIds"] as List<dynamic>? ?? const []))
            .map((e) => e as String)
            .toList(),
        era: json["era"] as String?,
        personalizationEnabled: json["personalizationEnabled"] != false,
        region: json["region"] as String?,
      );

  bool get isEmpty =>
      genres.isEmpty && artistIds.isEmpty && era == null;
}

/// Aggregate like/dislike counts for one track (shape from `/ratings`).
class TrackRatingStats {
  final int likes;
  final int dislikes;
  final int total;

  /// Share of ratings that are likes, or null when nothing has rated it yet —
  /// the backend sends null (not 0) so the UI can say "unrated" instead of
  /// showing a misleading 0%.
  final double? likeRatio;

  const TrackRatingStats({
    required this.likes,
    required this.dislikes,
    required this.total,
    required this.likeRatio,
  });

  factory TrackRatingStats.fromJson(Map json) => TrackRatingStats(
        likes: (json["likes"] as num?)?.toInt() ?? 0,
        dislikes: (json["dislikes"] as num?)?.toInt() ?? 0,
        total: (json["total"] as num?)?.toInt() ?? 0,
        likeRatio: (json["likeRatio"] as num?)?.toDouble(),
      );

  bool get isRated => total > 0;
}

/// Window metadata echoed by `GET /ratings/trending` (the thresholds the
/// server applied), so the UI can explain why a track is or isn't listed.
class TrendingWindow {
  final int days;
  final int minRatings;
  final int minLikePct;
  final int minAccountAgeHours;

  const TrendingWindow({
    required this.days,
    required this.minRatings,
    required this.minLikePct,
    required this.minAccountAgeHours,
  });

  factory TrendingWindow.fromJson(Map json) => TrendingWindow(
        days: (json["days"] as num?)?.toInt() ?? 0,
        minRatings: (json["minRatings"] as num?)?.toInt() ?? 0,
        minLikePct: (json["minLikePct"] as num?)?.toInt() ?? 0,
        minAccountAgeHours: (json["minAccountAgeHours"] as num?)?.toInt() ?? 0,
      );
}

/// One entry from the trending feed (`GET /ratings/trending`).
///
/// The endpoint returns the normal metadata-plugin track DTO with an extra
/// `rating` block merged in, so [track] is passed straight to the plugin's
/// track mapper and [rating] is read separately for the badge.
class TrendingTrack {
  final Map<String, dynamic> track;
  final TrackRatingStats rating;

  const TrendingTrack({required this.track, required this.rating});

  factory TrendingTrack.fromJson(Map json) => TrendingTrack(
        track: Map<String, dynamic>.from(json),
        rating: TrackRatingStats.fromJson(
          (json["rating"] as Map?) ?? const {},
        ),
      );
}

class WalletApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  /// Set when [code] is `mfa_required`: the server accepted the first factor
  /// and handed back a short-lived challenge instead of a session token.
  /// Exchange it via [WalletApiClient.mfaVerify] to finish the login. It is
  /// NOT an error — [statusCode] is left null on purpose so this never counts
  /// against [_guardCredentialAttempts]'s strike counter.
  final String? mfaToken;

  /// True when the failure came from the network itself (connection error /
  /// timeout / TLS handshake) rather than a server response. Offline-capable
  /// callers use this to enqueue the action for replay instead of erroring.
  final bool isConnectivity;

  const WalletApiException(
    this.message, {
    this.statusCode,
    this.code,
    this.isConnectivity = false,
    this.mfaToken,
  });

  /// User-readable rendering for toasts/banners. The server sends machine
  /// codes (`too_many_checkouts`, `insufficient_balance`, …) — never show those
  /// raw. Falls back to [message] for anything unmapped (server-supplied
  /// sentences like the checkout "temporarily unavailable" messages).
  String get friendlyMessage {
    if (isConnectivity) {
      return "Couldn't reach DeeMusiq — check your connection and try again.";
    }
    switch (code) {
      case "insufficient_balance":
        return "Not enough tokens — top up your wallet first.";
      case "bad_phone":
        return "Enter a valid phone number (e.g. +27 82 123 4567).";
      case "unknown_pack":
        return "That token pack isn't available anymore — reopen the token store.";
      case "track_not_found":
        return "That track isn't available on DeeMusiq anymore.";
      case "idempotency_key_reused":
        return "That request was already sent — refresh your wallet before trying again.";
      case "request_pending":
        return "You already have a request waiting for review.";
      case "already_published":
        return "That song is already published — request a takedown instead.";
      case "published_delete_via_takedown":
        return "Published songs are removed via a takedown request.";
      case "no_change":
        return "That's already your current setting.";
      case "artist_not_approved":
        return "Your artist profile needs approval before this is available.";
      case "no_artist_profile":
        return "Create your artist profile first.";
      case "too_many_checkouts":
      case "too_many_pushes":
      case "too_many_supports":
      case "too_many_requests":
      case "too_many_attempts":
        return "Too many attempts — give it a moment and try again.";
      case "security_state_unavailable":
        return "DeeMusiq is temporarily unavailable — try again shortly.";
      case "session_revoked":
        return "You've been signed out on this device. Sign in again.";
      case "processing_restricted":
        return "Payments are paused because consent was withdrawn. Delete your account in Settings to complete erasure.";
      case "logged_out":
        return message;
      case "account_frozen":
        return "This account is frozen. Contact support@deemusiq.co.za.";
      case "account_banned":
        return "This account has been banned. Contact support@deemusiq.co.za.";
      case "under_min_age":
        return "You're below the minimum age for a DeeMusiq account.";
      case "stale_timestamp":
        return "Your device's clock is out of sync — set the date & time automatically and try again.";
      case "missing_payment_signature":
      case "bad_signature":
        return "This build can't start payments — please update the app.";
    }
    switch (statusCode) {
      case 402:
        return "Payment didn't complete — you haven't been charged.";
      case 409:
        return "That conflicts with an earlier request — refresh and try again.";
      case 429:
        return "Too many attempts — give it a moment and try again.";
      case 503:
        return "DeeMusiq is temporarily unavailable — try again shortly.";
    }
    return message;
  }

  @override
  String toString() => "WalletApiException: $message";
}

/// HTTP client for the DeeMusiq backend (see `/backend`). It is INERT until
/// [PaymentGatewayConfig.backendBaseUrl] is set: with no backend the app stays
/// fully local. Auth is device-based — a generated UUID is exchanged for a JWT.
class WalletApiClient {
  WalletApiClient._();
  static final WalletApiClient instance = WalletApiClient._();

  static const _deviceKey = "deemusiq_device_id";

  /// H2 tombstone: set by "log out on all devices" / account sign-out. While
  /// present, [_authToken] refuses to silently re-authenticate this device —
  /// only an explicit user login clears it. Lives in the platform keystore.
  static const _loggedOutKey = "deemusiq_logged_out";

  static const _validProviders = {'spotify', 'google'};

  /// HMAC secret for payment-request signing. NEVER defaults to the secure
  /// channel key (H4): an empty value means checkouts go out unsigned and the
  /// backend rejects them — fail closed beats sharing one compile-time secret
  /// across two different security domains.
  static const _paymentHmacSecret = String.fromEnvironment(
    "DEEMUSIQ_PAYMENT_HMAC_SECRET",
    defaultValue: "",
  );
  static const _walletPageSize = 50;
  static const _checkoutKeyPrefix = "deemusiq_checkout_key_";

  static String get paymentHmacSecret => _paymentHmacSecret;

  static const _uuid = Uuid();
  // In-flight FUTURES, not resolved keys: two concurrent spends with the same
  // signature must share one key generation, or they race past the
  // check-then-set in [_loadOrCreateAttemptKey] and mint two keys — defeating
  // the backend's dedupe exactly in the double-submission case it exists for.
  final Map<String, Future<String>> _checkoutKeys = {};

  bool get isConfigured => PaymentGatewayConfig.backendBaseUrl.isNotEmpty;

  /// Reused across calls — [PaymentGatewayConfig.backendBaseUrl] is a compile
  /// time const, so one client (and one interceptor chain) is enough.
  Dio? _dio;

  Dio _client() {
    final cached = _dio;
    if (cached != null) return cached;
    _assertBackendUrlScheme();
    final dio = Dio(
      BaseOptions(
        baseUrl: PaymentGatewayConfig.backendBaseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 20),
        headers: {"Content-Type": "application/json"},
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (SecureChannel.enabled &&
              !SecureChannel.isExemptPath(options.path)) {
            try {
              final deviceId = await _resolvedDeviceId();
              options.headers[SecureChannel.headerName] = "1";
              options.headers[SecureChannel.deviceHeaderName] = deviceId;
              options.headers[SecureChannel.deviceIdHeaderName] = deviceId;
              if (options.data != null) {
                final envelope = await SecureChannel.sealForDevice(
                  jsonEncode(options.data),
                  deviceId,
                );
                options.data = SecureChannel.zwEnabled
                    ? {
                        "v": 3,
                        "zw": SecureChannel.zwEncode(jsonEncode(envelope)),
                      }
                    : envelope;
              }
            } catch (error, stack) {
              AppLogger.reportError(
                  error, stack, "WalletApiClient.secureRequest");
              handler.reject(
                DioException(
                  requestOptions: options,
                  error: error,
                  message: error.toString(),
                ),
              );
              return;
            }
          }
          // The v2 payment signature binds the EXACT wire body
          // (`${ts}.${body}`), so it must be (re)computed here, AFTER the
          // secure channel rewrote the body into its sealed envelope — the
          // signature set by paymentRequestHeaders covers the plain body and
          // stays valid only when nothing transformed it.
          final payTs = options.headers["X-DM-Pay-Ts"];
          final payTsMs = payTs is String ? int.tryParse(payTs) : null;
          if (payTsMs != null &&
              _paymentHmacSecret.isNotEmpty &&
              options.data != null) {
            options.headers["X-DM-Pay-Sig"] = paymentRequestSignature(
              timestamp: payTsMs,
              body: jsonEncode(options.data),
            );
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          var data = response.data;
          // Zero-width carrier first: unwrap to the sealed envelope.
          if (response.headers.value(SecureChannel.zwHeaderName) == "1" &&
              SecureChannel.isZwEnvelope(data)) {
            try {
              final carrier =
                  SecureChannel.zwDecode((data as Map)["zw"] as String);
              if (carrier == null) {
                throw const WalletApiException(
                  "Malformed zero-width response carrier.",
                );
              }
              data = jsonDecode(carrier);
              response.data = data;
            } catch (e) {
              handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  response: response,
                  message: "Could not decode the zero-width response.",
                ),
              );
              return;
            }
          }
          final encrypted =
              response.headers.value(SecureChannel.headerName) == "1";
          if (encrypted && SecureChannel.isEnvelope(data)) {
            try {
              final plain = SecureChannel.open(
                Map<String, dynamic>.from(data as Map),
              );
              response.data = jsonDecode(plain);
            } catch (e) {
              // Corrupt/tampered ciphertext or a wrong channel key — surface a
              // clean error instead of throwing into Dio and breaking the app.
              handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  response: response,
                  message: "Could not decrypt the secure response.",
                ),
              );
              return;
            }
          }
          handler.next(response);
        },
        onError: (e, handler) {
          // Error bodies are sealed too when the secure channel is on —
          // unseal so _message() can read the server's error code.
          final resp = e.response;
          if (resp != null) {
            var data = resp.data;
            if (resp.headers.value(SecureChannel.zwHeaderName) == "1" &&
                SecureChannel.isZwEnvelope(data)) {
              try {
                final carrier =
                    SecureChannel.zwDecode((data as Map)["zw"] as String);
                if (carrier == null) {
                  throw const WalletApiException(
                    "Malformed zero-width error carrier.",
                  );
                }
                data = jsonDecode(carrier);
                resp.data = data;
              } catch (err) {
                AppLogger.log.w('Failed to decode zero-width error envelope');
              }
            }
            if (resp.headers.value(SecureChannel.headerName) == "1" &&
                SecureChannel.isEnvelope(resp.data)) {
              try {
                resp.data = jsonDecode(
                  SecureChannel.open(
                      Map<String, dynamic>.from(resp.data as Map)),
                );
              } catch (e) {
                AppLogger.log.w(
                    'Failed to decrypt secure error envelope — using generic message');
              }
            }
          }
          // A cached JWT that expired/was revoked → 401. Drop it so the next
          // call re-authenticates (Ed25519 challenge-response) instead of
          // cascading 401s forever.
          //
          // Only when the request ACTUALLY carried the session token:
          // `/auth/mfa/verify`, `/auth/totp/enable` and `/auth/step-up` answer
          // 401 for a wrong code or missing step-up proof while the session is
          // perfectly valid. Dropping the token on those discarded a live
          // session and forced a full device re-authentication.
          if (e.response?.statusCode == 401 && _requestCarriedAuth(e)) {
            _token = null;
          }
          handler.next(e);
        },
      ),
    );
    _dio = dio;
    return dio;
  }

  /// H3: the secure channel seals request/response BODIES only — the
  /// `Authorization: Bearer` header and URL query strings still travel in
  /// cleartext, so plain HTTP is only acceptable for local development.
  /// Release/profile builds fail closed on `http://` backend URLs.
  static void _assertBackendUrlScheme() {
    const url = PaymentGatewayConfig.backendBaseUrl;
    if (url.isEmpty) return;
    if (!kDebugMode && Uri.parse(url).scheme == 'http') {
      throw const WalletApiException(
        "insecure_backend_url: the DeeMusiq backend URL must use https:// "
        "in release builds (http:// is allowed in debug builds only)",
        code: "insecure_backend_url",
      );
    }
  }

  /// True after "log out on all devices" / account sign-out (H2): blocks the
  /// silent device re-auth in [_authToken] until an explicit user login
  /// ([deviceLogin], [loginEmail], [totpRecover], [authWithGoogle]) clears it.
  Future<bool> isLoggedOut() async {
    final cached = _loggedOutCache;
    if (cached != null) return cached;
    try {
      final value =
          await EncryptedKvStoreService.storage.read(key: _loggedOutKey);
      final loggedOut = value == 'true';
      _loggedOutCache = loggedOut;
      return loggedOut;
    } catch (e) {
      AppLogger.log.w('loggedOut flag read failed: ${e.toString()}');
      return false;
    }
  }

  bool? _loggedOutCache;

  /// Sets the H2 tombstone and drops the in-memory session token. Called by
  /// [logoutAll] and by account sign-outs (Google) — any path after which a
  /// silent re-login would make the user's "sign out" action meaningless.
  Future<void> markLoggedOut() async {
    _token = null;
    _loggedOutCache = true;
    try {
      await EncryptedKvStoreService.storage
          .write(key: _loggedOutKey, value: 'true');
    } catch (e) {
      AppLogger.log.w('loggedOut flag write failed: ${e.toString()}');
    }
  }

  Future<void> _clearLoggedOut() async {
    _loggedOutCache = false;
    try {
      await EncryptedKvStoreService.storage.delete(key: _loggedOutKey);
    } catch (e) {
      AppLogger.log.w('loggedOut flag clear failed: ${e.toString()}');
    }
  }

  /// Test seam: production clears happen only inside the explicit login
  /// flows ([deviceLogin], [loginEmail], [totpRecover], [authWithGoogle]).
  @visibleForTesting
  Future<void> debugClearLoggedOutTombstone() => _clearLoggedOut();

  /// Signs in as this device (Ed25519 challenge–response) and returns the
  /// backend JWT. Used as the Google-less sign-in fallback — an explicit user
  /// action, so it bypasses (and on success clears) the logged-out tombstone.
  Future<String> deviceLogin() async {
    final token = await _authToken(explicitLogin: true);
    await _clearLoggedOut();
    return token;
  }

  bool hasToken() => _token != null;

  /// Cheap reachability probe. Returns true only when a backend is configured
  /// AND answers `/health` — the single gate for online-only features
  /// (downloads, payments, token balance, account linking).
  Future<bool> ping() async {
    if (!isConfigured) return false;
    try {
      final res = await _client().get(
        "/health",
        options: Options(
          sendTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 6),
        ),
      );
      return res.statusCode == 200;
    } catch (e, stack) {
      // Unreachable is a normal state (offline / no backend configured yet),
      // but the cause still gets logged and reported — never swallowed.
      AppLogger.log.w('Backend ping failed: ${e.toString()}');
      AppLogger.reportError(e, stack, 'WalletApiClient.ping');
      return false;
    }
  }

  String? _deviceIdCache;
  Future<void>? _deviceIdHydration;

  String _deviceId() {
    final cached = _deviceIdCache;
    if (cached != null && cached.isNotEmpty) return cached;

    _deviceIdHydration ??= _hydrateDeviceIdFromSecureStorage();
    final prefs = KVStoreService.sharedPreferences;
    final plain = prefs.getString(_deviceKey);
    if (plain != null && plain.isNotEmpty) {
      _deviceIdCache = plain;
      unawaited(_migrateDeviceIdToSecureStorage(plain));
      return plain;
    }

    final id = _uuid.v4();
    _deviceIdCache = id;
    try {
      prefs.setString(_deviceKey, id);
    } catch (e) {
      // Plain-storage fallback failed — only the secure-store write below
      // keeps the id; if that also fails the device id changes next launch
      // and the backend device-auth binding breaks.
      AppLogger.log.w('deviceId plain store write failed: ${e.toString()}');
    }
    unawaited(_persistDeviceId(id));
    return id;
  }

  Future<String> _resolvedDeviceId() async {
    _deviceIdHydration ??= _hydrateDeviceIdFromSecureStorage();
    await _deviceIdHydration;
    return _deviceId();
  }

  Future<void> _hydrateDeviceIdFromSecureStorage() async {
    try {
      final secure =
          await EncryptedKvStoreService.storage.read(key: _deviceKey);
      if (secure != null && secure.isNotEmpty) {
        _deviceIdCache = secure;
        try {
          await KVStoreService.sharedPreferences.remove(_deviceKey);
        } catch (e) {
          // Stale plain copy survives — harmless for the binding, but the
          // migration to secure storage will retry every launch until it is
          // removed; logged for diagnosis.
          AppLogger.log.w('deviceId plain store cleanup failed: ${e.toString()}');
        }
      }
    } catch (e) {
      AppLogger.log.w('deviceId keystore hydrate skipped: ${e.toString()}');
    }
  }

  Future<void> _persistDeviceId(String id) async {
    try {
      final existing =
          await EncryptedKvStoreService.storage.read(key: _deviceKey);
      if (existing != null && existing.isNotEmpty) {
        _deviceIdCache = existing;
      } else if (_deviceIdCache == null || _deviceIdCache == id) {
        await EncryptedKvStoreService.storage.write(key: _deviceKey, value: id);
      }
      try {
        await KVStoreService.sharedPreferences.remove(_deviceKey);
      } catch (e) {
        // Stale plain copy survives alongside the secure one — both hold the
        // same id so the device-auth binding is unaffected, but cleanup is
        // retried on every launch; logged for diagnosis.
        AppLogger.log.w('deviceId plain store cleanup failed: ${e.toString()}');
      }
    } catch (e) {
      AppLogger.log.w('deviceId secure store write failed: ${e.toString()}');
    }
  }

  Future<void> _migrateDeviceIdToSecureStorage(String id) async {
    try {
      final existing =
          await EncryptedKvStoreService.storage.read(key: _deviceKey);
      if (existing == null || existing.isEmpty) {
        await EncryptedKvStoreService.storage.write(key: _deviceKey, value: id);
      } else {
        _deviceIdCache = existing;
      }
      await KVStoreService.sharedPreferences.remove(_deviceKey);
    } catch (e) {
      AppLogger.log.w('deviceId migration skipped: ${e.toString()}');
    }
  }

  /// The resolved device id, awaiting secure-storage hydration (L4). All
  /// callers must use this — the old synchronous getter could mint a phantom
  /// UUID into plain prefs when hit before hydration completed, briefly
  /// splitting the device identity seen by the backend.
  Future<String> resolvedDeviceId() => _resolvedDeviceId();

  String? _token;

  /// In-flight device-login future, so concurrent `_authToken` callers share
  /// one round trip instead of each minting their own JWT.
  Future<String>? _inFlightAuth;

  /// The cached backend JWT, or null when this device hasn't authenticated
  /// yet. This NEVER triggers a login — it exists for fire-and-forget calls
  /// (e.g. the play-count scrobble) that attach auth when it happens to be in
  /// memory and stay anonymous otherwise.
  String? get sessionToken => _token;

  /// Device login via Ed25519 challenge–response. The backend issues a signed
  /// challenge; we sign it with the device's secure-enclave key (never sent) and
  /// present the signature + public key. No secret ever travels the wire.
  ///
  /// H2: after a "log out on all devices" / sign-out tombstone this refuses to
  /// silently re-authenticate — explicit login flows pass [explicitLogin].
  ///
  /// Single-flight: the in-flight future is cached in [_inFlightAuth] so
  /// concurrent callers share ONE challenge/response round trip. Without it
  /// this was a check-then-await-act race — every caller observing
  /// `_token == null` issued its own `/auth/device/challenge` +
  /// `/auth/device/login`, so a burst of parallel calls after a 401 (queue
  /// replay + wallet sync + scrobble) multiplied into a login storm and a
  /// backend rate-limit trip. Same pattern as `_managedAttemptKey`, which
  /// already guards the checkout path.
  Future<String> _authToken({bool explicitLogin = false}) async {
    final cached = _token;
    if (cached != null) return cached;
    final pending = _inFlightAuth;
    if (pending != null) return pending;
    final future = _performDeviceLogin(explicitLogin: explicitLogin);
    _inFlightAuth = future;
    try {
      return await future;
    } finally {
      // Clear only if still ours: a later login may have replaced it.
      if (identical(_inFlightAuth, future)) _inFlightAuth = null;
    }
  }

  Future<String> _performDeviceLogin({required bool explicitLogin}) async {
    if (!explicitLogin && await isLoggedOut()) {
      throw const WalletApiException(
        "This device was signed out. Sign in again to reconnect.",
        code: "logged_out",
      );
    }
    try {
      final deviceId = await _resolvedDeviceId();
      final dio = _client();
      final challengeRes = await dio.post(
        "/auth/device/challenge",
        data: {"deviceId": deviceId},
      );
      final challenge = (challengeRes.data as Map)["challenge"] as String;

      // Client attestation: when this build can report its cert + APK hashes,
      // sign them INTO the challenge so the backend can verify the binding and
      // refuse repackaged builds. Otherwise fall back to signing the bare
      // challenge (the backend treats that as "no attestation").
      final att = await IntegrityService.instance.attestation();
      final hasAttestation = att.cert != null || att.apk != null;
      final message = hasAttestation
          ? "$challenge|${att.cert ?? ''}|${att.apk ?? ''}"
          : challenge;

      final loginRes = await dio.post(
        "/auth/device/login",
        data: {
          "deviceId": deviceId,
          "publicKey": await DeviceIdentity.instance.publicKeyBase64(),
          "challenge": challenge,
          "signature": await DeviceIdentity.instance.sign(message),
          if (att.cert != null) "certSha256": att.cert,
          if (att.apk != null) "apkSha256": att.apk,
        },
      );
      final token = _sessionTokenFrom(loginRes.data as Map);
      _token = token;
      return token;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Attach an email + password to this wallet (works on any device after).
  Future<void> registerEmail({
    required String email,
    required String password,
    required bool acceptTerms,
  }) async {
    if (!acceptTerms) {
      throw const WalletApiException("terms_acceptance_required");
    }
    await _guardCredentialAttempts(() async {
      try {
        await _client().post(
          "/auth/register",
          data: {
            "email": email,
            "password": password,
            "acceptTerms": true,
          },
          options: await _authed(),
        );
      } on DioException catch (e) {
        throw _walletApiException(e);
      }
    });
  }

  /// Log in with email + password (e.g. on a new device); caches the token.
  Future<void> loginEmail({
    required String email,
    required String password,
  }) async {
    await _guardCredentialAttempts(() async {
      try {
        final res = await _client().post(
          "/auth/login",
          data: {"email": email, "password": password},
        );
        _token = _sessionTokenFrom(res.data as Map);
        await _clearLoggedOut();
      } on DioException catch (e) {
        throw _walletApiException(e);
      }
    });
  }

  // ── Client-side brute-force guard (credential endpoints) ─────────────────
  // In-memory only — a UX/anti-hammer guard, not a security boundary (the
  // backend enforces the real rate limits). After [_authLockoutThreshold]
  // consecutive credential rejections the next attempt is blocked for
  // [_authLockoutDuration].
  int _authFailures = 0;
  DateTime? _authLockedUntil;

  static const _authLockoutThreshold = 3;
  static const _authLockoutDuration = Duration(seconds: 10);

  /// Read the session token out of a login response, or raise the second
  /// factor challenge the server returned instead.
  ///
  /// Every auth entrypoint (email, device, Google) funnels through this so a
  /// 2FA-enrolled account can never be signed in by its first factor alone —
  /// the server answers `200 {mfa_required, mfaToken}` rather than a token.
  String _sessionTokenFrom(Map<dynamic, dynamic> data) {
    if (data["mfa_required"] == true) {
      final challenge = data["mfaToken"];
      if (challenge is String && challenge.isNotEmpty) {
        throw WalletApiException(
          "Two-factor authentication required.",
          code: "mfa_required",
          mfaToken: challenge,
        );
      }
    }
    final token = data["token"];
    if (token is! String || token.isEmpty) {
      throw const WalletApiException("server_error");
    }
    return token;
  }

  /// Finish a challenge started by a login attempt: exchanges the short-lived
  /// MFA challenge for a real session token and caches it.
  Future<void> mfaVerify({
    required String mfaToken,
    required String code,
  }) async {
    await _guardCredentialAttempts(() async {
      try {
        final res = await _client().post(
          "/auth/mfa/verify",
          data: {"mfaToken": mfaToken, "code": code},
        );
        _token = _sessionTokenFrom(res.data as Map);
        await _clearLoggedOut();
      } on DioException catch (e) {
        throw _walletApiException(e);
      }
    });
  }

  /// True when the failed request actually carried the session token.
  ///
  /// A 401 from an UNAUTHENTICATED call (e.g. a wrong MFA code, or a
  /// step-up that demands a password) says nothing about the cached JWT's
  /// validity, so it must not invalidate a live session.
  bool _requestCarriedAuth(DioException e) {
    final headers = e.requestOptions.headers;
    final auth = headers['Authorization'] ?? headers['authorization'];
    if (auth is String && auth.trim().isNotEmpty) return true;
    // Dio lowercases header names, but a caller may have set it directly.
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == 'authorization') {
        final v = entry.value;
        if (v is String && v.trim().isNotEmpty) return true;
      }
    }
    return false;
  }

  Future<T> _guardCredentialAttempts<T>(Future<T> Function() fn) async {
    final lockedUntil = _authLockedUntil;
    if (lockedUntil != null) {
      final remaining = lockedUntil.difference(DateTime.now());
      if (remaining > Duration.zero) {
        throw WalletApiException(
          "Too many failed attempts — try again in ${remaining.inSeconds + 1}s.",
        );
      }
    }
    try {
      final result = await fn();
      _authFailures = 0;
      _authLockedUntil = null;
      return result;
    } on WalletApiException catch (e) {
      // Only credential rejections (4xx) count — a flaky network must not
      // lock the user out.
      final status = e.statusCode;
      if (status != null && status >= 400 && status < 500) {
        _authFailures++;
        if (_authFailures >= _authLockoutThreshold) {
          _authFailures = 0;
          _authLockedUntil = DateTime.now().add(_authLockoutDuration);
        }
      }
      rethrow;
    }
  }

  /// Begin TOTP enrollment. Returns `{secret, otpauthUri}` to render a QR.
  ///
  /// The backend requires step-up proof: [password] when an email+password is
  /// attached, [code] (from the CURRENT authenticator) when re-enrolling while
  /// 2FA is active, and for a DEVICE-ONLY account a device-key signature over
  /// a fresh challenge (obtained automatically here). Missing proof answers
  /// 401 with `step_up_password_required` / `step_up_code_required` /
  /// `step_up_device_required` so the UI can prompt for exactly that.
  ///
  /// The device step-up is fetched here rather than pushed onto callers
  /// because it needs the Ed25519 key, which lives in the secure enclave: the
  /// honest owner always has it, so this cannot lock them out.
  Future<Map<String, dynamic>> totpSetup(
      {String? password, String? code}) async {
    final hasPassword = password != null && password.isNotEmpty;
    try {
      // Device-only accounts have no password to send, so preemptively fetch
      // the device-key step-up. A 401 here (an account WITH a password takes
      // the password path) is non-fatal — the body below simply omits it.
      Map<String, String> deviceStepUp = const {};
      if (!hasPassword) {
        try {
          final chal = await _client().post(
            "/auth/step-up/challenge",
            options: await _authed(),
          );
          final challenge =
              (chal.data as Map)["challenge"] as String? ?? "";
          if (challenge.isNotEmpty) {
            deviceStepUp = {
              "deviceChallenge": challenge,
              "deviceSignature": await DeviceIdentity.instance.sign(challenge),
              "devicePublicKey": await DeviceIdentity.instance.publicKeyBase64(),
            };
          }
        } on DioException catch (e) {
          AppLogger.log.w(
              'Device step-up challenge unavailable; server will decide: ${e.toString()}');
        }
      }
      final res = await _client().post(
        "/auth/totp/setup",
        data: {
          if (hasPassword) "password": password,
          if (code != null && code.isNotEmpty) "code": code,
          ...deviceStepUp,
        },
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Confirm TOTP enrollment with a code from the authenticator app.
  Future<void> totpEnable(String code) async {
    try {
      await _client().post(
        "/auth/totp/enable",
        data: {"code": code},
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Recover wallet access on a new device via email + password + a TOTP code.
  ///
  /// The password is REQUIRED, not optional: the server treats a TOTP code on
  /// its own as a single factor, so recovery demands both. Sending the code
  /// alone would authenticate the holder of a phished/shoulder-surfed code.
  Future<void> totpRecover(
      {required String email,
      required String password,
      required String code}) async {
    await _guardCredentialAttempts(() async {
      try {
        final res = await _client().post(
          "/auth/totp/recover",
          data: {"email": email, "password": password, "code": code},
        );
        _token = _sessionTokenFrom(res.data as Map);
        await _clearLoggedOut();
      } on DioException catch (e) {
        throw _walletApiException(e);
      }
    });
  }

  /// Send (or re-send) the email-verification link to the account's email.
  Future<void> requestVerify() async {
    try {
      await _client().post("/auth/request-verify", options: await _authed());
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Start a password reset — the backend emails a reset link. Always succeeds
  /// (never reveals whether the email exists).
  Future<void> forgotPassword(String email) async {
    try {
      await _client().post("/auth/forgot-password", data: {"email": email});
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Revoke every session for this account (server-side), drop the local
  /// token, and set the logged-out tombstone (H2): without it the very next
  /// authed call would silently mint a fresh JWT for the same wallet via
  /// device login, making "log out on all devices" a lie on this device.
  Future<void> logoutAll() async {
    try {
      await _client().post("/auth/logout-all", options: await _authed());
      await markLoggedOut();
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Permanently delete the account + all its data (POPIA/GDPR). The
  /// server anonymizes the row (status='deleted', email/password/keys
  /// cleared) and bumps tokenVersion so the current JWT is invalid.
  Future<void> deleteAccount() async {
    try {
      await _client().delete("/me/delete-account", options: await _authed());
      _token = null;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Authoritative list of linked accounts from the backend.
  Future<List<dynamic>> fetchLinkedAccounts() async {
    try {
      final res =
          await _client().get("/link/accounts", options: await _authed());
      return (res.data as Map)["accounts"] as List<dynamic>;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Disconnects a linked provider on the backend
  /// (`DELETE /link/accounts/:provider`).
  Future<void> unlinkAccount(String provider) async {
    if (!_validProviders.contains(provider)) {
      throw const WalletApiException('Invalid provider');
    }
    final encoded = Uri.encodeComponent(provider);
    try {
      await _client().delete(
        "/link/accounts/$encoded",
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  Future<Options> _authed() async =>
      Options(headers: {"Authorization": "Bearer ${await _authToken()}"});

  String _fileName(String path) => path.split(RegExp(r'[/\\]')).last;

  Map<String, dynamic> _uploadResult(Response<dynamic> response) {
    if (response.data is! Map) {
      throw const WalletApiException("creator_upload_invalid_response");
    }
    final data = Map<String, dynamic>.from(response.data as Map);
    if (data["mediaUploadId"] is! String ||
        (data["mediaUploadId"] as String).isEmpty) {
      throw const WalletApiException("creator_upload_incomplete");
    }
    return data;
  }

  String _message(DioException e) {
    final data = e.response?.data;
    if (data is Map && data["message"] is String) return data["message"];
    if (data is Map && data["error"] is String) return data["error"];
    if (e.error is SecureChannelException) {
      return (e.error as SecureChannelException).message;
    }
    return e.message ?? "Network error";
  }

  String? _errorCode(DioException e) {
    final data = e.response?.data;
    if (data is Map && data["error"] is String) return data["error"] as String;
    if (e.error is SecureChannelException) {
      return (e.error as SecureChannelException).message;
    }
    return null;
  }

  WalletApiException _walletApiException(DioException e) {
    return WalletApiException(
      _message(e),
      statusCode: e.response?.statusCode,
      code: _errorCode(e),
      isConnectivity: _isConnectivityError(e),
    );
  }

  /// Network-level failures (no response received): connection refused/reset,
  /// DNS failure, timeouts, TLS handshake problems. A 4xx/5xx answer means the
  /// backend WAS reached, so those are deliberately not connectivity errors.
  static bool _isConnectivityError(DioException e) {
    if (e.response != null) return false;
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      case DioExceptionType.unknown:
        final error = e.error;
        return error is SocketException ||
            error is HandshakeException ||
            error is TimeoutException;
      case DioExceptionType.badResponse:
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
        return false;
    }
  }

  /// v2 payment-request signature: HMAC-SHA256 over `"$timestamp.$body"`,
  /// where [timestamp] is unix MILLISECONDS (the `X-DM-Pay-Ts` value) and
  /// [body] is the exact JSON request body being sent. Binding the timestamp
  /// INTO the digest makes a captured signature worthless outside the
  /// backend's freshness window (5 min), closing the replay gap the v1
  /// field-joined scheme had.
  static String paymentRequestSignature({
    required int timestamp,
    required String body,
    String? secret,
  }) {
    final key = secret ?? _paymentHmacSecret;
    if (key.isEmpty) {
      throw const WalletApiException("payment_hmac_secret_missing");
    }
    return crypto.Hmac(
      crypto.sha256,
      utf8.encode(key),
    ).convert(utf8.encode("$timestamp.$body")).toString();
  }

  static Map<String, String> paymentRequestHeaders({
    required int timestamp,
    required String body,
    required String idempotencyKey,
    String? secret,
  }) {
    if (!RegExp(r'^[A-Za-z0-9_-]{8,64}$').hasMatch(idempotencyKey)) {
      throw const WalletApiException("invalid_idempotency_key");
    }
    final headers = <String, String>{"Idempotency-Key": idempotencyKey};
    final key = secret ?? _paymentHmacSecret;
    if (key.isNotEmpty) {
      headers.addAll({
        "X-DM-Pay-Ts": "$timestamp",
        "X-DM-Pay-Sig": paymentRequestSignature(
          timestamp: timestamp,
          body: body,
          secret: key,
        ),
      });
    }
    return headers;
  }

  String _checkoutSignature({
    required String packId,
    required String method,
    required String region,
    String? payerPhone,
  }) {
    return "$packId|$method|${region.toLowerCase()}|${payerPhone ?? ""}";
  }

  String _checkoutStorageKey(String signature) {
    final digest = crypto.sha256.convert(utf8.encode(signature)).toString();
    return "$_checkoutKeyPrefix${digest.substring(0, 32)}";
  }

  Future<String> _checkoutAttemptKey({
    required String packId,
    required String method,
    required String region,
    String? payerPhone,
  }) {
    return _managedAttemptKey(
      _checkoutSignature(
        packId: packId,
        method: method,
        region: region,
        payerPhone: payerPhone,
      ),
    );
  }

  /// One idempotency key per spend signature, shared by concurrent callers
  /// and persisted so a retry after an ambiguous failure (timeout where the
  /// server may have committed) replays instead of double-debiting. Callers
  /// clear the key via [_clearCheckoutAttempt] once the outcome is known.
  Future<String> _managedAttemptKey(String signature) {
    final inFlight = _checkoutKeys[signature];
    if (inFlight != null) return inFlight;
    final future = _loadOrCreateAttemptKey(signature);
    _checkoutKeys[signature] = future;
    unawaited(
      future.catchError((Object _) {
        // A failed generation must not poison the cache — the next attempt
        // retries the load/create instead of rethrowing a stale error.
        if (identical(_checkoutKeys[signature], future)) {
          _checkoutKeys.remove(signature);
        }
        return "";
      }),
    );
    return future;
  }

  Future<String> _loadOrCreateAttemptKey(String signature) async {
    final storageKey = _checkoutStorageKey(signature);
    try {
      final stored = KVStoreService.sharedPreferences.getString(storageKey);
      if (stored != null && RegExp(r'^[A-Za-z0-9_-]{8,64}$').hasMatch(stored)) {
        return stored;
      }
      final generated = _uuid.v4();
      final saved = await KVStoreService.sharedPreferences.setString(
        storageKey,
        generated,
      );
      if (!saved) {
        throw const WalletApiException("checkout_idempotency_persist_failed");
      }
      return generated;
    } catch (error) {
      if (error is WalletApiException) rethrow;
      throw WalletApiException(
        "checkout_idempotency_persist_failed: ${error.toString()}",
      );
    }
  }

  Future<void> _clearCheckoutAttempt(String signature) async {
    _checkoutKeys.remove(signature);
    try {
      await KVStoreService.sharedPreferences.remove(
        _checkoutStorageKey(signature),
      );
    } catch (e) {
      AppLogger.log.w('checkout idempotency cleanup failed: ${e.toString()}');
    }
  }

  /// Creates a payment intent on the backend. Returns the raw response, e.g.
  /// `{status: "redirect", payUrl}` (cards) or `{status: "crypto", deposit}`.
  Future<Map<String, dynamic>> createCheckout({
    required String packId,
    required String method,
    required String region,
    String? payerPhone,
    String? idempotencyKey,
  }) async {
    final attemptSignature = _checkoutSignature(
      packId: packId,
      method: method,
      region: region,
      payerPhone: payerPhone,
    );
    final managedKey = idempotencyKey == null;
    final key = idempotencyKey ??
        await _checkoutAttemptKey(
          packId: packId,
          method: method,
          region: region,
          payerPhone: payerPhone,
        );
    try {
      final authed = await _authed();
      // v2 payment signature: the timestamp is unix MILLISECONDS and the
      // HMAC binds `${ts}.${body}` — the exact JSON body below — so a
      // captured header set can't be replayed outside the backend's
      // freshness window or against a different body.
      final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
      final body = <String, dynamic>{
        "packId": packId,
        "method": method,
        "region": region,
        if (payerPhone != null) "payerPhone": payerPhone,
      };
      final headers = <String, dynamic>{
        ...?authed.headers,
        ...paymentRequestHeaders(
          timestamp: timestamp,
          body: jsonEncode(body),
          idempotencyKey: key,
        ),
      };
      final res = await _client().post(
        "/payments/checkout",
        data: body,
        options: Options(
          headers: headers,
          // Business refusals (region_unavailable / provider_not_configured /
          // crypto_wallet_not_configured) arrive as 409/503 with a JSON body
          // the caller switches on to grey out the rail — not transport
          // errors, so let the body through instead of throwing.
          validateStatus: (status) =>
              status != null &&
              ((status >= 200 && status < 400) ||
                  status == 409 ||
                  status == 503),
        ),
      );
      if (res.data is! Map) {
        throw const WalletApiException("checkout_invalid_response");
      }
      final result = Map<String, dynamic>.from(res.data as Map);
      final httpStatus = res.statusCode ?? 200;
      if (httpStatus >= 400 && result["status"] is! String) {
        // Error-shaped refusal (e.g. idempotency_key_reused), not a checkout
        // business response — route it through the friendly-code mapping
        // exactly as the old throwing path did.
        if (managedKey && httpStatus < 500) {
          await _clearCheckoutAttempt(attemptSignature);
        }
        final bodyMessage = result["message"] ?? result["error"];
        final bodyCode = result["error"] ?? result["code"];
        throw WalletApiException(
          bodyMessage is String ? bodyMessage : "checkout_failed",
          statusCode: httpStatus,
          code: bodyCode is String ? bodyCode : null,
        );
      }
      final intentId = result["intentId"];
      if (result["recoveryUrl"] == null &&
          result["recoveryPath"] == null &&
          result["statusUrl"] == null &&
          intentId is String &&
          intentId.isNotEmpty) {
        result["recoveryUrl"] = "/payments/${Uri.encodeComponent(intentId)}";
      }
      final hasAction = result["payUrl"] != null || result["deposit"] != null;
      if (managedKey &&
          (const {"completed", "failed", "expired", "refunded"}
                  .contains(result["status"]) ||
              hasAction)) {
        await _clearCheckoutAttempt(attemptSignature);
      }
      if (result["status"] == "pending" &&
          result["payUrl"] == null &&
          result["deposit"] == null &&
          result["recoveryUrl"] == null &&
          result["recoveryPath"] == null &&
          result["statusUrl"] == null &&
          (intentId is! String || intentId.isEmpty)) {
        throw const WalletApiException("checkout_pending_without_action");
      }
      return result;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (managedKey &&
          status != null &&
          status >= 400 &&
          status < 500 &&
          status != 408 &&
          status != 429) {
        await _clearCheckoutAttempt(attemptSignature);
      }
      throw _walletApiException(e);
    }
  }

  Future<Map<String, dynamic>> fetchPaymentStatus(String intentId) async {
    if (intentId.isEmpty) {
      throw const WalletApiException("payment_intent_required");
    }
    try {
      final res = await _client().get(
        "/payments/${Uri.encodeComponent(intentId)}",
        options: await _authed(),
      );
      if (res.data is! Map) {
        throw const WalletApiException("payment_status_invalid_response");
      }
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  List<Map<String, dynamic>> _walletTransactions(Map<String, dynamic> data) {
    Object? raw = data["transactions"];
    Map<String, dynamic>? page;
    if (raw is Map) {
      page = Map<String, dynamic>.from(raw);
      raw = page["items"] ?? page["transactions"];
    }
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  String? _walletCursor(Map<String, dynamic> data) {
    final sources = <Map<String, dynamic>>[data];
    final pagination = data["pagination"];
    if (pagination is Map) {
      sources.add(Map<String, dynamic>.from(pagination));
    }
    final rawTransactions = data["transactions"];
    if (rawTransactions is Map) {
      final page = Map<String, dynamic>.from(rawTransactions);
      sources.add(page);
      final nested = page["pagination"];
      if (nested is Map) sources.add(Map<String, dynamic>.from(nested));
    }
    for (final source in sources) {
      for (final key in const [
        "nextCursor",
        "transactionCursor",
        "transactionsNextCursor",
      ]) {
        final value = source[key];
        if (value is String && value.isNotEmpty) return value;
        if (value is num) return value.toString();
      }
    }
    return null;
  }

  bool? _walletHasMore(Map<String, dynamic> data) {
    final sources = <Map<String, dynamic>>[data];
    final pagination = data["pagination"];
    if (pagination is Map) {
      sources.add(Map<String, dynamic>.from(pagination));
    }
    final rawTransactions = data["transactions"];
    if (rawTransactions is Map) {
      final page = Map<String, dynamic>.from(rawTransactions);
      sources.add(page);
      final nested = page["pagination"];
      if (nested is Map) sources.add(Map<String, dynamic>.from(nested));
    }
    for (final source in sources) {
      final value = source["hasMore"];
      if (value is bool) return value;
      if (value is num) return value != 0;
    }
    return null;
  }

  bool? _walletHistoryComplete(Map<String, dynamic> data) {
    final sources = <Map<String, dynamic>>[data];
    final pagination = data["pagination"];
    if (pagination is Map) {
      sources.add(Map<String, dynamic>.from(pagination));
    }
    final rawTransactions = data["transactions"];
    if (rawTransactions is Map) {
      final page = Map<String, dynamic>.from(rawTransactions);
      sources.add(page);
      final nested = page["pagination"];
      if (nested is Map) sources.add(Map<String, dynamic>.from(nested));
    }
    for (final source in sources) {
      final value = source["historyComplete"];
      if (value is bool) return value;
    }
    return null;
  }

  int? _walletTotal(Map<String, dynamic> data) {
    for (final key in const [
      "transactionCount",
      "totalTransactions",
      "total"
    ]) {
      final value = data[key];
      if (value is num) return value.toInt();
    }
    final raw = data["transactions"];
    if (raw is Map) {
      final value = raw["total"] ?? raw["count"];
      if (value is num) return value.toInt();
    }
    return null;
  }

  Future<Map<String, dynamic>> _walletPage({
    String? cursor,
  }) async {
    final res = await _client().get(
      "/wallet",
      queryParameters: {
        "limit": _walletPageSize,
        if (cursor != null) "cursor": cursor,
      },
      options: await _authed(),
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// Authoritative wallet state from the server (balance, transactions,
  /// supported creators).
  Future<Map<String, dynamic>> fetchWallet() async {
    Map<String, dynamic>? firstPage;
    final transactions = <Map<String, dynamic>>[];
    final ids = <String>{};
    final cursors = <String>{};
    String? cursor;
    int? total;

    Map<String, dynamic> incomplete(String error) => {
          ...firstPage!,
          "transactions": transactions,
          "nextCursor": cursor,
          "historyComplete": false,
          "historyError": error,
        };

    try {
      var page = await _walletPage();
      firstPage = page;
      while (true) {
        final pageTransactions = _walletTransactions(page);
        final before = transactions.length;
        for (final transaction in pageTransactions) {
          final id = transaction["id"];
          if (id is String && id.isNotEmpty) {
            if (ids.add(id)) transactions.add(transaction);
          } else {
            transactions.add(transaction);
          }
        }

        final pageComplete = _walletHistoryComplete(page);
        final hasMore = _walletHasMore(page);
        cursor = _walletCursor(page);
        total ??= _walletTotal(page);
        final reachedTotal = total != null && transactions.length >= total;
        final shortLegacyPage = pageComplete == null &&
            hasMore == null &&
            cursor == null &&
            total == null &&
            pageTransactions.length < _walletPageSize;

        if (pageComplete == true || reachedTotal || shortLegacyPage) {
          return {
            ...firstPage,
            "transactions": transactions,
            "nextCursor": null,
            "historyComplete": true,
            "historyError": null,
          };
        }
        if (cursor == null) {
          return incomplete(
            hasMore == true
                ? "wallet_pagination_cursor_missing"
                : "wallet_history_pagination_unsupported",
          );
        }
        if (!cursors.add(cursor) || transactions.length == before) {
          return incomplete("wallet_pagination_stalled");
        }
        try {
          page = await _walletPage(cursor: cursor);
        } on DioException catch (e) {
          return incomplete(_walletApiException(e).message);
        }
      }
    } on DioException catch (e) {
      if (firstPage == null) throw _walletApiException(e);
      return incomplete(_walletApiException(e).message);
    } on WalletApiException catch (e) {
      if (firstPage == null) rethrow;
      return incomplete(e.message);
    }
  }

  Future<int> pushSong({
    required String songId,
    required String title,
    required String artist,
    String? artistId,
    String? imageUrl,
    required int tokens,
    String? idempotencyKey,
  }) async {
    // L2 idempotency (same managed-key contract as createCheckout): when the
    // caller supplies no key, one is managed per spend signature so a retry
    // after an ambiguous failure (a timeout where the server had already
    // committed the debit) replays the original result instead of
    // double-charging. The key clears on success or a definitive 4xx; only
    // connectivity/5xx outcomes keep it for the retry.
    final managedSignature =
        idempotencyKey == null ? "push|$songId|$tokens" : null;
    final key = idempotencyKey ?? await _managedAttemptKey(managedSignature!);
    try {
      final authed = await _authed();
      final res = await _client().post(
        "/wallet/push",
        data: {
          "songId": songId,
          "title": title,
          "artist": artist,
          // Omit absent optionals entirely: the backend's zod schema accepts
          // missing fields but rejects explicit JSON nulls with a 400.
          if (artistId != null) "artistId": artistId,
          if (imageUrl != null) "imageUrl": imageUrl,
          "tokens": tokens,
        },
        options: Options(headers: {
          ...?authed.headers,
          "Idempotency-Key": key,
        }),
      );
      final balance = ((res.data as Map)["balance"] as num).toInt();
      if (managedSignature != null) {
        await _clearCheckoutAttempt(managedSignature);
      }
      return balance;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (managedSignature != null &&
          status != null &&
          status >= 400 &&
          status < 500 &&
          status != 408 &&
          status != 429) {
        await _clearCheckoutAttempt(managedSignature);
      }
      throw _walletApiException(e);
    }
  }

  Future<int> supportCreator({
    required String creatorId,
    required String name,
    required int tokens,
    String? idempotencyKey,
  }) async {
    // Same managed-key idempotency contract as pushSong.
    final managedSignature =
        idempotencyKey == null ? "support|$creatorId|$tokens" : null;
    final key = idempotencyKey ?? await _managedAttemptKey(managedSignature!);
    try {
      final authed = await _authed();
      final res = await _client().post(
        "/wallet/support",
        data: {"creatorId": creatorId, "name": name, "tokens": tokens},
        options: Options(headers: {
          ...?authed.headers,
          "Idempotency-Key": key,
        }),
      );
      final balance = ((res.data as Map)["balance"] as num).toInt();
      if (managedSignature != null) {
        await _clearCheckoutAttempt(managedSignature);
      }
      return balance;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (managedSignature != null &&
          status != null &&
          status >= 400 &&
          status < 500 &&
          status != 408 &&
          status != 429) {
        await _clearCheckoutAttempt(managedSignature);
      }
      throw _walletApiException(e);
    }
  }

  // ── Artist boosts & the yearly leaderboard ────────────────────────────────

  /// Boost an artist with tokens. Returns the new wallet balance.
  ///
  /// Pass a fresh [idempotencyKey] per user-confirmed boost (the backend
  /// dedupes on it): a retry after a flaky network then replays the original
  /// result instead of double-debiting. Each NEW boost needs a NEW key.
  Future<int> boostArtist({
    required String artistId,
    required int tokens,
    String? idempotencyKey,
  }) async {
    try {
      final encoded = Uri.encodeComponent(artistId);
      final authed = await _authed();
      final res = await _client().post(
        "/artists/$encoded/boost",
        data: {"tokens": tokens},
        options: Options(headers: {
          ...?authed.headers,
          if (idempotencyKey != null) "Idempotency-Key": idempotencyKey,
        }),
      );
      return ((res.data as Map)["balance"] as num).toInt();
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// The artist leaderboard for a calendar [year] (defaults to the current year).
  /// Pass [region] (ISO alpha-2) for a regional board; the response echoes it
  /// back as `"region"`. Returns `{year, isCurrentYear, region, entries:[...]}`.
  Future<Map<String, dynamic>> fetchArtistLeaderboard({
    int? year,
    String? region,
  }) async {
    try {
      final res = await _client().get(
        "/leaderboard/artists",
        queryParameters: {
          if (year != null) "year": year,
          if (region != null) "region": region,
        },
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Past years' "Best Artist" winners. Returns the `winners` list.
  Future<List<dynamic>> fetchHallOfFame() async {
    try {
      final res = await _client().get("/leaderboard/artists/hall-of-fame");
      return (res.data as Map)["winners"] as List<dynamic>;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Creator mode ──────────────────────────────────────────────────────────

  /// Create/update the caller's artist profile (requires a linked Google account).
  Future<Map<String, dynamic>> createArtist({
    required String name,
    String? bio,
    String? imageUrl,
  }) async {
    try {
      final res = await _client().post(
        "/creator/artist",
        data: {
          "name": name,
          if (bio != null) "bio": bio,
          if (imageUrl != null) "imageUrl": imageUrl,
        },
        options: await _authed(),
      );
      return Map<String, dynamic>.from((res.data as Map)["artist"] as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// The caller's artist profile + stats, or `{artist: null}` if not a creator yet.
  Future<Map<String, dynamic>> fetchMyArtist() async {
    try {
      final res =
          await _client().get("/creator/artist", options: await _authed());
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// The caller's songs, each with a `stats` object.
  Future<List<dynamic>> fetchMySongs() async {
    try {
      final res =
          await _client().get("/creator/songs", options: await _authed());
      return (res.data as Map)["songs"] as List<dynamic>;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  Future<void> updateSong({
    required String songId,
    String? title,
    String? coverUrl,
    String? description,
    String? status,
  }) async {
    try {
      await _client().patch(
        "/creator/songs/${Uri.encodeComponent(songId)}",
        data: {
          if (title != null) "title": title,
          if (coverUrl != null) "coverUrl": coverUrl,
          if (description != null) "description": description,
          if (status != null) "status": status,
        },
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  Future<void> deleteSong(String songId) async {
    try {
      await _client().delete(
        "/creator/songs/${Uri.encodeComponent(songId)}",
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Ask for a PUBLISHED song to be removed from the catalog. The track stays
  /// live until an operator actions the request — published songs can't be
  /// hidden or deleted directly (the backend answers 409
  /// already_published / published_delete_via_takedown).
  Future<void> requestTakedown({
    required String songId,
    required String reason,
  }) async {
    try {
      await _client().post(
        "/creator/songs/${Uri.encodeComponent(songId)}/takedown-request",
        data: {"reason": reason},
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Full account-carried favorites (`[{trackId,title,artist}]`), used to rebuild
  /// local likes after signing in on a new device.
  Future<List<dynamic>> fetchFavorites() async {
    try {
      final res =
          await _client().get("/sync/favorites", options: await _authed());
      return (res.data as Map)["favorites"] as List<dynamic>;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Returns the provider OAuth URL the app should open in a browser.
  Future<String> startLinking(String provider) async {
    if (!_validProviders.contains(provider)) {
      throw const WalletApiException('Invalid provider');
    }
    final encoded = Uri.encodeComponent(provider);
    try {
      final res = await _client().get(
        "/link/$encoded/start",
        options: await _authed(),
      );
      return (res.data as Map)["url"] as String;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────

  /// Authenticate with a Google ID token. Returns a backend JWT.
  ///
  /// When this device already holds a session token, it is sent so the backend
  /// merges the Google identity into THIS device's wallet (an authenticated
  /// link). Without it the backend resolves to a standalone Google-owned wallet
  /// — the deviceId in the body is never trusted to graft onto an existing
  /// account (that would be an account-takeover vector).
  Future<String> authWithGoogle({
    required String idToken,
    required String deviceId,
  }) async {
    try {
      final res = await _client().post(
        "/auth/google",
        data: {"idToken": idToken, "deviceId": deviceId},
        options: _token != null
            ? Options(headers: {"Authorization": "Bearer $_token"})
            : null,
      );
      final token = _sessionTokenFrom(res.data as Map);
      _token = token;
      await _clearLoggedOut();
      return token;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Ad roll ───────────────────────────────────────────────────────────────

  /// Next eligible ad for this user, or null when the backend has no
  /// inventory. Sends already-heard ad ids so the backend rotates ads.
  Future<Map<String, dynamic>?> fetchNextAd({
    List<String> excludeIds = const [],
  }) async {
    try {
      final res = await _client().get(
        "/ads/next",
        queryParameters: {
          if (excludeIds.isNotEmpty) "exclude": excludeIds.join(","),
        },
        options: await _authed(),
      );
      final ad = (res.data as Map)["ad"];
      return ad is Map ? Map<String, dynamic>.from(ad) : null;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Report that the user skipped an ad (impression accounting).
  Future<void> reportAdSkip(String adId) async {
    try {
      await _client().post(
        "/ads/skip",
        data: {"adId": adId},
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Report that an ad played to completion (campaign spend accounting).
  Future<void> reportAdComplete(String adId) async {
    try {
      await _client().post(
        "/ads/complete",
        data: {"adId": adId},
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Anonymous Data Sync ───────────────────────────────────────────────────

  /// Like a song (sends only SHA-256 hash). Idempotent.
  Future<void> syncLikeSong(String songHash) async {
    try {
      await _client().post(
        "/sync/liked",
        data: {"songHash": songHash},
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Unlike a song.
  Future<void> syncUnlikeSong(String songHash) async {
    try {
      await _client().delete(
        "/sync/liked",
        queryParameters: {"songHash": songHash},
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Fetch all liked song hashes.
  Future<List<String>> syncFetchLikedSongs() async {
    try {
      final res = await _client().get(
        "/sync/liked",
        options: await _authed(),
      );
      final songs = (res.data as Map)["songs"] as List<dynamic>;
      return songs.map((s) => (s as Map)["songHash"] as String).toList();
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Create a playlist (name + hashed song IDs).
  Future<Map<String, dynamic>> syncCreatePlaylist({
    required String name,
    required List<String> songHashes,
  }) async {
    try {
      final res = await _client().post(
        "/sync/playlists",
        data: {"name": name, "songHashes": songHashes},
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Update a playlist.
  Future<void> syncUpdatePlaylist({
    required String id,
    String? name,
    List<String>? songHashes,
  }) async {
    try {
      await _client().patch(
        // encodeComponent: every other path in this file encodes ids; these two
        // were the exceptions, so an id containing "/" or ".." would alter the
        // request path (and the secure channel seals bodies, not the path).
        "/sync/playlists/${Uri.encodeComponent(id)}",
        data: {
          if (name != null) "name": name,
          if (songHashes != null) "songHashes": songHashes,
        },
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Delete a playlist.
  Future<void> syncDeletePlaylist(String id) async {
    try {
      await _client().delete(
        "/sync/playlists/${Uri.encodeComponent(id)}",
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Fetch all user playlists.
  Future<List<Map<String, dynamic>>> syncFetchPlaylists() async {
    try {
      final res = await _client().get(
        "/sync/playlists",
        options: await _authed(),
      );
      final playlists = (res.data as Map)["playlists"] as List<dynamic>;
      return playlists.map((p) => Map<String, dynamic>.from(p as Map)).toList();
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  Future<List<dynamic>> fetchLeaderboard({String? region}) async {
    try {
      final res = await _client().get(
        "/leaderboard",
        queryParameters: {if (region != null) "region": region},
      );
      return (res.data as Map)["entries"] as List<dynamic>;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Supporter badges (`/artists/:id/supporters`) ─────────────────────────

  /// The artist's ranked supporter board. Public endpoint.
  /// Returns `{artistId, tiers: {gold, silver, bronze}, entries: [{rank, name,
  /// totalTokens, tier, badge}]}` — names are anonymized server-side.
  Future<Map<String, dynamic>> fetchSupporters(
    String artistId, {
    int limit = 10,
  }) async {
    try {
      final res = await _client().get(
        "/artists/${Uri.encodeComponent(artistId)}/supporters",
        queryParameters: {"limit": limit},
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// The caller's own supporter standing with this artist (Bearer).
  /// Returns `{artistId, tiers, rank, totalTokens, tier, badge}` — `rank` is
  /// null when the caller has never tipped this artist.
  Future<Map<String, dynamic>> fetchMySupport(String artistId) async {
    try {
      final res = await _client().get(
        "/artists/${Uri.encodeComponent(artistId)}/supporters/me",
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// The DeeMusiq catalog (published songs). Returns `{items, nextCursor}`.
  Future<Map<String, dynamic>> fetchCatalog({
    String? cursor,
    String? query,
    int limit = 30,
  }) async {
    try {
      final res = await _client().get("/catalog", queryParameters: {
        if (cursor != null) "cursor": cursor,
        if (query != null && query.isNotEmpty) "q": query,
        "limit": limit,
      });
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Region-adjusted pricing from the server (authoritative).
  Future<Map<String, dynamic>> fetchPricing(String region) async {
    try {
      final res = await _client().get(
        "/pricing",
        queryParameters: {"region": region},
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Personalised track recommendations based on the user's liked songs.
  Future<Map<String, dynamic>> fetchRecommendations() async {
    try {
      final res = await _client().get(
        "/recommendations/for-you",
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Force-refresh the recommendations cache.
  Future<Map<String, dynamic>> refreshRecommendations() async {
    try {
      final res = await _client().post(
        "/recommendations/refresh",
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Like a track (for recommendations + account-carried favorites). Passing
  /// [title]/[artist] makes the like reversible so it can be pulled back and
  /// rebuilt as a local favorite on another device.
  Future<void> likeTrack(String trackId,
      {String? title, String? artist}) async {
    try {
      await _client().post(
        "/recommendations/like",
        data: {
          "trackId": trackId,
          if (title != null) "title": title,
          if (artist != null) "artist": artist,
        },
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Unlike a track.
  Future<void> unlikeTrack(String trackId) async {
    try {
      await _client().post(
        "/recommendations/unlike",
        data: {"trackId": trackId},
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Get the user's liked track IDs.
  Future<List<String>> fetchLikedTrackIds() async {
    try {
      final res = await _client().get(
        "/recommendations/liked",
        options: await _authed(),
      );
      final list = (res.data as Map)["likedIds"] as List<dynamic>;
      return list.cast<String>();
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Track quality ratings (`/ratings`) ──────────────────────────────────
  // A rating is a like/dislike quality signal, NOT a favorite — favorites
  // stay with the heart button (`/recommendations/like`).

  /// Per-track aggregates (`GET /ratings/:trackId`). The endpoint is public,
  /// but sending the session token makes the backend include `myRating`.
  Future<Map<String, dynamic>> fetchTrackRating(String trackId) async {
    try {
      final res = await _client().get(
        "/ratings/${Uri.encodeComponent(trackId)}",
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Set or change the caller's rating (`PUT /ratings/:trackId`); [value] is
  /// "like" or "dislike". Responds with `{rating, stats}`.
  Future<Map<String, dynamic>> rateTrack(String trackId, String value) async {
    try {
      final res = await _client().put(
        "/ratings/${Uri.encodeComponent(trackId)}",
        data: {"value": value},
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Clear the caller's rating (`DELETE /ratings/:trackId`). Responds with
  /// `{rating: null, stats}`.
  Future<Map<String, dynamic>> clearTrackRating(String trackId) async {
    try {
      final res = await _client().delete(
        "/ratings/${Uri.encodeComponent(trackId)}",
        data: const <String, dynamic>{},
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Every rating the caller has set (`GET /ratings/mine`), newest first.
  /// Lets the app restore like/dislike state for a whole screen in ONE call
  /// instead of `GET /ratings/:trackId` per visible tile.
  Future<List<({String trackId, String rating, DateTime updatedAt})>>
      fetchMyRatings() async {
    try {
      final res = await _client().get(
        "/ratings/mine",
        options: await _authed(),
      );
      final rows = (res.data as Map)["ratings"] as List<dynamic>;
      return rows.map((raw) {
        final r = raw as Map;
        return (
          trackId: r["trackId"] as String,
          rating: r["rating"] as String,
          updatedAt: DateTime.parse(r["updatedAt"] as String),
        );
      }).toList();
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Aggregate ratings for many tracks at once (`POST /ratings/batch`).
  /// Returns `trackId -> {likes, dislikes, total, likeRatio}`. The body is
  /// deliberately a POST: a long track list does not belong in a URL.
  Future<Map<String, TrackRatingStats>> fetchRatingsBatch(
      List<String> trackIds) async {
    if (trackIds.isEmpty) return const {};
    try {
      final res = await _client().post(
        "/ratings/batch",
        data: {"trackIds": trackIds},
      );
      final stats = (res.data as Map)["stats"] as Map;
      return stats.map((key, value) => MapEntry(
            key as String,
            TrackRatingStats.fromJson(value as Map),
          ));
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Time-windowed trending tracks (`GET /ratings/trending`). Public — the
  /// aggregates carry no per-user data, so no session token is sent.
  Future<({List<TrendingTrack> tracks, TrendingWindow window})>
      fetchTrendingTracks({int limit = 30}) async {
    try {
      final res = await _client().get(
        "/ratings/trending",
        queryParameters: {"limit": limit},
      );
      final body = res.data as Map;
      // The feed is a FLAT track DTO with a `rating` block merged in, not a
      // `{track, stats}` envelope — see ratingsRouter GET /trending.
      final rows = body["items"] as List<dynamic>;
      return (
        tracks: rows
            .map((raw) => TrendingTrack.fromJson(raw as Map))
            .toList(),
        window: TrendingWindow.fromJson(
          (body["window"] as Map?) ?? const {},
        ),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Artist self-serve: uploads, scheduling, verification ────────────────

  /// Submit a draft song (audio+cover not yet uploaded). The backend keeps
  /// the row in "draft" status until the audio and cover are attached and
  /// the artist hits `/creator/songs/:id/submit`.
  Future<Map<String, dynamic>> submitSong({
    required String title,
    String? youtubeId,
    String? coverUrl,
    String? description,
  }) async {
    try {
      final res = await _client().post(
        "/creator/songs",
        data: {
          "title": title,
          if (youtubeId != null) "youtubeId": youtubeId,
          if (coverUrl != null) "coverUrl": coverUrl,
          if (description != null) "description": description,
        },
        options: await _authed(),
      );
      if (res.data is! Map || (res.data as Map)["song"] is! Map) {
        throw const WalletApiException("creator_draft_invalid_response");
      }
      return Map<String, dynamic>.from((res.data as Map)["song"] as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Move a draft song to "pending" so the admin queue picks it up.
  Future<Map<String, dynamic>> submitSongForReview(String songId) async {
    try {
      final res = await _client().post(
        "/creator/songs/${Uri.encodeComponent(songId)}/submit",
        options: await _authed(),
      );
      if (res.data is! Map || (res.data as Map)["song"] is! Map) {
        throw const WalletApiException("creator_submit_invalid_response");
      }
      final song = Map<String, dynamic>.from((res.data as Map)["song"] as Map);
      if (song["status"] != "pending") {
        throw const WalletApiException("creator_submit_not_pending");
      }
      return song;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Multipart upload of an audio file for a CreatorSong. The file lives on
  /// the local filesystem (file_picker) and is streamed to the backend, which
  /// fans it out to R2 (primary) + Bunny (mirror) + Cloudflare cache.
  Future<Map<String, dynamic>> uploadAudio({
    required String creatorSongId,
    required String filePath,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final form = FormData.fromMap({
        "creatorSongId": creatorSongId,
        "audio": await MultipartFile.fromFile(
          filePath,
          filename: _fileName(filePath),
        ),
      });
      final authed = await _authed();
      final res = await _client().post(
        "/creator/uploads/audio",
        data: form,
        options: Options(
          headers: authed.headers,
          contentType: Headers.multipartFormDataContentType,
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 2),
        ),
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) onProgress(sent / total);
        },
      );
      return _uploadResult(res);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Multipart upload of cover art.
  Future<Map<String, dynamic>> uploadCover({
    required String creatorSongId,
    required String filePath,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final form = FormData.fromMap({
        "creatorSongId": creatorSongId,
        "cover": await MultipartFile.fromFile(
          filePath,
          filename: _fileName(filePath),
        ),
      });
      final authed = await _authed();
      final res = await _client().post(
        "/creator/uploads/cover",
        data: form,
        options: Options(
          headers: authed.headers,
          contentType: Headers.multipartFormDataContentType,
        ),
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) onProgress(sent / total);
        },
      );
      return _uploadResult(res);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Multipart upload of the artist's identity-proof photo (selfie holding a
  /// sign that says "deemusiq"). After this, the artist calls
  /// `submitVerification` to attach legal name + country.
  Future<Map<String, dynamic>> uploadVerificationProof(String filePath) async {
    try {
      final form = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          filePath,
          filename: _fileName(filePath),
        ),
      });
      final authed = await _authed();
      final res = await _client().post(
        "/creator/uploads/verification",
        data: form,
        options: Options(
          headers: authed.headers,
          contentType: Headers.multipartFormDataContentType,
        ),
      );
      return _uploadResult(res);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Submit the verification form: legal name, country, optional socials.
  /// Requires that `uploadVerificationProof` has been called first.
  Future<Map<String, dynamic>> submitVerification({
    required String legalName,
    required String country,
    List<({String provider, String url})> socials = const [],
  }) async {
    try {
      final res = await _client().post(
        "/creator/verification/submit",
        data: {
          "legalName": legalName,
          "country": country,
          "socials": socials
              .map((s) => {"provider": s.provider, "url": s.url})
              .toList(),
        },
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Schedule a song for a future publish moment. Requires the operator to
  /// have approved the submission first (status="approved").
  Future<Map<String, dynamic>> scheduleSong({
    required String songId,
    required DateTime publishAt,
  }) async {
    try {
      final res = await _client().post(
        "/creator/songs/${Uri.encodeComponent(songId)}/schedule",
        data: {"publishAt": publishAt.toUtc().toIso8601String()},
        options: await _authed(),
      );
      return Map<String, dynamic>.from((res.data as Map)["song"] as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Trigger an immediate publish for an approved song. Removes any
  /// previously-queued scheduled job and enqueues a zero-delay one.
  Future<Map<String, dynamic>> publishSongNow(String songId) async {
    try {
      final res = await _client().post(
        "/creator/songs/${Uri.encodeComponent(songId)}/publish-now",
        options: await _authed(),
      );
      return Map<String, dynamic>.from((res.data as Map)["song"] as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Cancel a scheduled (or in-flight) publish. Idempotent.
  Future<Map<String, dynamic>> cancelSongRelease(String songId) async {
    try {
      final res = await _client().post(
        "/creator/songs/${Uri.encodeComponent(songId)}/cancel-release",
        options: await _authed(),
      );
      return Map<String, dynamic>.from((res.data as Map)["song"] as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Server-side listening history & stats (GET /me/history, /me/stats) ────

  /// The caller's server-side listening history, newest day first.
  ///
  /// This is the cross-device counterpart to the on-device (Drift) history:
  /// it survives a reinstall and follows the account to a new phone.
  ///
  /// [before] is the opaque day cursor from a previous page's `nextBefore`.
  Future<List<ServerListenEntry>> fetchListeningHistory({
    int limit = 50,
    String? before,
    int? days,
  }) async {
    try {
      final res = await _client().get(
        "/me/history",
        queryParameters: {
          "limit": limit,
          if (before != null) "before": before,
          if (days != null) "days": days,
        },
        options: await _authed(),
      );
      final body = res.data as Map;
      final entries = body["entries"] as List<dynamic>;
      return entries
          .map((raw) => ServerListenEntry.fromJson(raw as Map))
          .toList();
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Server-side listening totals: minutes, per-day chart, top tracks and top
  /// artists over the last [days].
  ///
  /// Note the server reports `listens` as track-DAYS, not raw plays —
  /// ListenHistory is unique per (user, track, UTC day). `listensIncludingSkips`
  /// is the count with short skips added back in.
  Future<ServerListenStats> fetchListenStats({int days = 30}) async {
    try {
      final res = await _client().get(
        "/me/stats",
        queryParameters: {"days": days},
        options: await _authed(),
      );
      return ServerListenStats.fromJson(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Cross-device playback state (GET/PUT/DELETE /me/playback) ─────────────

  /// Read the saved queue + resume position.
  ///
  /// [stale] is advisory: the server's state is older than its configured
  /// window, so the UI can offer resume with a caveat rather than pretending
  /// it's current. [droppedTrackIds] are ids the server filtered out (taken
  /// down or unpublished) and the caller should prune locally.
  Future<RemotePlaybackState> fetchPlaybackState() async {
    try {
      final res = await _client().get(
        "/me/playback",
        options: await _authed(),
      );
      return RemotePlaybackState.fromJson(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Save the queue and position so another device can continue.
  ///
  /// Last-write-wins by design (two devices playing at once is inherently a
  /// race); the client always sends its whole state.
  ///
  /// Throws [WalletApiException] with `current_track_not_in_queue` if
  /// [currentTrackId] is not in [trackIds] — a caller bug, surfaced rather
  /// than silently storing an inconsistent pair.
  Future<void> savePlaybackState({
    required List<String> trackIds,
    String? currentTrackId,
    int positionMs = 0,
    bool playing = false,
  }) async {
    try {
      await _client().put(
        "/me/playback",
        data: {
          "queue": trackIds,
          "currentTrackId": currentTrackId,
          "positionMs": positionMs,
          "playing": playing,
        },
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Clear the stored state (e.g. the user finished or dismissed the resume).
  Future<void> clearPlaybackState() async {
    try {
      await _client().delete(
        "/me/playback",
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Collaborative playlists ────────────────────────────────────────────────

  /// Playlists this account collaborates on (owned or accepted as editor).
  Future<List<SharedPlaylist>> fetchSharedPlaylists() async {
    try {
      final res = await _client().get("/shared", options: await _authed());
      final rows = (res.data as Map)["playlists"] as List<dynamic>;
      return rows
          .map((raw) => SharedPlaylist.fromJson(raw as Map))
          .toList();
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Pending share invitations awaiting acceptance.
  Future<List<PlaylistInvite>> fetchPlaylistInvites() async {
    try {
      final res = await _client().get("/invites", options: await _authed());
      final rows = (res.data as Map)["invites"] as List<dynamic>;
      return rows
          .map((raw) => PlaylistInvite.fromJson(raw as Map))
          .toList();
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Accept an invitation. Until this is called the invite confers no access.
  Future<void> acceptPlaylistInvite(String playlistId) async {
    try {
      await _client().post(
        "/invites/${Uri.encodeComponent(playlistId)}/accept",
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Add tracks to a playlist this account can edit.
  /// Throws on a track the server refuses (taken down / invisible).
  Future<void> addTracksToSharedPlaylist(
    String playlistId,
    List<String> trackIds,
  ) async {
    try {
      await _client().post(
        "/collaboration/${Uri.encodeComponent(playlistId)}/tracks",
        data: {"trackIds": trackIds},
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  Future<void> removeTrackFromSharedPlaylist(
    String playlistId,
    String trackId,
  ) async {
    try {
      await _client().delete(
        "/collaboration/${Uri.encodeComponent(playlistId)}/tracks/${Uri.encodeComponent(trackId)}",
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Onboarding taste profile ──────────────────────────────────────────────

  /// The account's declared taste profile. Empty lists mean "no profile yet",
  /// which is a normal state the onboarding step renders — not an error.
  Future<TasteProfile> fetchTasteProfile() async {
    try {
      final res = await _client().get(
        "/recommendations/preferences",
        options: await _authed(),
      );
      return TasteProfile.fromJson(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Create or replace the profile. Also invalidates the server's cached
  /// For You page, so the next read reflects it immediately.
  Future<TasteProfile> saveTasteProfile(TasteProfile profile) async {
    try {
      final res = await _client().put(
        "/recommendations/preferences",
        data: {
          "genres": profile.genres,
          "artistIds": profile.artistIds,
          "era": profile.era,
          "personalizationEnabled": profile.personalizationEnabled,
          if (profile.region != null) "region": profile.region,
        },
        options: await _authed(),
      );
      return TasteProfile.fromJson(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Set just the caller's leaderboard region (`PUT
  /// /recommendations/preferences {"region": "ZA"|null}`) without touching
  /// the taste fields. Null returns to the global boards.
  Future<void> saveRegion(String? region) async {
    try {
      await _client().put(
        "/recommendations/preferences",
        data: {"region": region},
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  Future<void> clearTasteProfile() async {
    try {
      await _client().delete(
        "/recommendations/preferences",
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Scrobble / play telemetry ────────────────────────────────────────────

  /// POST /metadata/play/:id with the listened/duration fields so the
  /// backend can distinguish a real listen (counts toward playCount) from
  /// a skip. The backend records both in `ListenHistory`; the response
  /// includes `{counted: true|false}` for UI feedback ("scrobbled!").
  Future<bool> scrobble({
    required String trackId,
    required int listenedMs,
    int? durationMs,
    String source = "app",
  }) async {
    try {
      final res = await _client().post(
        "/metadata/play/${Uri.encodeComponent(trackId)}",
        data: {
          "listenedMs": listenedMs,
          if (durationMs != null) "durationMs": durationMs,
          "source": source,
        },
        options: await _authed(),
      );
      return (res.data as Map)["counted"] == true;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Offline license ──────────────────────────────────────────────────────

  /// Asks the backend to confirm this device's offline-playback license.
  /// The endpoint may not exist on older backends — callers treat 404 as
  /// "no license enforcement deployed" and keep the local grace policy.
  Future<void> confirmOfflineLicense() async {
    try {
      await _client().post(
        "/offline/license/confirm",
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Comments ─────────────────────────────────────────────────────────────

  /// Public read. Exactly one of trackId / albumId / artistId must be set.
  Future<Map<String, dynamic>> listComments({
    String? trackId,
    String? albumId,
    String? artistId,
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final res = await _client().get("/comments", queryParameters: {
        if (trackId != null) "trackId": trackId,
        if (albumId != null) "albumId": albumId,
        if (artistId != null) "artistId": artistId,
        if (cursor != null) "cursor": cursor,
        "limit": limit,
      });
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Post a comment. Body is required; pass exactly one target FK.
  Future<Map<String, dynamic>> postComment({
    required String body,
    String? trackId,
    String? albumId,
    String? artistId,
    String? parentId,
  }) async {
    try {
      final res = await _client().post(
        "/comments",
        data: {
          "body": body,
          if (trackId != null) "trackId": trackId,
          if (albumId != null) "albumId": albumId,
          if (artistId != null) "artistId": artistId,
          if (parentId != null) "parentId": parentId,
        },
        options: await _authed(),
      );
      return Map<String, dynamic>.from((res.data as Map)["comment"] as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  Future<List<dynamic>> listCommentReplies(String parentId) async {
    try {
      final res = await _client().get(
        "/comments/${Uri.encodeComponent(parentId)}/replies",
      );
      return (res.data as Map)["replies"] as List<dynamic>;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Reports (public create) ─────────────────────────────────────────────

  /// File a Trust & Safety report. Anonymous unless the user is logged in.
  /// For DMCA-style copyright claims, include `evidenceUrl`.
  Future<String> reportContent({
    required String targetKind,
    required String targetId,
    required String reason,
    String? description,
    String? evidenceUrl,
  }) async {
    try {
      final res = await _client().post(
        "/reports",
        data: {
          "targetKind": targetKind,
          "targetId": targetId,
          "reason": reason,
          if (description != null && description.isNotEmpty)
            "description": description,
          if (evidenceUrl != null && evidenceUrl.isNotEmpty)
            "evidenceUrl": evidenceUrl,
        },
        options: await _authed(),
      );
      return (res.data as Map)["id"] as String;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Follows ──────────────────────────────────────────────────────────────

  Future<void> followArtist(String artistId) async {
    try {
      await _client().post(
        "/follows",
        data: {"targetKind": "artist", "targetId": artistId},
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  Future<void> unfollowArtist(String artistId) async {
    try {
      await _client().delete(
        "/follows",
        data: {"targetKind": "artist", "targetId": artistId},
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  Future<int> artistFollowerCount(String artistId) async {
    try {
      final res = await _client().get(
        "/artists/${Uri.encodeComponent(artistId)}/followers-count",
      );
      return ((res.data as Map)["count"] as num).toInt();
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  Future<List<dynamic>> myFollowing() async {
    try {
      final res = await _client().get(
        "/me/follows",
        options: await _authed(),
      );
      return (res.data as Map)["follows"] as List<dynamic>;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Precise follow-state check (O(1)) — prefer over list-scan.
  /// GET /me/follows/check?targetKind=artist&targetId=xxx → {following: bool}
  Future<bool> isFollowing({
    required String targetKind,
    required String targetId,
  }) async {
    try {
      final res = await _client().get(
        "/me/follows/check",
        queryParameters: {"targetKind": targetKind, "targetId": targetId},
        options: await _authed(),
      );
      return (res.data as Map)["following"] == true;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── In-app notifications inbox ──────────────────────────────────────────

  Future<Map<String, dynamic>> fetchNotifications(
      {bool unreadOnly = false}) async {
    try {
      final res = await _client().get(
        "/me/notifications",
        queryParameters: {if (unreadOnly) "unreadOnly": "true"},
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  Future<int> markNotificationsRead({List<String> ids = const []}) async {
    try {
      final res = await _client().post(
        "/me/notifications/mark-read",
        data: {"ids": ids},
        options: await _authed(),
      );
      return ((res.data as Map)["marked"] as num).toInt();
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── GDPR / POPIA ───────────────────────────────────────────────────────

  /// Server-side birth-year check. Returns true on success. Throws
  /// WalletApiException with code "under_min_age" if the user is too young.
  Future<void> submitBirthYear(int birthYear) async {
    try {
      await _client().post(
        "/me/birth-year",
        data: {"birthYear": birthYear},
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// GDPR data export. Returns the full server-side dump as a Map; the
  /// caller can serialize to JSON and pass to a file-save dialog.
  Future<Map<String, dynamic>> exportMyData() async {
    try {
      final res = await _client().get("/me/export", options: await _authed());
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// POPIA consent records. GET /me/consent → {policyVersions, consents[]}
  Future<Map<String, dynamic>> fetchConsent() async {
    try {
      final res = await _client().get("/me/consent", options: await _authed());
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Grant/withdraw a consent purpose (terms|privacy|marketing).
  /// Withdrawing terms/privacy restricts processing (see backend note).
  Future<Map<String, dynamic>> updateConsent({
    required String purpose,
    required String action,
  }) async {
    try {
      final res = await _client().post(
        "/me/consent",
        data: {"purpose": purpose, "action": action},
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Email-code login hardening: request a one-time code to the account email.
  Future<void> requestEmailCode() async {
    try {
      await _client()
          .post("/auth/email-code/request", options: await _authed());
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Confirm a one-time email code (geo-lock / new-device verification).
  Future<Map<String, dynamic>> confirmEmailCode(String code) async {
    try {
      final res = await _client().post(
        "/auth/email-code/confirm",
        data: {"code": code},
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Complete a password reset with a reset token (emailed via forgotPassword).
  /// POST /auth/reset-password {token, password}
  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      await _client().post(
        "/auth/reset-password",
        data: {"token": token, "password": password},
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Verify an email address with an emailed token.
  /// POST /auth/verify {token} → {ok: true}
  ///
  /// The token goes in the BODY, not a query string. Query strings are exempt
  /// from the secure channel (it seals bodies only, see `secure_channel.dart`)
  /// and they land in every proxy/CDN access log and in `Referer` on any
  /// navigation away from the page — so a GET would write a live
  /// email-verification token into third-party logs.
  Future<void> verifyEmail(String token) async {
    try {
      await _client().post("/auth/verify", data: {"token": token});
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Creator monetization panel (post-approval) ─────────────────────────
  // Multi-format uploads are advertised by the backend so the picker never
  // hardcodes extensions; payout method + revenue-split cut + analytics live
  // here so Creator Studio is one import away from the whole panel.

  /// Supported upload containers (mp3/wav/flac/m4a/ogg/opus/webm/aiff…).
  Future<Map<String, dynamic>> fetchUploadFormats() async {
    try {
      final res = await _client().get(
        "/creator/uploads/formats",
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Artist analytics overview (gross vs platform fee vs net, daily, tracks).
  Future<Map<String, dynamic>> fetchCreatorAnalytics({
    String? artistId,
    String range = "30d",
  }) async {
    try {
      final res = await _client().get(
        "/creator/analytics/overview",
        queryParameters: {
          if (artistId != null) "artistId": artistId,
          "range": range,
        },
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Saved payout destination (masked) or null when never set.
  Future<Map<String, dynamic>?> fetchPayoutMethod({String? artistId}) async {
    try {
      final res = await _client().get(
        "/creator/payouts/method",
        queryParameters: {if (artistId != null) "artistId": artistId},
        options: await _authed(),
      );
      final method = (res.data as Map)["method"];
      if (method == null) return null;
      return Map<String, dynamic>.from(method as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Save the artist's payout destination (encrypted server-side).
  Future<Map<String, dynamic>> savePayoutMethod({
    required String artistId,
    required String method,
    required String details,
  }) async {
    try {
      final res = await _client().put(
        "/creator/payouts/method",
        data: {"artistId": artistId, "method": method, "details": details},
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Creator cash-out: payable balances per verified owned artist.
  /// GET /creator/payouts/balance → {rateZarPerTokenMinor, minTokens,
  /// manualThresholdZarMinor, balances[]}
  Future<Map<String, dynamic>> fetchPayoutBalance() async {
    try {
      final res = await _client().get(
        "/creator/payouts/balance",
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Request a cash-out. Uses saved payout method when details omitted.
  /// POST /creator/payouts/request {artistId, tokens, method, details?}
  /// Pass a caller-owned Idempotency-Key kept STABLE per form intent: a retry
  /// after a timeout then replays against the original request (backend
  /// answers the original row with deduped: true) instead of creating a
  /// duplicate pending payout.
  Future<Map<String, dynamic>> requestPayout({
    required String artistId,
    required int tokens,
    required String method,
    String? details,
    String? idempotencyKey,
  }) async {
    try {
      final authed = await _authed();
      final res = await _client().post(
        "/creator/payouts/request",
        data: {
          "artistId": artistId,
          "tokens": tokens,
          "method": method,
          if (details != null && details.isNotEmpty) "details": details,
        },
        options: Options(headers: {
          ...?authed.headers,
          if (idempotencyKey != null) "Idempotency-Key": idempotencyKey,
        }),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Creator's own payout requests (same shape as /history, newest first).
  /// GET /creator/payouts → {payouts[]}
  Future<Map<String, dynamic>> fetchMyPayouts() async {
    try {
      final res = await _client().get(
        "/creator/payouts",
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Payout statement for export. GET /creator/payouts/history → {payouts[]}
  /// (amount = ZAR minor units agreed at request time; no settlement details).
  Future<Map<String, dynamic>> fetchPayoutHistory() async {
    try {
      final res = await _client().get(
        "/creator/payouts/history",
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Current platform cut (default 30%) + pending/history.
  Future<Map<String, dynamic>> fetchRevenueSplit({String? artistId}) async {
    try {
      final res = await _client().get(
        "/creator/revenue-split",
        queryParameters: {if (artistId != null) "artistId": artistId},
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Request the 30% default or a custom cut (0–50%). Needs approval.
  Future<Map<String, dynamic>> requestRevenueSplit({
    required String artistId,
    required int requestedPct,
    String? note,
  }) async {
    try {
      final res = await _client().post(
        "/creator/revenue-split/request",
        data: {
          "artistId": artistId,
          "requestedPct": requestedPct,
          if (note != null && note.isNotEmpty) "note": note,
        },
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Gmail-link personalization profile for recommendations.
  Future<Map<String, dynamic>> fetchRecommendationProfile() async {
    try {
      final res = await _client().get(
        "/recommendations/profile",
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Earn-to-listen rewards (`/rewards`) ──────────────────────────────────

  /// The caller's earn-to-listen status (`GET /rewards/status`, Bearer).
  /// Returns `{enabled, earnedToday, dailyCap, perPlay, newAccountTaper,
  /// lifetimeEarned}`. Crediting happens server-side inside the verified-play
  /// path — there is no claim endpoint to call from here.
  ///
  /// A 404 means the backend predates the rewards feature: returns null so
  /// the caller can hide the UI instead of crashing on an absent endpoint.
  /// 401/429/503 still throw [WalletApiException] for the caller to fold.
  Future<Map<String, dynamic>?> fetchRewardsStatus() async {
    try {
      final res = await _client().get(
        "/rewards/status",
        options: await _authed(),
      );
      if (res.data is! Map) {
        throw const WalletApiException("rewards_status_invalid_response");
      }
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _walletApiException(e);
    }
  }
}
