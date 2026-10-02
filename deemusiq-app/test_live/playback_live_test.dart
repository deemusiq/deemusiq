/// LIVE tests — these hit the real YouTube network and real loopback TCP
/// servers. They are intentionally NOT part of the CI gate (`flutter test`
/// only runs `test/`). Run explicitly:
///
///   flutter test test_live/
///
/// Requires internet access. Video id jNQXAC9IVRw is "Me at the zoo" — the
/// first YouTube upload, stable and always available.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/server/routes/playback.dart';
import 'package:deemusiq/services/connectivity/engine_failover.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/services/metadata/deemusiq_native_plugin.dart';
import 'package:deemusiq/services/youtube_engine/youtube_engine.dart';
import 'package:deemusiq/services/youtube_engine/youtube_explode_engine.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

const _knownVideoId = 'jNQXAC9IVRw';

class _AlwaysFailingEngine implements YouTubeEngine {
  @override
  bool get isAvailableForPlatform => true;
  @override
  Future<bool> isInstalled() async => true;
  @override
  Future<StreamManifest> getStreamManifest(String videoId) =>
      throw StateError('permanent test failure');
  @override
  Future<Video> getVideo(String videoId) =>
      throw StateError('permanent test failure');
  @override
  Future<(Video, StreamManifest)> getVideoWithStreamInfo(String videoId) =>
      throw StateError('permanent test failure');
  @override
  Future<List<Video>> searchVideos(String query) =>
      throw StateError('permanent test failure');
  @override
  Future<Channel?> resolveChannel(String idOrName) =>
      throw StateError('permanent test failure');
  @override
  void dispose() {}
}

/// Refuses every connection — the shape of an unreachable DeeMusiq backend.
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Live tests exist to hit the real network: flutter_test's default
  // HttpOverrides returns 400 for every request without making it.
  HttpOverrides.global = null;
  final dio = Dio();

  setUp(() async {
    // YouTube resolution reads the audio-quality preference from the KV store.
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
    await KVStoreService.initialize();
  });

  group('live: YouTube extraction', () {
    test('explode engine returns playable audio streams', () async {
      final engine = YouTubeExplodeEngine();
      final manifest = await engine
          .getStreamManifest(_knownVideoId)
          .timeout(const Duration(seconds: 60));

      expect(
        manifest.audioOnly,
        isNotEmpty,
        reason: 'no audio streams for $_knownVideoId',
      );

      final stream = manifest.audioOnly.first;
      final head = await dio.headUri(stream.url);
      expect(
        head.statusCode,
        lessThan(400),
        reason: 'stream URL rejected: ${head.statusCode}',
      );

      final chunk = await dio.getUri<List<int>>(
        stream.url,
        options: Options(
          headers: {'range': 'bytes=0-2047'},
          responseType: ResponseType.bytes,
        ),
      );
      expect(chunk.data?.length, greaterThan(0));
    }, timeout: const Timeout(Duration(seconds: 120)));

    test('explode search returns results', () async {
      final engine = YouTubeExplodeEngine();
      final results = await engine
          .searchVideos('me at the zoo')
          .timeout(const Duration(seconds: 60));
      expect(results, isNotEmpty);
    }, timeout: const Timeout(Duration(seconds: 90)));

    test('failover skips a dead engine and records metrics', () async {
      EngineMetrics.reset();
      final manifest = await EngineFailover.tryEngines(
        engines: [_AlwaysFailingEngine(), YouTubeExplodeEngine()],
        operation: (engine) => engine.getStreamManifest(_knownVideoId),
      ).timeout(const Duration(seconds: 180));

      expect(manifest.audioOnly, isNotEmpty);

      final stats = EngineMetrics.snapshot();
      final failing = stats['_AlwaysFailingEngine'];
      final explode = stats['YouTubeExplodeEngine'];
      expect(failing, isNotNull);
      expect(failing!.failures, greaterThan(0));
      expect(failing.successes, 0);
      expect(explode, isNotNull);
      expect(explode!.successes, greaterThan(0));
    }, timeout: const Timeout(Duration(seconds: 240)));
  });

  group('live: loopback stream resume over real TCP', () {
    test('resumableCheckedStream stitches across a real connection drop',
        () async {
      // 256 KiB body; the server destroys the first connection after 64 KiB
      // and honors Range on the follow-up request.
      final body = Uint8List.fromList(
        List.generate(256 * 1024, (i) => i % 251),
      );
      final expectedDigest = sha256.convert(body).toString();

      var firstConnectionDropped = false;
      final server = await HttpServer.bind('127.0.0.1', 0);
      addTearDown(() => server.close(force: true));

      server.listen((request) async {
        final rangeHeader = request.headers.value('range');
        if (rangeHeader == null && !firstConnectionDropped) {
          firstConnectionDropped = true;
          // Advertise the full length, deliver 64 KiB, then destroy the
          // socket — a real TCP abort mid-body. Headers are written through
          // the detached socket: detachSocket() is only legal before any
          // response bytes (including a flush) have been sent.
          final socket = await request.response.detachSocket();
          socket.write(
            'HTTP/1.1 200 OK\r\n'
            'Content-Length: ${body.length}\r\n'
            '\r\n',
          );
          socket.add(body.sublist(0, 64 * 1024));
          await socket.flush();
          socket.destroy(); // the client sees a dead stream
          return;
        }
        final match = RegExp(r'bytes=(\d+)-').firstMatch(rangeHeader ?? '');
        if (match == null) {
          request.response.statusCode = 400;
          await request.response.close();
          return;
        }
        final start = int.parse(match.group(1)!);
        request.response.statusCode = 206;
        request.response.headers.set(
          'content-range',
          'bytes $start-${body.length - 1}/${body.length}',
        );
        request.response.headers.set('content-length', '${body.length - start}');
        request.response.add(body.sublist(start));
        await request.response.close();
      });

      final url = 'http://127.0.0.1:${server.port}/audio.webm';
      final resumeDio = Dio();

      Future<Stream<Uint8List>> open({int? offset}) async {
        final res = await resumeDio.get<ResponseBody>(
          url,
          options: Options(
            responseType: ResponseType.stream,
            headers: {if (offset != null) 'range': 'bytes=$offset-'},
            // First request must see a 200 despite the drop; resumes are 206.
            validateStatus: (s) => s == 200 || s == 206,
          ),
        );
        return res.data!.stream;
      }

      final resumeEvents = <int>[];
      final collected = <int>[];
      await for (final chunk in resumableCheckedStream(
        await open(),
        expectedLength: body.length,
        expectedHash: expectedDigest,
        onResume: (received, attempt, error) => resumeEvents.add(received),
        reopen: (offset) => open(offset: offset),
      )) {
        collected.addAll(chunk);
      }

      expect(firstConnectionDropped, isTrue);
      expect(resumeEvents, isNotEmpty);
      expect(collected.length, body.length);
      expect(sha256.convert(collected).toString(), expectedDigest);
    }, timeout: const Timeout(Duration(seconds: 60)));
  });

  group('live: catalog backend unreachable', () {
    test('catalog track resolves and streams straight from YouTube',
        () async {
      final refused = Dio(BaseOptions(baseUrl: 'https://catalog.example'))
        ..httpClientAdapter = _ConnectionRefusedAdapter();
      addTearDown(() => refused.close(force: true));

      final engine = YouTubeExplodeEngine();
      final endpoints = DeeMusiqNativeEndpoints(
        engine,
        [engine],
        catalogClient: refused,
      );

      // A signed catalog URL that only the (unreachable) backend can re-mint.
      final match = DeeMusiqAudioSourceMatchObject(
        id: 'catalog-1',
        title: 'Never Gonna Give You Up',
        artists: const ['Rick Astley'],
        duration: const Duration(minutes: 3, seconds: 33),
        externalUri: 'urlsource:https://catalog.example/metadata/audio/'
            'catalog-1?e=1&s=expired',
      );

      final streams = await endpoints.audioSource
          .streams(match)
          .timeout(const Duration(seconds: 120));
      expect(streams, isNotEmpty, reason: 'no YouTube fallback streams');
      expect(streams.first.url, contains('googlevideo'));

      // The fallback URL must be playable right now, not just present.
      final head = await dio.headUri(Uri.parse(streams.first.url));
      expect(head.statusCode, lessThan(400));

      final chunk = await dio.getUri<List<int>>(
        Uri.parse(streams.first.url),
        options: Options(
          headers: {'range': 'bytes=0-2047'},
          responseType: ResponseType.bytes,
        ),
      );
      expect(chunk.data?.length, greaterThan(0));
    }, timeout: const Timeout(Duration(seconds: 180)));
  });
}
