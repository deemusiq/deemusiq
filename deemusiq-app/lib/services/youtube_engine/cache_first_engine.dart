import 'dart:io';

import 'package:deemusiq/services/youtube_engine/youtube_engine.dart';
import 'package:deemusiq/provider/user_preferences/user_preferences_provider.dart';
import 'package:deemusiq/services/audio_player/audio_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';

/// Offline-first engine: checks local cache before attempting any network.
/// Returns a manifest pointing to the local streaming server if the track
/// has been cached by a previous playback session.
///
/// Pattern from InnerTune/ViMusic — instant replay, zero bandwidth.
class CacheFirstEngine implements YouTubeEngine {
  @override
  bool get isAvailableForPlatform => true;

  @override
  Future<bool> isInstalled() async => true;

  Future<String?> getCachePath(String videoId) async {
    try {
      final dir = await UserPreferencesNotifier.getMusicCacheDir();
      final cacheDir = Directory(dir);
      if (!await cacheDir.exists()) return null;
      await for (final f in cacheDir.list()) {
        final name = f.path.split('/').last;
        if (name.contains(videoId) && !name.endsWith('.part')) {
          return f.path;
        }
      }
    } catch (_) {}
    return null;
  }

  int _resolvePort() {
    final port = DeeMusiqMedia.serverPort;
    if (port > 0) return port;
    return -1;
  }

  StreamManifest _localManifest(String videoId) {
    return StreamManifest([
      AudioOnlyStreamInfo(
        VideoId(videoId), 0,
        Uri.parse('http://127.0.0.1:${_resolvePort()}/stream/$videoId'),
        StreamContainer.mp4,
        FileSize.unknown, const Bitrate(128000), 'aac', 'local-cached', [],
        MediaType.parse('audio/mp4'), null,
      ),
    ]);
  }

  @override
  Future<StreamManifest> getStreamManifest(String videoId) async {
    final cached = await getCachePath(videoId);
    if (cached != null) return _localManifest(videoId);
    throw Exception('Not cached — try next engine');
  }

  @override
  Future<Video> getVideo(String videoId) async {
    throw UnimplementedError('CacheFirstEngine: getVideo not supported');
  }

  @override
  Future<(Video, StreamManifest)> getVideoWithStreamInfo(String videoId) async {
    throw UnimplementedError('CacheFirstEngine: getVideoWithStreamInfo not supported');
  }

  @override
  Future<List<Video>> searchVideos(String query) async {
    throw UnimplementedError('CacheFirstEngine: searchVideos not supported');
  }

  @override
  void dispose() {}
}
