import 'package:youtube_explode_dart/youtube_explode_dart.dart';

abstract interface class YouTubeEngine {
  bool get isAvailableForPlatform => false;

  Future<bool> isInstalled() async {
    return false;
  }

  Future<Video> getVideo(String videoId);
  Future<StreamManifest> getStreamManifest(String videoId);
  Future<(Video, StreamManifest)> getVideoWithStreamInfo(String videoId);
  Future<List<Video>> searchVideos(String query);

  /// Resolves a YouTube channel by id or display name. Used to render artist
  /// pages for YouTube-sourced content when the catalog backend can't serve
  /// them. Null when the engine doesn't support channel lookups or the
  /// channel wasn't found.
  Future<Channel?> resolveChannel(String idOrName) => Future.value(null);

  void dispose();
}
