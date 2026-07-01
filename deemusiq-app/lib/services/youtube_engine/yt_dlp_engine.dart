import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:deemusiq/services/youtube_engine/youtube_engine.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/utils/platform.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:yt_dlp_dart/yt_dlp_dart.dart';
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';

class YtDlpEngine implements YouTubeEngine {
  StreamManifest _parseFormats(List formats, videoId) {
    if (formats.isEmpty) {
      AppLogger.log.w('YtDlpEngine: _parseFormats received empty formats list for $videoId');
      return StreamManifest(const []);
    }
    final audioOnlyStreams = formats
        .where((f) => f["resolution"] == "audio only")
        .sorted((a, b) => a["quality"] > b["quality"] ? 1 : -1)
        .map((f) {
      // Validate required fields before constructing stream info
      final urlStr = f["url"] as String?;
      if (urlStr == null || urlStr.isEmpty) {
        AppLogger.log.w('YtDlpEngine: skipping format with null/empty url for $videoId');
        return null;
      }
      final filesize = f["filesize"] ?? f["filesize_approx"];
      final containerRaw = (f["container"] as String?)?.replaceAll("_dash", "").replaceAll("m4a", "mp4");
      final containerStr = containerRaw ?? (f["protocol"] == "m3u8_native" ? "m3u8" : "mp4");
      final abrRaw = (f["abr"] ?? f["tbr"] ?? 0);
      final abr = (abrRaw is num) ? abrRaw.toInt() : (int.tryParse(abrRaw.toString()) ?? 0);
      final audioExt = f["audio_ext"] as String? ?? "mp4";
      final codec = f["acodec"] as String? ?? "aac";
      return AudioOnlyStreamInfo(
        VideoId(videoId),
        0,
        Uri.parse(urlStr),
        StreamContainer.parse(containerStr),
        filesize != null ? FileSize(filesize) : FileSize.unknown,
        Bitrate(abr * 1000),
        codec,
        f["format_note"],
        [],
        MediaType.parse(
          "audio/$audioExt",
        ),
        null,
      );
    }).whereType<AudioOnlyStreamInfo>();

    return StreamManifest(audioOnlyStreams);
  }

  Video _parseInfo(Map<String, dynamic> info) {
    final publishDate = info["upload_date"] != null
        ? DateTime.fromMillisecondsSinceEpoch(
            int.parse(info["upload_date"]) * 1000,
          )
        : DateTime.now();
    return Video(
      VideoId(info["id"]),
      info["title"],
      info["channel"],
      ChannelId(info["channel_id"]),
      publishDate,
      info["upload_date"] as String? ?? DateTime.now().toString(),
      publishDate,
      info["description"] ?? "",
      Duration(seconds: (info["duration"] as num).toInt()),
      ThumbnailSet(info["id"]),
      info["tags"]?.cast<String>() ?? <String>[],
      Engagement(
        info["view_count"],
        info["like_count"],
        null,
      ),
      info["is_live"] ?? false,
    );
  }

  static bool get isAvailableForPlatform => kIsDesktop;

  static Future<bool> isInstalled() async {
    return isAvailableForPlatform &&
        await YtDlp.instance.checkAvailableInPath();
  }

  @override
  Future<StreamManifest> getStreamManifest(String videoId) async {
    try {
      final formats = await YtDlp.instance.extractInfo(
        "https://www.youtube.com/watch?v=$videoId",
        formatSpecifiers: "%(formats)j",
        extraArgs: [
          "--no-check-certificate",
          "--geo-bypass",
          "--quiet",
          "--ignore-errors"
        ],
      ) as List;

      final manifest = _parseFormats(formats, videoId);
      AppLogger.log.i('YtDlp: got ${manifest.audioOnly.length} audio streams for $videoId');
      return manifest;
    } catch (e, stack) {
      AppLogger.log.w('YtDlpEngine: failed to get stream manifest for $videoId: ${e.toString()}');
      AppLogger.reportError(e, stack);
      rethrow;
    }
  }

  @override
  Future<Video> getVideo(String videoId) async {
    try {
      final info = await YtDlp.instance.extractInfo(
        "https://www.youtube.com/watch?v=$videoId",
        formatSpecifiers: "%()j",
        extraArgs: [
          "--skip-download",
          "--no-check-certificate",
          "--geo-bypass",
          "--quiet",
          "--ignore-errors",
        ],
      ) as Map<String, dynamic>;

      return _parseInfo(info);
    } catch (e, stack) {
      AppLogger.log.w('YtDlpEngine: failed to get video for $videoId: ${e.toString()}');
      AppLogger.reportError(e, stack);
      rethrow;
    }
  }

  @override
  Future<(Video, StreamManifest)> getVideoWithStreamInfo(String videoId) async {
    try {
      final info = await YtDlp.instance.extractInfo(
        "https://www.youtube.com/watch?v=$videoId",
        formatSpecifiers: "%()j",
        extraArgs: [
          "--no-check-certificate",
          "--geo-bypass",
          "--quiet",
          "--ignore-errors",
        ],
      ) as Map<String, dynamic>;

      return (_parseInfo(info), _parseFormats(info["formats"], videoId));
    } catch (e, stack) {
      AppLogger.log.w('YtDlpEngine: failed to get video+streams for $videoId: ${e.toString()}');
      AppLogger.reportError(e, stack);
      rethrow;
    }
  }

  @override
  Future<List<Video>> searchVideos(String query) async {
    try {
      final stdout = await YtDlp.instance.extractInfoString(
        "ytsearch10:$query",
        formatSpecifiers: "%()j",
        extraArgs: [
          "--skip-download",
          "--no-check-certificate",
          "--geo-bypass",
          "--quiet",
          "--ignore-errors",
          "--flat-playlist",
          "--no-playlist",
        ],
      );

      final json = jsonDecode(
        "[${stdout.split("\n").where((s) => s.trim().isNotEmpty).join(",")}]",
      ) as List;

      return json.map((e) => _parseInfo(e)).toList();
    } catch (e, stack) {
      AppLogger.log.w('YtDlpEngine: search failed for "$query": ${e.toString()}');
      AppLogger.reportError(e, stack);
      rethrow;
    }
  }

  @override
  void dispose() {}
}
