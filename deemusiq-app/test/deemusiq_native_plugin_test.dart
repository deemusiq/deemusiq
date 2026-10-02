import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/services/metadata/deemusiq_native_plugin.dart';
import 'package:deemusiq/services/metadata/errors/exceptions.dart';
import 'package:deemusiq/services/youtube_engine/youtube_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class _UnusedEngine extends Fake implements YouTubeEngine {}

class _ConnectionRefusedAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
      error: 'Connection refused',
    );
  }

  @override
  void close({bool force = false}) {}
}

class _CatalogAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  Map<String, dynamic> response = {};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode(response),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Answers every request with a fixed HTTP status — the shape of an origin
/// that is failing behind the edge (502/503/504, Cloudflare 521–524).
class _ServerErrorAdapter implements HttpClientAdapter {
  _ServerErrorAdapter(this.statusCode);

  final int statusCode;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      '{"error":"origin down"}',
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Minimal [Video] stand-in carrying only what the direct-YouTube fallback
/// reads (id, title, author, duration, live flag).
class _FakeVideo extends Fake implements Video {
  @override
  final VideoId id;
  @override
  final String title;
  @override
  final String author = 'Artist';
  @override
  final Duration? duration;
  @override
  bool get isLive => false;

  _FakeVideo({
    required String id,
    required this.title,
    required this.duration,
  }) : id = VideoId(id);

  @override
  ChannelId get channelId => ChannelId('UCabcdefghijklmnopqrstuv');

  @override
  ThumbnailSet get thumbnails => ThumbnailSet(id.value);
}

/// Minimal [AudioOnlyStreamInfo] stand-in: url/container/bitrate are the only
/// members the resolver and the quality filter read.
class _FakeAudioStream extends Fake implements AudioOnlyStreamInfo {
  @override
  final Uri url;
  @override
  final StreamContainer container = StreamContainer.mp4;
  @override
  final Bitrate bitrate = const Bitrate(128000);

  _FakeAudioStream(String videoId)
      : url = Uri.parse('https://googlevideo.example/$videoId');
}

/// Engine that only knows how to resolve single videos by id — the shape the
/// album endpoint's YouTube fallback needs.
class _VideoLookupEngine extends Fake implements YouTubeEngine {
  final videoRequests = <String>[];
  final Map<String, Video> videos;

  _VideoLookupEngine(this.videos);

  @override
  bool get isAvailableForPlatform => true;

  @override
  Future<Video> getVideo(String videoId) async {
    videoRequests.add(videoId);
    final video = videos[videoId];
    if (video == null) throw StateError('no such video: $videoId');
    return video;
  }

  @override
  void dispose() {}
}

/// Search engine whose results deliberately put the wrong version first, so
/// the fallback's duration-proximity pick is actually exercised.
class _FallbackSearchEngine extends Fake implements YouTubeEngine {
  final searchedQueries = <String>[];
  final manifestRequests = <String>[];

  @override
  bool get isAvailableForPlatform => true;

  @override
  Future<bool> isInstalled() async => true;

  @override
  Future<List<Video>> searchVideos(String query) async {
    searchedQueries.add(query);
    return [
      _FakeVideo(
        id: 'dQw4w9WgXcQ',
        title: 'Song (live)',
        duration: const Duration(seconds: 240),
      ),
      _FakeVideo(
        id: 'jNQXAC9IVRw',
        title: 'Song',
        duration: const Duration(seconds: 185),
      ),
    ];
  }

  @override
  Future<StreamManifest> getStreamManifest(String videoId) async {
    manifestRequests.add(videoId);
    return StreamManifest([_FakeAudioStream(videoId)]);
  }

  @override
  void dispose() {}
}

/// Engine whose search always fails — the fallback must then keep the
/// original offline error instead of masking it.
class _FailingSearchEngine extends Fake implements YouTubeEngine {
  final searchedQueries = <String>[];

  @override
  bool get isAvailableForPlatform => true;

  @override
  Future<bool> isInstalled() async => true;

  @override
  Future<List<Video>> searchVideos(String query) async {
    searchedQueries.add(query);
    throw StateError('search down');
  }

  @override
  void dispose() {}
}

DeeMusiqFullTrackObject _track(String uri) => DeeMusiqFullTrackObject(
      id: 'catalog-1',
      name: 'Song',
      externalUri: uri,
      artists: const [],
      album: DeeMusiqSimpleAlbumObject(
        id: 'album-1',
        name: 'Album',
        externalUri: '',
        artists: const [],
        albumType: DeeMusiqAlbumType.single,
      ),
      durationMs: 1000,
      isrc: '',
      explicit: false,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _CatalogAdapter adapter;
  late DeeMusiqNativeEndpoints endpoints;
  const expired =
      'urlsource:https://catalog.example/metadata/audio/old-uri-id?e=1&s=expired';

  setUp(() async {
    // YouTube resolution reads the user's audio-quality preference from the
    // KV store — give it an initialized (empty) mock store.
    SharedPreferences.setMockInitialValues({});
    await KVStoreService.initialize();
    adapter = _CatalogAdapter();
    final client = Dio(BaseOptions(baseUrl: 'https://catalog.example'))
      ..httpClientAdapter = adapter;
    addTearDown(() => client.close(force: true));
    endpoints = DeeMusiqNativeEndpoints(
      _UnusedEngine(),
      [],
      catalogClient: client,
    );
  });

  test('signed catalog matches persist stable source info', () async {
    final match = (await endpoints.audioSource.matches(_track(expired))).single;
    final restored = DeeMusiqAudioSourceMatchObject.fromJson(
      jsonDecode(jsonEncode(match)) as Map<String, dynamic>,
    );
    expect(restored.id, 'catalog-1');
    expect(restored.externalUri, 'catalogsource:catalog-1');
    expect(adapter.requests, isEmpty);
  });

  test('repeated streams renew by catalog ID rather than cached URI', () async {
    final match = (await endpoints.audioSource.matches(_track(expired))).single;
    for (final signature in ['first', 'second']) {
      final url =
          'https://catalog.example/metadata/audio/catalog-1?e=99&s=$signature';
      adapter.response = {
        'source': {'type': 'url', 'url': url},
      };
      final streams = await endpoints.audioSource.streams(match);
      expect(streams.single.url, url);
      expect(streams.single.container, 'webm');
    }
    expect(adapter.requests.map((r) => r.path), [
      '/metadata/track/catalog-1',
      '/metadata/track/catalog-1',
    ]);
  });

  test('legacy signed source info renews using match ID', () async {
    final match = DeeMusiqAudioSourceMatchObject(
      id: 'catalog-1',
      title: 'Song',
      artists: const [],
      duration: const Duration(seconds: 1),
      externalUri: expired,
    );
    adapter.response = {'streamUrl': 'https://cdn.example/fresh.mp3'};
    expect((await endpoints.audioSource.streams(match)).single.url,
        'https://cdn.example/fresh.mp3');
    expect(adapter.requests.single.path, '/metadata/track/catalog-1');
  });

  test('missing renewed source does not replay the expired URI', () async {
    final match = (await endpoints.audioSource.matches(_track(expired))).single;
    await expectLater(endpoints.audioSource.streams(match), throwsStateError);
  });

  for (final url in [
    'https://cdn.example/song.mp3?e=1&s=direct',
    'https://other.example/metadata/audio/catalog-1?e=1&s=direct',
    'https://catalog.example/song.mp3?e=1&s=direct',
    'https://catalog.example/metadata/audio/catalog-1',
  ]) {
    test('noncatalog direct source stays unchanged: $url', () async {
      final match =
          (await endpoints.audioSource.matches(_track('urlsource:$url'))).single;
      expect(match.externalUri, 'urlsource:$url');
      expect((await endpoints.audioSource.streams(match)).single.url, url);
      expect(adapter.requests, isEmpty);
    });
  }

  test('YouTube matches retain their direct source', () async {
    final match = (await endpoints.audioSource.matches(
      _track('ytsource:video-1'),
    ))
        .single;
    expect(match.externalUri, 'ytsource:video-1');
    expect(adapter.requests, isEmpty);
  });

  test('offline build reports catalog tracks unavailable immediately',
      () async {
    // No catalogClient and no DEEMUSIQ_BACKEND_URL dart-define: the backend
    // is not configured, so a signed catalog URL can never be re-minted.
    final offlineEndpoints = DeeMusiqNativeEndpoints(_UnusedEngine(), []);
    final matches = await offlineEndpoints.audioSource.matches(_track(expired));
    expect(matches, isEmpty);
    expect(adapter.requests, isEmpty);
  });

  test('unreachable backend fails fast without retrying', () async {
    final failingAdapter = _ConnectionRefusedAdapter();
    final client = Dio(BaseOptions(baseUrl: 'https://catalog.example'))
      ..httpClientAdapter = failingAdapter;
    addTearDown(() => client.close(force: true));
    final offlineEndpoints = DeeMusiqNativeEndpoints(
      _UnusedEngine(),
      [],
      catalogClient: client,
    );

    final match = DeeMusiqAudioSourceMatchObject(
      id: 'catalog-1',
      title: 'Song',
      artists: const [],
      duration: const Duration(seconds: 1),
      externalUri: expired,
    );
    await expectLater(
      offlineEndpoints.audioSource.streams(match),
      throwsA(isA<CatalogOfflineException>()),
    );
    // Fail fast: exactly one attempt, no retry loop.
    expect(failingAdapter.requests, hasLength(1));
  });
  test('unreachable backend plays the track from YouTube directly', () async {
    final failingAdapter = _ConnectionRefusedAdapter();
    final client = Dio(BaseOptions(baseUrl: 'https://catalog.example'))
      ..httpClientAdapter = failingAdapter;
    addTearDown(() => client.close(force: true));
    final engine = _FallbackSearchEngine();
    final offlineEndpoints = DeeMusiqNativeEndpoints(
      engine,
      [engine],
      catalogClient: client,
    );

    final match = DeeMusiqAudioSourceMatchObject(
      id: 'catalog-1',
      title: 'Song',
      artists: const ['Artist'],
      duration: const Duration(seconds: 180),
      externalUri: expired,
    );

    final streams = await offlineEndpoints.audioSource.streams(match);

    expect(streams, hasLength(1));
    expect(streams.single.url, contains('jNQXAC9IVRw'));
    expect(streams.single.container, 'mp4');
    // Searched YouTube with title + artist...
    expect(engine.searchedQueries, ['Song Artist']);
    // ...and preferred the duration-closest hit over the first result.
    expect(engine.manifestRequests, ['jNQXAC9IVRw']);
    // Fail fast on the catalog call: exactly one attempt, no retry loop.
    expect(failingAdapter.requests, hasLength(1));
  });

  test('fallback that finds nothing keeps the offline error', () async {
    final failingAdapter = _ConnectionRefusedAdapter();
    final client = Dio(BaseOptions(baseUrl: 'https://catalog.example'))
      ..httpClientAdapter = failingAdapter;
    addTearDown(() => client.close(force: true));
    final engine = _FailingSearchEngine();
    final offlineEndpoints = DeeMusiqNativeEndpoints(
      engine,
      [],
      catalogClient: client,
    );

    final match = DeeMusiqAudioSourceMatchObject(
      id: 'catalog-1',
      title: 'Song',
      artists: const ['Artist'],
      duration: const Duration(seconds: 180),
      externalUri: expired,
    );

    await expectLater(
      offlineEndpoints.audioSource.streams(match),
      throwsA(isA<CatalogOfflineException>()),
    );
    expect(engine.searchedQueries, ['Song Artist']);
  });

  test('origin 5xx (edge down) falls back to direct YouTube playback',
      () async {
    final failingAdapter = _ServerErrorAdapter(503);
    final client = Dio(BaseOptions(baseUrl: 'https://catalog.example'))
      ..httpClientAdapter = failingAdapter;
    addTearDown(() => client.close(force: true));
    final engine = _FallbackSearchEngine();
    final offlineEndpoints = DeeMusiqNativeEndpoints(
      engine,
      [engine],
      catalogClient: client,
    );

    final streams = await offlineEndpoints.audioSource.streams(
      DeeMusiqAudioSourceMatchObject(
        id: 'catalog-1',
        title: 'Song',
        artists: const ['Artist'],
        duration: const Duration(seconds: 180),
        externalUri: expired,
      ),
    );

    expect(streams.single.url, contains('jNQXAC9IVRw'));
    expect(engine.searchedQueries, ['Song Artist']);
    // The catalog client retries 5xx before the fallback engages.
    expect(failingAdapter.requests, hasLength(3));
  });

  test('origin 4xx stays a semantic error — no YouTube fallback', () async {
    final failingAdapter = _ServerErrorAdapter(404);
    final client = Dio(BaseOptions(baseUrl: 'https://catalog.example'))
      ..httpClientAdapter = failingAdapter;
    addTearDown(() => client.close(force: true));
    final engine = _FallbackSearchEngine();
    final offlineEndpoints = DeeMusiqNativeEndpoints(
      engine,
      [engine],
      catalogClient: client,
    );

    await expectLater(
      offlineEndpoints.audioSource.streams(
        DeeMusiqAudioSourceMatchObject(
          id: 'catalog-1',
          title: 'Song',
          artists: const ['Artist'],
          duration: const Duration(seconds: 180),
          externalUri: expired,
        ),
      ),
      throwsA(isA<DioException>()),
    );
    expect(engine.searchedQueries, isEmpty);
  });

  group('search.all', () {
    DeeMusiqNativeEndpoints withEngine(
      YouTubeEngine engine,
      _CatalogAdapter searchAdapter,
    ) {
      final client = Dio(BaseOptions(baseUrl: 'https://catalog.example'))
        ..httpClientAdapter = searchAdapter;
      addTearDown(() => client.close(force: true));
      return DeeMusiqNativeEndpoints(engine, [engine], catalogClient: client);
    }

    test('tracks-only catalog miss keeps album/artist matches and backfills '
        'tracks from YouTube', () async {
      final searchAdapter = _CatalogAdapter();
      final engine = _FallbackSearchEngine();
      final searchEndpoints = withEngine(engine, searchAdapter);
      searchAdapter.response = {
        'tracks': <dynamic>[],
        'albums': [
          {
            'id': 'alb-1',
            'title': 'Catalog Album',
            'artist': {'id': 'art-1', 'name': 'Catalog Artist'},
          },
        ],
        'artists': [
          {'id': 'art-1', 'name': 'Catalog Artist'},
        ],
        'playlists': <dynamic>[],
      };

      final res = await searchEndpoints.search.all('amapiano');

      // The catalog matches survive the tracks-only miss...
      expect(res.albums.single.name, 'Catalog Album');
      expect(res.artists.single.name, 'Catalog Artist');
      // ...and tracks are backfilled from YouTube instead of the whole
      // response being replaced by the fallback.
      expect(res.tracks, isNotEmpty);
      expect(engine.searchedQueries, ['amapiano']);
    });

    test('valid catalog tracks skip the YouTube fallback entirely', () async {
      final searchAdapter = _CatalogAdapter();
      final engine = _FallbackSearchEngine();
      final searchEndpoints = withEngine(engine, searchAdapter);
      searchAdapter.response = {
        'tracks': [
          {
            'id': 't-1',
            'title': 'Catalog Song',
            'source': {'type': 'url', 'url': 'https://cdn.example/s.mp3'},
            'artist': {'id': 'art-1', 'name': 'Catalog Artist'},
          },
        ],
        'albums': <dynamic>[],
        'artists': [
          {'id': 'art-1', 'name': 'Catalog Artist'},
        ],
        'playlists': <dynamic>[],
      };

      final res = await searchEndpoints.search.all('song');

      expect(res.tracks.single.name, 'Catalog Song');
      expect(res.artists.single.name, 'Catalog Artist');
      expect(engine.searchedQueries, isEmpty);
    });

    test('fully empty catalog response keeps the plain YouTube fallback',
        () async {
      final searchAdapter = _CatalogAdapter();
      final engine = _FallbackSearchEngine();
      final searchEndpoints = withEngine(engine, searchAdapter);
      searchAdapter.response = {
        'tracks': <dynamic>[],
        'albums': <dynamic>[],
        'artists': <dynamic>[],
        'playlists': <dynamic>[],
      };

      final res = await searchEndpoints.search.all('no-such-thing');

      expect(res.albums, isEmpty);
      expect(res.artists, isEmpty);
      expect(res.playlists, isEmpty);
      expect(res.tracks, isNotEmpty);
      expect(engine.searchedQueries, ['no-such-thing']);
    });
  });

  group('album YouTube-id resolution', () {
    const videoId = 'dQw4w9WgXcQ';

    DeeMusiqNativeEndpoints withStatus(_VideoLookupEngine engine, int status) {
      final statusAdapter = _ServerErrorAdapter(status);
      final client = Dio(BaseOptions(baseUrl: 'https://catalog.example'))
        ..httpClientAdapter = statusAdapter;
      addTearDown(() => client.close(force: true));
      return DeeMusiqNativeEndpoints(engine, [engine], catalogClient: client);
    }

    _VideoLookupEngine engineWithVideo() => _VideoLookupEngine({
          videoId: _FakeVideo(
            id: videoId,
            title: 'Amapiano Mix',
            duration: const Duration(minutes: 3),
          ),
        });

    test('404 + yt:-prefixed id resolves to a single playable track',
        () async {
      final engine = engineWithVideo();
      final ep = withStatus(engine, 404);

      final page = await ep.album.tracks('yt:$videoId');

      expect(page.items, hasLength(1));
      expect(page.items.single.name, 'Amapiano Mix');
      expect(page.items.single.externalUri, 'ytsource:$videoId');
      expect(engine.videoRequests, [videoId]);
    });

    test('404 + yt:-prefixed id resolves getAlbum to a single-track album',
        () async {
      final engine = engineWithVideo();
      final ep = withStatus(engine, 404);

      final album = await ep.album.getAlbum('yt:$videoId');

      expect(album.name, 'Amapiano Mix');
      expect(album.totalTracks, 1);
      expect(album.artists.single.name, 'Artist');
      expect(engine.videoRequests, [videoId]);
    });

    test('404 + bare 11-char video id still resolves', () async {
      final engine = engineWithVideo();
      final ep = withStatus(engine, 404);

      final page = await ep.album.tracks(videoId);

      expect(page.items.single.externalUri, 'ytsource:$videoId');
      expect(engine.videoRequests, [videoId]);
    });

    test('genuine catalog 404 stays an empty page (no YouTube lookup)',
        () async {
      final engine = _VideoLookupEngine(const {});
      final ep = withStatus(engine, 404);

      final page = await ep.album.tracks('catalog-album-1');

      expect(page.items, isEmpty);
      expect(engine.videoRequests, isEmpty);
    });

    test('failed YouTube resolution on 404 falls back to an empty page',
        () async {
      final engine = _VideoLookupEngine(const {});
      final ep = withStatus(engine, 404);

      final page = await ep.album.tracks('yt:$videoId');

      expect(page.items, isEmpty);
      expect(engine.videoRequests, [videoId]);
    });

    test('non-404 catalog errors rethrow from album.tracks', () async {
      final engine = _VideoLookupEngine(const {});
      final ep = withStatus(engine, 503);

      await expectLater(
        ep.album.tracks('yt:$videoId'),
        throwsA(isA<DioException>()),
      );
      // A failing backend must not silently degrade into a YouTube lookup.
      expect(engine.videoRequests, isEmpty);
    });

    test('non-404 catalog errors rethrow from album.getAlbum', () async {
      final engine = _VideoLookupEngine(const {});
      final ep = withStatus(engine, 503);

      await expectLater(
        ep.album.getAlbum('yt:$videoId'),
        throwsA(isA<DioException>()),
      );
    });

    test('non-404 catalog errors rethrow from playlist.tracks', () async {
      final engine = _VideoLookupEngine(const {});
      final ep = withStatus(engine, 503);

      await expectLater(
        ep.playlist.tracks('playlist-1'),
        throwsA(isA<DioException>()),
      );
    });

    test('playlist.tracks keeps an empty page on 404', () async {
      final engine = _VideoLookupEngine(const {});
      final ep = withStatus(engine, 404);

      expect((await ep.playlist.tracks('playlist-1')).items, isEmpty);
    });
  });
}
