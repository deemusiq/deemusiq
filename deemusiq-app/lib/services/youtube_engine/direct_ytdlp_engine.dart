import 'dart:convert';
import 'dart:io';

import 'package:deemusiq/services/youtube_engine/youtube_engine.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/utils/platform.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';

/// YouTube engine that calls yt-dlp CLI directly via Process.run with a real
/// timeout. No external package dependency. Bypasses all yt_dlp_dart issues.
/// Used as a fallback when the primary YtDlpEngine (which uses yt_dlp_dart) fails.
class DirectYtDlpEngine implements YouTubeEngine {
  @override
  bool get isAvailableForPlatform => kIsDesktop;

  String? _ytDlpPath;

  Future<String> _findYtDlpPath() async {
    if (_ytDlpPath != null) return _ytDlpPath!;

    try {
      final which = await Process.run('which', ['yt-dlp']);
      if (which.exitCode == 0) {
        final path = (which.stdout as String).trim();
        if (path.isNotEmpty) {
          _ytDlpPath = path;
          return path;
        }
      }
    } catch (_) {}

    const commonPaths = [
      '/usr/bin/yt-dlp',
      '/usr/local/bin/yt-dlp',
      '/opt/homebrew/bin/yt-dlp',
    ];

    for (final path in commonPaths) {
      if (await File(path).exists()) {
        _ytDlpPath = path;
        return path;
      }
    }

    final home = Platform.environment['HOME'];
    if (home != null) {
      final homePath = '$home/.local/bin/yt-dlp';
      if (await File(homePath).exists()) {
        _ytDlpPath = homePath;
        return homePath;
      }
    }

    _ytDlpPath = '/usr/bin/yt-dlp';
    return _ytDlpPath!;
  }

  DateTime _parseUploadDate(dynamic raw) {
    if (raw == null) return DateTime.now();
    final str = raw.toString();
    if (str.length != 8) return DateTime.now();
    try {
      final year = int.parse(str.substring(0, 4));
      final month = int.parse(str.substring(4, 6));
      final day = int.parse(str.substring(6, 8));
      return DateTime(year, month, day);
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  Future<bool> isInstalled() async {
    if (!isAvailableForPlatform) return false;
    final path = await _findYtDlpPath();
    return await File(path).exists();
  }

  Future<String> _run(List<String> args) async {
    final ytDlpPath = await _findYtDlpPath();
    final process = await Process.start(
      ytDlpPath,
      args,
      environment: {'PATH': Platform.environment['PATH'] ?? '/usr/bin:/bin'},
      workingDirectory: Directory.systemTemp.path,
    );

    final stdout = process.stdout.transform(utf8.decoder).join();
    final stderr = process.stderr.transform(utf8.decoder).join();

    final exitCode = await process.exitCode.timeout(
      const Duration(seconds: 25),
      onTimeout: () { process.kill(); return -1; },
    );

    if (exitCode == -1) {
      throw Exception('yt-dlp timed out after 25s');
    }

    final stdOut = await stdout;
    final stdErr = await stderr;

    if (stdErr.isNotEmpty && stdOut.isEmpty) {
      throw Exception('yt-dlp failed (exit $exitCode): $stdErr');
    }

    return stdOut;
  }

  StreamManifest _parseFormats(List formats, String videoId) {
    final parsed = formats
        .where((f) => f is Map && f['resolution'] == 'audio only')
        .map((f) {
      final urlStr = f['url'] as String?;
      if (urlStr == null || urlStr.isEmpty) return null;
      final container = ((f['container'] as String?) ?? 'mp4')
          .replaceAll('_dash', '')
          .replaceAll('m4a', 'mp4');
      final abr = (f['abr'] ?? f['tbr'] ?? 0);
      final bitrate = abr is num ? (abr * 1000).toInt() : 128000;
      final ext = (f['audio_ext'] as String?) ?? 'mp4';
      final codec = (f['acodec'] as String?) ?? 'aac';
      final filesize = f['filesize'] ?? f['filesize_approx'];
      return AudioOnlyStreamInfo(
        VideoId(videoId), 0, Uri.parse(urlStr),
        StreamContainer.parse(container),
        filesize != null ? FileSize(filesize) : FileSize.unknown,
        Bitrate(bitrate), codec, f['format_note'], [],
        MediaType.parse('audio/$ext'), null,
      );
    }).whereType<AudioOnlyStreamInfo>();
    return StreamManifest(parsed);
  }

  @override
  Future<StreamManifest> getStreamManifest(String videoId) async {
    final output = await _run([
      '--print', '%(formats)j',
      '--quiet', '--ignore-errors',
      '--remote-components', 'ejs:github',
      'https://www.youtube.com/watch?v=$videoId',
    ]);
    final data = jsonDecode(output);
    return _parseFormats(data is List ? data : <dynamic>[], videoId);
  }

  @override
  Future<Video> getVideo(String videoId) async {
    final output = await _run([
      '--print', '%()j', '--skip-download',
      '--quiet', '--ignore-errors',
      '--remote-components', 'ejs:github',
      'https://www.youtube.com/watch?v=$videoId',
    ]);
    final data = jsonDecode(output) as Map<String, dynamic>;
    return Video(
      VideoId(data['id'] ?? ''),
      data['title'] ?? 'Unknown',
      data['channel'] ?? 'Unknown',
      ChannelId(data['channel_id'] ?? data['id'] ?? ''),
      _parseUploadDate(data['upload_date']), (data['upload_date'] as String?) ?? '', _parseUploadDate(data['upload_date']),
      (data['description'] as String?) ?? '',
      Duration(seconds: ((data['duration'] as num?) ?? 0).toInt()),
      ThumbnailSet(data['id'] ?? ''),
      (data['tags'] as List?)?.cast<String>() ?? <String>[],
      Engagement(data['view_count'] ?? 0, data['like_count'] ?? 0, null),
      data['is_live'] ?? false,
    );
  }

  @override
  Future<(Video, StreamManifest)> getVideoWithStreamInfo(String videoId) async {
    final video = await getVideo(videoId);
    final manifest = await getStreamManifest(videoId);
    return (video, manifest);
  }

  @override
  Future<List<Video>> searchVideos(String query) async {
    final sanitized = query.replaceAll('\n', ' ').replaceAll('\r', '').trim();
    if (sanitized.isEmpty) return <Video>[];
    final output = await _run([
      '--print', '%()j',
      '--skip-download',
      '--quiet', '--ignore-errors', '--flat-playlist', '--no-playlist',
      '--remote-components', 'ejs:github',
      'ytsearch10:$sanitized',
    ]);
    final lines = output.split('\n').where((s) => s.trim().isNotEmpty && s.trim().startsWith('{')).toList();
    if (lines.isEmpty) return <Video>[];
    final list = jsonDecode('[${lines.join(',')}]') as List;
    final results = <Video>[];
    for (final e in list) {
      if (e is Map<String, dynamic>) {
        try {
          results.add(Video(
            VideoId(e['id'] ?? ''), e['title'] ?? 'Unknown',
            e['channel'] ?? 'Unknown', ChannelId(e['channel_id'] ?? e['id'] ?? ''),
            _parseUploadDate(e['upload_date']), (e['upload_date'] as String?) ?? '', _parseUploadDate(e['upload_date']),
            (e['description'] as String?) ?? '',
            Duration(seconds: ((e['duration'] as num?) ?? 0).toInt()),
            ThumbnailSet(e['id'] ?? ''),
            <String>[],
            Engagement(e['view_count'] ?? 0, e['like_count'] ?? 0, null),
            e['is_live'] ?? false,
          ));
        } catch (e, stack) {
          AppLogger.log.w('DirectYtDlp: skipping malformed search result: $e');
          AppLogger.reportError(e, stack, 'DirectYtDlp searchVideos');
        }
      }
    }
    return results;
  }

  @override
  void dispose() {}
}
