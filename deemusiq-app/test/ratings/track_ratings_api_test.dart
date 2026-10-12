import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deemusiq/services/ratings/track_ratings_api.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// Answers requests with canned JSON (or a fixed status) and records them so
/// tests can assert method / path / headers / body.
class _RatingsAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  int statusCode = 200;
  Map<String, dynamic> Function(RequestOptions options)? handler;
  DioException? transportError;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final error = transportError;
    if (error != null) throw error;
    final body = handler?.call(options) ?? <String, dynamic>{};
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<Map<String, dynamic>> _sentJsonBody(RequestOptions options) async {
  // Dio JSON-encodes the body before the adapter sees it — decode the stream.
  final stream = options.data is Stream
      ? options.data as Stream<Uint8List>
      : null;
  if (stream == null) {
    final data = options.data;
    if (data is Map<String, dynamic>) return data;
    if (data is String) return jsonDecode(data) as Map<String, dynamic>;
    return <String, dynamic>{};
  }
  final chunks = await stream.fold<List<int>>([], (a, b) => a..addAll(b));
  return jsonDecode(utf8.decode(chunks)) as Map<String, dynamic>;
}

void main() {
  late _RatingsAdapter adapter;
  late Dio client;
  late TrackRatingsApi api;

  setUp(() {
    adapter = _RatingsAdapter();
    client = Dio(BaseOptions(baseUrl: 'https://ratings.example'))
      ..httpClientAdapter = adapter;
    addTearDown(() => client.close(force: true));
    api = TrackRatingsApi(client: client, authToken: () async => 'test-token');
  });

  test('rate sends PUT with the wire value and parses rating + stats', () async {
    adapter.handler = (options) => {
          'ok': true,
          'rating': 'like',
          'stats': {'likes': 9, 'dislikes': 1, 'total': 10, 'likeRatio': 0.9},
        };

    final outcome = await api.rate('track-1', TrackRatingValue.like);

    final request = adapter.requests.single;
    expect(request.method, 'PUT');
    expect(request.path, '/ratings/track-1');
    expect(request.headers['Authorization'], 'Bearer test-token');
    expect(await _sentJsonBody(request), {'value': 'like'});

    expect(outcome.rating, TrackRatingValue.like);
    expect(outcome.stats.likes, 9);
    expect(outcome.stats.dislikes, 1);
    expect(outcome.stats.total, 10);
    expect(outcome.stats.likeRatio, 0.9);
    expect(outcome.stats.likePercent, 90);
  });

  test('remove sends DELETE and parses the cleared rating', () async {
    adapter.handler = (options) => {
          'ok': true,
          'rating': null,
          'stats': {'likes': 8, 'dislikes': 1, 'total': 9, 'likeRatio': 0.8889},
        };

    final outcome = await api.remove('track-1');

    final request = adapter.requests.single;
    expect(request.method, 'DELETE');
    expect(request.path, '/ratings/track-1');
    expect(request.headers['Authorization'], 'Bearer test-token');
    expect(outcome.rating, isNull);
    expect(outcome.stats.total, 9);
  });

  test('mine maps the ratings list and skips unknown values', () async {
    adapter.handler = (options) => {
          'ratings': [
            {'trackId': 'a', 'rating': 'like', 'updatedAt': '2026-10-01'},
            {'trackId': 'b', 'rating': 'dislike', 'updatedAt': '2026-10-01'},
            // Forward compatibility: a newer backend's new value must not
            // break the parse of everything else.
            {'trackId': 'c', 'rating': 'love', 'updatedAt': '2026-10-01'},
          ],
        };

    final mine = await api.mine();

    expect(adapter.requests.single.path, '/ratings/mine');
    expect(mine, {
      'a': TrackRatingValue.like,
      'b': TrackRatingValue.dislike,
    });
  });

  test('stats parses aggregate counters and myRating', () async {
    adapter.handler = (options) => {
          'trackId': 't9',
          'likes': 4,
          'dislikes': 4,
          'total': 8,
          'likeRatio': 0.5,
          'myRating': 'dislike',
        };

    final snapshot = await api.stats('t9');

    expect(adapter.requests.single.path, '/ratings/t9');
    expect(snapshot.stats.likes, 4);
    expect(snapshot.myRating, TrackRatingValue.dislike);
  });

  test('batch maps the keyed stats map', () async {
    adapter.handler = (options) => {
          'stats': {
            'a': {'likes': 1, 'dislikes': 0, 'total': 1, 'likeRatio': 1.0},
            'b': {'likes': 0, 'dislikes': 3, 'total': 3, 'likeRatio': 0.0},
          },
        };

    final stats = await api.batch(['a', 'b']);

    final request = adapter.requests.single;
    expect(request.method, 'POST');
    expect(request.path, '/ratings/batch');
    expect(await _sentJsonBody(request), {
      'trackIds': ['a', 'b'],
    });
    expect(stats['a']?.likeRatio, 1.0);
    expect(stats['b']?.dislikes, 3);
  });

  test('batch refuses more than 100 ids without hitting the network', () async {
    await expectLater(
      api.batch(List.generate(101, (i) => 't$i')),
      throwsA(isA<WalletApiException>().having(
        (e) => e.code,
        'code',
        'too_many_track_ids',
      )),
    );
    expect(adapter.requests, isEmpty);
  });

  test('trending parses the nested catalog DTO plus rating block', () async {
    adapter.handler = (options) => {
          'window': {'days': 7},
          'items': [
            {
              'id': 't1',
              'title': 'Heat',
              'artist': {'id': 'a1', 'name': 'Dee'},
              'album': {'id': 'al1', 'title': 'Singles'},
              'durationMs': 181000,
              'coverUrl': 'https://img.example/t1.jpg',
              'explicit': true,
              'releaseDate': '2026-09-01',
              'source': {'type': 'youtube', 'youtubeId': 'yt-1'},
              'rating': {'likes': 87, 'dislikes': 13, 'total': 100, 'likeRatio': 0.87},
            },
          ],
        };

    final items = await api.trending();

    expect(adapter.requests.single.uri.queryParameters['limit'], '30');
    final item = items.single;
    expect(item.id, 't1');
    expect(item.title, 'Heat');
    expect(item.artistId, 'a1');
    expect(item.artistName, 'Dee');
    expect(item.albumTitle, 'Singles');
    expect(item.youtubeId, 'yt-1');
    expect(item.explicit, isTrue);
    expect(item.rating?.likePercent, 87);
  });

  test('topTracks hits /catalog?sort=top and parses the flat feed shape',
      () async {
    adapter.handler = (options) => {
          'items': [
            {
              'id': 'c1',
              'title': 'Flat Song',
              'artistId': 'a2',
              'artistName': 'Flat Artist',
              'youtubeId': 'yt-2',
              'coverUrl': null,
              'durationMs': 200000,
              'releaseDate': '2026-08-01',
              'rating': {'likes': 5, 'dislikes': 5, 'total': 10, 'likeRatio': 0.5},
            },
          ],
        };

    final items = await api.topTracks();

    final request = adapter.requests.single;
    expect(request.path, '/catalog');
    expect(request.uri.queryParameters['sort'], 'top');
    final item = items.single;
    expect(item.artistName, 'Flat Artist');
    expect(item.artistId, 'a2');
    expect(item.youtubeId, 'yt-2');
    expect(item.rating?.total, 10);
    // The flat feed round-trips into the shared catalog mapper's input shape.
    expect(item.toFeedJson(), {
      'id': 'c1',
      'title': 'Flat Song',
      'artistId': 'a2',
      'artistName': 'Flat Artist',
      'youtubeId': 'yt-2',
      'durationMs': 200000,
      'releaseDate': '2026-08-01',
    });
  });

  test('server error surfaces code and status, not a raw DioException',
      () async {
    adapter.statusCode = 400;
    adapter.handler = (options) => {'error': 'invalid_value'};

    await expectLater(
      api.rate('t1', TrackRatingValue.like),
      throwsA(isA<WalletApiException>()
          .having((e) => e.code, 'code', 'invalid_value')
          .having((e) => e.statusCode, 'statusCode', 400)
          .having((e) => e.isConnectivity, 'isConnectivity', isFalse)),
    );
  });

  test('transport failure is flagged as connectivity', () async {
    adapter.transportError = DioException(
      requestOptions: RequestOptions(path: '/ratings/t1'),
      type: DioExceptionType.connectionError,
      error: 'Connection refused',
    );

    await expectLater(
      api.rate('t1', TrackRatingValue.like),
      throwsA(isA<WalletApiException>()
          .having((e) => e.isConnectivity, 'isConnectivity', isTrue)),
    );
  });

  test('malformed success payloads raise a typed invalid-response error',
      () async {
    adapter.handler = (options) => {'ok': true}; // no stats block

    await expectLater(
      api.rate('t1', TrackRatingValue.dislike),
      throwsA(isA<WalletApiException>().having(
        (e) => e.code,
        'code',
        'ratings_invalid_response',
      )),
    );
    await expectLater(
      api.trending(),
      throwsA(isA<WalletApiException>().having(
        (e) => e.code,
        'code',
        'ratings_invalid_response',
      )),
    );
  });

  test('unconfigured client reports isConfigured false', () {
    // No injected client and no DEEMUSIQ_BACKEND_URL dart-define in tests.
    expect(TrackRatingsApi().isConfigured, isFalse);
    expect(api.isConfigured, isTrue);
  });
}
