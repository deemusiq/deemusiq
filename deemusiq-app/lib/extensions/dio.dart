import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';

String? sha256FromHeaders(Headers headers) {
  const names = [
    'x-content-sha256',
    'content-sha256',
    'x-sha256',
    'x-checksum-sha256',
    'x-amz-meta-sha256',
    'x-amz-checksum-sha256',
    'x-goog-hash',
    'x-goog-content-hash',
    'x-ms-content-sha256',
    'content-digest',
    'digest',
  ];
  for (final name in names) {
    final value = headers.value(name);
    final normalized = normalizeSha256(value);
    if (normalized != null) return normalized;
  }
  return null;
}

String? normalizeSha256(String? value) {
  if (value == null) return null;
  var candidate = value.trim();
  if (candidate.isEmpty) return null;
  if (candidate.length >= 2 &&
      (candidate.startsWith('"') || candidate.startsWith("'"))) {
    candidate = candidate.substring(1, candidate.length - 1).trim();
  }
  final labelled = RegExp(
    r'(?:sha-?256|x-content-sha256|content-sha256)\s*[:=]\s*([^\s,;]+)',
    caseSensitive: false,
  ).firstMatch(candidate);
  if (labelled != null) candidate = labelled.group(1)!;
  candidate = candidate.replaceAll(RegExp(r'^[:=]+|[:=]+$'), '');
  if (RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(candidate)) {
    return candidate.toLowerCase();
  }
  try {
    final decoded = base64Decode(candidate);
    if (decoded.length == 32) {
      return decoded
          .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
          .join();
    }
  } catch (_) {}
  return null;
}

class ChunkDownloadException implements Exception {
  final String message;

  ChunkDownloadException(this.message);

  @override
  String toString() => 'ChunkDownloadException: $message';
}

extension ChunkDownloaderDioExtension on Dio {
  Future<Response> chunkDownload(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    FileAccessMode fileAccessMode = FileAccessMode.write,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
    int connections = 4,
    Duration maxDuration = const Duration(minutes: 30),
  }) async {
    final targetFile = File(savePath.toString());
    final targetDirectory = targetFile.parent;
    await targetDirectory.create(recursive: true);
    final temporaryDirectory = Directory(
      join(
        targetDirectory.path,
        '.${basename(targetFile.path)}.chunk-${_uniqueToken()}',
      ),
    );
    await temporaryDirectory.create(recursive: true);

    // Overall deadline: the per-request timeouts don't bound the WHOLE
    // download (probe + N range parts + assembly), so a stalled mirror could
    // hang a task slot forever. Cancel the caller's token when exceeded.
    final deadline = Timer(maxDuration, () {
      if (cancelToken != null && !cancelToken.isCancelled) {
        cancelToken.cancel(
          'Download exceeded the ${maxDuration.inMinutes}-minute limit',
        );
      }
    });

    try {
      final probe = await _probeDownload(
        urlPath,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        lengthHeader: lengthHeader,
      );

      final requestedConnections = max(connections, 1);
      if (!probe.supportsRange ||
          requestedConnections <= 1 ||
          fileAccessMode == FileAccessMode.append) {
        return await _downloadAndPromote(
          urlPath,
          targetFile,
          temporaryDirectory,
          probe: probe,
          onReceiveProgress: onReceiveProgress,
          queryParameters: queryParameters,
          cancelToken: cancelToken,
          fileAccessMode: fileAccessMode,
          lengthHeader: lengthHeader,
          data: data,
          options: options,
        );
      }

      return await _downloadRangesAndPromote(
        urlPath,
        targetFile,
        temporaryDirectory,
        probe: probe,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        lengthHeader: lengthHeader,
        data: data,
        options: options,
        connections: requestedConnections,
      );
    } catch (error, stackTrace) {
      if (deleteOnError) await _deleteQuietly(temporaryDirectory);
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      deadline.cancel();
      await _deleteQuietly(temporaryDirectory);
    }
  }

  Future<_DownloadProbe> _probeDownload(
    String urlPath, {
    required Map<String, dynamic>? queryParameters,
    required CancelToken? cancelToken,
    required Options? options,
    required String lengthHeader,
  }) async {
    Response? headResponse;
    try {
      headResponse = await head(
        urlPath,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: _requestOptions(
          options,
          responseType: ResponseType.bytes,
          headers: const {'Range': 'bytes=0-0'},
        ),
      );
    } catch (_) {}

    if (headResponse != null) {
      final status = headResponse.statusCode;
      if (status == 206) {
        final range =
            _parseContentRange(headResponse.headers.value('content-range'));
        if (range == null ||
            range.start != 0 ||
            range.end != 0 ||
            range.total <= range.end ||
            (_optionalLength(
                        headResponse.headers, Headers.contentLengthHeader) !=
                    null &&
                _optionalLength(
                        headResponse.headers, Headers.contentLengthHeader) !=
                    1)) {
          throw ChunkDownloadException(
            'Invalid range response while probing $urlPath',
          );
        }
        return _DownloadProbe(
          totalLength: range.total,
          supportsRange: true,
          sha256: sha256FromHeaders(headResponse.headers),
          etag: _headerValue(headResponse.headers, 'etag'),
        );
      }
      if (status == 200) {
        final total = _optionalLength(headResponse.headers, lengthHeader);
        if (total != null && total > 1) {
          return _DownloadProbe(
            totalLength: total,
            supportsRange: _acceptsRanges(headResponse.headers),
            sha256: sha256FromHeaders(headResponse.headers),
            etag: _headerValue(headResponse.headers, 'etag'),
          );
        }
      }
    }

    Response<ResponseBody> probeResponse;
    try {
      probeResponse = await get<ResponseBody>(
        urlPath,
        data: null,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: _requestOptions(
          options,
          responseType: ResponseType.stream,
          headers: const {'Range': 'bytes=0-0'},
        ),
      );
    } catch (_) {
      return const _DownloadProbe(
        totalLength: null,
        supportsRange: false,
        sha256: null,
        etag: null,
      );
    }

    final status = probeResponse.statusCode;
    if (status == 206) {
      final range = _parseContentRange(
        probeResponse.headers.value('content-range'),
      );
      final bodyLength = _optionalLength(
        probeResponse.headers,
        Headers.contentLengthHeader,
      );
      if (range == null ||
          range.start != 0 ||
          range.end != 0 ||
          range.total <= 0 ||
          bodyLength != 1) {
        throw ChunkDownloadException(
          'Invalid range response while probing $urlPath',
        );
      }
      await probeResponse.data!.stream.drain<void>();
      return _DownloadProbe(
        totalLength: range.total,
        supportsRange: true,
        sha256: sha256FromHeaders(probeResponse.headers),
        etag: _headerValue(probeResponse.headers, 'etag'),
      );
    }

    if (status == 200 && probeResponse.data != null) {
      final total = _optionalLength(probeResponse.headers, lengthHeader);
      await probeResponse.data!.stream.drain<void>();
      return _DownloadProbe(
        totalLength: total,
        supportsRange: _acceptsRanges(probeResponse.headers),
        sha256: sha256FromHeaders(probeResponse.headers),
        etag: _headerValue(probeResponse.headers, 'etag'),
      );
    }

    return const _DownloadProbe(
      totalLength: null,
      supportsRange: false,
      sha256: null,
      etag: null,
    );
  }

  Future<Response> _downloadAndPromote(
    String urlPath,
    File targetFile,
    Directory temporaryDirectory, {
    required _DownloadProbe probe,
    required ProgressCallback? onReceiveProgress,
    required Map<String, dynamic>? queryParameters,
    required CancelToken? cancelToken,
    required FileAccessMode fileAccessMode,
    required String lengthHeader,
    required Object? data,
    required Options? options,
  }) async {
    final temporaryFile = File(join(temporaryDirectory.path, 'download'));
    final initialLength =
        fileAccessMode == FileAccessMode.append && await targetFile.exists()
            ? await targetFile.length()
            : 0;
    if (initialLength > 0) {
      await targetFile.copy(temporaryFile.path);
    }

    final response = await download(
      urlPath,
      temporaryFile.path,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      deleteOnError: true,
      fileAccessMode: fileAccessMode,
      lengthHeader: lengthHeader,
      data: data,
      options: _requestOptions(
        options,
        responseType: ResponseType.stream,
        headers: const {'Range': null, 'If-Range': null},
      ),
    );
    _requireSuccessStatus(response.statusCode, urlPath);
    if (response.statusCode == 206 &&
        _parseContentRange(response.headers.value('content-range')) == null) {
      throw ChunkDownloadException(
        'Partial response without Content-Range for $urlPath',
      );
    }
    if (!await temporaryFile.exists()) {
      throw ChunkDownloadException(
          'Download did not create a file for $urlPath');
    }

    final finalLength = await temporaryFile.length();
    if (finalLength <= 0) {
      throw ChunkDownloadException(
          'Download created an empty file for $urlPath');
    }
    final declaredLength = _optionalLength(response.headers, lengthHeader);
    final declaredBodyLength = _optionalLength(
      response.headers,
      Headers.contentLengthHeader,
    );
    final expectedDeclaredLength = declaredLength ?? declaredBodyLength;
    if (expectedDeclaredLength != null &&
        finalLength - initialLength != expectedDeclaredLength) {
      throw ChunkDownloadException(
        'Length mismatch for $urlPath: expected $expectedDeclaredLength, got ${finalLength - initialLength}',
      );
    }
    _validateCompleteResponse(
      response.headers,
      urlPath,
      totalLength: probe.totalLength,
      actualLength: finalLength,
      allowPartial: false,
    );

    final actualHash = await _sha256File(temporaryFile);
    final expectedHash = sha256FromHeaders(response.headers) ?? probe.sha256;
    if (expectedHash != null && actualHash != expectedHash) {
      throw ChunkDownloadException(
        'SHA-256 mismatch for $urlPath: expected $expectedHash, got $actualHash',
      );
    }

    await _atomicReplace(temporaryFile, targetFile);
    return _completedResponse(
      urlPath,
      targetFile,
      actualHash,
      response.headers.value(Headers.contentTypeHeader),
      etag: _headerValue(response.headers, 'etag') ?? probe.etag,
      originSha256: expectedHash,
      originLength: probe.totalLength,
    );
  }

  Future<Response> _downloadRangesAndPromote(
    String urlPath,
    File targetFile,
    Directory temporaryDirectory, {
    required _DownloadProbe probe,
    required ProgressCallback? onReceiveProgress,
    required Map<String, dynamic>? queryParameters,
    required CancelToken? cancelToken,
    required String lengthHeader,
    required Object? data,
    required Options? options,
    required int connections,
  }) async {
    final totalLength = probe.totalLength!;
    final partCount = min(connections, totalLength);
    final chunkSize = (totalLength / partCount).ceil();
    final partFiles = List.generate(
      partCount,
      (index) => File(join(temporaryDirectory.path, 'part_$index')),
    );
    var downloaded = 0;

    final futures = <Future<_PartResult>>[];
    for (var index = 0; index < partCount; index++) {
      final start = index * chunkSize;
      final end = min((index + 1) * chunkSize - 1, totalLength - 1);
      final expectedLength = end - start + 1;
      futures.add(_downloadPart(
        urlPath,
        partFiles[index],
        start: start,
        end: end,
        expectedLength: expectedLength,
        totalLength: totalLength,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        data: data,
        options: options,
        onBytes: (count) {
          downloaded += count;
          onReceiveProgress?.call(min(downloaded, totalLength), totalLength);
        },
      ));
    }

    final partResults = await Future.wait(futures, eagerError: false);
    final partEtag = _singleHeaderValue(
      partResults.map((result) => result.etag),
      'ETag',
    );
    final partHash = _singleHeaderValue(
      partResults.map((result) => result.sha256),
      'SHA-256',
    );
    final expectedEtag = probe.etag ?? partEtag;
    final probeEtag = probe.etag;
    if (probeEtag != null &&
        partEtag != null &&
        _normaliseValidator(probeEtag) != _normaliseValidator(partEtag)) {
      throw ChunkDownloadException('ETag changed while downloading $urlPath');
    }
    final expectedHash = probe.sha256 ?? partHash;
    if (probe.sha256 != null && partHash != null && probe.sha256 != partHash) {
      throw ChunkDownloadException(
          'SHA-256 changed while downloading $urlPath');
    }

    var verifiedBytes = 0;
    for (var index = 0; index < partFiles.length; index++) {
      final part = partFiles[index];
      if (!await part.exists()) {
        throw ChunkDownloadException('Missing chunk part ${part.path}');
      }
      final expectedPartStart = index * chunkSize;
      final expectedPartEnd = min((index + 1) * chunkSize - 1, totalLength - 1);
      final expectedPartLength = expectedPartEnd - expectedPartStart + 1;
      final length = await part.length();
      if (length != expectedPartLength) {
        throw ChunkDownloadException(
          'Chunk part ${part.path} has $length bytes instead of $expectedPartLength',
        );
      }
      verifiedBytes += length;
    }
    if (verifiedBytes != totalLength) {
      throw ChunkDownloadException(
        'Incomplete download for $urlPath: expected $totalLength bytes, got $verifiedBytes',
      );
    }

    final assembledFile = File(join(temporaryDirectory.path, 'assembled'));
    final sink = assembledFile.openWrite(mode: FileMode.writeOnly);
    try {
      for (final part in partFiles) {
        await sink.addStream(part.openRead());
      }
      await sink.flush();
    } finally {
      await sink.close();
    }

    final assembledLength = await assembledFile.length();
    if (assembledLength != totalLength) {
      throw ChunkDownloadException(
        'Incomplete assembled download for $urlPath: expected $totalLength bytes, got $assembledLength',
      );
    }
    final actualHash = await _sha256File(assembledFile);
    if (expectedHash != null && actualHash != expectedHash) {
      throw ChunkDownloadException(
        'SHA-256 mismatch for $urlPath: expected $expectedHash, got $actualHash',
      );
    }

    await _atomicReplace(assembledFile, targetFile);
    return _completedResponse(
      urlPath,
      targetFile,
      actualHash,
      null,
      etag: expectedEtag,
      originSha256: expectedHash,
      originLength: totalLength,
    );
  }

  Future<_PartResult> _downloadPart(
    String urlPath,
    File partFile, {
    required int start,
    required int end,
    required int expectedLength,
    required int totalLength,
    required Map<String, dynamic>? queryParameters,
    required CancelToken? cancelToken,
    required Object? data,
    required Options? options,
    required void Function(int count) onBytes,
  }) async {
    final response = await get<ResponseBody>(
      urlPath,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: _requestOptions(
        options,
        responseType: ResponseType.stream,
        headers: {'Range': 'bytes=$start-$end'},
      ),
    );
    if (response.statusCode != 206) {
      final status = response.statusCode;
      throw ChunkDownloadException(
        'Range request for $urlPath returned ${status ?? "null"}',
      );
    }
    final range = _parseContentRange(response.headers.value('content-range'));
    final bodyLength = _optionalLength(
      response.headers,
      Headers.contentLengthHeader,
    );
    if (range == null ||
        range.start != start ||
        range.end != end ||
        range.total != totalLength ||
        bodyLength != expectedLength) {
      throw ChunkDownloadException(
        'Invalid range headers for $urlPath: requested $start-$end/$totalLength, got ${response.headers.value('content-range')} and ${response.headers.value('content-length')}',
      );
    }
    if (_hasContentEncoding(response.headers)) {
      throw ChunkDownloadException(
        'Encoded range response cannot be safely assembled for $urlPath',
      );
    }
    if (response.data == null) {
      throw ChunkDownloadException('Range response had no body for $urlPath');
    }

    var received = 0;
    final sink = partFile.openWrite(mode: FileMode.writeOnly);
    try {
      await for (final chunk in response.data!.stream) {
        if (received + chunk.length > expectedLength) {
          throw ChunkDownloadException(
            'Range $start-$end exceeded $expectedLength bytes for $urlPath',
          );
        }
        sink.add(chunk);
        received += chunk.length;
        onBytes(chunk.length);
      }
      await sink.flush();
    } finally {
      await sink.close();
    }
    if (received != expectedLength) {
      throw ChunkDownloadException(
        'Range $start-$end ended at $received bytes instead of $expectedLength',
      );
    }

    return _PartResult(
      etag: _headerValue(response.headers, 'etag'),
      sha256: sha256FromHeaders(response.headers),
    );
  }

  Response<dynamic> _completedResponse(
    String urlPath,
    File targetFile,
    String sha256,
    String? contentType, {
    String? etag,
    String? originSha256,
    int? originLength,
  }) {
    final length = targetFile.lengthSync();
    final headers = <String, List<String>>{
      Headers.contentLengthHeader: ['$length'],
      'accept-ranges': ['bytes'],
      'x-content-sha256': [sha256],
      // Origin-declared validators captured from the server's probe/GET
      // responses — independent of the assembled file, so callers can verify
      // against something the file itself didn't produce.
      if (originSha256 != null) 'x-origin-sha256': [originSha256],
      if (originLength != null) 'x-origin-content-length': ['$originLength'],
      if (contentType != null) Headers.contentTypeHeader: [contentType],
      if (etag != null) 'etag': [etag],
    };
    return Response<dynamic>(
      requestOptions: RequestOptions(path: urlPath),
      data: targetFile,
      statusCode: 200,
      statusMessage: 'Verified download completed',
      headers: Headers.fromMap(headers),
    );
  }
}

class _DownloadProbe {
  final int? totalLength;
  final bool supportsRange;
  final String? sha256;
  final String? etag;

  const _DownloadProbe({
    required this.totalLength,
    required this.supportsRange,
    required this.sha256,
    required this.etag,
  });
}

class _PartResult {
  final String? etag;
  final String? sha256;

  const _PartResult({required this.etag, required this.sha256});
}

class _ContentRange {
  final int start;
  final int end;
  final int total;

  const _ContentRange(this.start, this.end, this.total);
}

_ContentRange? _parseContentRange(String? value) {
  if (value == null) return null;
  final match = RegExp(
    r'^bytes\s+(\d+)-(\d+)/(\d+)$',
    caseSensitive: false,
  ).firstMatch(value.trim());
  if (match == null) return null;
  final start = int.tryParse(match.group(1)!);
  final end = int.tryParse(match.group(2)!);
  final total = int.tryParse(match.group(3)!);
  if (start == null || end == null || total == null || start < 0) return null;
  if (end < start || total <= end) return null;
  return _ContentRange(start, end, total);
}

int? _optionalLength(Headers headers, String name) {
  final value = headers.value(name);
  if (value == null || value.trim().isEmpty) return null;
  final length = int.tryParse(value.trim());
  if (length == null || length < 0) {
    throw FormatException('Invalid $name header: $value');
  }
  return length;
}

String? _headerValue(Headers headers, String name) {
  final value = headers.value(name);
  if (value == null) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

bool _acceptsRanges(Headers headers) {
  final value = headers.value('accept-ranges');
  return value
          ?.split(',')
          .map((part) => part.trim().toLowerCase())
          .contains('bytes') ??
      false;
}

bool _hasContentEncoding(Headers headers) {
  final value = headers.value(Headers.contentEncodingHeader);
  if (value == null) return false;
  final normalized = value.trim().toLowerCase();
  return normalized.isNotEmpty && normalized != 'identity';
}

String? _singleHeaderValue(Iterable<String?> values, String label) {
  final present = values.where((value) => value != null).toSet();
  if (present.length > 1) {
    throw ChunkDownloadException('Multiple conflicting $label headers');
  }
  return present.isEmpty ? null : present.first;
}

String? _normaliseValidator(String value) => value.trim();

void _requireSuccessStatus(int? statusCode, String urlPath) {
  if (statusCode == null || statusCode < 200 || statusCode >= 300) {
    throw ChunkDownloadException(
      'Download failed for $urlPath with status ${statusCode ?? 'null'}',
    );
  }
}

void _validateCompleteResponse(
  Headers headers,
  String urlPath, {
  required int? totalLength,
  required int actualLength,
  required bool allowPartial,
}) {
  final contentRangeValue = headers.value('content-range');
  final responseRange = _parseContentRange(contentRangeValue);
  if (contentRangeValue != null && responseRange == null) {
    throw ChunkDownloadException(
      'Invalid Content-Range for $urlPath: $contentRangeValue',
    );
  }
  if (responseRange != null && !allowPartial) {
    if (responseRange.start != 0 ||
        responseRange.end != responseRange.total - 1 ||
        responseRange.total != actualLength) {
      throw ChunkDownloadException(
        'Incomplete response for $urlPath: ${headers.value('content-range')}',
      );
    }
  }
  if (totalLength != null && actualLength != totalLength) {
    throw ChunkDownloadException(
      'Incomplete response for $urlPath: expected $totalLength bytes, got $actualLength',
    );
  }
}

Options _requestOptions(
  Options? options, {
  required ResponseType responseType,
  Map<String, dynamic>? headers,
}) {
  final base = options ?? Options();
  final merged = <String, dynamic>{...?base.headers};
  if (headers != null) {
    for (final entry in headers.entries) {
      merged.removeWhere(
        (key, _) => key.toLowerCase() == entry.key.toLowerCase(),
      );
      merged[entry.key] = entry.value;
    }
  }
  return base.copyWith(
    headers: merged,
    responseType: responseType,
    validateStatus: (status) => status != null && status >= 200 && status < 300,
  );
}

Future<String> _sha256File(File file) async {
  final digest = await sha256.bind(file.openRead()).first;
  return digest.toString();
}

String _uniqueToken() {
  final random = Random();
  return '${DateTime.now().microsecondsSinceEpoch}-${random.nextInt(1 << 32)}';
}

Future<void> _atomicReplace(File source, File target) async {
  if (source.path == target.path) return;
  try {
    await source.rename(target.path);
    return;
  } catch (_) {
    if (!await target.exists()) rethrow;
    final backup = File(
      '${target.path}.replace-${_uniqueToken()}',
    );
    await target.rename(backup.path);
    try {
      await source.rename(target.path);
    } catch (replacementError, replacementStack) {
      try {
        await backup.rename(target.path);
      } catch (_) {}
      Error.throwWithStackTrace(replacementError, replacementStack);
    }
    try {
      await backup.delete();
    } catch (_) {}
    return;
  }
}

Future<void> _deleteQuietly(FileSystemEntity entity) async {
  try {
    if (await entity.exists()) await entity.delete(recursive: true);
  } catch (_) {}
}
