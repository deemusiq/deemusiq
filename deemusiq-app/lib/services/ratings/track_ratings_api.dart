import 'dart:io';

import 'package:dio/dio.dart';
import 'package:deemusiq/services/wallet/payment_service.dart'
    show PaymentGatewayConfig;
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// The value a user can stamp on a track. The wire format is the lowercase
/// name (`"like"` / `"dislike"`); unknown server values parse to null so a
/// newer backend never crashes an older app.
enum TrackRatingValue {
  like,
  dislike;

  String get wireName => name;

  static TrackRatingValue? parse(Object? raw) {
    if (raw is! String) return null;
    for (final value in TrackRatingValue.values) {
      if (value.name == raw) return value;
    }
    return null;
  }
}

/// Aggregated rating counters for one track (`likes`, `dislikes`, `total`,
/// `likeRatio` 0..1 or null when unrated).
class TrackRatingStats {
  final int likes;
  final int dislikes;
  final int total;
  final double? likeRatio;

  const TrackRatingStats({
    this.likes = 0,
    this.dislikes = 0,
    this.total = 0,
    this.likeRatio,
  });

  factory TrackRatingStats.fromJson(Map<String, dynamic> json) {
    return TrackRatingStats(
      likes: (json["likes"] as num?)?.toInt() ?? 0,
      dislikes: (json["dislikes"] as num?)?.toInt() ?? 0,
      total: (json["total"] as num?)?.toInt() ?? 0,
      likeRatio: (json["likeRatio"] as num?)?.toDouble(),
    );
  }

  /// 0–100 for the "87%" badge, null when the track has no ratings yet.
  int? get likePercent {
    final ratio = likeRatio;
    if (ratio == null || total <= 0) return null;
    return (ratio * 100).round();
  }
}

/// Result of a rate/remove call: the caller's new rating (null after remove)
/// plus the refreshed aggregate stats.
class TrackRatingOutcome {
  final TrackRatingValue? rating;
  final TrackRatingStats stats;

  const TrackRatingOutcome({required this.rating, required this.stats});
}

/// Public per-track snapshot: aggregate stats plus the caller's own rating
/// when the request carried a session token.
class TrackRatingSnapshot {
  final TrackRatingStats stats;
  final TrackRatingValue? myRating;

  const TrackRatingSnapshot({required this.stats, this.myRating});
}

/// One trending / top-catalog row: the catalog track DTO plus its rating
/// block. [RatedTrack.fromJson] accepts both backend shapes — the trending
/// endpoint's nested `artist: {id, name}` / `source: {type, ...}` DTO and the
/// flat catalog feed (`artistId` / `artistName` / `youtubeId`).
class RatedTrack {
  final String id;
  final String title;
  final String artistId;
  final String artistName;
  final String? coverUrl;
  final String? youtubeId;
  final String? streamUrl;
  final int durationMs;
  final String? releaseDate;
  final String? albumTitle;
  final bool explicit;
  final TrackRatingStats? rating;

  const RatedTrack({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    this.coverUrl,
    this.youtubeId,
    this.streamUrl,
    this.durationMs = 0,
    this.releaseDate,
    this.albumTitle,
    this.explicit = false,
    this.rating,
  });

  factory RatedTrack.fromJson(Map<String, dynamic> json) {
    final artist = json["artist"];
    final album = json["album"];
    final source = json["source"];
    String? youtubeId = json["youtubeId"] as String?;
    String? streamUrl = json["streamUrl"] as String?;
    if (source is Map) {
      if (source["type"] == "youtube") {
        youtubeId ??= source["youtubeId"] as String?;
      } else if (source["type"] == "url") {
        streamUrl ??= source["url"] as String?;
      }
    }
    final rating = json["rating"];
    return RatedTrack(
      id: json["id"]?.toString() ?? "",
      title: json["title"]?.toString() ?? "",
      artistId: artist is Map
          ? artist["id"]?.toString() ?? ""
          : json["artistId"]?.toString() ?? "",
      artistName: artist is Map
          ? artist["name"]?.toString() ?? ""
          : json["artistName"]?.toString() ?? "",
      coverUrl: json["coverUrl"] as String?,
      youtubeId: youtubeId,
      streamUrl: streamUrl,
      durationMs: (json["durationMs"] as num?)?.toInt() ?? 0,
      releaseDate: json["releaseDate"] as String?,
      albumTitle: album is Map ? album["title"]?.toString() : null,
      explicit: json["explicit"] == true,
      rating: rating is Map
          ? TrackRatingStats.fromJson(Map<String, dynamic>.from(rating))
          : null,
    );
  }

  /// The flat catalog-feed shape — lets the trending/top items flow through
  /// the same item → playable-track mapping the catalog page uses.
  Map<String, dynamic> toFeedJson() => {
        "id": id,
        "title": title,
        "artistId": artistId,
        "artistName": artistName,
        if (coverUrl != null) "coverUrl": coverUrl,
        if (youtubeId != null) "youtubeId": youtubeId,
        if (streamUrl != null) "streamUrl": streamUrl,
        "durationMs": durationMs,
        if (releaseDate != null) "releaseDate": releaseDate,
      };
}

/// HTTP client for the backend track-rating system (`/ratings/*`, plus the
/// `/catalog?sort=top` fallback feed). Mirrors [WalletApiClient]: inert until
/// [PaymentGatewayConfig.backendBaseUrl] is set, and auth reuses the wallet's
/// device-JWT handling. The secure channel is not engaged here — the backend
/// only seals bodies when the client asks for it (`X-DM-Enc` header), and
/// catalog/scrobble traffic already goes over plain TLS the same way.
class TrackRatingsApi {
  /// [client] and [authToken] are test seams: inject a Dio with a fake
  /// adapter and a fixed token to exercise the mapping without a backend.
  TrackRatingsApi({Dio? client, Future<String> Function()? authToken})
      : _clientOverride = client,
        _authTokenOverride = authToken;

  final Dio? _clientOverride;
  final Future<String> Function()? _authTokenOverride;
  Dio? _dio;

  static const int maxBatchSize = 100;

  bool get isConfigured =>
      _clientOverride != null || PaymentGatewayConfig.backendBaseUrl.isNotEmpty;

  Dio _client() {
    final override = _clientOverride;
    if (override != null) return override;
    final cached = _dio;
    if (cached != null) return cached;
    final dio = Dio(
      BaseOptions(
        baseUrl: PaymentGatewayConfig.backendBaseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 20),
        headers: {"Content-Type": "application/json"},
      ),
    );
    _dio = dio;
    return dio;
  }

  Future<String> _token() =>
      (_authTokenOverride ?? WalletApiClient.instance.backendAuthToken).call();

  Future<Options> _authed() async =>
      Options(headers: {"Authorization": "Bearer ${await _token()}"});

  /// Auth for PUBLIC endpoints: attaches the cached session token when one is
  /// already in memory (so the backend can add `myRating`) but never triggers
  /// a device login — anonymous callers stay anonymous.
  Future<Options?> _optionalAuth() async {
    final override = _authTokenOverride;
    if (override != null) {
      return Options(headers: {"Authorization": "Bearer ${await override()}"});
    }
    final token = WalletApiClient.instance.sessionToken;
    if (token == null) return null;
    return Options(headers: {"Authorization": "Bearer $token"});
  }

  /// Set/replace the caller's rating on [trackId] (`PUT /ratings/:id`).
  Future<TrackRatingOutcome> rate(String trackId, TrackRatingValue value) async {
    try {
      final res = await _client().put(
        "/ratings/${Uri.encodeComponent(trackId)}",
        data: {"value": value.wireName},
        options: await _authed(),
      );
      return _parseOutcome(res.data);
    } on DioException catch (e) {
      throw _ratingsException(e);
    }
  }

  /// Clear the caller's rating on [trackId] (`DELETE /ratings/:id`).
  Future<TrackRatingOutcome> remove(String trackId) async {
    try {
      final res = await _client().delete(
        "/ratings/${Uri.encodeComponent(trackId)}",
        options: await _authed(),
      );
      return _parseOutcome(res.data);
    } on DioException catch (e) {
      throw _ratingsException(e);
    }
  }

  /// All of the caller's ratings (`GET /ratings/mine`) as trackId → value.
  /// Rows with unrecognised rating strings are skipped, not fatal.
  Future<Map<String, TrackRatingValue>> mine() async {
    try {
      final res = await _client().get("/ratings/mine", options: await _authed());
      final data = res.data;
      if (data is! Map) throw const WalletApiException("ratings_invalid_response", code: "ratings_invalid_response");
      final raw = data["ratings"];
      if (raw is! List) throw const WalletApiException("ratings_invalid_response", code: "ratings_invalid_response");
      final result = <String, TrackRatingValue>{};
      for (final entry in raw) {
        if (entry is! Map) continue;
        final trackId = entry["trackId"];
        final value = TrackRatingValue.parse(entry["rating"]);
        if (trackId is String && trackId.isNotEmpty && value != null) {
          result[trackId] = value;
        }
      }
      return result;
    } on DioException catch (e) {
      throw _ratingsException(e);
    }
  }

  /// Public stats for one track (`GET /ratings/:id`); carries `myRating` when
  /// a session token is in memory.
  Future<TrackRatingSnapshot> stats(String trackId) async {
    try {
      final res = await _client().get(
        "/ratings/${Uri.encodeComponent(trackId)}",
        options: await _optionalAuth(),
      );
      final data = res.data;
      if (data is! Map) throw const WalletApiException("ratings_invalid_response", code: "ratings_invalid_response");
      return TrackRatingSnapshot(
        stats: TrackRatingStats.fromJson(Map<String, dynamic>.from(data)),
        myRating: TrackRatingValue.parse(data["myRating"]),
      );
    } on DioException catch (e) {
      throw _ratingsException(e);
    }
  }

  /// Stats for up to [maxBatchSize] tracks in one call (`POST /ratings/batch`).
  Future<Map<String, TrackRatingStats>> batch(List<String> trackIds) async {
    if (trackIds.length > maxBatchSize) {
      throw const WalletApiException("too_many_track_ids", code: "too_many_track_ids");
    }
    try {
      final res = await _client().post(
        "/ratings/batch",
        data: {"trackIds": trackIds},
      );
      final data = res.data;
      if (data is! Map) throw const WalletApiException("ratings_invalid_response", code: "ratings_invalid_response");
      final stats = data["stats"];
      if (stats is! Map) throw const WalletApiException("ratings_invalid_response", code: "ratings_invalid_response");
      return {
        for (final entry in stats.entries)
          if (entry.value is Map)
            entry.key.toString(): TrackRatingStats.fromJson(
              Map<String, dynamic>.from(entry.value as Map),
            ),
      };
    } on DioException catch (e) {
      throw _ratingsException(e);
    }
  }

  /// The trending window's top-rated tracks (`GET /ratings/trending`).
  Future<List<RatedTrack>> trending({int limit = 30}) async {
    try {
      final res = await _client().get(
        "/ratings/trending",
        queryParameters: {"limit": limit},
      );
      return _parseTrackList(res.data, "items");
    } on DioException catch (e) {
      throw _ratingsException(e);
    }
  }

  /// The all-time top-rated catalog feed (`GET /catalog?sort=top`) — the
  /// fallback when the trending window has no rated tracks yet.
  Future<List<RatedTrack>> topTracks({int limit = 30}) async {
    try {
      final res = await _client().get(
        "/catalog",
        queryParameters: {"sort": "top", "limit": limit},
      );
      return _parseTrackList(res.data, "items");
    } on DioException catch (e) {
      throw _ratingsException(e);
    }
  }

  TrackRatingOutcome _parseOutcome(Object? data) {
    if (data is! Map) throw const WalletApiException("ratings_invalid_response", code: "ratings_invalid_response");
    final stats = data["stats"];
    if (stats is! Map) throw const WalletApiException("ratings_invalid_response", code: "ratings_invalid_response");
    return TrackRatingOutcome(
      rating: TrackRatingValue.parse(data["rating"]),
      stats: TrackRatingStats.fromJson(Map<String, dynamic>.from(stats)),
    );
  }

  List<RatedTrack> _parseTrackList(Object? data, String key) {
    if (data is! Map) throw const WalletApiException("ratings_invalid_response", code: "ratings_invalid_response");
    final raw = data[key];
    if (raw is! List) throw const WalletApiException("ratings_invalid_response", code: "ratings_invalid_response");
    return raw
        .whereType<Map>()
        .map((e) => RatedTrack.fromJson(Map<String, dynamic>.from(e)))
        .where((t) => t.id.isNotEmpty)
        .toList();
  }

  WalletApiException _ratingsException(DioException e) {
    final data = e.response?.data;
    var message = e.message ?? "Network error";
    String? code;
    if (data is Map) {
      final serverMessage = data["message"];
      final serverError = data["error"];
      if (serverMessage is String) message = serverMessage;
      if (serverError is String) code = serverError;
    }
    return WalletApiException(
      message,
      statusCode: e.response?.statusCode,
      code: code,
      isConnectivity: _isConnectivityError(e),
    );
  }

  /// Same rule as the wallet client: only network-level failures (no server
  /// response) count as connectivity errors.
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
        return error is SocketException || error is HandshakeException;
      case DioExceptionType.badResponse:
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
        return false;
    }
  }
}
