import 'dart:io';
import 'dart:typed_data';

import 'package:deemusiq/extensions/dio.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes sha256 metadata headers', () {
    final hash = List.filled(64, 'a').join();
    expect(normalizeSha256('sha256:$hash'), hash);
    expect(normalizeSha256('"${hash.toUpperCase()}"'), hash);
  });

  test('chunk download reassembles only verified parts', () async {
    final directory = await Directory.systemTemp.createTemp('deemusiq-chunk-');
    addTearDown(() => directory.delete(recursive: true));
    final target = File('${directory.path}/track.bin');
    final payload = List<int>.generate(37, (index) => index);
    final adapter = _RangeAdapter(payload);
    final dio = Dio()..httpClientAdapter = adapter;

    final response = await dio.chunkDownload(
      'https://example.test/audio',
      target.path,
      connections: 4,
    );

    expect(response.statusCode, 200);
    expect(await target.readAsBytes(), payload);
    expect(adapter.rangeRequests.length, 4);
    expect(
      directory
          .listSync()
          .whereType<Directory>()
          .where((entity) => entity.path.contains('.chunk-')),
      isEmpty,
    );
  });

  test('chunk download propagates a part failure and never promotes data',
      () async {
    final directory = await Directory.systemTemp.createTemp('deemusiq-chunk-');
    addTearDown(() => directory.delete(recursive: true));
    final target = File('${directory.path}/track.bin');
    await target.writeAsBytes(const [7, 8, 9]);
    final adapter =
        _RangeAdapter(List<int>.generate(32, (index) => index), failPart: 2);
    final dio = Dio()..httpClientAdapter = adapter;

    await expectLater(
      dio.chunkDownload(
        'https://example.test/audio',
        target.path,
        connections: 4,
      ),
      throwsA(isA<DioException>()),
    );

    expect(await target.readAsBytes(), const [7, 8, 9]);
    expect(
      directory
          .listSync()
          .whereType<Directory>()
          .where((entity) => entity.path.contains('.chunk-')),
      isEmpty,
    );
  });

  test('chunk download rejects an incorrect Content-Range', () async {
    final directory = await Directory.systemTemp.createTemp('deemusiq-chunk-');
    addTearDown(() => directory.delete(recursive: true));
    final target = File('${directory.path}/track.bin');
    final adapter = _RangeAdapter(
      List<int>.generate(32, (index) => index),
      corruptRangeForPart: 1,
    );
    final dio = Dio()..httpClientAdapter = adapter;

    await expectLater(
      dio.chunkDownload(
        'https://example.test/audio',
        target.path,
        connections: 4,
      ),
      throwsA(isA<ChunkDownloadException>()),
    );
    expect(await target.exists(), isFalse);
  });
}

class _RangeAdapter implements HttpClientAdapter {
  final List<int> payload;
  final int? failPart;
  final int? corruptRangeForPart;
  final List<String> rangeRequests = [];

  _RangeAdapter(
    this.payload, {
    this.failPart,
    this.corruptRangeForPart,
  });

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final method = options.method.toUpperCase();
    final range = _header(options, 'range');
    if (method == 'HEAD') {
      return ResponseBody.fromBytes(
        const [],
        206,
        headers: {
          'content-range': ['bytes 0-0/${payload.length}'],
          'content-length': ['1'],
          'accept-ranges': ['bytes'],
          'etag': ['"fixture"'],
        },
      );
    }
    if (range == null || !range.startsWith('bytes=')) {
      throw StateError('Missing range');
    }
    final pieces = range.substring('bytes='.length).split('-');
    final start = int.parse(pieces[0]);
    final end = int.parse(pieces[1]);
    rangeRequests.add(range);
    final part = start ~/ ((payload.length / 4).ceil());
    if (failPart == part) {
      return ResponseBody.fromBytes(
        const [],
        500,
        headers: {
          'content-length': ['0']
        },
      );
    }
    final actualEnd = end.clamp(0, payload.length - 1);
    final bytes = payload.sublist(start, actualEnd + 1);
    final rangeStart = part == corruptRangeForPart ? start + 1 : start;
    return ResponseBody.fromBytes(
      bytes,
      206,
      headers: {
        'content-range': ['bytes $rangeStart-$actualEnd/${payload.length}'],
        'content-length': ['${bytes.length}'],
        'etag': ['"fixture"'],
      },
    );
  }

  String? _header(RequestOptions options, String name) {
    for (final entry in options.headers.entries) {
      if (entry.key.toLowerCase() == name.toLowerCase()) {
        return entry.value.toString();
      }
    }
    return null;
  }

  @override
  void close({bool force = false}) {}
}
