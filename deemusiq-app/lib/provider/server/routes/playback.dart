import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart' hide Response;
import 'package:dio/dio.dart' as dio_lib;
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart';
import 'package:shelf/shelf.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/models/parser/range_headers.dart';
import 'package:deemusiq/provider/audio_player/audio_player.dart';
import 'package:deemusiq/provider/audio_player/state.dart';

import 'package:deemusiq/provider/server/active_track_sources.dart';
import 'package:deemusiq/provider/server/sourced_track_provider.dart';
import 'package:deemusiq/provider/user_preferences/user_preferences_provider.dart';
import 'package:deemusiq/services/audio_player/audio_player.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/sourced_track/sourced_track.dart';
import 'package:deemusiq/utils/service_utils.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

final _deviceClients = Set.unmodifiable({
  YoutubeApiClient.ios,
  YoutubeApiClient.android,
  YoutubeApiClient.mweb,
  YoutubeApiClient.safari,
});

String? get _randomUserAgent => _deviceClients
    .elementAt(
      Random().nextInt(_deviceClients.length),
    )
    .payload["context"]["client"]["userAgent"];

class ServerPlaybackRoutes {
  final Ref ref;
  UserPreferences get userPreferences => ref.read(userPreferencesProvider);
  AudioPlayerState get playlist => ref.read(audioPlayerProvider);
  final Dio dio;
  final Map<String, _CachedUrlEntry> _urlCache = {};

  static const _urlCacheTtlSeconds = 30;

  ServerPlaybackRoutes(this.ref) : dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 15),
  ));

  Future<String> _getTrackCacheFilePath(SourcedTrack track) async {
    return join(
      await UserPreferencesNotifier.getMusicCacheDir(),
      ServiceUtils.sanitizeFilename(
        '${track.query.name} - ${track.query.artists.map((d) => d.name).join(",")} (${track.info.id}).${track.qualityPreset?.getFileExtension() ?? "mp4"}',
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
    final mediaIndex = medias.indexWhere((e) => e.uri == request.requestedUri.toString());
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
    SourcedTrack track,
  ) async {
    AppLogger.log.i(
      "HEAD request for track: ${track.query.name}\n"
      "Headers: ${request.headers}",
    );

    final trackCacheFile = File(await _getTrackCacheFilePath(track));

    if (await trackCacheFile.exists() && userPreferences.cacheMusic) {
      final fileLength = await trackCacheFile.length();

      return dio_lib.Response(
        statusCode: 200,
        headers: Headers.fromMap({
          "content-type": ["audio/${track.qualityPreset?.name ?? "mp4"}"],
          "content-length": ["$fileLength"],
          "accept-ranges": ["bytes"],
          "content-range": ["bytes 0-$fileLength/$fileLength"],
        }),
        requestOptions: RequestOptions(path: request.requestedUri.toString()),
      );
    }

    String? resolvedUrl = track.url;
    if (resolvedUrl == null) {
      final cached = _urlCache[track.query.id];
      if (cached != null && cached.isValid) {
        resolvedUrl = cached.url;
      } else {
        final swapped = await ref
            .read(sourcedTrackProvider(track.query).notifier)
            .swapWithNextSibling();
        resolvedUrl = swapped.url;
        if (resolvedUrl != null) {
          _urlCache[track.query.id] = _CachedUrlEntry(resolvedUrl);
        }
      }
    }
    if (resolvedUrl == null || resolvedUrl.isEmpty) return null;
    final url = resolvedUrl;

    final options = Options(
      headers: {
        "user-agent": _randomUserAgent,
        "Cache-Control": "max-age=3600",
        "Connection": "keep-alive",
        "host": Uri.parse(url).host,
      },
      validateStatus: (status) => status! < 400,
    );

    final res = await dio.head(url, options: options);

    return res;
  }

  Future<dio_lib.Response?> streamTrack(
    Request request,
    SourcedTrack track,
    Map<String, dynamic> headers,
  ) async {
    AppLogger.log.i(
      "GET request for track: ${track.query.name}\n"
      "Headers: ${request.headers}",
    );

    // Parse Range header for seeking support
    final rangeHeader = request.headers['range'] ?? request.headers['Range'];
    int? rangeStart, rangeEnd;
    if (rangeHeader != null) {
      try {
        final parsed = RangeHeader.parse(rangeHeader);
        rangeStart = parsed.start;
        rangeEnd = parsed.end;
      } catch (e, stack) {
        AppLogger.reportError(e, stack, 'playback: range header parse failed');
      }
    }

    final trackCacheFile = File(await _getTrackCacheFilePath(track));

    if (await trackCacheFile.exists() && userPreferences.cacheMusic) {
      final fileLength = await trackCacheFile.length();

      if (rangeStart != null) {
        final end = rangeEnd ?? fileLength - 1;
        final stream = trackCacheFile.openRead(rangeStart, end + 1);
        final contentLength = end - rangeStart + 1;

        return dio_lib.Response<Stream<List<int>>>(
          statusCode: 206,
          headers: Headers.fromMap({
            "content-type": ["audio/${track.qualityPreset?.name ?? "mp4"}"],
            "content-length": ["$contentLength"],
            "accept-ranges": ["bytes"],
            "content-range": [
              ContentRangeHeader(rangeStart, end, fileLength).toString(),
            ],
            "connection": ["close"],
          }),
          requestOptions: RequestOptions(path: request.requestedUri.toString()),
          data: stream,
        );
      }

      return dio_lib.Response<Stream<List<int>>>(
        statusCode: 200,
        headers: Headers.fromMap({
          "content-type": ["audio/${track.qualityPreset?.name ?? "mp4"}"],
          "content-length": ["$fileLength"],
          "accept-ranges": ["bytes"],
        }),
        requestOptions: RequestOptions(path: request.requestedUri.toString()),
        data: trackCacheFile.openRead(),
      );
    }

    AppLogger.log.i('streamTrack: resolving URL for ${track.query.name}');
    String? resolvedUrl = track.url;
    if (resolvedUrl == null) {
      final cached = _urlCache[track.query.id];
      if (cached != null && cached.isValid) {
        resolvedUrl = cached.url;
        AppLogger.log.i('streamTrack: using cached URL for ${track.query.id}');
      } else {
        AppLogger.log.i('streamTrack: url is null, trying swapWithNextSibling');
        try {
          final swapped = await ref
              .read(sourcedTrackProvider(track.query).notifier)
              .swapWithNextSibling();
          resolvedUrl = swapped.url;
          if (resolvedUrl != null) {
            _urlCache[track.query.id] = _CachedUrlEntry(resolvedUrl);
          }
          AppLogger.log.i('streamTrack: swapped URL ${resolvedUrl?.substring(0, resolvedUrl?.indexOf('?') ?? 80)}');
        } catch (e, stack) {
          AppLogger.log.w('streamTrack: swapWithNextSibling failed: $e');
          AppLogger.reportError(e, stack, 'streamTrack: swapWithNextSibling');
        }
      }
    }
    if (resolvedUrl == null || resolvedUrl.isEmpty) {
      AppLogger.log.e('streamTrack: FATAL no URL resolved for ${track.query.id}');
      throw Exception('No audio source for ${track.query.id}');
    }
    final url = resolvedUrl;

    final options = Options(
      headers: {
        ...headers,
        "user-agent": _randomUserAgent,
        "Cache-Control": "max-age=3600",
        "Connection": "keep-alive",
        "host": Uri.parse(url).host,
      },
      responseType: ResponseType.stream,
      validateStatus: (status) => status! < 400,
    );

    final contentLengthRes = await Future<dio_lib.Response?>.value(
      dio.head(
        url,
        options: options.copyWith(responseType: ResponseType.bytes),
      ),
    ).catchError((e, stack) async {
      AppLogger.reportError(e, stack);

      final sourcedTrack = await ref
          .read(sourcedTrackProvider(track.query).notifier)
          .refreshStreamingUrl();

      final refreshedUrl = sourcedTrack.url;
      if (refreshedUrl == null) throw Exception('No audio source after refresh');

      return dio.head(refreshedUrl, options: options);
    });

    // Redirect to m3u8 link directly as it handles range requests internally
    if (contentLengthRes?.headers.value("content-type") ==
        "application/vnd.apple.mpegurl") {
      return dio_lib.Response<Uint8List>(
        statusCode: 301,
        statusMessage: "M3U8 Redirect",
        headers: Headers.fromMap({
          "location": [url],
          "content-type": ["application/vnd.apple.mpegurl"],
        }),
        requestOptions: RequestOptions(path: request.requestedUri.toString()),
        isRedirect: true,
      );
    }

    final res = await dio.get<ResponseBody>(url, options: options);

    AppLogger.log.i(
      "Response for track: ${track.query.name}\n"
      "Status Code: ${res.statusCode}\n"
      "Headers: ${res.headers.map}",
    );

    if (!userPreferences.cacheMusic) {
      return res;
    }

    if (res.data == null) {
      AppLogger.log.w('streamTrack: empty response body for ${track.query.id}');
      throw Exception('Empty response from audio source');
    }
    final resStream = res.data!.stream.asBroadcastStream();

    final trackPartialCacheFile = File("${trackCacheFile.path}.part");
    if (!await trackPartialCacheFile.exists()) {
      await trackPartialCacheFile.create(recursive: true);
    }

    // Write the stream to the file based on the range
    final partialCacheFileSink =
        trackPartialCacheFile.openWrite(mode: FileMode.writeOnlyAppend);
    final contentRange = res.headers.value("content-range") != null
        ? ContentRangeHeader.parse(res.headers.value("content-range") ?? "")
        : ContentRangeHeader(0, 0, -1);

    resStream.listen(
      (data) {
        partialCacheFileSink.add(data);
      },
      onError: (e, stack) {
        partialCacheFileSink.close();
        AppLogger.reportError(e, stack, 'streamTrack write error');
        trackPartialCacheFile.delete().catchError((_) {});
      },
      onDone: () async {
        await partialCacheFileSink.close();

        final fileLength = await trackPartialCacheFile.length();
        if (fileLength == 0) {
          AppLogger.log.w('streamTrack: empty cache file for ${track.query.id}, cleaning up');
          await trackPartialCacheFile.delete().catchError((_) {});
          return;
        }
        if (contentRange.total > 0 && fileLength < contentRange.total) return;

        try {
          await trackPartialCacheFile.rename(trackCacheFile.path);
        } catch (e, stack) {
          AppLogger.log.w('streamTrack: rename failed for ${track.query.id}: $e');
          AppLogger.reportError(e, stack, 'streamTrack rename');
          await trackPartialCacheFile.delete().catchError((_) {});
          return;
        }

        await _evictCacheIfNeeded();

        if (track.qualityPreset?.getFileExtension() == "weba") return;

        final imageBytes = await ServiceUtils.downloadImage(
          track.query.album.images.asUrlString(
            placeholder: ImagePlaceholder.albumArt,
            index: 1,
          ),
        );

        await MetadataGod.writeMetadata(
          file: trackCacheFile.path,
          metadata: track.query.toMetadata(
            imageBytes: imageBytes,
            fileLength: fileLength,
          ),
        ).catchError((e, stackTrace) {
          AppLogger.reportError(e, stackTrace);
        });
      },
      cancelOnError: false,
    );

    res.data?.stream =
        resStream; // To avoid Stream has been already listened to exception
    return res;
  }

  static const _maxCacheSizeBytes = 500 * 1024 * 1024;

  Future<void> _evictCacheIfNeeded() async {
    try {
      final cacheDir = Directory(await UserPreferencesNotifier.getMusicCacheDir());
      if (!await cacheDir.exists()) return;

      final files = <FileSystemEntity>[];
      await for (final entity in cacheDir.list()) {
        if (entity is File) {
          if (entity.path.endsWith('.part')) {
            try { await entity.delete(); } catch (_) {}
            continue;
          }
          files.add(entity);
        }
      }

      if (files.isEmpty) return;

      var totalSize = 0;
      final sizedFiles = <_CacheFile>[];
      for (final f in files) {
        try {
          final stat = await f.stat();
          totalSize += stat.size;
          sizedFiles.add(_CacheFile(f.path, stat.modified, stat.size));
        } catch (_) {}
      }

      if (totalSize <= _maxCacheSizeBytes) return;

      sizedFiles.sort((a, b) => a.modified.compareTo(b.modified));
      for (final cf in sizedFiles) {
        if (totalSize <= _maxCacheSizeBytes * 0.8) break;
        try {
          final removedSize = cf.size;
          await File(cf.path).delete();
          totalSize -= removedSize;
          AppLogger.log.d('Cache evicted: ${cf.path}');
        } catch (_) {}
      }
    } catch (e, stack) {
      AppLogger.reportError(e, stack, '_evictCacheIfNeeded');
    }
  }

  /// @head('/stream/<trackId>')
  Future<Response> headStreamTrackId(Request request, String trackId) async {
    try {
      final sourcedTrack = await _getSourcedTrack(request, trackId);

      if (sourcedTrack == null) {
        return Response.notFound("Track not found in the current queue");
      }

      final res = await streamTrackInformation(
        request,
        sourcedTrack,
      );

      if (res == null) return Response.internalServerError();

      return Response(
        res.statusCode!,
        headers: res.headers.map,
      );
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
      return Response.internalServerError();
    }
  }

  /// @get('/stream/<trackId>')
  Future<Response> getStreamTrackId(Request request, String trackId) async {
    try {
      final sourcedTrack = await _getSourcedTrack(request, trackId);

      if (sourcedTrack == null) {
        return Response.notFound("Track not found in the current queue");
      }

      final res = await streamTrack(
        request,
        sourcedTrack,
        request.headers,
      );

      if (res == null) return Response.internalServerError();

      if (res.isRedirect) {
        final location = res.headers.value('location');
        if (location != null) {
          return Response.found(location);
        }
      }

      if (res.data is ResponseBody) {
        return Response(
          res.statusCode!,
          body: (res.data as ResponseBody).stream,
          headers: res.headers.map,
        );
      }

      return Response(
        res.statusCode!,
        body: res.data,
        headers: res.headers.map,
      );
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
      return Response.internalServerError();
    }
  }

  /// @get('/playback/toggle-playback')
  Future<Response> togglePlayback(Request request) async {
    audioPlayer.isPlaying
        ? await audioPlayer.pause()
        : await audioPlayer.resume();

    return Response.ok("Playback toggled");
  }

  /// @get('/playback/previous')
  Future<Response> previousTrack(Request request) async {
    await audioPlayer.skipToPrevious();
    return Response.ok("Previous track");
  }

  /// @get('/playback/next')
  Future<Response> nextTrack(Request request) async {
    await audioPlayer.skipToNext();
    return Response.ok("Next track");
  }
}

class _CachedUrlEntry {
  final String url;
  final DateTime cachedAt;
  _CachedUrlEntry(this.url) : cachedAt = DateTime.now();

  bool get isValid =>
      DateTime.now().difference(cachedAt).inSeconds < 30;
}

class _CacheFile {
  final String path;
  final DateTime modified;
  final int size;
  _CacheFile(this.path, this.modified, this.size);
}

final serverPlaybackRoutesProvider =
    Provider((ref) => ServerPlaybackRoutes(ref));
