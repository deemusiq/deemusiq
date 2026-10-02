import 'package:dio/dio.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/services/logger/logger.dart';

/// Third-party artist imagery for everyone — including users with no backend
/// account and builds with no backend configured at all.
///
/// Sources, in order:
/// 1. Deezer Search API — keyless, fast, and serves real artist photos from
///    `cdn-images.dzcdn.net`.
/// 2. iTunes Search API — keyless; artist artwork comes from their top
///    album's cover, upscaled via the well-known `artworkUrl100` rewrite.
///
/// Security: only HTTPS URLs on an explicit host allowlist are ever returned
/// (no userinfo, no exotic ports), so a hostile or broken upstream can never
/// turn the artist page into an SSRF/tracking vector. Results are cached in
/// the KV store for 7 days.
class ArtistInfoService {
  ArtistInfoService._();

  static final ArtistInfoService instance = ArtistInfoService._();

  static const _cacheTtl = Duration(days: 7);
  static const _cachePrefix = 'artist_img_v1_';

  /// Hosts we trust to serve artist images. Anything else is dropped.
  static const imageHostAllowlist = {
    // Deezer CDN
    'cdn-images.dzcdn.net',
    // Apple/iTunes CDN
    'mzstatic.com',
    // YouTube channel avatars / thumbnails
    'yt3.ggpht.com',
    'yt3.googleusercontent.com',
    'i.ytimg.com',
    // Wikimedia (Wikipedia images)
    'upload.wikimedia.org',
    // Last.fm CDN
    'lastfm.freetls.fastly.net',
  };

  /// Returns [url] when it is an HTTPS URL on the allowlist with no embedded
  /// credentials or non-default port, else null.
  static String? secureImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final uri = Uri.tryParse(url.trim());
    if (uri == null || uri.scheme != 'https') return null;
    if (!uri.hasAuthority || uri.host.isEmpty) return null;
    if (uri.userInfo.isNotEmpty) return null;
    if (uri.hasPort && uri.port != 443) return null;
    final host = uri.host.toLowerCase();
    final allowed = imageHostAllowlist.any(
      (allowed) => host == allowed || host.endsWith('.$allowed'),
    );
    return allowed ? uri.toString() : null;
  }

  final _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 6),
      receiveTimeout: const Duration(seconds: 6),
      // A plain browser UA — both APIs serve an empty/403 response to
      // default dart:io UAs on some edge nodes.
      headers: {'user-agent': 'DeeMusiq/1.1 (artist-info)'},
    ),
  );

  /// Returns a validated image URL for [artistName], or null. Fast path is
  /// the KV cache; otherwise Deezer first, iTunes as fallback.
  Future<String?> fetchArtistImage(String artistName) async {
    final name = artistName.trim();
    if (name.isEmpty) return null;

    final cacheKey = '$_cachePrefix${name.toLowerCase()}';
    try {
      final cached = KVStoreService.sharedPreferences.getString(cacheKey);
      if (cached != null) {
        final sep = cached.lastIndexOf('|');
        if (sep > 0) {
          final ts = int.tryParse(cached.substring(sep + 1)) ?? 0;
          final url = cached.substring(0, sep);
          final age = DateTime.now().millisecondsSinceEpoch - ts;
          if (age < _cacheTtl.inMilliseconds) {
            // Re-validate cached values: the allowlist may have tightened
            // since the entry was written.
            final safe = secureImageUrl(url);
            if (safe != null) return safe;
          }
        }
      }
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'ArtistInfoService cache read');
    }

    final url = await _fromDeezer(name) ?? await _fromItunes(name);
    final safe = secureImageUrl(url);
    if (safe == null) {
      if (url != null) {
        AppLogger.log.w('ArtistInfoService: rejected image URL for "$name"');
      }
      return null;
    }

    try {
      await KVStoreService.sharedPreferences.setString(
        cacheKey,
        '$safe|${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'ArtistInfoService cache write');
    }
    return safe;
  }

  Future<String?> _fromDeezer(String name) async {
    try {
      final res = await _dio.getUri<Map<String, dynamic>>(
        Uri.https('api.deezer.com', '/search/artist', {'q': name, 'limit': '5'}),
      );
      final artists = (res.data?['data'] as List?) ?? const [];
      if (artists.isEmpty) return null;

      // Prefer an exact name match; otherwise take the first (most popular)
      // hit that has a real photo.
      Map<String, dynamic>? pick;
      for (final a in artists.whereType<Map>()) {
        final map = a.cast<String, dynamic>();
        final artistName = (map['name'] ?? '').toString();
        final picture = (map['picture_xl'] ?? map['picture_big'] ?? '')
            .toString();
        if (picture.isEmpty) continue;
        if (artistName.toLowerCase() == name.toLowerCase()) {
          pick = map;
          break;
        }
        pick ??= map;
      }
      final picture = pick?['picture_xl'] ?? pick?['picture_big'];
      return picture?.toString();
    } catch (e, stack) {
      AppLogger.log.w('ArtistInfoService: Deezer lookup failed for "$name": $e');
      AppLogger.reportError(e, stack, 'ArtistInfoService Deezer');
      return null;
    }
  }

  Future<String?> _fromItunes(String name) async {
    try {
      // Artists themselves carry no artwork in the iTunes Search API; their
      // top album's cover is the accepted stand-in.
      final res = await _dio.getUri<Map<String, dynamic>>(
        Uri.https('itunes.apple.com', '/search', {
          'term': name,
          'entity': 'album',
          'attribute': 'artistTerm',
          'limit': '5',
        }),
      );
      final results = (res.data?['results'] as List?) ?? const [];
      for (final item in results.whereType<Map>()) {
        final map = item.cast<String, dynamic>();
        final artistName = (map['artistName'] ?? '').toString();
        final artwork = (map['artworkUrl100'] ?? '').toString();
        if (artwork.isEmpty) continue;
        if (!artistName.toLowerCase().contains(name.toLowerCase()) &&
            !name.toLowerCase().contains(artistName.toLowerCase())) {
          continue;
        }
        // 100x100 → 600x600 via Apple's documented size-token rewrite.
        return artwork.replaceFirst('100x100bb', '600x600bb');
      }
      return null;
    } catch (e, stack) {
      AppLogger.log.w('ArtistInfoService: iTunes lookup failed for "$name": $e');
      AppLogger.reportError(e, stack, 'ArtistInfoService iTunes');
      return null;
    }
  }
}
