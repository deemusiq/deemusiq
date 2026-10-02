import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:deemusiq/services/youtube_engine/quickjs_solver.dart';
import 'package:deemusiq/services/youtube_engine/youtube_engine.dart';
import 'package:youtube_explode_dart/js_challenge.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'dart:async';
import 'package:deemusiq/services/logger/logger.dart';

/// It contains methods that are computationally expensive
class IsolatedYoutubeExplode {
  final Isolate _isolate;
  final SendPort _sendPort;
  final ReceivePort _receivePort;

  IsolatedYoutubeExplode._(
    Isolate isolate,
    ReceivePort receivePort,
    SendPort sendPort,
  )   : _isolate = isolate,
        _receivePort = receivePort,
        _sendPort = sendPort;

  static IsolatedYoutubeExplode? _instance;

  static IsolatedYoutubeExplode get instance {
    if (_instance == null) {
      throw StateError(
        'IsolatedYoutubeExplode has not been initialized. '
        'Call IsolatedYoutubeExplode.initialize() first.',
      );
    }
    return _instance!;
  }

  static bool get isInitialized => _instance != null;

  static Completer<void>? _initLock;

  static Future<void> initialize() async {
    if (_instance != null) return;
    if (_initLock != null) {
      await _initLock!.future;
      return;
    }
    _initLock = Completer<void>();
    try {
      final completer = Completer<SendPort>();

      final receivePort = ReceivePort();

      /// Listen for the main isolate to set the main port
      final subscription = receivePort.listen((message) {
        if (message is SendPort) {
          completer.complete(message);
        }
      });

      final isolate = await Isolate.spawn(
        _isolateEntry,
        receivePort.sendPort,
      ).timeout(const Duration(seconds: 10)); // Don't hang forever

      _instance = IsolatedYoutubeExplode._(
        isolate,
        receivePort,
        await completer.future.timeout(const Duration(seconds: 10)),
      );

      if (completer.isCompleted) {
        subscription.cancel();
      }
    } finally {
      _initLock?.complete();
      _initLock = null;
    }
  }

  static Future<void> _isolateEntry(SendPort mainSendPort) async {
    final receivePort = ReceivePort();
    // EJS solver for n-cipher/signature challenges ("not a bot" pages).
    // Degrade to plain explode when the QuickJS runtime or module download
    // fails — extraction still works for unchallenged videos.
    BaseJSChallengeSolver? jsSolver;
    try {
      jsSolver = await QuickJSEJSSolver.init();
    } catch (e, stack) {
      debugPrint('IsolatedYoutubeExplode: EJS solver init failed, continuing without: $e');
      AppLogger.reportError(e, stack, 'IsolatedYoutubeExplode EJS solver init');
    }
    final youtubeExplode = YoutubeExplode(jsSolver: jsSolver);
    final stopWatch = kDebugMode ? Stopwatch() : null;

    /// Send the main port to the main isolate
    mainSendPort.send(receivePort.sendPort);

    receivePort.listen((message) async {
      final SendPort replyPort = message[0];
      final String methodName = message[1];
      final List<dynamic> arguments = message[2];

      if (stopWatch != null) {
        if (stopWatch.isRunning) {
          stopWatch.stop();
          final symbol = stopWatch.elapsedMilliseconds < 1000 ? "⚠️" : "⏱️";
          debugPrint(
            "$symbol YoutubeExplode operation gap ${stopWatch.elapsedMilliseconds} ms",
          );
          stopWatch.reset();
        } else {
          stopWatch.start();
        }
      }

      // Run the requested method on YoutubeExplode
      try {
        var result = switch (methodName) {
          "search" => youtubeExplode.search
              .search(
                arguments[0] as String,
                filter: arguments.elementAtOrNull(1) ?? TypeFilters.video,
              )
              .then((s) => s.toList()),
          "searchChannels" => youtubeExplode.search
              .searchContent(
                arguments[0] as String,
                filter: TypeFilters.channel,
              )
              .then((s) =>
                  List<SearchChannel>.from(s.whereType<SearchChannel>())),
          "channel" =>
            youtubeExplode.channels.get(ChannelId(arguments[0] as String)),
          "video" => youtubeExplode.videos.get(arguments[0] as String),
          "manifest" => youtubeExplode.videos.streamsClient.getManifest(
              arguments[0] as String,
              requireWatchPage: arguments.elementAtOrNull(1) ?? true,
              ytClients: arguments.elementAtOrNull(2) as List<YoutubeApiClient>?,
            ),
          _ => throw ArgumentError('Invalid method name: $methodName'),
        };

        replyPort.send(await result);
      } catch (e, stack) {
        debugPrint('IsolatedYoutubeExplode: unhandled error in isolate: $e');
        debugPrintStack(stackTrace: stack);
        AppLogger.reportError(e, stack, 'IsolatedYoutubeExplode isolate error');
        replyPort.send(e); // Propagate error to caller
      }
    });
  }

  Future<T> _runMethod<T>(String methodName, List<dynamic> args) {
    final completer = Completer<T>();
    final responsePort = ReceivePort();

    responsePort.listen((message) {
      if (!completer.isCompleted) {
        if (message is Exception || message is Error) {
          completer.completeError(message);
        } else {
          completer.complete(message as T);
        }
        responsePort.close();
      }
    });

    _sendPort.send([responsePort.sendPort, methodName, args]);
    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        responsePort.close();
        throw TimeoutException(
          'YoutubeExplode isolate timed out on $methodName',
        );
      },
    );
  }

  Future<List<Video>> search(
    String query, {
    SearchFilter? filter,
  }) async {
    return _runMethod<List<Video>>("search", [query]);
  }

  Future<Video> video(String videoId) async {
    return _runMethod<Video>("video", [videoId]);
  }

  Future<Channel> channel(String channelId) async {
    return _runMethod<Channel>("channel", [channelId]);
  }

  Future<List<SearchChannel>> searchChannels(String query) async {
    return _runMethod<List<SearchChannel>>("searchChannels", [query]);
  }

  Future<StreamManifest> manifest(
    String videoId, {
    bool requireWatchPage = false,
    List<YoutubeApiClient>? ytClients,
  }) async {
    return _runMethod<StreamManifest>("manifest", [
      videoId,
      requireWatchPage,
      ytClients,
    ]);
  }

  void dispose() {
    _receivePort.close();
    _isolate.kill(priority: Isolate.immediate);
  }
}

class YouTubeExplodeEngine implements YouTubeEngine {
  static IsolatedYoutubeExplode get _youtubeExplode {
    if (!IsolatedYoutubeExplode.isInitialized) {
      AppLogger.log.w(
        'YouTubeExplodeEngine: IsolatedYoutubeExplode accessed before initialization',
      );
    }
    return IsolatedYoutubeExplode.instance;
  }

  @override
  bool get isAvailableForPlatform => true;

  @override
  Future<bool> isInstalled() async {
    return true;
  }

  @override
  Future<StreamManifest> getStreamManifest(String videoId) async {
    if (videoId.isEmpty) {
      throw ArgumentError('videoId must not be empty');
    }
    await IsolatedYoutubeExplode.initialize();

    final ytClients = [
      YoutubeApiClient.ios,
      YoutubeApiClient.androidVr,
      YoutubeApiClient.android,
    ];

    StreamManifest build(StreamManifest raw) {
      var audioStreams = raw.audioOnly.where(
        (stream) => stream.bitrate.bitsPerSecond >= 40960,
      );
      if (audioStreams.isEmpty) {
        audioStreams = raw.audioOnly;
      }
      return StreamManifest(
        audioStreams.map(
          (stream) => AudioOnlyStreamInfo(
            stream.videoId,
            stream.tag,
            stream.url,
            stream.container,
            stream.size,
            stream.bitrate,
            stream.audioCodec,
            switch (stream.bitrate.bitsPerSecond) {
              > 130 * 1024 => "high",
              > 64 * 1024 => "medium",
              _ => "low",
            },
            stream.fragments,
            stream.codec,
            stream.audioTrack,
          ),
        ),
      );
    }

    try {
      final streamManifest = await _youtubeExplode.manifest(
        videoId,
        requireWatchPage: false,
        ytClients: ytClients,
      );

      final manifest = build(streamManifest);
      if (manifest.audioOnly.isNotEmpty) return manifest;

      AppLogger.log.w('YouTubeExplode: fast path returned empty streams for $videoId, retrying with watch page');
      final retryManifest = await _youtubeExplode.manifest(
        videoId,
        requireWatchPage: true,
        ytClients: ytClients,
      );
      return build(retryManifest);
    } catch (e, stack) {
      AppLogger.log.w('YouTubeExplode: fast path failed for $videoId: ${e.toString()}, retrying with watch page');
      AppLogger.reportError(e, stack);
      try {
        final retryManifest = await _youtubeExplode.manifest(
          videoId,
          requireWatchPage: true,
          ytClients: ytClients,
        );
        return build(retryManifest);
      } catch (e2, stack2) {
        AppLogger.log.w('YouTubeExplode: watch page retry also failed for $videoId: ${e2.toString()}');
        AppLogger.reportError(e2, stack2);
        rethrow;
      }
    }
  }

  @override
  Future<Video> getVideo(String videoId) async {
    if (videoId.isEmpty) {
      throw ArgumentError('videoId must not be empty');
    }
    await IsolatedYoutubeExplode.initialize();
    try {
      return await _youtubeExplode.video(videoId);
    } catch (e, stack) {
      AppLogger.log.w('YouTubeExplode: Failed to get video for $videoId: ${e.toString()}');
      AppLogger.reportError(e, stack);
      rethrow;
    }
  }

  @override
  Future<(Video, StreamManifest)> getVideoWithStreamInfo(String videoId) async {
    await IsolatedYoutubeExplode.initialize();

    final video = await getVideo(videoId);
    final streamManifest = await getStreamManifest(videoId);

    return (video, streamManifest);
  }

  @override
  Future<List<Video>> searchVideos(String query) async {
    if (query.trim().isEmpty) {
      return const [];
    }
    await IsolatedYoutubeExplode.initialize();

    try {
      return await _youtubeExplode
          .search(
            query,
            filter: TypeFilters.video,
          )
          .then((searchList) => searchList.toList());
    } catch (e, stack) {
      AppLogger.log.w('YouTubeExplode: Search failed for "$query": ${e.toString()}');
      AppLogger.reportError(e, stack);
      rethrow;
    }
  }

  @override
  Future<Channel?> resolveChannel(String idOrName) async {
    final candidate = idOrName.trim();
    if (candidate.isEmpty) return null;
    await IsolatedYoutubeExplode.initialize();

    try {
      // Channel ids and channel URLs resolve directly; anything else is a
      // display name that goes through channel search first.
      final directId = ChannelId.parseChannelId(candidate);
      if (directId != null) {
        return await _youtubeExplode.channel(directId);
      }
      final results = await _youtubeExplode.searchChannels(candidate);
      final channelId = results.firstOrNull?.id;
      if (channelId == null) return null;
      return await _youtubeExplode.channel(channelId.value);
    } catch (e, stack) {
      AppLogger.log.w(
        'YouTubeExplode: channel resolution failed for "$idOrName": ${e.toString()}',
      );
      AppLogger.reportError(e, stack);
      return null;
    }
  }

  @override
  void dispose() {
    if (IsolatedYoutubeExplode.isInitialized) {
      IsolatedYoutubeExplode.instance.dispose();
    }
  }
}
