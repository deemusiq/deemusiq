import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/services/metadata/endpoints/album.dart';
import 'package:deemusiq/services/metadata/endpoints/artist.dart';
import 'package:deemusiq/services/metadata/endpoints/audio_source.dart';
import 'package:deemusiq/services/metadata/endpoints/auth.dart';
import 'package:deemusiq/services/metadata/endpoints/browse.dart';
import 'package:deemusiq/services/metadata/endpoints/core.dart';
import 'package:deemusiq/services/metadata/endpoints/playlist.dart';
import 'package:deemusiq/services/metadata/endpoints/search.dart';
import 'package:deemusiq/services/metadata/endpoints/track.dart';
import 'package:deemusiq/services/metadata/endpoints/user.dart';
import 'package:deemusiq/services/metadata/errors/exceptions.dart';
import 'package:deemusiq/services/wallet/payment_service.dart'
    show PaymentGatewayConfig;
import 'package:deemusiq/services/wallet/wallet_api.dart';
import 'package:deemusiq/services/auth/data_sync.dart' show DataSyncService;
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/services/youtube_engine/youtube_engine.dart';
import 'package:deemusiq/services/youtube_engine/yt_dlp_engine.dart';
import 'package:deemusiq/services/youtube_engine/direct_ytdlp_engine.dart';
import 'package:deemusiq/services/youtube_engine/yt_dlp_provisioner.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' show Video, StreamManifest;
import 'package:deemusiq/services/audio_player/audio_error_handler.dart';
import 'package:deemusiq/services/audio_player/audio_quality.dart';
import 'package:deemusiq/services/artist_info/artist_info_service.dart';
import 'package:deemusiq/services/connectivity/engine_failover.dart';
import 'package:deemusiq/services/content_filter.dart';
import 'package:deemusiq/services/logger/logger.dart';

/// The built-in "plugin" identity DeeMusiq presents in place of any external
/// metadata provider. It carries no bytecode — the endpoints are native Dart
/// (see below) talking to the DeeMusiq backend `/metadata` API.
final PluginConfiguration kDeeMusiqNativePluginConfig = PluginConfiguration(
  name: "DeeMusiq",
  description: "DeeMusiq's own catalog — artists, albums and tracks.",
  version: "1.0.0",
  author: "DeeMusiq",
  entryPoint: "",
  pluginApiVersion: "2.0.0",
  apis: const [],
  abilities: const [
    PluginAbilities.metadata,
    PluginAbilities.audioSource,
  ],
);



// ── Playable-source encoding ─────────────────────────────────────────────────
// Each track carries its audio source in `externalUri` so the audio-source
// endpoint can resolve it without a second lookup.
const _ytPrefix = "ytsource:";
const _urlPrefix = "urlsource:";
const _catalogPrefix = "catalogsource:";

String _encodeSource(Map? source) {
  if (source == null) return "";
  switch (source["type"]) {
    case "youtube":
      return "$_ytPrefix${source["youtubeId"]}";
    case "url":
      return "$_urlPrefix${source["url"]}";
    default:
      return "";
  }
}

/// True when the DeeMusiq backend cannot serve a catalog request right now:
/// network-level unreachability ([CatalogOfflineException]) or a 5xx from the
/// origin/edge (Cloudflare 521–524 while the origin is down, 502/503/504).
/// 4xx responses (not found, auth, rate limit) stay semantic errors and are
/// never masked by a YouTube fallback.
bool _isBackendUnavailable(Object error) {
  if (error is CatalogOfflineException) return true;
  if (error is DioException) {
    final status = error.response?.statusCode ?? 0;
    return status >= 500 && status < 600;
  }
  return false;
}

/// True when the catalog answered 404 — the id simply isn't in the catalog,
/// which is a semantic miss (YouTube-fallback eligible), not a failure.
bool _isNotFound(Object error) =>
    error is DioException && error.response?.statusCode == 404;

// ── YouTube-sourced album ids ────────────────────────────────────────────────
// The browse fallback's genre-mix cards are YouTube videos masquerading as
// albums. Their ids carry this prefix so the album endpoint knows to resolve
// them through the YouTube engine instead of the catalog API.
const _ytAlbumIdPrefix = "yt:";
final _youtubeVideoIdShape = RegExp(r'^[A-Za-z0-9_-]{11}$');

/// Extracts the YouTube video id from an album id fabricated by the browse
/// fallback (`yt:`-prefixed, or a bare 11-char video id from older cached
/// data). Null for regular catalog album ids.
String? _youtubeVideoIdFromAlbumId(String albumId) {
  if (albumId.startsWith(_ytAlbumIdPrefix)) {
    final id = albumId.substring(_ytAlbumIdPrefix.length);
    return id.isEmpty ? null : id;
  }
  return _youtubeVideoIdShape.hasMatch(albumId) ? albumId : null;
}

/// Maps a YouTube [Video] to a playable track (streamed through the
/// `ytsource:` branch of the audio source endpoint).
DeeMusiqFullTrackObject _videoToFullTrack(Video video) {
  return DeeMusiqFullTrackObject(
    id: video.id.value,
    name: video.title,
    externalUri: "$_ytPrefix${video.id.value}",
    artists: [
      DeeMusiqSimpleArtistObject(
        id: video.channelId.value,
        name: video.author,
        externalUri: "deemusiq:artist:${video.channelId.value}",
      ),
    ],
    album: DeeMusiqSimpleAlbumObject(
      id: "$_ytAlbumIdPrefix${video.id.value}",
      name: video.title,
      externalUri: "deemusiq:album:$_ytAlbumIdPrefix${video.id.value}",
      artists: const [],
      images: video.thumbnails.highResUrl.isNotEmpty
          ? [DeeMusiqImageObject(url: video.thumbnails.highResUrl)]
          : const [],
      albumType: DeeMusiqAlbumType.single,
      releaseDate: video.uploadDate?.toIso8601String(),
    ),
    durationMs: video.duration?.inMilliseconds ?? 0,
    isrc: "",
    explicit: false,
  );
}

// ── Backend client ───────────────────────────────────────────────────────────

class _CatalogApi {
  static const _maxAttempts = 3;
  static const _backoff = [
    Duration(milliseconds: 500),
    Duration(seconds: 2),
  ];

  Dio? _cachedClient;

  _CatalogApi([this._cachedClient]);

  String get baseUrl =>
      _cachedClient?.options.baseUrl ?? PaymentGatewayConfig.backendBaseUrl;

  /// True when [source] carries the shape of a backend-minted signed stream
  /// URL (`/metadata/audio/<id>?e=…&s=…`), regardless of whether the backend
  /// is configured in this build.
  static bool isCatalogStreamUrl(String source) {
    final raw =
        source.startsWith(_urlPrefix) ? source.substring(_urlPrefix.length) : source;
    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasAuthority) return false;
    return RegExp(r'^/metadata/audio/[^/]+$').hasMatch(uri.path) &&
        uri.queryParameters.containsKey('e') &&
        uri.queryParameters.containsKey('s');
  }

  bool isCatalogStream(String source) {
    if (!source.startsWith(_urlPrefix) || !isConfigured) return false;
    final uri = Uri.tryParse(source.substring(_urlPrefix.length));
    final base = Uri.tryParse(baseUrl);
    if (uri == null || base == null || !uri.hasAuthority) return false;
    return uri.scheme == base.scheme &&
        uri.host == base.host &&
        uri.port == base.port &&
        isCatalogStreamUrl(source);
  }

  /// True for network-level failures (backend unreachable): connection
  /// refused/timeout, DNS failures, etc. HTTP error responses are NOT
  /// network-level and stay retryable.
  static bool isConnectionError(Object error) {
    if (error is SocketException) return true;
    if (error is DioException) {
      return error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.error is SocketException;
    }
    return false;
  }

  Dio _client() => _cachedClient ??= Dio(
        BaseOptions(
          baseUrl: PaymentGatewayConfig.backendBaseUrl,
          connectTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );

  bool get isConfigured => baseUrl.isNotEmpty;

  /// Returns null if the backend is not configured — callers should fall
  /// back to YouTube search or cached data when this returns null.
  ///
  /// Throws [CatalogOfflineException] immediately (no retries) when the
  /// backend is unreachable at the network level; other errors are retried
  /// up to [_maxAttempts] times with a 500ms/2s backoff before rethrowing.
  Future<Map<String, dynamic>?> _get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    int attempt = 0;
    if (!isConfigured) {
      AppLogger.log.i('Backend not configured — returning null for $path');
      return null;
    }
    while (true) {
      try {
        final res = await _client().get(path, queryParameters: query);
        return (res.data as Map).cast<String, dynamic>();
      } catch (e, stack) {
        attempt++;
        if (isConnectionError(e)) {
          AppLogger.log.w('Catalog API unreachable: $path — ${e.toString()}');
          AppLogger.reportError(e, stack);
          throw CatalogOfflineException(
            "Couldn't reach DeeMusiq servers",
            e,
          );
        }
        if (attempt >= _maxAttempts) {
          AppLogger.log.w('Catalog API failed after $_maxAttempts attempts: $path — ${e.toString()}');
          AppLogger.reportError(e, stack);
          rethrow;
        }
        final delay = _backoff[(attempt - 1).clamp(0, _backoff.length - 1)];
        AppLogger.log.w('Catalog API attempt $attempt/$_maxAttempts failed: $path — retrying in ${delay.inMilliseconds}ms');
        await Future.delayed(delay);
      }
    }
  }

  Future<Map<String, dynamic>?> search(String q, String type, int limit) =>
      _get("/metadata/search", query: {"q": q, "type": type, "limit": limit});
  Future<Map<String, dynamic>?> home() => _get("/metadata/home");
  Future<Map<String, dynamic>?> artist(String id) => _get("/metadata/artist/$id");
  Future<Map<String, dynamic>?> album(String id) => _get("/metadata/album/$id");
  Future<Map<String, dynamic>?> playlist(String id) =>
      _get("/metadata/playlist/$id");
  Future<Map<String, dynamic>?> track(String id) =>
      _get("/metadata/track/${Uri.encodeComponent(id)}");
}

// ── Mappers: backend JSON → app model objects ────────────────────────────────

/// The `verified` flag of a catalog artist. `_fullArtist` can't carry it (the
/// metadata model has no such field), so the artist page header fetches it
/// separately — same backend flag the artist leaderboard shows. Returns false
/// when the backend is unreachable or the id isn't a catalog artist.
Future<bool> fetchCatalogArtistVerified(String artistId) async {
  try {
    final a = await _CatalogApi().artist(artistId);
    return a?["verified"] == true;
  } catch (e, stack) {
    AppLogger.log.w(
        'Failed to fetch verified state for artist $artistId: ${e.toString()}');
    AppLogger.reportError(e, stack);
    return false;
  }
}

List<DeeMusiqImageObject> _images(String? url) =>
    url == null || url.isEmpty ? const [] : [DeeMusiqImageObject(url: url)];

DeeMusiqAlbumType _albumType(String? t) {
  switch (t) {
    case "single":
    case "ep":
      return DeeMusiqAlbumType.single;
    case "compilation":
      return DeeMusiqAlbumType.compilation;
    default:
      return DeeMusiqAlbumType.album;
  }
}

DeeMusiqSimpleArtistObject _simpleArtistFromRef(Map a) =>
    DeeMusiqSimpleArtistObject(
      id: (a["id"] ?? "").toString(),
      name: (a["name"] ?? "").toString(),
      externalUri: "deemusiq:artist:${a["id"] ?? ""}",
    );

DeeMusiqFullArtistObject _fullArtist(Map a) => DeeMusiqFullArtistObject(
      id: (a["id"] ?? "").toString(),
      name: (a["name"] ?? "").toString(),
      externalUri: "deemusiq:artist:${a["id"] ?? ""}",
      images: _images(a["imageUrl"] as String?),
    );

DeeMusiqSimpleAlbumObject _simpleAlbum(Map a) {
  final artistRef = a["artist"] as Map?;
  return DeeMusiqSimpleAlbumObject(
    id: (a["id"] ?? "").toString(),
    name: (a["title"] ?? a["name"] ?? "").toString(),
    externalUri: "deemusiq:album:${a["id"] ?? ""}",
    artists: artistRef != null ? [_simpleArtistFromRef(artistRef)] : const [],
    images: _images(a["coverUrl"] as String?),
    albumType: _albumType(a["albumType"] as String?),
    releaseDate: a["releaseDate"]?.toString(),
  );
}

DeeMusiqSimpleAlbumObject _trackAlbum(Map t) {
  final album = t["album"] as Map?;
  final artistRef = t["artist"] as Map?;
  if (album != null) {
    return DeeMusiqSimpleAlbumObject(
      id: (album["id"] ?? "").toString(),
      name: (album["title"] ?? "").toString(),
      externalUri: "deemusiq:album:${album["id"] ?? ""}",
      artists: artistRef != null ? [_simpleArtistFromRef(artistRef)] : const [],
      images: _images((album["coverUrl"] ?? t["coverUrl"]) as String?),
      albumType: DeeMusiqAlbumType.album,
    );
  }
  // Single/loose track: synthesise a one-track album from the track itself.
  return DeeMusiqSimpleAlbumObject(
    id: (t["id"] ?? "").toString(),
    name: (t["title"] ?? "").toString(),
    externalUri: "deemusiq:track:${t["id"] ?? ""}",
    artists: artistRef != null ? [_simpleArtistFromRef(artistRef)] : const [],
    images: _images(t["coverUrl"] as String?),
    albumType: DeeMusiqAlbumType.single,
  );
}

DeeMusiqFullTrackObject _track(Map t) {
  final artistRef = t["artist"] as Map?;
  return DeeMusiqTrackObject.full(
    id: (t["id"] ?? "").toString(),
    name: (t["title"] ?? "").toString(),
    externalUri: _encodeSource(t["source"] as Map?),
    artists: artistRef != null ? [_simpleArtistFromRef(artistRef)] : const [],
    album: _trackAlbum(t),
    durationMs: (t["durationMs"] as num?)?.toInt() ?? 0,
    isrc: "",
    explicit: t["explicit"] == true,
  ) as DeeMusiqFullTrackObject;
}

/// Maps a flat /catalog feed item to a playable track. The feed shape differs
/// from /metadata track JSON: artist is `artistId`/`artistName` strings and
/// the source is `youtubeId` or a signed `streamUrl`, never a `source` map.
DeeMusiqFullTrackObject _catalogFeedTrack(Map s) {
  final id = (s["id"] ?? "").toString();
  final title = (s["title"] ?? "").toString();
  final artist = (s["artistName"] ?? "").toString();
  final youtubeId = (s["youtubeId"] ?? "").toString();
  final streamUrl = (s["streamUrl"] ?? "").toString();
  final playUri = streamUrl.isNotEmpty
      ? "$_urlPrefix$streamUrl"
      : "$_ytPrefix$youtubeId";
  final cover = s["coverUrl"] as String?;
  final albumRef = s["album"] as Map?;
  return DeeMusiqTrackObject.full(
    id: id,
    name: title,
    externalUri: playUri,
    artists: [
      DeeMusiqSimpleArtistObject(
        id: (s["artistId"] ?? artist).toString(),
        name: artist,
        externalUri: "deemusiq:artist:${s["artistId"] ?? ""}",
      ),
    ],
    album: albumRef != null
        ? DeeMusiqSimpleAlbumObject(
            id: albumRef["id"].toString(),
            name: albumRef["title"].toString(),
            externalUri: "deemusiq:album:${albumRef["id"]}",
            artists: const [],
            images: _images((albumRef["coverUrl"] ?? cover) as String?),
            albumType: DeeMusiqAlbumType.album,
          )
        : DeeMusiqSimpleAlbumObject(
            id: id,
            name: title,
            externalUri: "deemusiq:track:$id",
            artists: const [],
            images: _images(cover),
            albumType: DeeMusiqAlbumType.single,
          ),
    durationMs: (s["durationMs"] as num?)?.toInt() ?? 0,
    isrc: "",
    explicit: s["explicit"] == true,
  ) as DeeMusiqFullTrackObject;
}

DeeMusiqUserObject get _deemusiqOwner => DeeMusiqUserObject(
      id: "deemusiq",
      name: "DeeMusiq",
      externalUri: "deemusiq:user:deemusiq",
    );

DeeMusiqSimplePlaylistObject _simplePlaylist(Map p) =>
    DeeMusiqSimplePlaylistObject(
      id: (p["id"] ?? "").toString(),
      name: (p["title"] ?? "").toString(),
      description: (p["description"] ?? "").toString(),
      externalUri: "deemusiq:playlist:${p["id"] ?? ""}",
      owner: _deemusiqOwner,
      images: _images(p["coverUrl"] as String?),
    );

DeeMusiqPaginationResponseObject<T> _page<T>(List<T> items) =>
    DeeMusiqPaginationResponseObject<T>(
      limit: items.length,
      nextOffset: null,
      total: items.length,
      hasMore: false,
      items: items,
    );

List<Map> _list(dynamic v) =>
    (v as List? ?? const []).whereType<Map>().toList();

// ── Native endpoints ─────────────────────────────────────────────────────────

class _NativeSearch extends MetadataPluginSearchEndpoint {
  final _CatalogApi api;
  final List<YouTubeEngine> _allEngines;
  _NativeSearch(this.api, this._allEngines) : super();

  @override
  List<String> get chips => const ["all", "tracks", "artists", "albums", "playlists"];

  /// Maps a YouTube [Video] search result to a [DeeMusiqFullTrackObject].
  DeeMusiqFullTrackObject _videoToTrack(Video video) {
    return DeeMusiqTrackObject.full(
      id: video.id.value,
      name: video.title,
      externalUri: "$_ytPrefix${video.id.value}",
      artists: video.author.isNotEmpty
          ? [
              DeeMusiqSimpleArtistObject(
                id: video.author,
                name: video.author,
                externalUri: "deemusiq:artist:${video.author}",
              )
            ]
          : [],
      album: DeeMusiqSimpleAlbumObject(
        id: "$_ytAlbumIdPrefix${video.id.value}",
        name: video.title,
        externalUri: "deemusiq:album:$_ytAlbumIdPrefix${video.id.value}",
        artists: video.author.isNotEmpty
            ? [
                DeeMusiqSimpleArtistObject(
                  id: video.author,
                  name: video.author,
                  externalUri: "deemusiq:artist:${video.author}",
                )
              ]
            : const [],
        images: video.thumbnails.highResUrl.isNotEmpty
            ? [DeeMusiqImageObject(url: video.thumbnails.highResUrl)]
            : const [],
        albumType: DeeMusiqAlbumType.single,
        releaseDate: video.uploadDate?.toIso8601String(),
      ),
      durationMs: video.duration?.inMilliseconds ?? 0,
      isrc: "",
      explicit: false,
    ) as DeeMusiqFullTrackObject;
  }

  /// Searches YouTube for tracks as a fallback when the backend is unavailable
  /// or returns no results.
  Future<List<DeeMusiqFullTrackObject>> _youtubeTrackSearch(
      String query, int limit) async {
    try {
      final videos = await EngineFailover.tryEngines(
        engines: _allEngines,
        operation: (engine) async {
          final results = await engine.searchVideos(query);
          return results.take(limit).toList();
        },
        onRetry: (msg, attempt) {
          AppLogger.log.i('Engine retry: $msg (attempt $attempt)');
        },
      );
      final filtered = videos
          .where((v) => ContentFilter.isPlayableSong(v))
          .take(limit)
          .map(_videoToTrack)
          .toList();
      return filtered;
    } catch (e, stack) {
      AppLogger.log.w('YouTube search fallback failed: ${e.toString()}');
      AppLogger.reportError(e, stack);
      return [];
    }
  }

  @override
  Future<DeeMusiqSearchResponseObject> all(String query) async {
    // Try backend first
    if (api.isConfigured) {
      try {
        final d = await api.search(query, "all", 20);
        if (d != null) {
          final albums = _list(d["albums"]).map(_simpleAlbum).toList();
          final artists = _list(d["artists"]).map(_fullArtist).toList();
          final playlists =
              _list(d["playlists"]).map(_simplePlaylist).toList();
          final validTracks = _list(d["tracks"])
              .map(_track)
              .where((t) => t.externalUri.isNotEmpty)
              .toList();
          if (validTracks.isNotEmpty) {
            return DeeMusiqSearchResponseObject(
              albums: albums,
              artists: artists,
              playlists: playlists,
              tracks: validTracks,
            );
          }
          // Tracks-only miss: the catalog DID match in other sections — keep
          // those matches and backfill just the tracks from YouTube, instead
          // of discarding the catalog's albums/artists/playlists wholesale.
          if (albums.isNotEmpty ||
              artists.isNotEmpty ||
              playlists.isNotEmpty) {
            return DeeMusiqSearchResponseObject(
              albums: albums,
              artists: artists,
              playlists: playlists,
              tracks: await _youtubeTrackSearch(query, 20),
            );
          }
          // Every catalog section empty: a genuine no-match — fall through to
          // the full YouTube fallback below.
        }
      } catch (e, stack) {
        AppLogger.log.w('Backend search "all" failed, falling back to YouTube: ${e.toString()}');
        AppLogger.reportError(e, stack);
        // Fall through to YouTube fallback
      }
    }
    // Fallback to YouTube search
    final ytTracks = await _youtubeTrackSearch(query, 20);
    return DeeMusiqSearchResponseObject(
      albums: const [],
      artists: const [],
      playlists: const [],
      tracks: ytTracks,
    );
  }

  @override
  Future<DeeMusiqPaginationResponseObject<DeeMusiqSimpleAlbumObject>> albums(
      String query, {int? limit, int? offset}) async {
    if (!api.isConfigured) return _page(const []);
    try {
      final d = await api.search(query, "album", limit ?? 20);
      if (d == null) return _page(const []);
      return _page(_list(d["albums"]).map(_simpleAlbum).toList());
    } catch (e, stack) {
      AppLogger.log.w('Backend album search failed for "$query": ${e.toString()}');
      AppLogger.reportError(e, stack);
      return _page(const []);
    }
  }

  @override
  Future<DeeMusiqPaginationResponseObject<DeeMusiqFullArtistObject>> artists(
      String query, {int? limit, int? offset}) async {
    if (!api.isConfigured) return _page(const []);
    try {
      final d = await api.search(query, "artist", limit ?? 20);
      if (d == null) return _page(const []);
      return _page(_list(d["artists"]).map(_fullArtist).toList());
    } catch (e, stack) {
      AppLogger.log.w('Backend artist search failed for "$query": ${e.toString()}');
      AppLogger.reportError(e, stack);
      return _page(const []);
    }
  }

  @override
  Future<DeeMusiqPaginationResponseObject<DeeMusiqSimplePlaylistObject>>
      playlists(String query, {int? limit, int? offset}) async {
    if (!api.isConfigured) return _page(const []);
    try {
      final d = await api.search(query, "playlist", limit ?? 20);
      if (d == null) return _page(const []);
      return _page(_list(d["playlists"]).map(_simplePlaylist).toList());
    } catch (e, stack) {
      AppLogger.log.w('Backend playlist search failed for "$query": ${e.toString()}');
      AppLogger.reportError(e, stack);
      return _page(const []);
    }
  }

  @override
  Future<DeeMusiqPaginationResponseObject<DeeMusiqFullTrackObject>> tracks(
      String query, {int? limit, int? offset}) async {
    final lim = limit ?? 20;
    // Try backend first
    if (api.isConfigured) {
      try {
        final d = await api.search(query, "track", lim);
        if (d != null) {
          final tracks = _list(d["tracks"]).map(_track).toList();
          final validTracks = tracks.where((t) => t.externalUri.isNotEmpty).toList();
          if (validTracks.isNotEmpty) {
            return _page(validTracks);
          }
        }
      } catch (e, stack) {
        AppLogger.log.w('Backend track search failed for "$query", falling back to YouTube: ${e.toString()}');
        AppLogger.reportError(e, stack);
        // Fall through to YouTube fallback
      }
    }
    // Fallback to YouTube search
    final ytTracks = await _youtubeTrackSearch(query, lim);
    return _page(ytTracks);
  }
}

class _NativeAlbum extends MetadataPluginAlbumEndpoint {
  final _CatalogApi api;
  YouTubeEngine? _ytEngine;

  _NativeAlbum(this.api) : super();

  /// Injected by [DeeMusiqNativeEndpoints] after construction so the album
  /// endpoint can resolve YouTube-sourced "albums" (the browse fallback's
  /// genre-mix cards carry a YouTube video id as the album id) when the
  /// catalog backend can't serve them.
  void injectYouTube(YouTubeEngine engine) {
    _ytEngine = engine;
  }

  /// Resolves the video behind a YouTube-sourced album id. Null when the id
  /// isn't YouTube-shaped, no engine is injected, or resolution fails.
  Future<Video?> _resolveYouTubeVideo(String id) async {
    final engine = _ytEngine;
    final videoId = _youtubeVideoIdFromAlbumId(id);
    if (engine == null || videoId == null) return null;
    try {
      return await engine.getVideo(videoId);
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'NativeAlbum YouTube fallback $id');
      return null;
    }
  }

  Future<DeeMusiqFullTrackObject?> _resolveYouTubeTrack(String id) async {
    final video = await _resolveYouTubeVideo(id);
    return video == null ? null : _videoToFullTrack(video);
  }

  /// A YouTube-sourced album is a single-video shell: the video itself is the
  /// only "track".
  Future<DeeMusiqFullAlbumObject?> _resolveYouTubeAlbum(String id) async {
    final video = await _resolveYouTubeVideo(id);
    if (video == null) return null;
    return DeeMusiqFullAlbumObject(
      id: id,
      name: video.title,
      artists: video.author.isNotEmpty
          ? [
              DeeMusiqSimpleArtistObject(
                id: video.channelId.value,
                name: video.author,
                externalUri: "deemusiq:artist:${video.channelId.value}",
              ),
            ]
          : const [],
      images: video.thumbnails.highResUrl.isNotEmpty
          ? [DeeMusiqImageObject(url: video.thumbnails.highResUrl)]
          : const [],
      releaseDate: video.uploadDate?.toIso8601String() ?? "",
      externalUri: "deemusiq:album:$id",
      totalTracks: 1,
      albumType: DeeMusiqAlbumType.single,
    );
  }

  DeeMusiqFullAlbumObject _unknownAlbum(String id) {
    return DeeMusiqFullAlbumObject(
      id: id,
      name: "Unknown Album",
      artists: const [],
      images: const [],
      releaseDate: "",
      externalUri: "deemusiq:album:$id",
      totalTracks: 0,
      albumType: DeeMusiqAlbumType.album,
    );
  }

  @override
  Future<DeeMusiqFullAlbumObject> getAlbum(String id) async {
    try {
      final a = await api.album(id);
      if (a == null) {
        // Backend not configured: YouTube-sourced albums can still resolve.
        final yt = await _resolveYouTubeAlbum(id);
        return yt ?? _unknownAlbum(id);
      }
      final artistRef = a["artist"] as Map?;
      final tracks = _list(a["tracks"]);
      return DeeMusiqFullAlbumObject(
        id: (a["id"] ?? "").toString(),
        name: (a["title"] ?? "").toString(),
        artists: artistRef != null ? [_simpleArtistFromRef(artistRef)] : const [],
        images: _images(a["coverUrl"] as String?),
        releaseDate: (a["releaseDate"] ?? "").toString(),
        externalUri: "deemusiq:album:$id",
        totalTracks: tracks.length,
        albumType: _albumType(a["albumType"] as String?),
      );
    } catch (e, stack) {
      if (_isNotFound(e)) {
        // Not in the catalog — maybe a YouTube-sourced album id.
        final yt = await _resolveYouTubeAlbum(id);
        return yt ?? _unknownAlbum(id);
      }
      // Real failures (offline, 5xx) must reach the detail page's ErrorBox
      // instead of degrading to an empty "Unknown Album" shell.
      AppLogger.log.w('Failed to fetch album $id: ${e.toString()}');
      AppLogger.reportError(e, stack);
      rethrow;
    }
  }

  @override
  Future<DeeMusiqPaginationResponseObject<DeeMusiqFullTrackObject>> tracks(
      String id, {int? offset, int? limit}) async {
    try {
      final a = await api.album(id);
      if (a == null) {
        // Backend not configured: YouTube-sourced albums can still resolve.
        final yt = await _resolveYouTubeTrack(id);
        return _page(yt == null ? const <DeeMusiqFullTrackObject>[] : [yt]);
      }
      return _page(_list(a["tracks"]).map(_track).toList());
    } catch (e, stack) {
      if (_isNotFound(e)) {
        // Not in the catalog — maybe a YouTube-sourced album id.
        final yt = await _resolveYouTubeTrack(id);
        if (yt != null) return _page([yt]);
        AppLogger.log.w('Album $id not found in catalog or on YouTube');
        return _page(const <DeeMusiqFullTrackObject>[]);
      }
      AppLogger.log.w('Failed to fetch album tracks for $id: ${e.toString()}');
      AppLogger.reportError(e, stack);
      rethrow;
    }
  }

  @override
  Future<DeeMusiqPaginationResponseObject<DeeMusiqSimpleAlbumObject>> releases(
      {int? offset, int? limit}) async {
    // 1) Try the real backend first.
    if (api.isConfigured) {
      try {
        final d = await api.home();
        if (d != null) {
          final albums = <DeeMusiqSimpleAlbumObject>[];
          for (final s in _list(d["sections"])) {
            if (s["type"] == "albums") {
              albums.addAll(_list(s["items"]).map(_simpleAlbum));
            }
          }
          if (albums.isNotEmpty) return _page(albums);
        }
      } catch (e, stack) {
        AppLogger.log.w('Backend home (releases) failed, falling back to YouTube: ${e.toString()}');
        AppLogger.reportError(e, stack);
        // Fall through to YouTube fallback
      }
    }

    return _page([]);
  }

  /// Saved albums persist locally (see [_LocalSaves]).
  @override
  Future<void> save(List<String> ids) async =>
      _LocalSaves.add(_kSavedAlbums, ids);
  @override
  Future<void> unsave(List<String> ids) async =>
      _LocalSaves.remove(_kSavedAlbums, ids);
}

class _NativeArtist extends MetadataPluginArtistEndpoint {
  final _CatalogApi api;
  YouTubeEngine? _ytEngine;
  _NativeArtist(this.api) : super();

  /// Injected by [DeeMusiqNativeEndpoints] after construction so artist pages
  /// still work for YouTube-sourced content when the catalog backend can't
  /// serve them (offline, outage, or a non-catalog artist id).
  void injectYouTube(YouTubeEngine engine) {
    _ytEngine = engine;
  }

  @override
  Future<DeeMusiqFullArtistObject> getArtist(String id) async {
    try {
      final a = await api.artist(id);
      if (a == null) throw Exception('Backend unavailable');
      return _enrichWithThirdPartyImage(_fullArtist(a));
    } catch (e, stack) {
      AppLogger.log.w('Failed to fetch artist $id: ${e.toString()}');
      AppLogger.reportError(e, stack);
      // Backend can't serve this artist — resolve it as a YouTube channel
      // so the page shows the real name/avatar instead of an empty shell.
      final yt = await _resolveYouTubeArtist(id);
      if (yt != null) return _enrichWithThirdPartyImage(yt);
      return DeeMusiqFullArtistObject(
        id: id,
        name: "Unknown Artist",
        externalUri: "deemusiq:artist:$id",
        images: const [],
      );
    }
  }

  /// Third-party photo (Deezer/iTunes) when neither the backend nor YouTube
  /// provided one — for every user, with or without a backend account.
  Future<DeeMusiqFullArtistObject> _enrichWithThirdPartyImage(
    DeeMusiqFullArtistObject artist,
  ) async {
    if (artist.images.isNotEmpty) return artist;
    if (artist.name.trim().isEmpty || artist.name == "Unknown Artist") {
      return artist;
    }
    try {
      final url = await ArtistInfoService.instance.fetchArtistImage(artist.name);
      if (url == null) return artist;
      return artist.copyWith(images: [DeeMusiqImageObject(url: url)]);
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'artist image enrichment ${artist.id}');
      return artist;
    }
  }

  Future<DeeMusiqFullArtistObject?> _resolveYouTubeArtist(String id) async {
    final engine = _ytEngine;
    if (engine == null) return null;
    try {
      final channel = await engine.resolveChannel(id);
      if (channel == null) return null;
      return DeeMusiqFullArtistObject(
        id: channel.id.value,
        name: channel.title,
        externalUri: "deemusiq:artist:${channel.id.value}",
        images: [
          if (channel.logoUrl.isNotEmpty)
            DeeMusiqImageObject(url: channel.logoUrl),
        ],
      );
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'NativeArtist YouTube fallback $id');
      return null;
    }
  }

  @override
  Future<DeeMusiqPaginationResponseObject<DeeMusiqFullTrackObject>> topTracks(
      String id, {int? offset, int? limit}) async {
    try {
      final a = await api.artist(id);
      if (a != null) {
        return _page(_list(a["topTracks"]).map(_track).toList());
      }
    } catch (e, stack) {
      AppLogger.log.w('Failed to fetch top tracks for artist $id: ${e.toString()}');
      AppLogger.reportError(e, stack);
    }
    // Backend can't serve this artist (offline build, outage, or a
    // YouTube-sourced artist): surface the channel's uploads as playable
    // tracks instead of an empty page.
    final engine = _ytEngine;
    if (engine == null) return _page(const <DeeMusiqFullTrackObject>[]);
    try {
      final artist = await _resolveYouTubeArtist(id);
      final videos = await engine.searchVideos(artist?.name ?? id);
      final tracks = videos
          .where(ContentFilter.isPlayableSong)
          .take(10)
          .map(_videoToFullTrack)
          .toList();
      return _page(tracks);
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'NativeArtist.topTracks YouTube fallback $id');
      return _page(const <DeeMusiqFullTrackObject>[]);
    }
  }

  @override
  Future<DeeMusiqPaginationResponseObject<DeeMusiqSimpleAlbumObject>> albums(
      String id, {int? offset, int? limit}) async {
    try {
      final a = await api.artist(id);
      if (a == null) return _page(const []);
      return _page(_list(a["albums"]).map(_simpleAlbum).toList());
    } catch (e, stack) {
      AppLogger.log.w('Failed to fetch albums for artist $id: ${e.toString()}');
      AppLogger.reportError(e, stack);
      return _page(const <DeeMusiqSimpleAlbumObject>[]);
    }
  }

  /// Related artists: other published artists on the platform, busiest first.
  @override
  Future<DeeMusiqPaginationResponseObject<DeeMusiqFullArtistObject>> related(
      String id, {int? offset, int? limit}) async {
    if (!api.isConfigured) return _page(const []);
    try {
      final d = await api._get("/metadata/artist/$id/related");
      return _page(_list(d?["artists"]).map(_fullArtist).toList());
    } catch (e, stack) {
      AppLogger.log.w('Failed to fetch related artists for $id: ${e.toString()}');
      AppLogger.reportError(e, stack, 'NativeArtist.related $id');
      return _page(const <DeeMusiqFullArtistObject>[]);
    }
  }

  /// Followed artists persist locally (see [_LocalSaves]).
  @override
  Future<void> save(List<String> ids) async =>
      _LocalSaves.add(_kFollowedArtists, ids);
  @override
  Future<void> unsave(List<String> ids) async =>
      _LocalSaves.remove(_kFollowedArtists, ids);
}

class _NativePlaylist extends MetadataPluginPlaylistEndpoint {
  final _CatalogApi api;
  _NativePlaylist(this.api) : super();

  @override
  Future<DeeMusiqFullPlaylistObject> getPlaylist(String id) async {
    try {
      final p = await api.playlist(id);
      if (p == null) throw Exception('Backend unavailable');
      return DeeMusiqFullPlaylistObject(
        id: (p["id"] ?? "").toString(),
        name: (p["title"] ?? "").toString(),
        description: (p["description"] ?? "").toString(),
        externalUri: "deemusiq:playlist:$id",
        owner: _deemusiqOwner,
        images: _images(p["coverUrl"] as String?),
      );
    } catch (e, stack) {
      AppLogger.log.w('Failed to fetch playlist $id: ${e.toString()}');
      AppLogger.reportError(e, stack);
      return DeeMusiqFullPlaylistObject(
        id: id,
        name: "Unknown Playlist",
        description: "",
        externalUri: "deemusiq:playlist:$id",
        owner: _deemusiqOwner,
        images: const [],
      );
    }
  }

  @override
  Future<DeeMusiqPaginationResponseObject<DeeMusiqFullTrackObject>> tracks(
      String id, {int? offset, int? limit}) async {
    try {
      final p = await api.playlist(id);
      // Backend not configured (offline build): nothing to serve, but not a
      // failure — match the other endpoints' empty-page behavior.
      if (p == null) return _page(const <DeeMusiqFullTrackObject>[]);
      return _page(_list(p["tracks"]).map(_track).toList());
    } catch (e, stack) {
      if (_isNotFound(e)) {
        AppLogger.log.w('Playlist $id not found in catalog');
        return _page(const <DeeMusiqFullTrackObject>[]);
      }
      // Real failures (offline, 5xx) must reach the detail page's ErrorBox
      // instead of silently rendering an empty playlist.
      AppLogger.log.w('Failed to fetch playlist tracks for $id: ${e.toString()}');
      AppLogger.reportError(e, stack);
      rethrow;
    }
  }

  // User-created playlists are carried by the anonymous account-sync API
  // (/sync/playlists): names are encrypted at rest, songs stored as SHA-256
  // hashes of their catalog ids (same scheme as [DataSyncService]).

  @override
  Future<DeeMusiqFullPlaylistObject?> create(String userId,
      {required String name,
      String? description,
      bool? public,
      bool? collaborative}) async {
    if (!WalletApiClient.instance.isConfigured) return null;
    try {
      final p = await WalletApiClient.instance.syncCreatePlaylist(
        name: name,
        songHashes: const [],
      );
      return DeeMusiqFullPlaylistObject(
        id: (p["id"] ?? "").toString(),
        name: (p["name"] ?? name).toString(),
        description: description ?? "",
        externalUri: "deemusiq:playlist:${p["id"] ?? ""}",
        owner: _deemusiqOwner,
        collaborative: collaborative ?? false,
        public: public ?? false,
      );
    } catch (e, stack) {
      AppLogger.log.w('Playlist create failed: ${e.toString()}');
      AppLogger.reportError(e, stack, 'NativePlaylist.create');
      return null;
    }
  }

  @override
  Future<void> update(String playlistId,
      {String? name,
      String? description,
      bool? public,
      bool? collaborative}) async {
    if (name == null || !WalletApiClient.instance.isConfigured) return;
    try {
      await WalletApiClient.instance.syncUpdatePlaylist(
        id: playlistId,
        name: name,
      );
    } catch (e, stack) {
      AppLogger.log.w('Playlist update failed: ${e.toString()}');
      AppLogger.reportError(e, stack, 'NativePlaylist.update');
    }
  }

  @override
  Future<void> addTracks(String playlistId,
      {required List<String> trackIds, int? position}) async {
    await _mutatePlaylistHashes(playlistId, trackIds, add: true);
  }

  @override
  Future<void> removeTracks(String playlistId,
      {required List<String> trackIds}) async {
    await _mutatePlaylistHashes(playlistId, trackIds, add: false);
  }

  /// Read-modify-write of the hash list — the backend PATCH replaces the
  /// whole set. Skips hashes already present/absent so it stays idempotent.
  Future<void> _mutatePlaylistHashes(
    String playlistId,
    List<String> trackIds, {
    required bool add,
  }) async {
    if (trackIds.isEmpty || !WalletApiClient.instance.isConfigured) return;
    try {
      final playlists = await WalletApiClient.instance.syncFetchPlaylists();
      final current = playlists.firstWhere(
        (p) => p["id"] == playlistId,
        orElse: () => <String, dynamic>{},
      );
      if (current.isEmpty) return;
      final hashes = ((current["songHashes"] as List?) ?? const [])
          .map((h) => h.toString())
          .toSet();
      for (final id in trackIds) {
        final hash = DataSyncService.hashSongId(id);
        add ? hashes.add(hash) : hashes.remove(hash);
      }
      await WalletApiClient.instance
          .syncUpdatePlaylist(id: playlistId, songHashes: hashes.toList());
    } catch (e, stack) {
      AppLogger.log.w('Playlist tracks mutation failed: ${e.toString()}');
      AppLogger.reportError(e, stack, 'NativePlaylist._mutatePlaylistHashes');
    }
  }

  /// Following a playlist persists locally; the playlist itself lives on the
  /// account (see [_LocalSaves]).
  @override
  Future<void> save(String playlistId) async =>
      _LocalSaves.add(_kFollowedPlaylists, [playlistId]);
  @override
  Future<void> unsave(String playlistId) async =>
      _LocalSaves.remove(_kFollowedPlaylists, [playlistId]);
  @override
  Future<void> deletePlaylist(String playlistId) async {
    if (!WalletApiClient.instance.isConfigured) return;
    try {
      await WalletApiClient.instance.syncDeletePlaylist(playlistId);
    } catch (e, stack) {
      AppLogger.log.w('Playlist delete failed: ${e.toString()}');
      AppLogger.reportError(e, stack, 'NativePlaylist.deletePlaylist');
    }
  }
}

class _NativeTrack extends MetadataPluginTrackEndpoint {
  final _CatalogApi api;
  _NativeTrack(this.api) : super();

  @override
  Future<DeeMusiqFullTrackObject> getTrack(String id) async {
    try {
      final t = await api.track(id);
      if (t == null) throw Exception('Backend unavailable');
      return _track(t);
    } catch (e, stack) {
      AppLogger.log.w('Failed to fetch track $id: ${e.toString()}');
      AppLogger.reportError(e, stack, 'NativeTrack.getTrack $id');
      rethrow;
    }
  }

  /// Radio for a track: more from the same artist (top tracks minus the
  /// seed), falling back to the platform catalog when the artist page is thin.
  @override
  Future<List<DeeMusiqFullTrackObject>> radio(String id) async {
    if (!api.isConfigured) return const [];
    try {
      // `id` is a TRACK id — the artist endpoint 404s on those. Resolve the
      // track first to find its artist (that lookup bug silently killed
      // endless playback for every catalog track).
      final t = await api.track(id);
      final artistId = (t?["artist"] as Map?)?["id"]?.toString() ?? "";
      if (artistId.isNotEmpty) {
        final a = await api.artist(artistId);
        final radio = _list(a?["topTracks"])
            .map(_track)
            .where((track) => track.id != id)
            .take(20)
            .toList();
        if (radio.isNotEmpty) return radio;
      }
      // Thin artist page — fall back to the catalog feed. Feed items have the
      // flat /catalog shape, not the /metadata track shape, so they need the
      // feed mapper (otherwise artist + playable source come out empty).
      final cat = await WalletApiClient.instance.fetchCatalog(limit: 20);
      return _list(cat["items"])
          .map(_catalogFeedTrack)
          .where((track) => track.id != id)
          .toList();
    } catch (e, stack) {
      AppLogger.log.w('Radio failed for $id: ${e.toString()}');
      AppLogger.reportError(e, stack, 'NativeTrack.radio $id');
      return const [];
    }
  }

  /// "Saved" tracks persist locally (the account-level like lives in the
  /// wallet/anonymous-sync layer, which is driven by the favorites flow).
  @override
  Future<void> save(List<String> ids) async => _LocalSaves.add(
        _kSavedTracks,
        ids,
      );
  @override
  Future<void> unsave(List<String> ids) async => _LocalSaves.remove(
        _kSavedTracks,
        ids,
      );
}

/// Persisted id-sets backing the plugin's save/follow endpoints. These are
/// device-local by design: account-carried likes/favorites go through
/// [WalletApiClient] instead, so no remote call is duplicated here.
class _LocalSaves {
  static Set<String> _load(String key) =>
      (KVStoreService.sharedPreferences.getStringList(key) ?? const [])
          .toSet();

  static void _store(String key, Set<String> set) =>
      KVStoreService.sharedPreferences.setStringList(key, set.toList());

  static void add(String key, List<String> ids) {
    if (ids.isEmpty) return;
    final set = _load(key)..addAll(ids);
    _store(key, set);
  }

  static void remove(String key, List<String> ids) {
    if (ids.isEmpty) return;
    final set = _load(key)..removeAll(ids);
    _store(key, set);
  }

  static bool contains(String key, String id) => _load(key).contains(id);

  static List<bool> flags(String key, List<String> ids) {
    final set = _load(key);
    return ids.map(set.contains).toList();
  }

  static List<String> all(String key) => _load(key).toList();
}

class _NativeBrowse extends MetadataPluginBrowseEndpoint {
  final _CatalogApi api;
  List<YouTubeEngine>? _allYtEngines;

  _NativeBrowse(this.api) : super();

  /// Injected by [DeeMusiqNativeEndpoints] after construction so that
  /// the browse endpoint can fall back to YouTube when the backend is empty.
  void injectYouTube(List<YouTubeEngine> allEngines) {
    _allYtEngines = allEngines;
  }

  /// Converts a YouTube [Video] into a [DeeMusiqSimpleAlbumObject] suitable
  /// for displaying inside a [HorizontalPlaybuttonCardView]. The id carries
  /// the `_ytAlbumIdPrefix` marker so the album endpoint resolves it through
  /// the YouTube engine (see [_NativeAlbum]).
  DeeMusiqSimpleAlbumObject _videoToSimpleAlbum(Video video) {
    return DeeMusiqSimpleAlbumObject(
      id: "$_ytAlbumIdPrefix${video.id.value}",
      name: video.title,
      externalUri: "deemusiq:album:$_ytAlbumIdPrefix${video.id.value}",
      // The artist id is the channel ID (URL-safe, resolvable via
      // resolveChannel) — display names can contain slashes/spaces that
      // break the /artist/:id route and can't be resolved later.
      artists: video.author.isNotEmpty
          ? [
              DeeMusiqSimpleArtistObject(
                id: video.channelId.value,
                name: video.author,
                externalUri: "deemusiq:artist:${video.channelId.value}",
              )
            ]
          : const [],
      images: video.thumbnails.highResUrl.isNotEmpty
          ? [DeeMusiqImageObject(url: video.thumbnails.highResUrl)]
          : const [],
      albumType: DeeMusiqAlbumType.single,
      releaseDate: video.uploadDate?.toIso8601String(),
    );
  }

  /// Searches YouTube and returns album-shaped results for browse sections.
  Future<List<DeeMusiqSimpleAlbumObject>> _youtubeAlbumSearch(
      String query, int limit) async {
    if (_allYtEngines == null || _allYtEngines!.isEmpty) return [];
    try {
      final videos = await EngineFailover.tryEngines(
        engines: _allYtEngines!,
        operation: (engine) async {
          final results = await engine.searchVideos(query);
          return results.take(limit).toList();
        },
        onRetry: (msg, attempt) {
          AppLogger.log.i('Engine retry: $msg (attempt $attempt)');
        },
      );
      return videos.map(_videoToSimpleAlbum).toList();
    } catch (e, stack) {
      AppLogger.log.w(
          'YouTube browse album search failed for "$query": ${e.toString()}');
      AppLogger.reportError(e, stack);
      return [];
    }
  }

  @override
  Future<DeeMusiqPaginationResponseObject<DeeMusiqBrowseSectionObject<Object>>>
      sections({int? offset, int? limit}) async {
    // 1) Try the real backend first.
    if (api.isConfigured) {
      try {
        final d = await api.home();
        if (d != null) {
          final sections = <DeeMusiqBrowseSectionObject<Object>>[];
          for (final s in _list(d["sections"])) {
            final type = s["type"];
            final items = _list(s["items"]);
            final List<Object> mapped;
            switch (type) {
              case "tracks":
                mapped = items.map(_track).toList();
                break;
              case "albums":
                mapped = items.map(_simpleAlbum).toList();
                break;
              case "artists":
                mapped = items.map(_fullArtist).toList();
                break;
              case "playlists":
                mapped = items.map(_simplePlaylist).toList();
                break;
              default:
                mapped = const [];
            }
            sections.add(DeeMusiqBrowseSectionObject<Object>(
              id: (s["id"] ?? "").toString(),
              title: (s["title"] ?? "").toString(),
              externalUri: "deemusiq:section:${s["id"] ?? ""}",
              browseMore: false,
              items: mapped,
            ));
          }
          if (sections.isNotEmpty) return _page(sections);
        }
      } catch (e, stack) {
        AppLogger.log.w('Backend home (browse) failed, falling back to YouTube: ${e.toString()}');
        AppLogger.reportError(e, stack);
        // Fall through to YouTube fallback
      }
    }

    // 2) Backend unavailable / empty → YouTube fallback with popular SA queries.
    const fallbackQueries = <String, String>{
      "Amapiano 2026": "Amapiano 2026",
      "South African House 2026": "South African House 2026",
      "Afrobeat 2026": "Afrobeat 2026",
      "Gqom 2026": "Gqom 2026",
    };

    // Fetch all sections in parallel, each with its own deadline — sequential
    // engine failover per query can otherwise keep the home page on
    // "building your timeline" for minutes when one query hangs.
    final results = await Future.wait(
      fallbackQueries.entries.map(
        (entry) => _youtubeAlbumSearch(entry.value, 10)
            .timeout(const Duration(seconds: 45), onTimeout: () => const []),
      ),
    );

    final sections = <DeeMusiqBrowseSectionObject<Object>>[];
    var index = 0;
    for (final entry in fallbackQueries.entries) {
      final albums = results[index++];
      if (albums.isNotEmpty) {
        sections.add(DeeMusiqBrowseSectionObject<Object>(
          id: entry.key.replaceAll(" ", "_").toLowerCase(),
          title: entry.key,
          externalUri:
              "deemusiq:section:${entry.key.replaceAll(" ", "_").toLowerCase()}",
          browseMore: false,
          items: albums,
        ));
      }
    }

    return _page(sections);
  }

  /// Items for one browse section. The backend's home feed already returns
  /// full item lists per section, so this re-fetches home and serves the
  /// requested section (cached briefly to avoid refetch storms).
  static Map<String, List<Object>>? _sectionCache;
  static DateTime? _sectionCacheAt;

  @override
  Future<DeeMusiqPaginationResponseObject<Object>> sectionItems(String id,
      {int? offset, int? limit}) async {
    final cached = _sectionCache;
    if (cached == null ||
        _sectionCacheAt == null ||
        DateTime.now().difference(_sectionCacheAt!) > const Duration(minutes: 5)) {
      final fresh = <String, List<Object>>{};
      try {
        final page = await sections();
        for (final s in page.items) {
          fresh[s.id] = s.items;
        }
        _sectionCache = fresh;
        _sectionCacheAt = DateTime.now();
      } catch (e, stack) {
        AppLogger.log.w('sectionItems refresh failed: ${e.toString()}');
        AppLogger.reportError(e, stack, 'NativeBrowse.sectionItems $id');
      }
    }
    final items = _sectionCache?[id] ?? const [];
    return _page(items);
  }
}

/// Keys for the locally persisted save/follow sets (see [_LocalSaves]).
const _kSavedTracks = "plugin_saved_tracks";
const _kSavedAlbums = "plugin_saved_albums";
const _kFollowedArtists = "plugin_followed_artists";
const _kFollowedPlaylists = "plugin_followed_playlists";

class _NativeUser extends MetadataPluginUserEndpoint {
  final _CatalogApi api;
  _NativeUser(this.api) : super();

  /// Minimal playable track built from an account-carried favorite
  /// ({trackId,title,artist}) without a per-track catalog round-trip.
  DeeMusiqFullTrackObject _favoriteTrack(Map f) {
    final id = (f["trackId"] ?? "").toString();
    final title = (f["title"] ?? "").toString();
    final artistName = (f["artist"] ?? "").toString();
    return DeeMusiqTrackObject.full(
      id: id,
      name: title,
      externalUri: "",
      artists: [
        DeeMusiqSimpleArtistObject(
          id: id,
          name: artistName,
          externalUri: "",
          images: null,
        ),
      ],
      album: DeeMusiqSimpleAlbumObject(
        albumType: DeeMusiqAlbumType.single,
        artists: const [],
        externalUri: "",
        id: id,
        name: title,
        releaseDate: null,
        images: const [],
      ),
      durationMs: 0,
      isrc: "",
      explicit: false,
    ) as DeeMusiqFullTrackObject;
  }

  @override
  Future<DeeMusiqUserObject> me() async => _deemusiqOwner;

  /// The account's liked songs, pulled from the backend favorites.
  @override
  Future<DeeMusiqPaginationResponseObject<DeeMusiqFullTrackObject>> savedTracks(
      {int? offset, int? limit}) async {
    if (!WalletApiClient.instance.isConfigured) return _page(const []);
    try {
      final favs = await WalletApiClient.instance.fetchFavorites();
      final tracks =
          favs.map((e) => _favoriteTrack(Map<String, dynamic>.from(e as Map)));
      return _page(tracks.toList());
    } catch (e, stack) {
      AppLogger.log.w('savedTracks failed: ${e.toString()}');
      AppLogger.reportError(e, stack, 'NativeUser.savedTracks');
      return _page(const <DeeMusiqFullTrackObject>[]);
    }
  }

  /// Playlists followed on this device.
  @override
  Future<DeeMusiqPaginationResponseObject<DeeMusiqSimplePlaylistObject>>
      savedPlaylists({int? offset, int? limit}) async {
    final ids = _LocalSaves.all(_kFollowedPlaylists);
    if (ids.isEmpty || !WalletApiClient.instance.isConfigured) {
      return _page(const []);
    }
    try {
      final all = await WalletApiClient.instance.syncFetchPlaylists();
      final followed = all.where((p) => ids.contains(p["id"]));
      return _page(followed
          .map((p) => DeeMusiqSimplePlaylistObject(
                id: (p["id"] ?? "").toString(),
                name: (p["name"] ?? "").toString(),
                description: "",
                externalUri: "deemusiq:playlist:${p["id"] ?? ""}",
                owner: _deemusiqOwner,
              ))
          .toList());
    } catch (e, stack) {
      AppLogger.log.w('savedPlaylists failed: ${e.toString()}');
      AppLogger.reportError(e, stack, 'NativeUser.savedPlaylists');
      return _page(const <DeeMusiqSimplePlaylistObject>[]);
    }
  }

  @override
  Future<DeeMusiqPaginationResponseObject<DeeMusiqSimpleAlbumObject>>
      savedAlbums({int? offset, int? limit}) async {
    final ids = _LocalSaves.all(_kSavedAlbums);
    if (ids.isEmpty || !api.isConfigured) return _page(const []);
    final albums = <DeeMusiqSimpleAlbumObject>[];
    for (final id in ids) {
      try {
        final a = await api.album(id);
        if (a != null) albums.add(_simpleAlbum(a));
      } catch (e, stack) {
        // Album may have left the catalog — log it and keep building the list.
        AppLogger.log.w('savedAlbums: album $id unavailable: ${e.toString()}');
        AppLogger.reportError(e, stack, 'NativeUser.savedAlbums $id');
      }
    }
    return _page(albums);
  }

  @override
  Future<DeeMusiqPaginationResponseObject<DeeMusiqFullArtistObject>>
      savedArtists({int? offset, int? limit}) async {
    final ids = _LocalSaves.all(_kFollowedArtists);
    if (ids.isEmpty || !api.isConfigured) return _page(const []);
    final artists = <DeeMusiqFullArtistObject>[];
    for (final id in ids) {
      try {
        final a = await api.artist(id);
        if (a != null) artists.add(_fullArtist(a));
      } catch (e, stack) {
        // Artist may have left the catalog — log it and keep going.
        AppLogger.log.w('savedArtists: artist $id unavailable: ${e.toString()}');
        AppLogger.reportError(e, stack, 'NativeUser.savedArtists $id');
      }
    }
    return _page(artists);
  }

  @override
  Future<bool> isSavedPlaylist(String playlistId) async =>
      _LocalSaves.contains(_kFollowedPlaylists, playlistId);

  /// Backend truth (account likes), so heart states survive device switches.
  @override
  Future<List<bool>> isSavedTracks(List<String> ids) async {
    if (ids.isEmpty) return const [];
    if (!WalletApiClient.instance.isConfigured) {
      return List.filled(ids.length, false);
    }
    try {
      final liked = (await WalletApiClient.instance.fetchLikedTrackIds()).toSet();
      return ids.map(liked.contains).toList();
    } catch (e) {
      AppLogger.log.w('isSavedTracks failed: ${e.toString()}');
      return List.filled(ids.length, false);
    }
  }

  @override
  Future<List<bool>> isSavedAlbums(List<String> ids) async =>
      _LocalSaves.flags(_kSavedAlbums, ids);

  @override
  Future<List<bool>> isSavedArtists(List<String> ids) async =>
      _LocalSaves.flags(_kFollowedArtists, ids);
}

class _NativeAuth extends MetadataAuthEndpoint {
  _NativeAuth() : super();

  // Typed as raw `Stream` to match the base getter's return type exactly
  // (a `Stream<dynamic>` literal is rejected as an invalid override).
  final Stream _authState = const Stream.empty();

  @override
  Future<void> authenticate() async {}
  @override
  bool isAuthenticated() => true; // no external login — the catalog is public
  @override
  Future<void> logout() async {}
  @override
  Stream get authStateStream => _authState;
}

class _NativeCore extends MetadataPluginCore {
  _NativeCore() : super();

  static Dio? _scrobbleClient;

  /// The native plugin ships inside the app binary — it cannot be updated
  /// independently of the app (updates are delivered by the in-app updater,
  /// see RootAppUpdateDialog). Hence: no plugin-level update available.
  @override
  Future<PluginUpdateAvailable?> checkUpdate(PluginConfiguration pluginConfig) async =>
      null;

  @override
  Future<String> get support async => "https://deemusiq.co.za/";

  /// Play reporting: bumps the track's playCount on the backend so "Popular"
  /// rankings and recommendations reflect real listening. Fire-and-forget —
  /// playback must never break because telemetry did — but failures are
  /// logged and reported, never swallowed.
  @override
  Future<void> scrobble(Map<String, dynamic> details) async {
    final id = (details["id"] ?? "").toString();
    if (id.isEmpty || !PaymentGatewayConfig.backendBaseUrl.isNotEmpty) return;
    try {
      _scrobbleClient ??= Dio(
        BaseOptions(
          baseUrl: PaymentGatewayConfig.backendBaseUrl,
          connectTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 6),
        ),
      );
      // Pass the listened/duration fields so the backend can distinguish
      // a real listen (counts toward playCount) from a skip.
      final listenedMs = (details["listenedMs"] as num?)?.toInt();
      final durationMs = (details["durationMs"] as num?)?.toInt();
      // Attach the backend JWT when one is already in memory (no login is
      // ever triggered from here) so play counts can be attributed; logged-
      // out devices keep scrobbling anonymously.
      final token = WalletApiClient.instance.sessionToken;
      await _scrobbleClient!.post(
        "/metadata/play/${Uri.encodeComponent(id)}",
        data: {
          if (listenedMs != null) "listenedMs": listenedMs,
          if (durationMs != null) "durationMs": durationMs,
          "source": "app",
        },
        options: token == null
            ? null
            : Options(headers: {"Authorization": "Bearer $token"}),
      );
    } catch (e, stack) {
      AppLogger.log.w('Scrobble failed for $id: ${e.toString()}');
      AppLogger.reportError(e, stack, 'NativeCore.scrobble $id');
    }
  }
}

class _NativeAudioSource extends MetadataPluginAudioSourceEndpoint {
  final YouTubeEngine youtubeEngine;
  final List<YouTubeEngine> allEngines;
  final _CatalogApi api;
  _NativeAudioSource(this.youtubeEngine, this.allEngines, this.api) : super();

  @override
  List<DeeMusiqAudioSourceContainerPreset> get supportedPresets => [
        DeeMusiqAudioSourceContainerPreset.lossy(
          type: DeeMusiqMediaCompressionType.lossy,
          name: "Audio",
          qualities: [
            DeeMusiqAudioLossyContainerQuality(bitrate: 320000),
            DeeMusiqAudioLossyContainerQuality(bitrate: 160000),
            DeeMusiqAudioLossyContainerQuality(bitrate: 128000),
            DeeMusiqAudioLossyContainerQuality(bitrate: 96000),
            DeeMusiqAudioLossyContainerQuality(bitrate: 64000),
            DeeMusiqAudioLossyContainerQuality(bitrate: 48000),
          ],
        ),
      ];

  @override
  Future<List<DeeMusiqAudioSourceMatchObject>> matches(
      DeeMusiqFullTrackObject track) async {
    // Offline build (no DEEMUSIQ_BACKEND_URL): a catalog track's signed URL
    // can never be re-minted, so report it unavailable immediately instead of
    // hammering an expired URL.
    if (!api.isConfigured &&
        _CatalogApi.isCatalogStreamUrl(track.externalUri)) {
      AppLogger.log.w(
        'Catalog track ${track.id} is unavailable: no DeeMusiq backend configured (offline build)',
      );
      return const [];
    }
    final uri = api.isCatalogStream(track.externalUri) && track.id.isNotEmpty
        ? "$_catalogPrefix${track.id}"
        : track.externalUri;
    if (uri.isNotEmpty && uri.startsWith(_ytPrefix)) {
      return [
        DeeMusiqAudioSourceMatchObject(
          id: track.id,
          title: track.name,
          artists: track.artists.map((a) => a.name).toList(),
          duration: Duration(milliseconds: track.durationMs),
          thumbnail: track.album.images.isNotEmpty
              ? track.album.images.first.url
              : null,
          externalUri: uri,
        ),
      ];
    }
    if (uri.startsWith(_urlPrefix) || uri.startsWith(_catalogPrefix)) {
      return [
        DeeMusiqAudioSourceMatchObject(
          id: track.id,
          title: track.name,
          artists: track.artists.map((a) => a.name).toList(),
          duration: Duration(milliseconds: track.durationMs),
          thumbnail: track.album.images.isNotEmpty
              ? track.album.images.first.url
              : null,
          externalUri: uri,
        ),
      ];
    }
    if (track.name.isEmpty) {
      AppLogger.log.w('Cannot search YouTube: track has no name (id: ${track.id})');
      return const [];
    }
    final searchQuery = StringBuffer(track.name);
    if (track.artists.isNotEmpty) {
      searchQuery.write(' ${track.artists.first.name}');
    }

    List<DeeMusiqAudioSourceMatchObject> toMatches(List<Video> videos) {
      return videos.where(ContentFilter.isPlayableSong).map((video) {
        return DeeMusiqAudioSourceMatchObject(
          id: video.id.value,
          title: video.title,
          artists: [video.author],
          duration: video.duration ?? Duration.zero,
          thumbnail: video.thumbnails.highResUrl.isNotEmpty
              ? video.thumbnails.highResUrl
              : null,
          externalUri: "$_ytPrefix${video.id.value}",
        );
      }).toList();
    }

    Future<List<Video>> searchWithFailover(String query) {
      return EngineFailover.tryEngines(
        engines: allEngines,
        operation: (engine) async {
          final results = await engine.searchVideos(query);
          return results.take(5).toList();
        },
        onRetry: (msg, attempt) {
          AppLogger.log.i('Engine retry: $msg (attempt $attempt)');
        },
      );
    }

    // ISRC-first: an ISRC search lands on the official upload (YouTube
    // Music / Topic) far more reliably than a free-text query.
    final isrc = track.isrc.trim();
    if (isrc.isNotEmpty) {
      try {
        final isrcMatches = toMatches(await searchWithFailover(isrc));
        if (isrcMatches.isNotEmpty) return isrcMatches;
        AppLogger.log.i(
          'ISRC search for "${track.name}" ($isrc) yielded no playable match — falling back to title search',
        );
      } catch (e, stack) {
        AppLogger.log.w(
          'ISRC search failed for "${track.name}" ($isrc): ${e.toString()} — falling back to title search',
        );
        AppLogger.reportError(e, stack);
      }
    }

    try {
      final videos = await searchWithFailover(searchQuery.toString());
      if (videos.isEmpty) return const [];
      return toMatches(videos);
    } catch (e, stack) {
      AppLogger.log.w(
        'YouTube fallback search failed for "${track.name}": ${e.toString()}',
      );
      AppLogger.reportError(e, stack);
      return const [];
    }
  }

  @override
  Future<List<DeeMusiqAudioSourceStreamObject>> streams(
      DeeMusiqAudioSourceMatchObject match) async {
    var uri = match.externalUri;
    if (uri.startsWith(_catalogPrefix) || api.isCatalogStream(uri)) {
      final id = uri.startsWith(_catalogPrefix)
          ? uri.substring(_catalogPrefix.length)
          : match.id;
      if (id.isEmpty) throw StateError('Missing catalog track ID');
      Map<String, dynamic>? track;
      try {
        track = await api.track(id);
      } catch (error, stack) {
        if (!_isBackendUnavailable(error)) rethrow;
        // The backend can't serve the signed stream URL right now (unreachable
        // at the network level, or the origin/edge is failing) — it cannot be
        // (re-)minted here, so degrade to a direct YouTube match for the same
        // song instead of failing the play. The cached catalog source is left
        // untouched, so the backend path resumes by itself once it answers.
        AppLogger.log.w(
          'Catalog backend unavailable for $id (${error.runtimeType}) — trying direct YouTube playback',
        );
        AppLogger.reportError(error, stack, 'Catalog unavailable YouTube fallback');
        final fallback = await _youtubeFallbackStreams(match);
        if (fallback.isNotEmpty) return fallback;
        rethrow;
      }
      if (track == null) {
        throw StateError(
          api.isConfigured
              ? 'Catalog unavailable'
              : 'Catalog track $id is unavailable: no DeeMusiq backend configured (offline build)',
        );
      }
      final streamUrl = track['streamUrl'] as String?;
      uri = streamUrl != null && streamUrl.isNotEmpty
          ? '$_urlPrefix$streamUrl'
          : _encodeSource(track['source'] as Map?);
      if (uri.isEmpty || uri == _urlPrefix || uri == _ytPrefix) {
        throw StateError('No audio source for catalog track $id');
      }
    }
    if (uri.startsWith(_ytPrefix)) {
      final videoId = uri.substring(_ytPrefix.length);
      try {
        // Fast path: try primary engine directly first (no failover overhead)
        StreamManifest manifest;
        try {
          manifest = await youtubeEngine.getStreamManifest(videoId)
              .timeout(const Duration(seconds: 15));
        } catch (e, stack) {
          AppLogger.log.i('Primary engine failed for $videoId, trying failover...');
          AppLogger.reportError(e, stack);
          manifest = await EngineFailover.tryEngines(
            engines: allEngines,
            operation: (engine) => engine.getStreamManifest(videoId),
            onRetry: (msg, attempt) {
              AppLogger.log.i('Engine retry: $msg (attempt $attempt)');
            },
          );
        }
        AppLogger.log.i(
          'Got manifest for $videoId: ${manifest.audioOnly.length} audio streams',
        );
        final filteredStreams = YouTubeAudioQualityService.filterStreams(
          manifest.audioOnly,
        );
        if (filteredStreams.isEmpty) {
          AppLogger.log.w(
            'All ${manifest.audioOnly.length} streams for $videoId were filtered out by quality settings',
          );
        }
        AppLogger.log.i(
          'Returning ${filteredStreams.length} streams for $videoId after quality filtering',
        );
        return filteredStreams
            .map(
              (s) => DeeMusiqAudioSourceStreamObject(
                url: s.url.toString(),
                container: s.container.name,
                type: DeeMusiqMediaCompressionType.lossy,
                bitrate: s.bitrate.bitsPerSecond.toDouble(),
              ),
            )
            .toList();
      } catch (e, stack) {
        if (e is EngineFailoverException) {
          AppLogger.log.w(
            'Engine failover exhausted for $videoId: ${e.message} — Errors: ${e.errors.join(" | ")}',
          );
        } else {
          AppLogger.log.w('Failed to get YouTube streams for $videoId: ${e.toString()}');
        }
        AppLogger.reportError(e, stack);

        // Self-healing: retry once more. The first attempt may have been
        // killed by yt-dlp component download timeout; the second attempt
        // succeeds because components are now cached.
        try {
          AppLogger.log.i('Retrying stream extraction for $videoId...');
          // A total extraction failure often means YouTube changed something
          // and the managed yt-dlp build is stale — pull the latest release
          // before the retry sweep (desktop only; no-op on Android where
          // yt-dlp engines are unavailable).
          if (allEngines.any((e) => e is YtDlpEngine || e is DirectYtDlpEngine)) {
            try {
              await YtDlpProvisioner.instance.resolveOrInstall(
                forceLatest: true,
              );
            } catch (updateErr, updateStack) {
              AppLogger.log.w('yt-dlp force-update before retry failed: $updateErr');
              AppLogger.reportError(updateErr, updateStack, 'yt-dlp escalation');
            }
          }
          final retryManifest = await EngineFailover.tryEngines(
            engines: allEngines,
            operation: (eng) => eng.getStreamManifest(videoId),
          );
          final retryStreams = YouTubeAudioQualityService.filterStreams(retryManifest.audioOnly);
          if (retryStreams.isNotEmpty) {
            AppLogger.log.i('Retry succeeded: ${retryStreams.length} streams for $videoId');
            return retryStreams
                .map((s) => DeeMusiqAudioSourceStreamObject(
                  url: s.url.toString(),
                  container: s.container.name,
                  type: DeeMusiqMediaCompressionType.lossy,
                  bitrate: s.bitrate.bitsPerSecond.toDouble(),
                ))
                .toList();
          }
        } catch (retryErr) {
          AppLogger.log.w('Retry also failed for $videoId: $retryErr');
        }
        return const [];
      }
    }
    if (uri.startsWith(_urlPrefix)) {
      final url = uri.substring(_urlPrefix.length);
      // Signed/proxied backend URLs carry no file extension — default to webm
      // (opus), the typical audio container, and let the player sniff.
      final ext = RegExp(r'\.([A-Za-z0-9]{2,5})(?:[?#]|$)')
              .firstMatch(url)
              ?.group(1)
              ?.toLowerCase() ??
          "webm";
      return [
        DeeMusiqAudioSourceStreamObject(
          url: url,
          container: ext,
          type: DeeMusiqMediaCompressionType.lossy,
        ),
      ];
    }
    return const [];
  }

  /// Last-resort fallback for a catalog track whose signed stream URL cannot
  /// be (re-)minted because the DeeMusiq backend is unreachable at the network
  /// level: find the same song on YouTube and stream it from there.
  ///
  /// Searches with the regular engine chain (title + artist, closest duration
  /// wins) and resolves the winner by routing a synthetic `ytsource:<videoId>`
  /// match back through [streams], so the existing fast-path/failover/
  /// self-heal chain applies unchanged. Returns an empty list when nothing
  /// playable is found — the caller then keeps the original offline error.
  Future<List<DeeMusiqAudioSourceStreamObject>> _youtubeFallbackStreams(
    DeeMusiqAudioSourceMatchObject match,
  ) async {
    final query = StringBuffer(match.title.trim());
    final artist = match.artists.isNotEmpty ? match.artists.first.trim() : '';
    if (artist.isNotEmpty) query.write(' $artist');
    if (query.isEmpty) return const [];

    List<Video> videos;
    try {
      videos = await youtubeEngine
          .searchVideos(query.toString())
          .timeout(const Duration(seconds: 15));
    } catch (e, stack) {
      AppLogger.log.w(
        'YouTube fallback search failed for "${query.toString()}": ${e.toString()}',
      );
      AppLogger.reportError(e, stack, 'YouTube fallback search');
      if (allEngines.isEmpty) return const [];
      try {
        videos = await EngineFailover.tryEngines(
          engines: allEngines,
          operation: (engine) => engine.searchVideos(query.toString()),
        );
      } catch (failoverError, failoverStack) {
        AppLogger.log.w('YouTube fallback search exhausted: $failoverError');
        AppLogger.reportError(
          failoverError,
          failoverStack,
          'YouTube fallback search',
        );
        return const [];
      }
    }

    final candidates =
        videos.where(ContentFilter.isPlayableSong).toList(growable: false);
    if (candidates.isEmpty) {
      AppLogger.log.w('YouTube fallback found no playable match for "$query"');
      return const [];
    }

    // Closest duration wins: the catalog video id is scrubbed from stream-mode
    // responses, so duration is the strongest signal available here.
    var best = candidates.first;
    if (match.duration > Duration.zero) {
      for (final candidate in candidates) {
        final candidateDuration = candidate.duration;
        if (candidateDuration == null) continue;
        if ((candidateDuration - match.duration).abs() <=
            const Duration(seconds: 30)) {
          best = candidate;
          break;
        }
      }
    }

    AppLogger.log.i(
      'Playing ${match.id} from YouTube ${best.id.value} (backend unreachable)',
    );
    final fallbackStreams = await streams(
      DeeMusiqAudioSourceMatchObject(
        id: best.id.value,
        title: best.title,
        artists: [best.author],
        duration: best.duration ?? match.duration,
        externalUri: '$_ytPrefix${best.id.value}',
      ),
    );
    if (fallbackStreams.isNotEmpty) {
      AudioErrorHandler.instance.notifyPlaybackFallback(
        'DeeMusiq servers unreachable — playing from YouTube',
      );
    }
    return fallbackStreams;
  }

}

/// Wires the native endpoints onto a [MetadataPlugin]-shaped object. Used by the
/// `MetadataPlugin.native` constructor.
class DeeMusiqNativeEndpoints {
  final _CatalogApi _api;
  late final MetadataAuthEndpoint auth = _NativeAuth();
  late final MetadataPluginAudioSourceEndpoint audioSource;
  late final MetadataPluginAlbumEndpoint album;
  late final MetadataPluginArtistEndpoint artist;
  late final MetadataPluginBrowseEndpoint browse;
  late final MetadataPluginSearchEndpoint search;
  late final MetadataPluginPlaylistEndpoint playlist = _NativePlaylist(_api);
  late final MetadataPluginTrackEndpoint track = _NativeTrack(_api);
  late final MetadataPluginUserEndpoint user = _NativeUser(_api);
  late final MetadataPluginCore core = _NativeCore();

  DeeMusiqNativeEndpoints(
    YouTubeEngine youtubeEngine,
    List<YouTubeEngine> allEngines, {
    Dio? catalogClient,
  }) : _api = _CatalogApi(catalogClient) {
    audioSource = _NativeAudioSource(youtubeEngine, allEngines, _api);
    search = _NativeSearch(_api, allEngines);

    final al = _NativeAlbum(_api);
    al.injectYouTube(youtubeEngine);
    album = al;

    final a = _NativeArtist(_api);
    a.injectYouTube(youtubeEngine);
    artist = a;

    final b = _NativeBrowse(_api);
    b.injectYouTube(allEngines);
    browse = b;
  }
}
