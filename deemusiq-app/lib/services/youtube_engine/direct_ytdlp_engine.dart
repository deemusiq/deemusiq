import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/youtube_engine/youtube_engine.dart';
import 'package:deemusiq/services/youtube_engine/yt_dlp_provisioner.dart';
import 'package:deemusiq/utils/platform.dart';
import 'package:http_parser/http_parser.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YtDlpBinaryResolution {
  const YtDlpBinaryResolution({
    this.path,
    this.actualSha256,
    this.actualVersion,
    this.error,
    this.managed = false,
  });

  final String? path;
  final String? actualSha256;
  final String? actualVersion;
  final String? error;

  /// True when the binary was installed by DeeMusiq itself rather than found on
  /// the system (`YtDlpProvisioner`).
  final bool managed;

  bool get isApproved => path != null;
}

typedef YtDlpVersionReader = Future<String> Function(String path);

/// Returns the path (and recorded digest) of the binary DeeMusiq installed for
/// itself, or `null` when there is none.
typedef YtDlpManagedBinaryLookup = ({String path, String? sha256})? Function();

class YtDlpBinaryPolicy {
  const YtDlpBinaryPolicy({
    this.approvedVersion = defaultApprovedVersion,
    this.configuredSha256 = defaultConfiguredSha256,
    this.versionReader,
    this.managedBinary = _managedBinaryFromStore,
  });

  static const defaultApprovedVersion = String.fromEnvironment(
    'DEEMUSIQ_YTDLP_VERSION',
  );
  static const defaultConfiguredSha256 = String.fromEnvironment(
    'DEEMUSIQ_YTDLP_SHA256',
  );
  static String? approvedPath;
  static final _sha256 = Sha256();
  static final _sha256Pattern = RegExp(r'^[0-9a-f]{64}$');
  static final _versionPattern =
      RegExp(r'^[0-9]{4}\.[0-9]{2}\.[0-9]{2}(\.[0-9]+)?$');

  final String approvedVersion;
  final String configuredSha256;
  final YtDlpVersionReader? versionReader;

  /// Where the self-installed binary lives. Injectable so tests can run without
  /// a KV store; the default reads the record written by `YtDlpProvisioner`.
  final YtDlpManagedBinaryLookup managedBinary;

  static ({String path, String? sha256})? _managedBinaryFromStore() {
    try {
      final record = KVStoreService.managedYtDlp;
      final path = record?['path'] as String?;
      if (path == null || path.isEmpty) return null;
      return (path: path, sha256: record?['sha256'] as String?);
    } catch (error) {
      // Preferences are not available yet (early boot, unit tests).
      return null;
    }
  }

  static String get buildApprovedVersion => defaultApprovedVersion;
  static String get buildApprovedSha256 =>
      const YtDlpBinaryPolicy().approvedSha256;
  static bool get hasBuildApprovedBinary =>
      const YtDlpBinaryPolicy().hasApprovedBinary;

  String get approvedSha256 => configuredSha256
      .trim()
      .toLowerCase()
      .replaceFirst(RegExp(r'^sha256:'), '');

  bool get hasApprovedBinary =>
      _sha256Pattern.hasMatch(approvedSha256) &&
      RegExp(r'^[0-9]{4}\.[0-9]{2}\.[0-9]{2}([.-][0-9A-Za-z.-]+)?$')
          .hasMatch(approvedVersion.trim());

  static String _hex(Iterable<int> bytes) =>
      bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

  /// SHA-256 of a file, hex encoded — shared by both verification paths.
  static Future<String> sha256Of(File file) async =>
      _hex((await _sha256.hash(await file.readAsBytes())).bytes);

  static String? _normalizeSha256(String? raw) {
    if (raw == null) return null;
    final value = raw.trim().toLowerCase().replaceFirst(RegExp(r'^sha256:'), '');
    return _sha256Pattern.hasMatch(value) ? value : null;
  }

  static Future<String> _readVersion(String path) async {
    final result = await Process.run(
      path,
      const ['--no-update', '--version'],
      environment: {
        ...Platform.environment,
        'PYTHONNOUSERSITE': '1',
      },
      workingDirectory: Directory.systemTemp.path,
      runInShell: false,
    );
    if (result.exitCode != 0) {
      throw ProcessException(
        path,
        const ['--version'],
        (result.stderr as String).trim(),
        result.exitCode,
      );
    }
    return (result.stdout as String).trim();
  }

  Future<YtDlpBinaryResolution> verify(String path) async {
    if (!hasApprovedBinary) {
      return const YtDlpBinaryResolution(
        error: 'No approved yt-dlp version and SHA-256 are configured',
      );
    }
    final file = File(path);
    if (!await file.exists()) {
      return YtDlpBinaryResolution(error: 'yt-dlp executable not found: $path');
    }
    try {
      final actualSha256 = _hex(
        (await _sha256.hash(await file.readAsBytes())).bytes,
      );
      if (actualSha256 != approvedSha256) {
        return YtDlpBinaryResolution(
          actualSha256: actualSha256,
          error: 'yt-dlp SHA-256 is not approved',
        );
      }
      final actualVersion = await (versionReader ?? _readVersion)(file.path);
      if (actualVersion != approvedVersion.trim()) {
        return YtDlpBinaryResolution(
          actualSha256: actualSha256,
          actualVersion: actualVersion,
          error: 'yt-dlp version is not approved',
        );
      }
      return YtDlpBinaryResolution(
        path: file.path,
        actualSha256: actualSha256,
        actualVersion: actualVersion,
      );
    } catch (error) {
      return YtDlpBinaryResolution(
        error: 'yt-dlp verification failed: ${error.toString()}',
      );
    }
  }

  /// Accepts a binary this app installed itself: the digest recorded at install
  /// time must still match, and the binary must report a plausible yt-dlp
  /// version. Used whenever the build pinned no version + digest.
  Future<YtDlpBinaryResolution> verifyManaged(
    String path, {
    String? expectedSha256,
  }) async {
    final file = File(path);
    if (!await file.exists()) {
      return YtDlpBinaryResolution(error: 'yt-dlp executable not found: $path');
    }
    try {
      final actualSha256 = await sha256Of(file);
      final expected = _normalizeSha256(expectedSha256);
      if (expected != null && expected != actualSha256) {
        return YtDlpBinaryResolution(
          actualSha256: actualSha256,
          error: 'yt-dlp SHA-256 is not the recorded digest',
        );
      }
      final actualVersion = await (versionReader ?? _readVersion)(file.path);
      if (!_versionPattern.hasMatch(actualVersion)) {
        return YtDlpBinaryResolution(
          actualSha256: actualSha256,
          actualVersion: actualVersion,
          error: 'yt-dlp reported an unrecognised version: $actualVersion',
        );
      }
      return YtDlpBinaryResolution(
        path: file.path,
        actualSha256: actualSha256,
        actualVersion: actualVersion,
        managed: true,
      );
    } catch (error) {
      return YtDlpBinaryResolution(
        error: 'yt-dlp verification failed: ${error.toString()}',
      );
    }
  }

  /// Locates a usable yt-dlp, in priority order:
  /// 1. an explicit path (user setting / override),
  /// 2. the path approved earlier in this session,
  /// 3. the binary DeeMusiq installed for itself,
  /// 4. `yt-dlp` on `PATH` and the usual install locations.
  ///
  /// With a build-pinned version + digest, every candidate is held to that pin.
  /// Without one, candidates are validated by their recorded digest (for the
  /// self-installed binary) or, failing that, by a plausible `--version`.
  Future<YtDlpBinaryResolution> resolve({String? selectedPath}) async {
    final candidates = <({String path, String? sha256})>[];
    final explicit = selectedPath?.trim();
    if (explicit != null && explicit.isNotEmpty) {
      candidates.add((path: explicit, sha256: null));
    }
    final cached = approvedPath;
    if (cached != null && cached.isNotEmpty) {
      candidates.add((path: cached, sha256: managedBinary()?.sha256));
    }
    final managed = managedBinary();
    if (managed != null && managed.path.isNotEmpty) {
      candidates.add(managed);
    }
    try {
      candidates.addAll(await _systemCandidates());
    } catch (error) {
      AppLogger.log.d('YtDlpEngine: executable lookup failed: $error');
    }

    for (final candidate in candidates) {
      final resolution = hasApprovedBinary
          ? await verify(candidate.path)
          : await verifyManaged(
              candidate.path,
              expectedSha256: candidate.sha256,
            );
      if (resolution.isApproved) return resolution;
      AppLogger.log.d(
        'YtDlpEngine: rejected ${candidate.path}: ${resolution.error}',
      );
    }
    return YtDlpBinaryResolution(
      error: hasApprovedBinary
          ? 'No yt-dlp matching the approved version '
              '${approvedVersion.trim()} was found'
          : 'No yt-dlp executable was found',
    );
  }

  Future<List<({String path, String? sha256})>> _systemCandidates() async {
    final candidates = <({String path, String? sha256})>[];
    final locator = Platform.isWindows ? 'where' : 'which';
    final result = await Process.run(locator, const ['yt-dlp']);
    final path = '${result.stdout}'.split('\n').first.trim();
    if (result.exitCode == 0 && path.isNotEmpty) {
      candidates.add((path: path, sha256: null));
    }
    const paths = [
      '/usr/bin/yt-dlp',
      '/usr/local/bin/yt-dlp',
      '/opt/homebrew/bin/yt-dlp',
    ];
    for (final candidate in paths) {
      if (await File(candidate).exists()) {
        candidates.add((path: candidate, sha256: null));
      }
    }
    final home = Platform.environment['HOME'];
    if (home != null) {
      final local = '$home/.local/bin/yt-dlp';
      if (await File(local).exists()) {
        candidates.add((path: local, sha256: null));
      }
    }
    return candidates;
  }
}

class DirectYtDlpEngine implements YouTubeEngine {
  DirectYtDlpEngine({
    this.configuredPath,
    this.binaryPolicy = const YtDlpBinaryPolicy(),
  });

  final String? configuredPath;
  final YtDlpBinaryPolicy binaryPolicy;

  @override
  bool get isAvailableForPlatform => kIsDesktop;

  Future<YtDlpBinaryResolution> resolveExecutable() =>
      binaryPolicy.resolve(selectedPath: configuredPath);

  Future<String> _findYtDlpPath() async {
    // resolveOrInstall() falls back to installing the official release when the
    // machine has no usable yt-dlp, so a fresh install needs no manual setup.
    final resolution = await YtDlpProvisioner.instance
        .resolveOrInstall(selectedPath: configuredPath);
    if (!resolution.isApproved) {
      throw StateError(resolution.error ?? 'yt-dlp is unavailable');
    }
    return resolution.path!;
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
    } catch (error) {
      AppLogger.log.d(
        'YtDlpEngine: unparseable upload_date "$str": ${error.toString()}',
      );
      return DateTime.now();
    }
  }

  @override
  Future<bool> isInstalled() async => (await resolveExecutable()).isApproved;

  Future<String> _run(List<String> args) async {
    final ytDlpPath = await _findYtDlpPath();
    final process = await Process.start(
      ytDlpPath,
      [
        '--no-update',
        '--ignore-config',
        '--no-config-locations',
        '--no-remote-components',
        ...args,
      ],
      environment: {
        ...Platform.environment,
        'PYTHONNOUSERSITE': '1',
      },
      workingDirectory: Directory.systemTemp.path,
      runInShell: false,
    );

    final stdout = process.stdout.transform(utf8.decoder).join();
    final stderr = process.stderr.transform(utf8.decoder).join();
    final exitCode = await process.exitCode.timeout(
      const Duration(seconds: 25),
      onTimeout: () {
        process.kill();
        return -1;
      },
    );

    if (exitCode == -1) {
      throw Exception('yt-dlp timed out after 25s');
    }
    final stdOut = await stdout;
    final stdErr = await stderr;
    if (exitCode != 0) {
      throw Exception('yt-dlp failed (exit $exitCode): $stdErr');
    }
    return stdOut;
  }

  StreamManifest _parseFormats(List formats, String videoId) {
    final parsed = formats
        .where(
            (format) => format is Map && format['resolution'] == 'audio only')
        .map((format) {
      final url = format['url'] as String?;
      if (url == null || url.isEmpty) return null;
      final container = ((format['container'] as String?) ?? 'mp4')
          .replaceAll('_dash', '')
          .replaceAll('m4a', 'mp4');
      final bitrateValue = format['abr'] ?? format['tbr'] ?? 0;
      final bitrate =
          bitrateValue is num ? (bitrateValue * 1000).toInt() : 128000;
      final extension = (format['audio_ext'] as String?) ?? 'mp4';
      final codec = (format['acodec'] as String?) ?? 'aac';
      final size = format['filesize'] ?? format['filesize_approx'];
      return AudioOnlyStreamInfo(
        VideoId(videoId),
        0,
        Uri.parse(url),
        StreamContainer.parse(container),
        size != null ? FileSize(size) : FileSize.unknown,
        Bitrate(bitrate),
        codec,
        format['format_note'],
        [],
        MediaType.parse('audio/$extension'),
        null,
      );
    }).whereType<AudioOnlyStreamInfo>();
    return StreamManifest(parsed);
  }

  @override
  Future<StreamManifest> getStreamManifest(String videoId) async {
    final output = await _run([
      '--print',
      '%(formats)j',
      '--quiet',
      '--ignore-errors',
      'https://www.youtube.com/watch?v=$videoId',
    ]);
    final data = jsonDecode(output);
    return _parseFormats(data is List ? data : <dynamic>[], videoId);
  }

  @override
  Future<Video> getVideo(String videoId) async {
    final output = await _run([
      '--print',
      '%()j',
      '--skip-download',
      '--quiet',
      '--ignore-errors',
      'https://www.youtube.com/watch?v=$videoId',
    ]);
    final data = jsonDecode(output) as Map<String, dynamic>;
    return Video(
      VideoId(data['id'] ?? ''),
      data['title'] ?? 'Unknown',
      data['channel'] ?? 'Unknown',
      ChannelId(data['channel_id'] ?? data['id'] ?? ''),
      _parseUploadDate(data['upload_date']),
      (data['upload_date'] as String?) ?? '',
      _parseUploadDate(data['upload_date']),
      (data['description'] as String?) ?? '',
      Duration(seconds: ((data['duration'] as num?) ?? 0).toInt()),
      ThumbnailSet(data['id'] ?? ''),
      (data['tags'] as List?)?.cast<String>() ?? <String>[],
      Engagement(data['view_count'] ?? 0, data['like_count'] ?? 0, null),
      data['is_live'] ?? false,
    );
  }

  @override
  Future<(Video, StreamManifest)> getVideoWithStreamInfo(
    String videoId,
  ) async {
    final video = await getVideo(videoId);
    final manifest = await getStreamManifest(videoId);
    return (video, manifest);
  }

  @override
  Future<List<Video>> searchVideos(String query) async {
    final sanitized = query.replaceAll('\n', ' ').replaceAll('\r', '').trim();
    if (sanitized.isEmpty) return <Video>[];
    final output = await _run([
      '--print',
      '%()j',
      '--skip-download',
      '--quiet',
      '--ignore-errors',
      '--flat-playlist',
      '--no-playlist',
      'ytsearch10:$sanitized',
    ]);
    final lines = output
        .split('\n')
        .where((line) => line.trim().isNotEmpty && line.trim().startsWith('{'))
        .toList();
    if (lines.isEmpty) return <Video>[];
    final data = jsonDecode('[${lines.join(',')}]') as List;
    final results = <Video>[];
    for (final entry in data) {
      if (entry is Map<String, dynamic>) {
        try {
          results.add(
            Video(
              VideoId(entry['id'] ?? ''),
              entry['title'] ?? 'Unknown',
              entry['channel'] ?? 'Unknown',
              ChannelId(entry['channel_id'] ?? entry['id'] ?? ''),
              _parseUploadDate(entry['upload_date']),
              (entry['upload_date'] as String?) ?? '',
              _parseUploadDate(entry['upload_date']),
              (entry['description'] as String?) ?? '',
              Duration(seconds: ((entry['duration'] as num?) ?? 0).toInt()),
              ThumbnailSet(entry['id'] ?? ''),
              <String>[],
              Engagement(
                entry['view_count'] ?? 0,
                entry['like_count'] ?? 0,
                null,
              ),
              entry['is_live'] ?? false,
            ),
          );
        } catch (error, stack) {
          AppLogger.log.w(
            'DirectYtDlp: skipping malformed search result: $error',
          );
          AppLogger.reportError(error, stack, 'DirectYtDlp searchVideos');
        }
      }
    }
    return results;
  }

  @override
  /// Channel lookups are only supported by the explode engine.
  @override
  Future<Channel?> resolveChannel(String idOrName) => Future.value(null);

  @override
  void dispose() {}
}
