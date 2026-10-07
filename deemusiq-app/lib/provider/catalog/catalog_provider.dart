import 'dart:convert';

import 'package:drift/drift.dart' show Value, InsertMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/database/database.dart';
import 'package:deemusiq/provider/metadata_plugin/metadata_plugin_provider.dart';
import 'package:deemusiq/provider/metadata_plugin/utils/common.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// The DeeMusiq catalog: the platform's own songs, each an UNLISTED YouTube
/// video served by the backend. Each row is mapped to a playable
/// [DeeMusiqFullTrackObject], and the app's source-match cache is SEEDED with
/// the unlisted videoId so the existing YouTube engine resolves it directly
/// (no title search, no plugin fork). After that, play / queue / download /
/// "Push this song" all work through the normal track widgets.
///
/// Cursor-paginated: [CatalogNotifier.fetchMore] appends the next page from
/// `nextCursor`; [CatalogNotifier.hasMore] drives the page's infinite list.
class CatalogNotifier
    extends AsyncNotifier<List<DeeMusiqFullTrackObject>> {
  static const int _pageSize = 50;

  String? _cursor;
  bool _hasMore = false;

  /// True while another backend page is available after the loaded items.
  bool get hasMore => _hasMore;

  @override
  Future<List<DeeMusiqFullTrackObject>> build() async {
    _cursor = null;
    _hasMore = false;
    return _loadPage(null);
  }

  /// Loads one backend page starting at [cursor] and maps it to tracks.
  Future<List<DeeMusiqFullTrackObject>> _loadPage(String? cursor) async {
    if (!WalletApiClient.instance.isConfigured) {
      throw StateError(
        'Catalog unavailable: backend is not configured. Rebuild the app with '
        '--dart-define=DEEMUSIQ_BACKEND_URL=<backend URL>.',
      );
    }

    final res = await WalletApiClient.instance
        .fetchCatalog(cursor: cursor, limit: _pageSize);
    final items = (res["items"] as List? ?? const []);
    _cursor = res["nextCursor"] as String?;
    _hasMore = _cursor != null && _cursor!.isNotEmpty;

    final db = ref.read(databaseProvider);
    final audioCfg = await ref.read(
      metadataPluginsProvider.selectAsync((d) => d.defaultAudioSourcePluginConfig),
    );

    final tracks = <DeeMusiqFullTrackObject>[];
    for (final raw in items) {
      final s = Map<String, dynamic>.from(raw as Map);
      final id = s["id"] as String;
      final title = s["title"] as String;
      final artist = s["artistName"] as String;
      final youtubeId = (s["youtubeId"] as String?) ?? "";
      // Backend "hide the source" mode: a short-lived signed play URL served by
      // the backend itself — neither YouTube nor any file host is exposed.
      final streamUrl = (s["streamUrl"] as String?) ?? "";
      final useStream = streamUrl.isNotEmpty;
      final cover = s["coverUrl"] as String?;
      final durationMs = (s["durationMs"] as int?) ?? 0;
      // Real catalog album linkage (when the backend feed carries it): tapping
      // the album opens the full album page. Loose tracks fall back to a
      // synthesized single-track shell, as before.
      final albumRef = s["album"] as Map?;
      final albumCover = (albumRef?["coverUrl"] as String?) ?? cover;
      final ytUri = useStream
          ? streamUrl
          : "https://www.youtube.com/watch?v=$youtubeId";
      final playUri = useStream ? "urlsource:$streamUrl" : "ytsource:$youtubeId";

      // Seed the source-match cache: trackId -> the exact unlisted videoId.
      // insertOrIgnore so we never clobber a user's sibling swap. Skipped in
      // stream mode: playback goes through the backend URL, not YouTube.
      if (!useStream && youtubeId.isNotEmpty && audioCfg != null) {
        final match = DeeMusiqAudioSourceMatchObject(
          id: youtubeId,
          title: title,
          artists: [artist],
          duration: Duration(milliseconds: durationMs),
          thumbnail: cover,
          externalUri: playUri,
        );
        await db.into(db.sourceMatchTable).insert(
              SourceMatchTableCompanion.insert(
                trackId: id,
                sourceInfo: Value(jsonEncode(match)),
                sourceType: audioCfg.slug,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }

      tracks.add(
        DeeMusiqTrackObject.full(
          id: id,
          name: title,
          externalUri: playUri,
          artists: [
            DeeMusiqSimpleArtistObject(
              id: (s["artistId"] as String?) ?? artist,
              name: artist,
              externalUri: "",
              images: null,
            ),
          ],
          album: DeeMusiqSimpleAlbumObject(
            albumType: albumRef != null
                ? DeeMusiqAlbumType.album
                : DeeMusiqAlbumType.single,
            artists: albumRef != null
                ? [
                    DeeMusiqSimpleArtistObject(
                      id: (s["artistId"] as String?) ?? artist,
                      name: artist,
                      externalUri: "",
                      images: null,
                    ),
                  ]
                : const [],
            externalUri: albumRef != null
                ? "deemusiq:album:${albumRef["id"]}"
                : ytUri,
            id: (albumRef?["id"] as String?) ?? id,
            name: (albumRef?["title"] as String?) ?? title,
            releaseDate: s["releaseDate"] as String?,
            images: albumCover != null
                ? [DeeMusiqImageObject(height: 300, width: 300, url: albumCover)]
                : const [],
          ),
          durationMs: durationMs,
          isrc: "",
          explicit: false,
        ) as DeeMusiqFullTrackObject,
      );
    }
    return tracks;
  }

  /// Appends the next catalog page. Best-effort: on error the previous state
  /// is kept so the list never blanks out mid-scroll, and [_hasMore] stays
  /// true — a transient failure must not silently truncate the catalog (the
  /// next edge touch retries the same cursor).
  Future<void> fetchMore() async {
    if (!_hasMore || state.isLoadingNextPage) return;
    final oldState = state.asData?.value;
    try {
      state = AsyncLoadingNext(
        oldState ?? const <DeeMusiqFullTrackObject>[],
      );
      final more = await _loadPage(_cursor);
      state = AsyncData(<DeeMusiqFullTrackObject>[
        ...?oldState,
        ...more,
      ]);
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'CatalogNotifier.fetchMore');
      if (oldState != null) state = AsyncData(oldState);
    }
  }

  /// Loads every remaining page (used by "download all" style actions).
  /// Stops when a page fails (cursor stops advancing) rather than spinning
  /// forever on a backend outage.
  Future<List<DeeMusiqFullTrackObject>> fetchAll() async {
    while (_hasMore) {
      final cursorBefore = _cursor;
      await fetchMore();
      if (_cursor == cursorBefore) break;
    }
    return state.value ?? const [];
  }
}

final catalogProvider =
    AsyncNotifierProvider<CatalogNotifier, List<DeeMusiqFullTrackObject>>(
  CatalogNotifier.new,
);
