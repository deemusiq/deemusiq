import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart' as dio_lib;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';

import 'package:deemusiq/collections/fake.dart';
import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/metadata_plugin/audio_source/quality_presets.dart';
import 'package:deemusiq/provider/server/routes/playback.dart';
import 'package:deemusiq/provider/user_preferences/user_preferences_provider.dart';
import 'package:deemusiq/services/sourced_track/sourced_track.dart';

/// Writes a cache entry the way the playback proxy does: content-addressed
/// file name plus the `.deemusiq-<path hash>.json` metadata sidecar.
Future<File> writeCacheEntry(
  Directory dir, {
  required List<int> bytes,
  required String trackId,
  String sourceId = 'video-1',
  String extension = 'm4a',
  DateTime? modified,
  // Bytes actually written to disk; defaults to [bytes]. Pass different
  // content to simulate a corrupted cache entry.
  List<int>? diskBytes,
  bool withMetadata = true,
}) async {
  final hash = sha256.convert(bytes).toString();
  final file = File(p.join(dir.path, '$hash-$sourceId.$extension'));
  await file.create(recursive: true);
  await file.writeAsBytes(diskBytes ?? bytes);
  if (modified != null) await file.setLastModified(modified);
  if (withMetadata) {
    final pathHash =
        sha256.convert(utf8.encode(file.absolute.path)).toString();
    final metadata = File(p.join(dir.path, '.deemusiq-$pathHash.json'));
    await metadata.writeAsString(jsonEncode({
      'trackId': trackId,
      'sourceId': sourceId,
      'sha256': hash,
      'length': bytes.length,
      'totalLength': bytes.length,
    }));
  }
  return file;
}

class _FakeUserPreferencesNotifier extends UserPreferencesNotifier {
  @override
  PreferencesTableData build() =>
      PreferencesTable.defaults().copyWith(cacheMusic: false);
}

class _FakePresetsNotifier extends AudioSourceAvailableQualityPresetsNotifier {
  @override
  AudioSourcePresetsState build() => AudioSourcePresetsState(
        presets: [
          DeeMusiqAudioSourceContainerPreset.lossy(
            type: DeeMusiqMediaCompressionType.lossy,
            name: 'mp4',
            qualities: [DeeMusiqAudioLossyContainerQuality(bitrate: 128)],
          ),
        ],
      );
}

/// Hands out the container-backed [Ref] that SourcedTrack/ServerPlaybackRoutes
/// expect (a bare ProviderContainer is not itself a Ref in riverpod 2.5).
final _refProvider = Provider<Ref>((ref) => ref);

void main() {
  group('evictMusicCacheDir (monthly Top-50 tiering)', () {
    late Directory cacheDir;

    setUp(() async {
      cacheDir = await Directory.systemTemp.createTemp('dmq-top50-');
    });

    tearDown(() async {
      if (await cacheDir.exists()) await cacheDir.delete(recursive: true);
    });

    test('under the cap nothing is evicted', () async {
      final a = await writeCacheEntry(
        cacheDir,
        bytes: List.filled(400, 1),
        trackId: 'track-a',
      );
      await evictMusicCacheDir(
        cacheDir: cacheDir,
        pinnedTrackIds: const {},
        maxSizeBytes: 1000,
      );
      expect(await a.exists(), isTrue);
    });

    test('temporary files are cleaned even under the cap', () async {
      final part = File(p.join(cacheDir.path, '.m4a.part-123'));
      await part.writeAsBytes(List.filled(10, 0));
      await evictMusicCacheDir(
        cacheDir: cacheDir,
        pinnedTrackIds: const {},
        maxSizeBytes: 1000,
      );
      expect(await part.exists(), isFalse);
    });

    test('over the cap, pinned tracks survive and unpinned go LRU-first',
        () async {
      final base = DateTime(2026, 10, 1, 12);
      // Pinned and oldest — must still survive.
      final pinned = await writeCacheEntry(
        cacheDir,
        bytes: List.filled(400, 2),
        trackId: 'track-pinned',
        modified: base,
      );
      final pinnedMetadata = File(
        p.join(
          cacheDir.path,
          '.deemusiq-${sha256.convert(utf8.encode(pinned.absolute.path))}.json',
        ),
      );
      final old = await writeCacheEntry(
        cacheDir,
        bytes: List.filled(400, 3),
        trackId: 'track-old',
        modified: base.add(const Duration(hours: 1)),
      );
      final fresh = await writeCacheEntry(
        cacheDir,
        bytes: List.filled(400, 4),
        trackId: 'track-fresh',
        modified: base.add(const Duration(hours: 2)),
      );

      await evictMusicCacheDir(
        cacheDir: cacheDir,
        pinnedTrackIds: {'track-pinned'},
        maxSizeBytes: 1000,
      );

      // 1200 > 1000: evict until <= 800. The oldest unpinned file goes first,
      // the pinned file is untouchable despite being older.
      expect(await pinned.exists(), isTrue);
      expect(await pinnedMetadata.exists(), isTrue);
      expect(await old.exists(), isFalse);
      expect(await fresh.exists(), isTrue);
    });

    test('a track that falls out of the Top 50 becomes evictable', () async {
      final base = DateTime(2026, 10, 1, 12);
      final dropped = await writeCacheEntry(
        cacheDir,
        bytes: List.filled(400, 5),
        trackId: 'track-dropped',
        modified: base,
      );
      final kept = await writeCacheEntry(
        cacheDir,
        bytes: List.filled(400, 6),
        trackId: 'track-kept',
        modified: base.add(const Duration(hours: 1)),
      );
      final other = await writeCacheEntry(
        cacheDir,
        bytes: List.filled(400, 7),
        trackId: 'track-other',
        modified: base.add(const Duration(hours: 2)),
      );

      await evictMusicCacheDir(
        cacheDir: cacheDir,
        pinnedTrackIds: {'track-kept'},
        maxSizeBytes: 1000,
      );

      expect(await dropped.exists(), isFalse);
      expect(await kept.exists(), isTrue);
      expect(await other.exists(), isTrue);
    });

    test('when only pinned files remain the sweep stops instead of deleting',
        () async {
      final a = await writeCacheEntry(
        cacheDir,
        bytes: List.filled(400, 8),
        trackId: 'track-a',
      );
      final b = await writeCacheEntry(
        cacheDir,
        bytes: List.filled(400, 9),
        trackId: 'track-b',
      );

      await evictMusicCacheDir(
        cacheDir: cacheDir,
        pinnedTrackIds: {'track-a', 'track-b'},
        maxSizeBytes: 100,
      );

      expect(await a.exists(), isTrue);
      expect(await b.exists(), isTrue);
    });

    test('files without metadata are treated as unpinned', () async {
      final base = DateTime(2026, 10, 1, 12);
      final withMeta = await writeCacheEntry(
        cacheDir,
        bytes: List.filled(400, 10),
        trackId: 'track-known',
        modified: base,
      );
      final withoutMeta = await writeCacheEntry(
        cacheDir,
        bytes: List.filled(400, 11),
        trackId: 'track-unknown',
        modified: base.add(const Duration(hours: 1)),
        withMetadata: false,
      );

      await evictMusicCacheDir(
        cacheDir: cacheDir,
        pinnedTrackIds: {'track-known', 'track-unknown'},
        maxSizeBytes: 100,
      );

      expect(await withMeta.exists(), isTrue);
      expect(await withoutMeta.exists(), isFalse);
    });

    test('a missing cache directory is a no-op', () async {
      await cacheDir.delete(recursive: true);
      await evictMusicCacheDir(
        cacheDir: cacheDir,
        pinnedTrackIds: const {},
        maxSizeBytes: 100,
      );
      expect(await cacheDir.exists(), isFalse);
    });
  });

  group('pinned cache playback failover', () {
    const pathProviderChannel =
        MethodChannel('plugins.flutter.io/path_provider');

    late Directory appCacheDir;
    late Directory cacheDir;
    late HttpServer remoteServer;
    late List<int> remoteBytes;
    var remoteHits = 0;

    late ProviderContainer container;
    late ServerPlaybackRoutes routes;

    SourcedTrack buildTrack() {
      return SourcedTrack(
        ref: container.read(_refProvider),
        query: FakeData.track,
        info: DeeMusiqAudioSourceMatchObject(
          id: 'video-1',
          title: 'A good track',
          artists: const ['What an artist'],
          duration: const Duration(minutes: 3),
          externalUri: 'https://example.com/video-1',
        ),
        source: 'youtube',
        sources: [
          DeeMusiqAudioSourceStreamObject(
            url: 'http://127.0.0.1:${remoteServer.port}/audio',
            container: 'mp4',
            type: DeeMusiqMediaCompressionType.lossy,
            bitrate: 128,
          ),
        ],
        siblings: const [],
      );
    }

    Future<dio_lib.Response<dynamic>> stream(SourcedTrack track) async {
      final request = Request(
        'GET',
        Uri.parse('http://127.0.0.1/stream/${track.query.id}'),
      );
      final response = await routes.streamTrack(
        request,
        track,
        request.headers,
        siblingAttemptsLeft: 0,
      );
      if (response == null) {
        throw StateError('streamTrack returned no response');
      }
      return response;
    }

    Future<Uint8List> collect(Stream<List<int>> stream) async {
      final builder = BytesBuilder(copy: false);
      await for (final chunk in stream) {
        builder.add(chunk);
      }
      return builder.toBytes();
    }

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      // flutter_test installs an HttpOverrides that answers every request
      // with a synthetic 400 — these tests exercise the real loopback
      // failover path, so restore real networking.
      HttpOverrides.global = null;
      appCacheDir = await Directory.systemTemp.createTemp('dmq-appcache-');
      cacheDir = Directory(p.join(appCacheDir.path, 'cached_tracks'));
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pathProviderChannel, (call) async {
        if (call.method == 'getApplicationCacheDirectory') {
          return appCacheDir.path;
        }
        return null;
      });

      remoteBytes = List.generate(64 * 1024, (i) => (i * 7) % 251);
      remoteHits = 0;
      remoteServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      remoteServer.listen((request) async {
        remoteHits++;
        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType('audio', 'mp4')
          ..headers.contentLength = remoteBytes.length;
        if (request.method == 'GET') {
          request.response.add(remoteBytes);
        }
        await request.response.close();
      });

      container = ProviderContainer(overrides: [
        userPreferencesProvider.overrideWith(_FakeUserPreferencesNotifier.new),
        audioSourcePresetsProvider.overrideWith(_FakePresetsNotifier.new),
      ]);
      routes = ServerPlaybackRoutes(container.read(_refProvider));
    });

    tearDown(() async {
      container.dispose();
      await remoteServer.close(force: true);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pathProviderChannel, null);
      if (await appCacheDir.exists()) {
        await appCacheDir.delete(recursive: true);
      }
    });

    test('a corrupt pinned cache entry fails over to the remote stream',
        () async {
      final track = buildTrack();
      // Pinned entry for this (track, source): metadata is intact and names
      // the current track+source, but the bytes on disk don't match the
      // recorded hash — the local copy must be bypassed, not served.
      await writeCacheEntry(
        cacheDir,
        bytes: remoteBytes,
        trackId: track.query.id,
        sourceId: track.info.id,
        diskBytes: List.filled(remoteBytes.length, 0),
      );

      final response = await stream(track);
      expect(response.statusCode, 200);
      expect(remoteHits, greaterThanOrEqualTo(1));
      final body = await collect(
        (response.data as dio_lib.ResponseBody).stream,
      );
      expect(body, remoteBytes);
      expect(
        response.headers.value('x-deemusiq-cache-verified'),
        isNull,
      );
    });

    test('a missing cache entry streams remotely', () async {
      final track = buildTrack();
      final response = await stream(track);
      expect(response.statusCode, 200);
      expect(remoteHits, greaterThanOrEqualTo(1));
      final body = await collect(
        (response.data as dio_lib.ResponseBody).stream,
      );
      expect(body, remoteBytes);
    });

    test('a valid pinned entry plays fully offline (no network touched)',
        () async {
      final track = buildTrack();
      await writeCacheEntry(
        cacheDir,
        bytes: remoteBytes,
        trackId: track.query.id,
        sourceId: track.info.id,
      );

      final response = await stream(track);
      expect(response.statusCode, 200);
      // The cache hit bypasses the remote source entirely.
      expect(remoteHits, 0);
      expect(
        response.headers.value('x-deemusiq-cache-verified'),
        'true',
      );
      final body = await collect(response.data as Stream<List<int>>);
      expect(body, remoteBytes);
    });

    test('a cache entry from a different source does not shadow the current '
        'source', () async {
      final track = buildTrack();
      // Same track, cached under a DIFFERENT source id — the source-match
      // predicate must bypass it even though the track is pinned.
      await writeCacheEntry(
        cacheDir,
        bytes: List.filled(remoteBytes.length, 9),
        trackId: track.query.id,
        sourceId: 'video-old',
      );

      final response = await stream(track);
      expect(response.statusCode, 200);
      expect(remoteHits, greaterThanOrEqualTo(1));
      final body = await collect(
        (response.data as dio_lib.ResponseBody).stream,
      );
      expect(body, remoteBytes);
    });
  });
}
