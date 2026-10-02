import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart' hide Response;
import 'package:dio/dio.dart' as dio_lib;
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:shelf/shelf.dart';
import 'package:deemusiq/extensions/dio.dart'
    show normalizeSha256, sha256FromHeaders;
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/models/parser/range_headers.dart';
import 'package:deemusiq/provider/audio_player/audio_player.dart';
import 'package:deemusiq/provider/audio_player/state.dart';
import 'package:deemusiq/provider/history/monthly_plays.dart';
import 'package:deemusiq/provider/server/active_track_sources.dart';
import 'package:deemusiq/provider/server/sourced_track_provider.dart';
import 'package:deemusiq/provider/user_preferences/user_preferences_provider.dart';
import 'package:deemusiq/services/audio_player/audio_player.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/metadata/errors/exceptions.dart'
    show CatalogOfflineException;
import 'package:deemusiq/services/offline_drm/offline_drm.dart';
import 'package:deemusiq/services/offline_drm/offline_license.dart';
import 'package:deemusiq/services/sourced_track/sourced_track.dart';
import 'package:deemusiq/utils/service_utils.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

const playbackUnavailableHeader = 'x-deemusiq-playback-state';
const playbackDownloadActionHeader = 'x-deemusiq-playback-action';
const playbackFallbackHeader = 'x-deemusiq-playback-fallback';
const playbackPrimaryErrorHeader = 'x-deemusiq-playback-primary-error';
const playbackOfflineHeader = 'x-deemusiq-playback-offline';

/// True for network-level failures (backend/stream host unreachable):
/// connection refused/timeout, DNS/socket errors. HTTP error responses are
/// NOT network-level. Used to fail fast with a distinct "offline" state
/// instead of retrying or skip-storming.
bool isNetworkLevelPlaybackError(Object error) {
  if (error is CatalogOfflineException) return true;
  if (error is SocketException) return true;
  if (error is DioException) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.error is SocketException;
  }
  return false;
}

/// A cached audio entry is only valid for the (track, source) pair it was
/// fetched from. When a track's selected source changes (different video id,
/// different engine, re-minted signed URL), audio cached under the old source
/// must be bypassed so the new source actually plays. Metadata written before
/// sourceIds were recorded (null) is treated as unverifiable and bypassed
/// whenever the current source identity is known.
bool cacheMetadataMatchesTrackSource({
  required String? metadataTrackId,
  required String? metadataSourceId,
  required String trackId,
  required String sourceId,
}) {
  if (metadataTrackId == null || metadataTrackId != trackId) return false;
  if (sourceId.isEmpty) return true;
  return metadataSourceId == sourceId;
}

final _deviceClients = Set.unmodifiable({
  YoutubeApiClient.ios,
  YoutubeApiClient.android,
  YoutubeApiClient.mweb,
  YoutubeApiClient.safari,
});

/// Picks one device User-Agent for the lifetime of the playback server. Real
/// clients keep a single UA across HEAD/GET/range probes of the same media —
/// rotating UAs per request is itself a bot fingerprint and can invalidate
/// googlevideo URLs tied to the client that minted them.
String? _pickSessionUserAgent() => _deviceClients
    .elementAt(Random().nextInt(_deviceClients.length))
    .payload["context"]["client"]["userAgent"] as String?;

class PlaybackUnavailableException implements Exception {
  final String trackId;
  final Object primaryError;
  final StackTrace primaryStackTrace;

  /// True when the failure is network-level (the DeeMusiq backend or stream
  /// host is unreachable) — the UI should say so instead of auto-retrying.
  final bool offline;

  const PlaybackUnavailableException(
    this.trackId,
    this.primaryError,
    this.primaryStackTrace, {
    this.offline = false,
  });

  @override
  String toString() => 'PlaybackUnavailableException: $trackId: $primaryError';
}

class ServerPlaybackRoutes {
  final Ref ref;
  UserPreferences get userPreferences => ref.read(userPreferencesProvider);
  AudioPlayerState get playlist => ref.read(audioPlayerProvider);
  final Dio dio;
  final Map<String, _CachedUrlEntry> _urlCache = {};
  final Map<String, Future<_VerifiedLocalCopy?>> _verificationCache = {};

  /// In-flight remote cache writes, keyed by DeeMusiq track id. A concurrent
  /// request for the same track awaits the first fetch and then serves the
  /// verified local copy, instead of downloading the same bytes twice
  /// (mpv fires HEAD + GET + range probes in parallel).
  final Map<String, Future<void>> _remoteFetchInFlight = {};

  static const _urlCacheTtlSeconds = 30;

  /// How often an interrupted remote body is resumed with a Range request
  /// before the track is declared failed.
  static const _maxStreamResumes = 3;

  ServerPlaybackRoutes(this.ref, {Dio? dio})
      : dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 60),
              sendTimeout: const Duration(seconds: 15),
            ));

  Future<String> _getTrackCacheFilePath(SourcedTrack track) async {
    return join(
      await UserPreferencesNotifier.getMusicCacheDir(),
      ServiceUtils.sanitizeFilename(
        '${track.query.name} - ${track.query.artists.map((d) => d.name).join(",")} (${track.info.id}).${_cacheExtension(track)}',
      ),
    );
  }

  Future<SourcedTrack?> _getSourcedTrack(
    Request request,
    String trackId,
  ) async {
    final activeTracks = playlist.tracks;
    if (activeTracks.isEmpty) return null;
    final fullTracks = activeTracks.whereType<DeeMusiqFullTrackObject>();
    final track = fullTracks.cast<DeeMusiqFullTrackObject?>().firstWhere(
          (element) => element?.id == trackId,
          orElse: () => null,
        );
    if (track == null) return null;

    final activeSourcedTrack =
        await ref.read(activeTrackSourcesProvider.future);

    final medias = audioPlayer.playlist.medias;
    if (medias.isEmpty) return null;
    final mediaIndex = medias.indexWhere(
      (e) => e.uri == request.requestedUri.toString(),
    );
    final media = mediaIndex >= 0 ? medias[mediaIndex] : medias.firstOrNull;
    if (media == null) return null;
    final spotubeMedia =
        media is DeeMusiqMedia ? media : DeeMusiqMedia.media(media);
    final sourcedTrack = activeSourcedTrack?.track.id == track.id
        ? activeSourcedTrack?.source
        : await ref.read(
            sourcedTrackProvider(spotubeMedia.track as DeeMusiqFullTrackObject)
                .future,
          );

    return sourcedTrack;
  }

  Future<dio_lib.Response?> streamTrackInformation(
    Request request,
    SourcedTrack track, {
    int siblingAttemptsLeft = 1,
  }) async {
    _logInfo(
      "HEAD request for track: ${track.query.name}\nHeaders: ${request.headers}",
    );

    _VerifiedLocalCopy? local;
    try {
      local = await _findVerifiedLocalCopy(track);
    } catch (error, stackTrace) {
      _reportCacheError(error, stackTrace, track.query.id);
    }
    if (local != null) return _localInformationResponse(request, track, local);

    late final String url;
    try {
      url = await _resolveRemoteUrl(track);
    } catch (error, stackTrace) {
      throw PlaybackUnavailableException(
        track.query.id,
        error,
        stackTrace,
        offline: isNetworkLevelPlaybackError(error),
      );
    }
    final options = _remoteOptions(
      url,
      request.headers,
      responseType: ResponseType.bytes,
    );
    try {
      final response = await dio.head(url, options: options);
      _readRemoteHeaders(response, url);
      return response;
    } catch (error, stackTrace) {
      try {
        final fallback = await _findVerifiedLocalCopy(track);
        if (fallback != null) {
          _reportPrimaryError(error, stackTrace);
          return _addFallbackHeaders(
            _localInformationResponse(request, track, fallback),
            error,
          );
        }
      } catch (cacheError, cacheStackTrace) {
        _reportCacheError(cacheError, cacheStackTrace, track.query.id);
      }
      if (siblingAttemptsLeft > 0 && !isNetworkLevelPlaybackError(error)) {
        final swapped = await _swapToNextSibling(track);
        if (swapped != null) {
          return streamTrackInformation(
            request,
            swapped,
            siblingAttemptsLeft: siblingAttemptsLeft - 1,
          );
        }
      }
      Error.throwWithStackTrace(
        PlaybackUnavailableException(
          track.query.id,
          error,
          stackTrace,
          offline: isNetworkLevelPlaybackError(error),
        ),
        stackTrace,
      );
    }
  }

  Future<dio_lib.Response?> streamTrack(
    Request request,
    SourcedTrack track,
    Map<String, dynamic> headers, {
    int siblingAttemptsLeft = 1,
  }) async {
    _logInfo(
      "GET request for track: ${track.query.name}\nHeaders: ${request.headers}",
    );

    late final _RequestedRange? requestedRange;
    try {
      requestedRange = _parseRequestedRange(request.headers);
    } catch (_) {
      return _rangeNotAvailableResponse(0);
    }
    _VerifiedLocalCopy? initialLocal;
    try {
      initialLocal = await _findVerifiedLocalCopy(track);
    } catch (error, stackTrace) {
      _reportCacheError(error, stackTrace, track.query.id);
    }
    if (initialLocal != null) {
      return _serveLocalCopy(
        request,
        track,
        initialLocal,
        requestedRange,
      );
    }

    // Single-flight: another request for this track is currently downloading
    // it into the cache — wait briefly and serve the verified local copy
    // instead of downloading the same bytes twice.
    final inFlightFetch = _remoteFetchInFlight[track.query.id];
    if (inFlightFetch != null) {
      try {
        await inFlightFetch.timeout(const Duration(seconds: 30));
      } catch (_) {
        // Timed out or failed — fall through and fetch from remote ourselves.
      }
      try {
        final awaitedLocal = await _findVerifiedLocalCopy(track);
        if (awaitedLocal != null) {
          return _serveLocalCopy(request, track, awaitedLocal, requestedRange);
        }
      } catch (error, stackTrace) {
        _reportCacheError(error, stackTrace, track.query.id);
      }
    }

    Object? primaryError;
    StackTrace? primaryStackTrace;
    var offline = false;
    late String url;
    try {
      url = await _resolveRemoteUrl(track);
    } catch (error, stackTrace) {
      throw PlaybackUnavailableException(
        track.query.id,
        error,
        stackTrace,
        offline: isNetworkLevelPlaybackError(error),
      );
    }
    _RemoteHeaders? headHeaders;
    try {
      final headResponse = await dio.head(
        url,
        options: _remoteOptions(
          url,
          headers,
          responseType: ResponseType.bytes,
        ),
      );
      headHeaders = _readRemoteHeaders(headResponse, url);
      if (headHeaders.hls) {
        return _localManifestRedirect(request, track.query.id);
      }
    } catch (error, stackTrace) {
      primaryError = error;
      primaryStackTrace = stackTrace;
      offline = isNetworkLevelPlaybackError(error);
      try {
        final refreshedUrl = await _refreshRemoteUrl(track);
        if (refreshedUrl != null) {
          url = refreshedUrl;
          try {
            final retry = await dio.head(
              url,
              options: _remoteOptions(
                url,
                headers,
                responseType: ResponseType.bytes,
              ),
            );
            headHeaders = _readRemoteHeaders(retry, url);
            if (headHeaders.hls) {
        return _localManifestRedirect(request, track.query.id);
      }
          } catch (_) {}
        }
      } catch (_) {
        // Refreshing the streaming URL failed at the network level — the
        // backend is unreachable; surface as offline rather than retrying.
        offline = true;
      }
    }

    if (primaryError != null && primaryStackTrace != null) {
      _reportPrimaryError(primaryError, primaryStackTrace);
    }
    dio_lib.Response<ResponseBody>? response;
    Object? getError;
    StackTrace? getStackTrace;
    for (var getAttempt = 0; getAttempt < 2; getAttempt++) {
      try {
        response = await dio.get<ResponseBody>(
          url,
          options: _remoteOptions(
            url,
            headers,
            responseType: ResponseType.stream,
          ),
        );
        break;
      } catch (error, stackTrace) {
        getError = error;
        getStackTrace = stackTrace;
        offline = offline || isNetworkLevelPlaybackError(error);
        // Mirror the HEAD path: an expired signed URL (401/403/410) gets one
        // URL refresh + one GET retry before falling back to the local cache.
        if (getAttempt == 0 && _isExpiredSignedUrlError(error)) {
          try {
            final refreshedUrl = await _refreshRemoteUrl(track);
            if (refreshedUrl != null) {
              url = refreshedUrl;
              continue;
            }
          } catch (_) {
            offline = true;
          }
        }
        break;
      }
    }
    if (response == null) {
      return await _fallbackOrUnavailable(
        request,
        track,
        requestedRange,
        headHeaders,
        primaryError ?? getError ?? StateError('Remote source GET failed'),
        primaryStackTrace ?? getStackTrace ?? StackTrace.current,
        offline: offline,
        siblingAttemptsLeft: siblingAttemptsLeft,
      );
    }

    try {
      final body = _validateRemoteResponse(
        response,
        url,
        requestedRange,
        headHeaders,
      );
      if (body.hls) {
        await response.data!.stream.drain<void>();
        return _localManifestRedirect(request, track.query.id);
      }
      return _prepareRemoteResponse(
        track,
        url,
        response,
        body,
        requestHeaders: headers,
        requestedRange: requestedRange,
      );
    } catch (error, stackTrace) {
      return await _fallbackOrUnavailable(
        request,
        track,
        requestedRange,
        headHeaders,
        primaryError ?? error,
        primaryStackTrace ?? stackTrace,
        offline: offline || isNetworkLevelPlaybackError(error),
        siblingAttemptsLeft: siblingAttemptsLeft,
      );
    }
  }

  /// Re-mints the streaming URL once (fresh signed URL for catalog tracks).
  /// Returns null when no usable URL comes back; rethrows network-level
  /// failures so callers can flag the track as offline instead of retrying.
  Future<String?> _refreshRemoteUrl(SourcedTrack track) async {
    try {
      final refreshed = await ref
          .read(sourcedTrackProvider(track.query).notifier)
          .refreshStreamingUrl();
      final refreshedUrl = refreshed.url;
      if (refreshedUrl == null || refreshedUrl.isEmpty) return null;
      _validateRemoteUrl(refreshedUrl);
      _urlCache[_urlCacheKey(refreshed)] = _CachedUrlEntry(refreshedUrl);
      return refreshedUrl;
    } catch (error) {
      if (isNetworkLevelPlaybackError(error)) rethrow;
      return null;
    }
  }

  /// True when the remote rejected the URL in a way a freshly minted signed
  /// URL can fix (expired/revoked signature), as opposed to a server error.
  bool _isExpiredSignedUrlError(Object error) {
    if (error is! DioException) return false;
    final status = error.response?.statusCode;
    return status == 401 || status == 403 || status == 410;
  }

  /// Re-opens the remote body at [offset] via a Range request so an
  /// interrupted stream resumes where it stopped. Refreshes an expired
  /// signed URL once when the resume itself is rejected with 401/403/410.
  Future<Stream<Uint8List>> _openResumeStream(
    SourcedTrack track,
    String url,
    int offset,
    Map<String, dynamic> requestHeaders,
  ) async {
    final headers = <String, dynamic>{
      ...requestHeaders,
      'range': 'bytes=$offset-',
    };
    Future<dio_lib.Response<ResponseBody>> open(String target) {
      return dio.get<ResponseBody>(
        target,
        options: _remoteOptions(
          target,
          headers,
          responseType: ResponseType.stream,
        ),
      );
    }

    dio_lib.Response<ResponseBody> response;
    try {
      response = await open(url);
    } catch (error) {
      if (!_isExpiredSignedUrlError(error)) rethrow;
      final refreshedUrl = await _refreshRemoteUrl(track);
      if (refreshedUrl == null) rethrow;
      response = await open(refreshedUrl);
    }
    // A 200 here means the Range header was ignored — stitching a fresh
    // full body onto already-delivered bytes would corrupt the output.
    // Likewise, a 206 whose Content-Range starts at a different offset than
    // requested would mis-stitch bytes (undetectable when the source carries
    // no SHA-256, e.g. googlevideo), so it is rejected just as hard.
    final contentRange =
        _parseContentRangeValue(response.headers.value('content-range'));
    if (response.statusCode != 206 ||
        response.data == null ||
        contentRange == null ||
        contentRange.start != offset) {
      await response.data?.stream.drain<void>();
      throw StateError(
        'Resume request for ${track.query.id} was not honored (status ${response.statusCode}, start ${contentRange?.start}, wanted $offset)',
      );
    }
    return response.data!.stream;
  }

  /// Swaps the sourced track to the next matched YouTube sibling (a different
  /// video) after a remote failure — the failed video may be removed,
  /// region-blocked or bot-walled while other matches still play. Returns
  /// null when no sibling is available or the swap failed.
  Future<SourcedTrack?> _swapToNextSibling(SourcedTrack track) async {
    try {
      final swapped = await ref
          .read(sourcedTrackProvider(track.query).notifier)
          .swapWithNextSibling();
      if (swapped.info.id == track.info.id) return null;
      _logInfo(
        'Playback: swapping ${track.query.id} to sibling ${swapped.info.id} after remote failure',
      );
      return swapped;
    } catch (error, stackTrace) {
      AppLogger.reportError(error, stackTrace, 'sibling fallback');
      return null;
    }
  }

  Future<dio_lib.Response<dynamic>> _fallbackOrUnavailable(
    Request request,
    SourcedTrack track,
    _RequestedRange? requestedRange,
    _RemoteHeaders? remoteHeaders,
    Object primaryError,
    StackTrace primaryStackTrace, {
    bool offline = false,
    int siblingAttemptsLeft = 0,
  }) async {
    _VerifiedLocalCopy? local;
    try {
      local = await _findVerifiedLocalCopy(
        track,
        expectedHash: remoteHeaders?.sha256,
        expectedEtag: remoteHeaders?.etag,
        expectedLength: remoteHeaders?.totalLength,
      );
    } catch (cacheError, cacheStackTrace) {
      _reportCacheError(cacheError, cacheStackTrace, track.query.id);
    }
    if (local != null) {
      _reportPrimaryError(primaryError, primaryStackTrace);
      final response = await _serveLocalCopy(
        request,
        track,
        local,
        requestedRange,
      );
      return _addFallbackHeaders(response, primaryError);
    }
    // Last resort before declaring the track unavailable: try a different
    // matched YouTube video. Pointless when the failure is network-level
    // (every source is equally unreachable).
    if (siblingAttemptsLeft > 0 && !offline) {
      final swapped = await _swapToNextSibling(track);
      if (swapped != null) {
        final response = await streamTrack(
          request,
          swapped,
          request.headers,
          siblingAttemptsLeft: siblingAttemptsLeft - 1,
        );
        if (response != null) return response;
      }
    }
    throw PlaybackUnavailableException(
      track.query.id,
      primaryError,
      primaryStackTrace,
      offline: offline || isNetworkLevelPlaybackError(primaryError),
    );
  }

  Future<dio_lib.Response<dynamic>> _prepareRemoteResponse(
    SourcedTrack track,
    String url,
    dio_lib.Response<ResponseBody> response,
    _RemoteBody body, {
    required Map<String, dynamic> requestHeaders,
    required _RequestedRange? requestedRange,
  }) async {
    final checked = resumableCheckedStream(
      response.data!.stream,
      baseOffset: requestedRange?.start ?? 0,
      expectedLength: body.expectedLength,
      expectedHash: body.sha256,
      maxResumes: _maxStreamResumes,
      onResume: (received, attempt, error) {
        AppLogger.log.w(
          'Remote stream for ${track.query.id} interrupted at '
          '$received/${body.expectedLength ?? '?'} bytes '
          '(${error ?? 'early EOF'}) — resuming (attempt $attempt/$_maxStreamResumes)',
        );
      },
      reopen: (offset) => _openResumeStream(track, url, offset, requestHeaders),
    );
    final broadcast = checked.asBroadcastStream();
    response.data!.stream = broadcast;

    if (userPreferences.cacheMusic && !body.cacheable) {
      _reportCacheError(
        StateError('Partial or encoded response was not promoted to cache'),
        StackTrace.current,
        track.query.id,
      );
    } else if (userPreferences.cacheMusic && body.cacheable) {
      final writeFuture = _writeRemoteCache(
        track: track,
        sourceUrl: url,
        stream: broadcast,
        expectedLength: body.expectedLength,
        totalLength: body.totalLength,
        expectedHash: body.sha256,
        etag: body.etag,
        lastModified: body.lastModified,
        contentType: response.headers.value(Headers.contentTypeHeader),
      );
      _remoteFetchInFlight[track.query.id] = writeFuture;
      unawaited(
        writeFuture
            .catchError((Object error, StackTrace stackTrace) {
              _reportCacheError(error, stackTrace, track.query.id);
            })
            .whenComplete(() {
              if (identical(
                _remoteFetchInFlight[track.query.id],
                writeFuture,
              )) {
                _remoteFetchInFlight.remove(track.query.id);
              }
            }),
      );
    }
    return response;
  }

  Future<void> _writeRemoteCache({
    required SourcedTrack track,
    required String sourceUrl,
    required Stream<List<int>> stream,
    required int? expectedLength,
    required int? totalLength,
    required String? expectedHash,
    required String? etag,
    required String? lastModified,
    required String? contentType,
  }) async {
    final directory =
        Directory(await UserPreferencesNotifier.getMusicCacheDir());
    await directory.create(recursive: true);
    final temporaryFile = File(
      join(
        directory.path,
        '.${_cacheExtension(track)}.part-${_uniqueToken()}',
      ),
    );
    try {
      final sink = temporaryFile.openWrite(mode: FileMode.writeOnly);
      var received = 0;
      try {
        await for (final chunk in stream) {
          if (expectedLength != null &&
              received + chunk.length > expectedLength) {
            throw StateError(
              'Cache response exceeded expected length for ${track.query.id}',
            );
          }
          sink.add(chunk);
          received += chunk.length;
        }
        await sink.flush();
      } finally {
        await sink.close();
      }
      if (expectedLength != null && received != expectedLength) {
        throw StateError(
          'Cache response for ${track.query.id} ended at $received bytes instead of $expectedLength',
        );
      }
      if (received == 0) {
        throw StateError('Cache response for ${track.query.id} was empty');
      }
      if (totalLength != null && received != totalLength) {
        throw StateError(
          'Cache response for ${track.query.id} did not contain the complete object',
        );
      }

      final actualHash = await _sha256File(temporaryFile);
      if (expectedHash != null && actualHash != expectedHash) {
        throw StateError('Cache hash mismatch for ${track.query.id}');
      }
      final promoted = await _promoteCacheFile(
        temporaryFile,
        actualHash,
        _cacheExtension(track),
        track.info.id,
      );
      await _writeCacheMetadata(
        promoted,
        _CacheMetadata(
          trackId: track.query.id,
          sourceId: track.info.id,
          sha256: actualHash,
          length: await promoted.length(),
          etag: etag,
          lastModified: lastModified,
          contentType: contentType,
          sourceUrl: sourceUrl,
          totalLength: totalLength ?? await promoted.length(),
        ),
      );
      await _evictCacheIfNeeded();
    } finally {
      await _deleteQuietly(temporaryFile);
    }
  }

  Future<_VerifiedLocalCopy?> _findVerifiedLocalCopy(
    SourcedTrack track, {
    String? expectedHash,
    String? expectedEtag,
    int? expectedLength,
  }) async {
    final directory =
        Directory(await UserPreferencesNotifier.getMusicCacheDir());
    if (!await directory.exists()) return null;

    final candidates = <String, File>{};
    final extension = _cacheExtension(track);
    if (expectedHash != null) {
      for (final name in [
        _contentAddressedName(expectedHash, extension, track.info.id),
        '$expectedHash.$extension',
      ]) {
        final contentFile = File(join(directory.path, name));
        candidates[contentFile.path] = contentFile;
      }
    }
    final legacy = File(await _getTrackCacheFilePath(track));
    candidates[legacy.path] = legacy;

    try {
      await for (final entity in directory.list()) {
        if (entity is! File) continue;
        final path = entity.path;
        if (_isMetadataPath(path) ||
            path.endsWith('.part') ||
            path.contains('.part-') ||
            path.contains('.chunk-') ||
            path.contains('.replace-') ||
            path.endsWith('.tmp')) {
          continue;
        }
        final metadata = await _readCacheMetadata(entity);
        if (cacheMetadataMatchesTrackSource(
          metadataTrackId: metadata?.trackId,
          metadataSourceId: metadata?.sourceId,
          trackId: track.query.id,
          sourceId: track.info.id,
        )) {
          candidates[path] = entity;
        }
        if (track.info.id.isNotEmpty &&
            (basenameWithoutExtension(path) == track.info.id ||
                basename(path).contains(track.info.id))) {
          candidates[path] = entity;
        }
      }
    } catch (error, stackTrace) {
      _reportCacheError(error, stackTrace, track.query.id);
    }

    for (final candidate in candidates.values.toSet()) {
      final verified = await _verifyLocalFile(
        candidate,
        track: track,
        expectedHash: expectedHash,
        expectedEtag: expectedEtag,
        expectedLength: expectedLength,
      );
      if (verified != null) return verified;
    }
    return null;
  }

  Future<_VerifiedLocalCopy?> _verifyLocalFile(
    File file, {
    required SourcedTrack track,
    required String? expectedHash,
    required String? expectedEtag,
    required int? expectedLength,
  }) async {
    if (!await file.exists()) return null;
    final stat = await file.stat();
    if (stat.type != FileSystemEntityType.file || stat.size <= 0) return null;
    final cacheKey =
        '${file.path}|${stat.size}|${stat.modified.microsecondsSinceEpoch}|$expectedHash|$expectedEtag|$expectedLength|${track.query.id}|${track.info.id}';
    final active = _verificationCache[cacheKey];
    if (active != null) return active;
    final future = _verifyLocalFileUncached(
      file,
      track: track,
      expectedHash: expectedHash,
      expectedEtag: expectedEtag,
      expectedLength: expectedLength,
    );
    _verificationCache[cacheKey] = future;
    return future;
  }

  Future<_VerifiedLocalCopy?> _verifyLocalFileUncached(
    File file, {
    required SourcedTrack track,
    required String? expectedHash,
    required String? expectedEtag,
    required int? expectedLength,
  }) async {
    final metadata = await _readCacheMetadata(file);
    if (metadata != null &&
        !cacheMetadataMatchesTrackSource(
          metadataTrackId: metadata.trackId,
          metadataSourceId: metadata.sourceId,
          trackId: track.query.id,
          sourceId: track.info.id,
        )) {
      return null;
    }
    final length = await file.length();
    if (length <= 0 || (expectedLength != null && length != expectedLength)) {
      return null;
    }
    if (metadata != null &&
        (metadata.length != length ||
            (metadata.totalLength != null && metadata.totalLength != length))) {
      return null;
    }
    if (expectedEtag != null &&
        (metadata == null ||
            metadata.etag == null ||
            _normaliseValidator(metadata.etag!) !=
                _normaliseValidator(expectedEtag))) {
      return null;
    }
    final actualHash = await _sha256File(file);
    final requiredHash = expectedHash ?? metadata?.sha256;
    if (requiredHash != null && actualHash != requiredHash) return null;

    final target = File(
      join(
        await UserPreferencesNotifier.getMusicCacheDir(),
        _contentAddressedName(
          actualHash,
          _cacheExtension(track),
          track.info.id,
        ),
      ),
    );
    var promoted = file;
    if (file.path != target.path) {
      try {
        if (await target.exists()) {
          final existing = await _readCacheMetadata(target);
          if (await target.length() == length &&
              existing?.sha256 == actualHash) {
            promoted = target;
          } else {
            await _atomicReplace(file, target);
            promoted = target;
          }
        } else {
          await _atomicReplace(file, target);
          promoted = target;
        }
      } catch (error, stackTrace) {
        _reportCacheError(error, stackTrace, track.query.id);
        promoted = file;
      }
    }
    final effectiveMetadata = metadata ??
        _CacheMetadata(
          trackId: track.query.id,
          sourceId: track.info.id,
          sha256: actualHash,
          length: length,
          etag: expectedEtag,
          lastModified: null,
          contentType: null,
          sourceUrl: null,
          totalLength: length,
        );
    if (promoted.path == file.path && metadata == null) {
      try {
        await _writeCacheMetadata(promoted, effectiveMetadata);
      } catch (error, stackTrace) {
        _reportCacheError(error, stackTrace, track.query.id);
      }
    } else if (metadata == null || promoted.path != file.path) {
      try {
        await _writeCacheMetadata(promoted, effectiveMetadata);
      } catch (error, stackTrace) {
        _reportCacheError(error, stackTrace, track.query.id);
      }
    }
    return _VerifiedLocalCopy(promoted, actualHash, length);
  }

  _RemoteHeaders _readRemoteHeaders(
    dio_lib.Response<dynamic> response,
    String url,
  ) {
    final status = response.statusCode;
    if (status == null || status < 200 || status >= 300) {
      throw StateError('Remote source returned ${status ?? 'null'} for $url');
    }
    final contentType = response.headers.value(Headers.contentTypeHeader);
    // `hls` doubles as "is an adaptive manifest" (HLS or DASH): both must
    // skip the progressive cache and go through the manifest endpoint.
    final hls = manifestContentType(contentType) != null;
    int? totalLength;
    final range = _parseContentRangeValue(
      response.headers.value('content-range'),
    );
    if (status == 206) {
      if (range == null) {
        throw StateError('Remote source returned an invalid Content-Range');
      }
      totalLength = range.total;
    } else {
      if (response.headers.value('content-range') != null) {
        throw StateError(
            'Remote source returned Content-Range with status 200');
      }
      totalLength = _optionalHeaderInt(
        response.headers,
        Headers.contentLengthHeader,
      );
    }
    return _RemoteHeaders(
      totalLength: totalLength,
      sha256: sha256FromHeaders(response.headers),
      etag: _normaliseOptionalHeader(response.headers.value('etag')),
      lastModified: _normaliseOptionalHeader(
        response.headers.value('last-modified'),
      ),
      hls: hls,
    );
  }

  _RemoteBody _validateRemoteResponse(
    dio_lib.Response<ResponseBody> response,
    String url,
    _RequestedRange? requestedRange,
    _RemoteHeaders? headHeaders,
  ) {
    final status = response.statusCode;
    if (status != 200 && status != 206) {
      throw StateError('Remote source returned ${status ?? 'null'} for $url');
    }
    if (response.data == null) {
      throw StateError('Remote source returned an empty body for $url');
    }
    final headers = response.headers;
    final contentLength = _optionalHeaderInt(
      headers,
      Headers.contentLengthHeader,
    );
    final contentRangeHeader = headers.value('content-range');
    final range = _parseContentRangeValue(contentRangeHeader);
    // HLS or DASH manifest — see _readRemoteHeaders.
    final hls = manifestContentType(
          headers.value(Headers.contentTypeHeader),
        ) !=
        null;
    if (status == 206) {
      if (range == null) {
        throw StateError('Remote source returned an invalid Content-Range');
      }
      if (requestedRange?.start != null &&
          range.start != requestedRange!.start) {
        throw StateError('Remote source returned an unexpected range start');
      }
      if (requestedRange?.end != null && range.end > requestedRange!.end!) {
        throw StateError('Remote source returned an unexpected range end');
      }
      if (contentLength == null ||
          contentLength != range.end - range.start + 1) {
        throw StateError('Remote source returned an invalid range length');
      }
      if (headHeaders?.totalLength != null &&
          headHeaders!.totalLength != range.total) {
        throw StateError('Remote source length changed during playback');
      }
      final responseEtag = _normaliseOptionalHeader(headers.value('etag'));
      if (headHeaders?.etag != null &&
          responseEtag != null &&
          headHeaders!.etag != responseEtag) {
        throw StateError('Remote source ETag changed during playback');
      }
      final responseHash = sha256FromHeaders(headers);
      if (headHeaders?.sha256 != null &&
          responseHash != null &&
          headHeaders!.sha256 != responseHash) {
        throw StateError('Remote source hash changed during playback');
      }
      final cacheable = !hls &&
          !_hasContentEncoding(headers) &&
          range.start == 0 &&
          range.end == range.total - 1;
      if (requestedRange == null && !cacheable) {
        throw StateError('Remote source returned an unsolicited partial range');
      }
      return _RemoteBody(
        expectedLength: contentLength,
        totalLength: range.total,
        sha256: responseHash ?? headHeaders?.sha256,
        etag: responseEtag ?? headHeaders?.etag,
        lastModified: headHeaders?.lastModified,
        hls: hls,
        cacheable: cacheable,
      );
    }

    if (contentRangeHeader != null) {
      throw StateError('Remote source returned Content-Range with status 200');
    }
    if (contentLength == 0) {
      throw StateError('Remote source returned an empty body');
    }
    if (headHeaders?.totalLength != null &&
        contentLength != null &&
        headHeaders!.totalLength != contentLength) {
      throw StateError('Remote source length changed during playback');
    }
    final responseEtag = _normaliseOptionalHeader(headers.value('etag'));
    if (headHeaders?.etag != null &&
        responseEtag != null &&
        headHeaders!.etag != responseEtag) {
      throw StateError('Remote source ETag changed during playback');
    }
    final responseHash = sha256FromHeaders(headers);
    if (headHeaders?.sha256 != null &&
        responseHash != null &&
        headHeaders!.sha256 != responseHash) {
      throw StateError('Remote source hash changed during playback');
    }
    return _RemoteBody(
      expectedLength: contentLength ?? headHeaders?.totalLength,
      totalLength: headHeaders?.totalLength ?? contentLength,
      sha256: responseHash ?? headHeaders?.sha256,
      etag: responseEtag ?? headHeaders?.etag,
      lastModified: headHeaders?.lastModified,
      hls: hls,
      cacheable: !hls &&
          !_hasContentEncoding(headers) &&
          (contentLength != null || headHeaders?.totalLength != null),
    );
  }

  Future<dio_lib.Response<dynamic>> _serveLocalCopy(
    Request request,
    SourcedTrack track,
    _VerifiedLocalCopy local,
    _RequestedRange? range,
  ) async {
    // Serving a cached copy counts as "used": bump the mtime so LRU
    // eviction rotates out what actually stopped being played.
    try {
      await local.file.setLastModified(DateTime.now());
    } catch (_) {}
    final length = local.length;
    final requestedEnd = range?.end;
    if (range != null &&
        (range.start < 0 ||
            range.start >= length ||
            (requestedEnd != null && requestedEnd < range.start))) {
      return _rangeNotAvailableResponse(length);
    }
    final headers = _localHeaders(track, local, length);
    if (range == null) {
      return dio_lib.Response<Stream<List<int>>>(
        statusCode: 200,
        headers: Headers.fromMap(headers),
        requestOptions: RequestOptions(path: request.requestedUri.toString()),
        data: local.file.openRead(),
      );
    }
    final end = min(requestedEnd ?? length - 1, length - 1);
    final contentLength = end - range.start + 1;
    headers['content-length'] = ['$contentLength'];
    headers['content-range'] = [
      ContentRangeHeader(range.start, end, length).toString(),
    ];
    return dio_lib.Response<Stream<List<int>>>(
      statusCode: 206,
      headers: Headers.fromMap(headers),
      requestOptions: RequestOptions(path: request.requestedUri.toString()),
      data: local.file.openRead(range.start, end + 1),
    );
  }

  dio_lib.Response<dynamic> _localInformationResponse(
    Request request,
    SourcedTrack track,
    _VerifiedLocalCopy local,
  ) {
    return dio_lib.Response<dynamic>(
      statusCode: 200,
      headers: Headers.fromMap(_localHeaders(track, local, local.length)),
      requestOptions: RequestOptions(path: request.requestedUri.toString()),
    );
  }

  Map<String, List<String>> _localHeaders(
    SourcedTrack track,
    _VerifiedLocalCopy local,
    int length,
  ) {
    return {
      'content-type': ['audio/${track.qualityPreset?.name ?? "mp4"}'],
      'content-length': ['$length'],
      'accept-ranges': ['bytes'],
      'x-deemusiq-cache-sha256': [local.sha256],
      'x-deemusiq-cache-verified': ['true'],
    };
  }

  dio_lib.Response<dynamic> _rangeNotAvailableResponse(int length) {
    return dio_lib.Response<dynamic>(
      statusCode: 416,
      requestOptions: RequestOptions(path: 'range'),
      data: 'Requested range is not available',
      headers: Headers.fromMap({
        'content-range': ['bytes */$length'],
        'content-type': ['text/plain; charset=utf-8'],
      }),
    );
  }

  Future<String> _resolveRemoteUrl(SourcedTrack track) async {
    final direct = track.url;
    if (direct != null && direct.isNotEmpty) {
      _validateRemoteUrl(direct);
      return direct;
    }
    final cacheKey = _urlCacheKey(track);
    final cached = _urlCache[cacheKey];
    if (cached != null && cached.isValid) {
      _validateRemoteUrl(cached.url);
      return cached.url;
    }
    final swapped = await ref
        .read(sourcedTrackProvider(track.query).notifier)
        .swapWithNextSibling();
    final url = swapped.url;
    if (url == null || url.isEmpty) {
      throw StateError('No audio source for ${track.query.id}');
    }
    _validateRemoteUrl(url);
    _urlCache[_urlCacheKey(swapped)] = _CachedUrlEntry(url);
    return url;
  }

  /// Signed URLs are minted per source, so the cache key includes the source
  /// identity — a swapped/alternative source must never reuse the URL of the
  /// previous one.
  String _urlCacheKey(SourcedTrack track) =>
      '${track.query.id}:${track.info.id}';

  /// The one device User-Agent used for every upstream request of this
  /// server instance (see [_pickSessionUserAgent]).
  late final String? _sessionUserAgent = _pickSessionUserAgent();

  Options _remoteOptions(
    String url,
    Map<String, dynamic> headers, {
    required ResponseType responseType,
  }) {
    final merged = <String, dynamic>{...headers};
    _putHeader(merged, 'user-agent', _sessionUserAgent);
    // Real clients always send Accept and Accept-Language; their absence is
    // a trivially detectable bot signal.
    _putHeader(merged, 'accept', '*/*');
    _putHeader(merged, 'accept-language', 'en-US,en;q=0.9');
    _putHeader(merged, 'cache-control', 'max-age=3600');
    _putHeader(merged, 'connection', 'keep-alive');
    _putHeader(merged, 'host', Uri.parse(url).host);
    return Options(
      headers: merged,
      responseType: responseType,
      followRedirects: true,
      validateStatus: (status) =>
          status != null && status >= 200 && status < 300,
    );
  }

  Future<void> _evictCacheIfNeeded() async {
    try {
      final cacheDir =
          Directory(await UserPreferencesNotifier.getMusicCacheDir());
      // Pinned = this month's Top-50 tracks. A failure reading the
      // leaderboard must never break eviction — fall back to "nothing
      // pinned" rather than letting the cache grow unbounded.
      Set<String> pinnedTrackIds;
      try {
        pinnedTrackIds = ref.read(monthlyPlaysProvider.notifier).pinnedTrackIds();
      } catch (_) {
        pinnedTrackIds = const {};
      }
      await evictMusicCacheDir(
        cacheDir: cacheDir,
        pinnedTrackIds: pinnedTrackIds,
        maxSizeBytes: maxCacheSizeBytes,
      );
    } catch (error, stackTrace) {
      _reportCacheError(error, stackTrace, '_evictCacheIfNeeded');
    }
  }

  Response _unavailableResponse(PlaybackUnavailableException error) {
    final primary = _safeError(error.primaryError);
    final body = jsonEncode({
      'state': 'unavailable',
      'action': 'offer_download',
      'requiresConsent': true,
      'trackId': error.trackId,
      'offline': error.offline,
      'message': error.offline
          ? "Couldn't reach DeeMusiq servers — check your connection and try again."
          : 'This track is temporarily unavailable. Download it when you are ready to keep listening.',
      'primaryError': primary,
    });
    return Response(
      503,
      body: body,
      headers: {
        'content-type': ['application/json; charset=utf-8'],
        'retry-after': ['5'],
        playbackUnavailableHeader: ['unavailable'],
        playbackDownloadActionHeader: ['offer_download'],
        playbackPrimaryErrorHeader: [primary],
        if (error.offline) playbackOfflineHeader: ['true'],
      },
    );
  }

  dio_lib.Response<dynamic> _addFallbackHeaders(
    dio_lib.Response<dynamic> response,
    Object primaryError,
  ) {
    final headers = Map<String, List<String>>.from(response.headers.map);
    headers[playbackFallbackHeader] = ['local'];
    headers[playbackPrimaryErrorHeader] = [_safeError(primaryError)];
    return dio_lib.Response<dynamic>(
      requestOptions: response.requestOptions,
      data: response.data,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      headers: Headers.fromMap(headers),
      isRedirect: response.isRedirect,
    );
  }

  /// Points the player at the loopback manifest endpoint instead of the raw
  /// upstream manifest, so HLS segment requests flow back through this proxy
  /// (uniform session headers, access gating, single place to refresh URLs).
  dio_lib.Response<Uint8List> _localManifestRedirect(
    Request request,
    String trackId,
  ) {
    final base = request.requestedUri;
    final location =
        '${base.scheme}://${base.authority}/stream/${Uri.encodeComponent(trackId)}/manifest';
    return dio_lib.Response<Uint8List>(
      statusCode: 302,
      statusMessage: 'Manifest Redirect',
      headers: Headers.fromMap({
        'location': [location],
      }),
      requestOptions: RequestOptions(path: location),
      data: Uint8List(0),
      isRedirect: true,
    );
  }

  /// Serves the track's adaptive manifest. HLS playlists are rewritten so
  /// every segment (and encryption-key) URI flows back through
  /// `/stream/<trackId>/segment`, inheriting the proxy's session headers.
  /// DASH MPDs redirect to the raw URL: mpv parses MPD natively, and segment
  /// templates ($Number$/$Time$) cannot be URL-rewritten safely.
  Future<Response> getStreamManifest(Request request, String trackId) async {
    try {
      final track = playlist.tracks
          .whereType<DeeMusiqFullTrackObject>()
          .firstWhereOrNull((t) => t.id == trackId);
      if (track == null) {
        return Response.notFound('Track not found in the current queue');
      }
      final sourcedTrack = await ref.read(sourcedTrackProvider(track).future);

      final String url;
      try {
        url = await _resolveRemoteUrl(sourcedTrack);
      } catch (error, stackTrace) {
        throw PlaybackUnavailableException(
          track.id,
          error,
          stackTrace,
          offline: isNetworkLevelPlaybackError(error),
        );
      }

      final manifestResponse = await dio.get<String>(
        url,
        options: _remoteOptions(
          url,
          request.headers,
          responseType: ResponseType.plain,
        ),
      );
      final body = manifestResponse.data;
      final kind = manifestContentType(
            manifestResponse.headers.value(Headers.contentTypeHeader),
          ) ??
          manifestContentTypeFromUrl(url);
      if (kind == null || body == null || body.trim().isEmpty) {
        return Response.internalServerError(
          body: 'Remote source is not an HLS/DASH manifest',
        );
      }

      if (kind == 'application/dash+xml') {
        return Response.found(url);
      }

      return Response.ok(
        rewriteHlsManifest(body, url, trackId),
        headers: {
          'content-type': kind,
        },
      );
    } on PlaybackUnavailableException catch (error) {
      _reportPrimaryError(error.primaryError, error.primaryStackTrace);
      return _unavailableResponse(error);
    } catch (error, stackTrace) {
      AppLogger.reportError(error, stackTrace);
      if (isNetworkLevelPlaybackError(error)) {
        return _unavailableResponse(
          PlaybackUnavailableException(
            trackId,
            error,
            stackTrace,
            offline: true,
          ),
        );
      }
      return Response.internalServerError(
        body: jsonEncode({'message': error.toString()}),
        headers: {
          'content-type': ['application/json; charset=utf-8']
        },
      );
    }
  }

  /// Proxies a single HLS segment (or encryption key) whose URL was minted by
  /// [getStreamManifest]. The player's Range header is forwarded upstream.
  ///
  /// The `sig` query param is REQUIRED: it is the HMAC-SHA256 of the `url`
  /// value under a per-process random key (see [_signSegmentUrl]), so only
  /// URLs this server itself minted in a rewritten manifest are fetched.
  /// Unsigned or badly-signed requests are rejected — the endpoint must not
  /// be an open proxy to arbitrary URLs for any local caller.
  Future<Response> getStreamSegment(Request request, String trackId) async {
    final segmentUrl = request.requestedUri.queryParameters['url'];
    if (segmentUrl == null || segmentUrl.isEmpty) {
      return Response.badRequest(body: 'Missing segment url');
    }
    final signature = request.requestedUri.queryParameters['sig'];
    if (signature == null ||
        !_verifySegmentSignature(segmentUrl, signature)) {
      return Response.forbidden('Invalid segment signature');
    }
    try {
      _validateRemoteUrl(segmentUrl);
    } on FormatException {
      return Response.forbidden('Invalid segment url');
    }

    try {
      final upstream = await dio.get<ResponseBody>(
        segmentUrl,
        options: _remoteOptions(
          segmentUrl,
          request.headers,
          responseType: ResponseType.stream,
        ),
      );
      final headers = <String, List<String>>{};
      for (final name in const [
        'content-type',
        'content-length',
        'content-range',
        'accept-ranges',
        'etag',
      ]) {
        final value = upstream.headers.value(name);
        if (value != null) headers[name] = [value];
      }
      return Response(
        upstream.statusCode ?? 200,
        body: upstream.data?.stream,
        headers: headers,
      );
    } catch (error, stackTrace) {
      AppLogger.reportError(error, stackTrace, 'segment proxy $trackId');
      return Response(502, body: 'Failed to fetch segment');
    }
  }

  Future<Response> headStreamTrackId(Request request, String trackId) async {
    try {
      final sourcedTrack = await _getSourcedTrack(request, trackId);
      if (sourcedTrack == null) {
        return Response.notFound('Track not found in the current queue');
      }
      final res = await streamTrackInformation(request, sourcedTrack);
      if (res == null) {
        throw StateError('No response for ${sourcedTrack.query.id}');
      }
      return Response(
        res.statusCode!,
        headers: res.headers.map,
      );
    } on PlaybackUnavailableException catch (error) {
      _reportPrimaryError(error.primaryError, error.primaryStackTrace);
      return _unavailableResponse(error);
    } catch (error, stackTrace) {
      AppLogger.reportError(error, stackTrace);
      // Backend unreachable while resolving the track source — answer with
      // the same "unavailable (offline)" contract instead of a bare 500, so
      // the player shows a clear message instead of skip-storming the queue.
      if (isNetworkLevelPlaybackError(error)) {
        return _unavailableResponse(
          PlaybackUnavailableException(
            trackId,
            error,
            stackTrace,
            offline: true,
          ),
        );
      }
      return Response.internalServerError(
        body: jsonEncode({'message': error.toString()}),
        headers: {
          'content-type': ['application/json; charset=utf-8']
        },
      );
    }
  }

  Future<Response> getStreamTrackId(Request request, String trackId) async {
    try {
      final sourcedTrack = await _getSourcedTrack(request, trackId);
      if (sourcedTrack == null) {
        return Response.notFound('Track not found in the current queue');
      }
      final res = await streamTrack(
        request,
        sourcedTrack,
        request.headers,
      );
      if (res == null) {
        throw StateError('No response for ${sourcedTrack.query.id}');
      }
      if (res.isRedirect) {
        final location = res.headers.value('location');
        if (location != null) return Response.found(location);
      }
      if (res.data is ResponseBody) {
        return Response(
          res.statusCode!,
          body: (res.data as ResponseBody).stream,
          headers: res.headers.map,
        );
      }
      if (res.data is Stream<List<int>>) {
        return Response(
          res.statusCode!,
          body: res.data,
          headers: res.headers.map,
        );
      }
      return Response(
        res.statusCode!,
        body: res.data,
        headers: res.headers.map,
      );
    } on PlaybackUnavailableException catch (error) {
      _reportPrimaryError(error.primaryError, error.primaryStackTrace);
      return _unavailableResponse(error);
    } catch (error, stackTrace) {
      AppLogger.reportError(error, stackTrace);
      if (isNetworkLevelPlaybackError(error)) {
        return _unavailableResponse(
          PlaybackUnavailableException(
            trackId,
            error,
            stackTrace,
            offline: true,
          ),
        );
      }
      return Response.internalServerError(
        body: jsonEncode({'message': error.toString()}),
        headers: {
          'content-type': ['application/json; charset=utf-8']
        },
      );
    }
  }

  /// Streams a DRM-protected offline download (`<name>.deemusiq` in the
  /// app-private documents directory), decrypted IN MEMORY via the offline
  /// DRM service — plaintext never lands in a temp file. The license gate
  /// (OfflineLicenseManager) runs inside [OfflineTrackEncryption.decrypt]:
  /// a locked license answers 403 so the UI can show the "reconnect to renew"
  /// state; a missing/corrupt/tampered file (or a retired key generation)
  /// answers 404.
  Future<Response> getOfflineTrack(Request request, String name) async {
    try {
      final plain = await OfflineTrackEncryption.instance.decrypt(name);
      final audioName = name.toLowerCase().endsWith('.deemusiq')
          ? name.substring(0, name.length - '.deemusiq'.length)
          : name;
      final contentType =
          lookupMimeType(audioName) ?? 'application/octet-stream';

      _RequestedRange? range;
      try {
        range = _parseRequestedRange(request.headers);
      } catch (_) {
        return Response(
          416,
          body: 'Requested range is not available',
          headers: {'content-range': 'bytes */${plain.length}'},
        );
      }

      if (range == null) {
        return Response.ok(
          plain,
          headers: {
            'content-type': contentType,
            'content-length': '${plain.length}',
            'accept-ranges': 'bytes',
          },
        );
      }

      final start = range.start;
      final end = range.end != null && range.end! < plain.length
          ? range.end!
          : plain.length - 1;
      if (start < 0 || start >= plain.length || end < start) {
        return Response(
          416,
          body: 'Requested range is not available',
          headers: {'content-range': 'bytes */${plain.length}'},
        );
      }
      final slice = Uint8List.fromList(plain.sublist(start, end + 1));
      return Response(
        206,
        body: slice,
        headers: {
          'content-type': contentType,
          'content-length': '${slice.length}',
          'content-range': 'bytes $start-$end/${plain.length}',
          'accept-ranges': 'bytes',
        },
      );
    } on OfflineTrackLicenseException catch (e) {
      return Response.forbidden(
        jsonEncode({'message': e.message}),
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    } on OfflineTrackDecryptException catch (e) {
      return Response.notFound(
        jsonEncode({'message': e.message}),
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    } catch (error, stackTrace) {
      AppLogger.reportError(error, stackTrace);
      return Response.internalServerError(
        body: jsonEncode({'message': error.toString()}),
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    }
  }

  Future<Response> togglePlayback(Request request) async {
    audioPlayer.isPlaying
        ? await audioPlayer.pause()
        : await audioPlayer.resume();
    return Response.ok('Playback toggled');
  }

  Future<Response> previousTrack(Request request) async {
    await audioPlayer.skipToPrevious();
    return Response.ok('Previous track');
  }

  Future<Response> nextTrack(Request request) async {
    await audioPlayer.skipToNext();
    return Response.ok('Next track');
  }

  /// Size cap for the on-device audio cache. Tracks in the current month's
  /// Top 50 (see `MonthlyPlaysNotifier`) are pinned and never evicted; the
  /// rest rotate out least-recently-used first once the cache grows past
  /// this cap.
  static const maxCacheSizeBytes = 1536 * 1024 * 1024;
}

class _CachedUrlEntry {
  final String url;
  final DateTime cachedAt;
  _CachedUrlEntry(this.url) : cachedAt = DateTime.now().toUtc();

  bool get isValid =>
      DateTime.now().toUtc().difference(cachedAt).inSeconds <
      ServerPlaybackRoutes._urlCacheTtlSeconds;
}

class _CacheFile {
  final String path;
  final DateTime modified;
  final int size;
  _CacheFile(this.path, this.modified, this.size);
}

class _VerifiedLocalCopy {
  final File file;
  final String sha256;
  final int length;
  const _VerifiedLocalCopy(this.file, this.sha256, this.length);
}

class _CacheMetadata {
  final String trackId;
  final String? sourceId;
  final String sha256;
  final int length;
  final String? etag;
  final String? lastModified;
  final String? contentType;
  final String? sourceUrl;
  final int? totalLength;

  const _CacheMetadata({
    required this.trackId,
    required this.sourceId,
    required this.sha256,
    required this.length,
    required this.etag,
    required this.lastModified,
    required this.contentType,
    required this.sourceUrl,
    required this.totalLength,
  });

  Map<String, dynamic> toJson() => {
        'trackId': trackId,
        'sourceId': sourceId,
        'sha256': sha256,
        'length': length,
        'etag': etag,
        'lastModified': lastModified,
        'contentType': contentType,
        'sourceUrl': sourceUrl,
        'totalLength': totalLength,
      };

  static _CacheMetadata? fromJson(Object? value) {
    if (value is! Map) return null;
    final map = Map<String, dynamic>.from(value);
    final trackId = map['trackId'];
    final sha256 = normalizeSha256(map['sha256']?.toString());
    final length = map['length'];
    if (trackId is! String ||
        trackId.isEmpty ||
        sha256 == null ||
        length is! num ||
        length.toInt() <= 0) {
      return null;
    }
    return _CacheMetadata(
      trackId: trackId,
      sourceId: map['sourceId']?.toString(),
      sha256: sha256,
      length: length.toInt(),
      etag: _normaliseOptionalHeader(map['etag']?.toString()),
      lastModified: _normaliseOptionalHeader(map['lastModified']?.toString()),
      contentType: _normaliseOptionalHeader(map['contentType']?.toString()),
      sourceUrl: _normaliseOptionalHeader(map['sourceUrl']?.toString()),
      totalLength: map['totalLength'] is num
          ? (map['totalLength'] as num).toInt()
          : length.toInt(),
    );
  }
}

class _RemoteHeaders {
  final int? totalLength;
  final String? sha256;
  final String? etag;
  final String? lastModified;
  final bool hls;
  const _RemoteHeaders({
    required this.totalLength,
    required this.sha256,
    required this.etag,
    required this.lastModified,
    required this.hls,
  });
}

class _RemoteBody {
  final int? expectedLength;
  final int? totalLength;
  final String? sha256;
  final String? etag;
  final String? lastModified;
  final bool hls;
  final bool cacheable;
  const _RemoteBody({
    required this.expectedLength,
    required this.totalLength,
    required this.sha256,
    required this.etag,
    required this.lastModified,
    required this.hls,
    required this.cacheable,
  });
}

class _RequestedRange {
  final int start;
  final int? end;
  const _RequestedRange(this.start, this.end);
}

class _ContentRangeValue {
  final int start;
  final int end;
  final int total;
  const _ContentRangeValue(this.start, this.end, this.total);
}

class _DigestCollector implements Sink<Digest> {
  Digest? value;

  @override
  void add(Digest value) {
    this.value = value;
  }

  @override
  void close() {}
}

Future<_CacheMetadata?> _readCacheMetadata(File file) async {
  for (final metadataFile in _metadataFiles(file)) {
    if (!await metadataFile.exists()) continue;
    try {
      final decoded = jsonDecode(await metadataFile.readAsString());
      final metadata = _CacheMetadata.fromJson(decoded);
      if (metadata != null) return metadata;
    } catch (_) {}
  }
  return null;
}

Future<void> _writeCacheMetadata(
  File file,
  _CacheMetadata metadata,
) async {
  final metadataFile = _metadataFiles(file).first;
  final temporaryFile = File(
    '${metadataFile.path}.${_uniqueToken()}.tmp',
  );
  try {
    await temporaryFile.writeAsString(
      jsonEncode(metadata.toJson()),
      flush: true,
    );
    await _atomicReplace(temporaryFile, metadataFile);
    for (final oldMetadata in _metadataFiles(file).skip(1)) {
      await _deleteQuietly(oldMetadata);
    }
  } finally {
    await _deleteQuietly(temporaryFile);
  }
}

Iterable<File> _metadataFiles(File file) sync* {
  final pathHash = sha256.convert(utf8.encode(file.absolute.path)).toString();
  yield File(join(file.parent.path, '.deemusiq-$pathHash.json'));
  yield File('${file.path}.meta.json');
}

Future<File> _promoteCacheFile(
  File source,
  String hash,
  String extension,
  String sourceId,
) async {
  final directory = source.parent;
  final target = File(
    join(directory.path, _contentAddressedName(hash, extension, sourceId)),
  );
  if (await target.exists()) {
    final existingHash = await _sha256File(target);
    if (existingHash == hash) {
      await _deleteQuietly(source);
      return target;
    }
  }
  await _atomicReplace(source, target);
  return target;
}

/// Trims [cacheDir] down to [maxSizeBytes]: temporary files (interrupted
/// downloads, in-flight renames) are always removed; when the remaining
/// audio files exceed the cap, the least recently used ones (by file mtime —
/// bumped on every local serve) are deleted until the cache is back under
/// 80% of the cap.
///
/// Files whose metadata names a track in [pinnedTrackIds] (the current
/// month's Top 50) are never evicted — they still count toward the total,
/// so if the pinned set alone exceeds the cap everything unpinned goes and
/// the sweep stops. Files without readable metadata are treated as unpinned.
/// Metadata sidecars are kept (pinning and verification both read them);
/// a sidecar is deleted together with its audio file.
Future<void> evictMusicCacheDir({
  required Directory cacheDir,
  required Set<String> pinnedTrackIds,
  required int maxSizeBytes,
}) async {
  if (!await cacheDir.exists()) return;

  final files = <File>[];
  await for (final entity in cacheDir.list()) {
    if (entity is! File) continue;
    if (_isMetadataPath(entity.path)) continue;
    if (_isTemporaryCachePath(entity.path)) {
      await _deleteQuietly(entity);
      continue;
    }
    files.add(entity);
  }
  if (files.isEmpty) return;

  var totalSize = 0;
  final sizedFiles = <_CacheFile>[];
  for (final file in files) {
    try {
      final stat = await file.stat();
      totalSize += stat.size;
      sizedFiles.add(_CacheFile(file.path, stat.modified, stat.size));
    } catch (error, stackTrace) {
      _reportCacheError(error, stackTrace, file.path);
    }
  }
  if (totalSize <= maxSizeBytes) return;

  final evictable = <_CacheFile>[];
  for (final cacheFile in sizedFiles) {
    String? trackId;
    try {
      trackId = (await _readCacheMetadata(File(cacheFile.path)))?.trackId;
    } catch (_) {}
    if (trackId != null && pinnedTrackIds.contains(trackId)) continue;
    evictable.add(cacheFile);
  }

  evictable.sort((a, b) => a.modified.compareTo(b.modified));
  for (final cacheFile in evictable) {
    if (totalSize <= maxSizeBytes * 0.8) break;
    try {
      final file = File(cacheFile.path);
      final removedSize = cacheFile.size;
      await file.delete();
      for (final metadata in _metadataFiles(file)) {
        await _deleteQuietly(metadata);
      }
      totalSize -= removedSize;
    } catch (error, stackTrace) {
      _reportCacheError(error, stackTrace, cacheFile.path);
    }
  }
}

/// Sentinel for a body that grew past its advertised length — corruption,
/// never resumable.
class _ResponseOverflowError implements Exception {
  @override
  String toString() => 'Response exceeded expected length';
}

/// Wraps a remote body with integrity checks and transparent resume: when the
/// connection drops mid-track (or the server closes early), the stream is
/// re-opened with `Range: bytes=<baseOffset+received>-` via [reopen] and
/// stitched onto what was already delivered, up to [maxResumes] times — the
/// player never sees the interruption. Resume only happens when the total
/// [expectedLength] is known, so stitched bytes can be validated.
Stream<Uint8List> resumableCheckedStream(
  Stream<Uint8List> source, {
  required Future<Stream<Uint8List>> Function(int offset) reopen,
  int baseOffset = 0,
  int? expectedLength,
  String? expectedHash,
  int maxResumes = 3,
  void Function(int received, int resumeAttempt, Object? error)? onResume,
}) async* {
  var received = 0;
  final digestSink = expectedHash == null ? null : _DigestCollector();
  final digestInput =
      digestSink == null ? null : sha256.startChunkedConversion(digestSink);

  var current = source;
  var resumes = 0;

  while (true) {
    Object? streamError;
    try {
      await for (final chunk in current) {
        if (expectedLength != null &&
            received + chunk.length > expectedLength) {
          throw _ResponseOverflowError();
        }
        received += chunk.length;
        digestInput?.add(chunk);
        yield chunk;
      }
    } on _ResponseOverflowError {
      digestInput?.close();
      throw StateError('Response exceeded expected length');
    } catch (error) {
      streamError = error;
    }

    final truncated = expectedLength != null && received < expectedLength;

    if (streamError == null && !truncated) {
      break;
    }

    if (!truncated || resumes >= maxResumes) {
      digestInput?.close();
      if (streamError != null) throw streamError;
      throw StateError(
        'Response ended at $received bytes instead of $expectedLength',
      );
    }

    resumes++;
    onResume?.call(received, resumes, streamError);
    current = await reopen(baseOffset + received);
  }

  digestInput?.close();
  if (expectedLength == null && received == 0) {
    throw StateError('Response contained no audio bytes');
  }
  if (expectedHash != null && digestSink?.value?.toString() != expectedHash) {
    throw StateError('Response hash did not match the advertised digest');
  }
}

_ContentRangeValue? _parseContentRangeValue(String? value) {
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
  return _ContentRangeValue(start, end, total);
}

bool _hasContentEncoding(Headers headers) {
  final value = headers.value(Headers.contentEncodingHeader);
  if (value == null) return false;
  final normalized = value.trim().toLowerCase();
  return normalized.isNotEmpty && normalized != 'identity';
}

/// Returns the canonical content-type when [contentType] denotes an HLS or
/// DASH manifest, else null. HLS variants cover the Apple type plus the
/// de-facto `application/x-mpegurl`/`audio/mpegurl` spellings.
String? manifestContentType(String? contentType) {
  final value = contentType?.toLowerCase();
  if (value == null) return null;
  if (value.contains('application/vnd.apple.mpegurl') ||
      value.contains('application/x-mpegurl') ||
      value.contains('audio/mpegurl')) {
    return 'application/vnd.apple.mpegurl';
  }
  if (value.contains('application/dash+xml')) {
    return 'application/dash+xml';
  }
  return null;
}

/// Content-type fallback for manifest URLs served with a generic type.
String? manifestContentTypeFromUrl(String url) {
  final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
  if (path.endsWith('.mpd')) return 'application/dash+xml';
  if (path.endsWith('.m3u8')) return 'application/vnd.apple.mpegurl';
  return null;
}

/// Resolves a segment reference against its manifest URL (absolute,
/// root-relative and relative forms).
String resolveSegmentUrl(String url, String manifestBase, Uri origin) {
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  if (url.startsWith('/')) return '${origin.scheme}://${origin.authority}$url';
  return '$manifestBase/$url';
}

/// Rewrites every segment URI of an HLS playlist to flow through the
/// loopback segment endpoint. Root-relative paths resolve against the
/// manifest URL's origin, so no absolute host needs to be baked in.
String rewriteHlsManifest(String manifest, String baseUrl, String trackId) {
  // Directory part of the manifest URL. A bare origin ("https://host") has no
  // path slash — its last '/' is the scheme's own, so keep the whole URL.
  final lastSlash = baseUrl.lastIndexOf('/');
  final manifestBase = lastSlash > 8 ? baseUrl.substring(0, lastSlash) : baseUrl;
  final origin = Uri.parse(baseUrl);
  final segmentPath = '/stream/${Uri.encodeComponent(trackId)}/segment?url=';
  String proxied(String raw) {
    final resolved = resolveSegmentUrl(raw, manifestBase, origin);
    return '$segmentPath${Uri.encodeComponent(resolved)}'
        '&sig=${_signSegmentUrl(resolved)}';
  }

  final out = <String>[];
  for (final rawLine in manifest.split('\n')) {
    final line = rawLine.trimRight();
    if (line.isEmpty) {
      out.add(line);
      continue;
    }
    if (line.startsWith('#')) {
      // EXT-X-KEY / EXT-X-MAP carry URIs inside tag attributes.
      if (line.startsWith('#EXT-X-KEY') || line.startsWith('#EXT-X-MAP')) {
        out.add(
          line.replaceAllMapped(
            RegExp('URI="([^"]+)"'),
            (match) => 'URI="${proxied(match.group(1)!)}"',
          ),
        );
      } else {
        out.add(line);
      }
      continue;
    }
    out.add(proxied(line));
  }
  return out.join('\n');
}

int? _optionalHeaderInt(Headers headers, String name) {
  final value = headers.value(name);
  if (value == null || value.trim().isEmpty) return null;
  final parsed = int.tryParse(value.trim());
  if (parsed == null || parsed < 0) {
    throw FormatException('Invalid $name header: $value');
  }
  return parsed;
}

String? _normaliseOptionalHeader(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _normaliseValidator(String value) => value.trim();

String _cacheExtension(SourcedTrack track) {
  final extension = track.qualityPreset?.getFileExtension() ?? 'mp4';
  final normalized = extension.toLowerCase().replaceAll(
        RegExp('[^a-z0-9]'),
        '',
      );
  return normalized.isEmpty ? 'mp4' : normalized;
}

String _contentAddressedName(
  String hash,
  String extension,
  String sourceId,
) {
  final safeSourceId = sourceId.replaceAll(RegExp('[^a-zA-Z0-9_-]'), '_');
  return safeSourceId.isEmpty
      ? '$hash.$extension'
      : '$hash-$safeSourceId.$extension';
}

_RequestedRange? _parseRequestedRange(Map<String, String> headers) {
  final value = headers['range'] ?? headers['Range'];
  if (value == null || value.trim().isEmpty) return null;
  final parsed = RangeHeader.parse(value);
  if (parsed.start < 0) throw const FormatException('Invalid range start');
  if (parsed.end != null && parsed.end! < parsed.start) {
    throw const FormatException('Invalid range end');
  }
  return _RequestedRange(parsed.start, parsed.end);
}

void _validateRemoteUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null ||
      !uri.hasAuthority ||
      (uri.scheme != 'http' && uri.scheme != 'https') ||
      uri.host.isEmpty) {
    throw const FormatException('Invalid remote audio URL');
  }
}

/// Per-process random key that signs `/stream/<id>/segment?url=` links minted
/// by [rewriteHlsManifest]. The segment endpoint fetches arbitrary URLs for
/// any caller that can reach the loopback server; requiring an HMAC of the
/// URL means only URLs this process itself handed out are fetchable (the key
/// never leaves the process), closing the open-SSRF surface. Regenerated on
/// every app start, which also invalidates links from a previous run.
final _segmentProxySecret = (() {
  final rng = Random.secure();
  return Uint8List.fromList(List.generate(32, (_) => rng.nextInt(256)));
})();

String _signSegmentUrl(String url) =>
    Hmac(sha256, _segmentProxySecret).convert(utf8.encode(url)).toString();

/// Constant-time verification of the `sig` query param on segment URLs.
bool _verifySegmentSignature(String url, String provided) {
  final expected = _signSegmentUrl(url);
  if (expected.length != provided.length) return false;
  var diff = 0;
  for (var i = 0; i < expected.length; i++) {
    diff |= expected.codeUnitAt(i) ^ provided.codeUnitAt(i);
  }
  return diff == 0;
}

void _putHeader(Map<String, dynamic> headers, String name, dynamic value) {
  headers.removeWhere((key, _) => key.toLowerCase() == name.toLowerCase());
  if (value != null) headers[name] = value;
}

bool _isMetadataPath(String path) {
  final name = basename(path);
  return name.endsWith('.meta.json') ||
      (name.startsWith('.deemusiq-') && name.endsWith('.json'));
}

bool _isTemporaryCachePath(String path) {
  final name = basename(path);
  return _isMetadataPath(path) ||
      name.endsWith('.part') ||
      name.contains('.part-') ||
      name.contains('.chunk-') ||
      name.contains('.replace-') ||
      name.endsWith('.tmp');
}

String _uniqueToken() {
  final random = Random();
  return '${DateTime.now().microsecondsSinceEpoch}-${random.nextInt(1 << 32)}';
}

Future<String> _sha256File(File file) async {
  final digest = await sha256.bind(file.openRead()).first;
  return digest.toString();
}

Future<void> _atomicReplace(File source, File target) async {
  if (source.path == target.path) return;
  try {
    await source.rename(target.path);
    return;
  } catch (_) {
    if (!await target.exists()) rethrow;
    final backup = File('${target.path}.${_uniqueToken()}.replace');
    await target.rename(backup.path);
    try {
      await source.rename(target.path);
    } catch (error, stackTrace) {
      try {
        await backup.rename(target.path);
      } catch (_) {}
      Error.throwWithStackTrace(error, stackTrace);
    }
    try {
      await backup.delete();
    } catch (_) {}
  }
}

Future<void> _deleteQuietly(FileSystemEntity entity) async {
  try {
    if (await entity.exists()) await entity.delete(recursive: true);
  } catch (_) {}
}

void _logInfo(String message) {
  try {
    AppLogger.log.i(message);
  } catch (_) {}
}

void _reportCacheError(Object error, StackTrace stackTrace, String context) {
  try {
    AppLogger.reportError(error, stackTrace, context);
  } catch (_) {}
}

void _reportPrimaryError(Object error, StackTrace stackTrace) {
  try {
    AppLogger.reportError(error, stackTrace, 'playback remote source');
  } catch (_) {}
}

String _safeError(Object error) {
  final value = error
      .toString()
      .replaceAll(RegExp(r'[\r\n]'), ' ')
      .replaceAll(RegExp(r'[^\x20-\x7e]'), '?')
      .trim();
  return value.length <= 512 ? value : value.substring(0, 512);
}

final serverPlaybackRoutesProvider =
    Provider((ref) => ServerPlaybackRoutes(ref));
