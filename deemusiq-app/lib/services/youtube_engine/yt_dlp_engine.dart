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
    final audioOnlyStreams = formats
        .where((f) => f is Map && f["resolution"] == "audio only")
        .sorted((a, b) {
          final aq = a["quality"] ?? 0;
          final bq = b["quality"] ?? 0;
          return (aq is num ? aq.toInt() : 0) > (bq is num ? bq.toInt() : 0) ? 1 : -1;
        })
        .map((f) {
      final urlStr = f["url"] as String?;
      if (urlStr == null || urlStr.isEmpty) return null;
      final filesize = f["filesize"] ?? f["filesize_approx"];
      final containerRaw = (f["container"] as String?)?.replaceAll("_dash", "").replaceAll("m4a", "mp4");
      final containerStr = containerRaw ?? (f["protocol"] == "m3u8_native" ? "m3u8" : "mp4");
      final abrRaw = f["abr"] ?? f["tbr"] ?? 0;
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
        MediaType.parse("audio/$audioExt"),
        null,
      );
    }).whereType<AudioOnlyStreamInfo>();

    return StreamManifest(audioOnlyStreams);
  }

  int _safeParseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

  Video _parseInfo(Map<String, dynamic> info) {
    DateTime publishDate;
    try {
      final rawDate = info["upload_date"] as String?;
      if (rawDate != null && rawDate.length == 8) {
        final year = int.parse(rawDate.substring(0, 4));
        final month = int.parse(rawDate.substring(4, 6));
        final day = int.parse(rawDate.substring(6, 8));
        publishDate = DateTime(year, month, day);
      } else {
        publishDate = DateTime.now();
      }
    } catch (_) {
      AppLogger.log.w('YtDlpEngine: failed to parse upload_date: ${info["upload_date"]}');
      publishDate = DateTime.now();
    }

    final id = (info["id"] as String?) ?? "";
    return Video(
      VideoId(id),
      (info["title"] as String?) ?? "Unknown",
      (info["channel"] as String?) ?? "Unknown",
      ChannelId((info["channel_id"] as String?) ?? id),
      publishDate,
      (info["upload_date"] as String?) ?? DateTime.now().toString(),
      publishDate,
      (info["description"] as String?) ?? "",
      Duration(seconds: _safeParseInt(info["duration"])),
      ThumbnailSet(id),
      (info["tags"] as List?)?.cast<String>() ?? <String>[],
      Engagement(
        _safeParseInt(info["view_count"]),
        _safeParseInt(info["like_count"]),
        null,
      ),
      info["is_live"] ?? false,
    );
  }

  @override
  bool get isAvailableForPlatform => kIsDesktop;

  @override
  Future<bool> isInstalled() async {
    return isAvailableForPlatform &&
        await YtDlp.instance.checkAvailableInPath();
  }

  @override
  Future<StreamManifest> getStreamManifest(String videoId) async {
    try {
      final result = await YtDlp.instance.extractInfo(
        "https://www.youtube.com/watch?v=$videoId",
        formatSpecifiers: "%(formats)j",
        extraArgs: _ytDlpArgs,
      );
      final formats = result is List ? result : <dynamic>[];
      return _parseFormats(formats, videoId);
    } catch (e, stack) {
      AppLogger.log.w('YtDlpEngine: getStreamManifest failed for $videoId: $e');
      AppLogger.reportError(e, stack);
      rethrow;
    }
  }

  @override
  Future<Video> getVideo(String videoId) async {
    try {
      final result = await YtDlp.instance.extractInfo(
        "https://www.youtube.com/watch?v=$videoId",
        formatSpecifiers: "%()j",
        extraArgs: _ytDlpArgs,
      );
      if (result is Map<String, dynamic>) return _parseInfo(result);
      throw Exception('yt-dlp returned unexpected type: ${result.runtimeType}');
    } catch (e, stack) {
      AppLogger.log.w('YtDlpEngine: getVideo failed for $videoId: $e');
      AppLogger.reportError(e, stack);
      rethrow;
    }
  }

  @override
  Future<(Video, StreamManifest)> getVideoWithStreamInfo(String videoId) async {
    try {
      final result = await YtDlp.instance.extractInfo(
        "https://www.youtube.com/watch?v=$videoId",
        formatSpecifiers: "%()j",
        extraArgs: _ytDlpArgs,
      );
      if (result is Map<String, dynamic>) {
        final video = _parseInfo(result);
        final fmts = result["formats"];
        final manifest = _parseFormats(fmts is List ? fmts : <dynamic>[], videoId);
        return (video, manifest);
      }
      throw Exception('yt-dlp returned unexpected type: ${result.runtimeType}');
    } catch (e, stack) {
      AppLogger.log.w('YtDlpEngine: getVideoWithStream failed for $videoId: $e');
      AppLogger.reportError(e, stack);
      rethrow;
    }
  }

  @override
  Future<List<Video>> searchVideos(String query) async {
    try {
      final sanitized = query.replaceAll('\n', ' ').replaceAll('\r', '').trim();
      if (sanitized.isEmpty) return <Video>[];

      final stdout = await YtDlp.instance.extractInfoString(
        "ytsearch10:$sanitized",
        formatSpecifiers: "%()j",
        extraArgs: _searchArgs,
      );

      final lines = stdout
          .split("\n")
          .where((s) => s.trim().isNotEmpty && s.trim().startsWith('{'))
          .toList();
      if (lines.isEmpty) return <Video>[];

      final json = jsonDecode("[${lines.join(",")}]");
      final list = json is List ? json : <dynamic>[];

      final entries = <Video>[];
      for (final e in list) {
        if (e is Map<String, dynamic>) {
          try {
            entries.add(_parseInfo(e));
          } catch (itemErr) {
            AppLogger.log.d('YtDlp: skipping bad search result: $itemErr');
          }
        }
      }
      return entries;
    } catch (e, stack) {
      AppLogger.log.w('YtDlpEngine: searchVideos failed for "$query": $e');
      AppLogger.reportError(e, stack);
      rethrow;
    }
  }

  static const _ytDlpArgs = [
    "--no-check-certificate",
    "--quiet",
    "--ignore-errors",
    "--remote-components",
    "ejs:github",
  ];

  static const _searchArgs = [
    "--skip-download",
    "--no-check-certificate",
    "--quiet",
    "--ignore-errors",
    "--flat-playlist",
    "--no-playlist",
    "--remote-components",
    "ejs:github",
  ];

  @override
  void dispose() {}
}
