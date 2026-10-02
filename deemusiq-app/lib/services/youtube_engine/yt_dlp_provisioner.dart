import 'dart:async';
import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:deemusiq/services/dio/dio.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/youtube_engine/direct_ytdlp_engine.dart';
import 'package:deemusiq/utils/platform.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:yt_dlp_dart/yt_dlp_dart.dart';

/// Lifecycle of an unattended yt-dlp install, so the UI can render it.
enum YtDlpInstallPhase { checking, downloading, verifying, installing, done, failed }

class YtDlpInstallStatus {
  const YtDlpInstallStatus({
    required this.phase,
    this.received = 0,
    this.total = 0,
    this.version,
    this.message,
  });

  final YtDlpInstallPhase phase;
  final int received;
  final int total;
  final String? version;
  final String? message;

  /// 0..1 when the server sent a Content-Length, `null` while unknown.
  double? get progress =>
      total > 0 ? (received / total).clamp(0.0, 1.0).toDouble() : null;
}

typedef YtDlpDownloader = Future<void> Function(
  String url,
  File target, {
  void Function(int received, int total)? onReceiveProgress,
  CancelToken? cancelToken,
});

typedef YtDlpVersionProbe = Future<String> Function(String path);

typedef YtDlpBinDirectoryProvider = Future<Directory> Function();

/// Resolves the newest published yt-dlp tag (injectable for tests).
typedef YtDlpLatestTagResolver = Future<String?> Function();

/// Downloads, verifies and installs the official yt-dlp release binary into the
/// app's support directory, so a fresh install never depends on the user having
/// yt-dlp on `PATH` (and never on a Python interpreter: the standalone
/// `yt-dlp_linux` / `yt-dlp_macos` / `yt-dlp.exe` builds are used).
///
/// Guarantees:
/// * HTTPS-only download from the `yt-dlp/yt-dlp` GitHub release, with every
///   redirect hop checked against [trustedHosts];
/// * bytes go to a `.part` file, are hashed, probed with `--version` and only
///   then atomically promoted, so a crashed or cancelled download can never
///   leave a broken binary behind;
/// * the SHA-256 and version are recorded in the KV store and re-checked before
///   every reuse, so a tampered binary is reinstalled instead of executed;
/// * when the build pinned a version and digest (see `YtDlpBinaryPolicy`) that
///   exact release is installed and the digest must match — the pinned path is
///   never weakened;
/// * otherwise the newest release is installed and refreshed once it is older
///   than [maxAge] (default 7 days), so playback keeps working as YouTube
///   changes.
class YtDlpProvisioner {
  YtDlpProvisioner({
    Dio? dio,
    YtDlpDownloader? downloader,
    YtDlpVersionProbe? versionProbe,
    YtDlpBinDirectoryProvider? binDirectoryProvider,
    YtDlpBinaryPolicy? policy,
    YtDlpLatestTagResolver? latestTagResolver,
    this.maxAge = defaultMaxAge,
  })  : _dio = dio ?? globalDio,
        _download = downloader ?? _defaultDownload,
        _probeVersion = versionProbe ?? _defaultProbeVersion,
        _resolveBinDirectory = binDirectoryProvider ?? _defaultBinDirectory,
        policy = policy ?? const YtDlpBinaryPolicy(),
        _latestTagResolver = latestTagResolver;

  static final instance = YtDlpProvisioner();

  /// Hard switch used by tests and by headless tooling.
  static bool autoProvisionEnabled = true;

  static const defaultMaxAge = Duration(days: 7);
  static const releaseBase = 'https://github.com/yt-dlp/yt-dlp/releases';
  static const latestAlias = '$releaseBase/latest/download';

  /// Hosts the release download may legitimately redirect through.
  static const trustedHosts = <String>{
    'github.com',
    'objects.githubusercontent.com',
    'github-releases.githubusercontent.com',
    'release-assets.githubusercontent.com',
  };

  static final _versionPattern =
      RegExp(r'^[0-9]{4}\.[0-9]{2}\.[0-9]{2}(\.[0-9]+)?$');
  static final _tagPattern =
      RegExp(r'^[0-9]{4}\.[0-9]{2}\.[0-9]{2}(\.[0-9]+)?$');
  static final _sha256 = Sha256();

  final Duration maxAge;
  final Dio _dio;
  final YtDlpDownloader _download;
  final YtDlpVersionProbe _probeVersion;
  final YtDlpBinDirectoryProvider _resolveBinDirectory;
  final YtDlpLatestTagResolver? _latestTagResolver;

  /// Version + digest rules to enforce (build-pinned when configured).
  final YtDlpBinaryPolicy policy;

  Future<YtDlpBinaryResolution>? _inFlight;

  /// Name of the release asset published for the running platform, or `null`
  /// when yt-dlp publishes no standalone build for it (Linux armv7l and every
  /// mobile target) — those callers fall back to a manual path.
  static String? assetNameForCurrentPlatform() => assetNameFor(
        abiName: Abi.current().toString(),
        isWindows: kIsWindows,
        isMacOS: kIsMacOS,
        isLinux: kIsLinux,
        isMusl: _isMuslLinux(),
      );

  /// Pure mapping, split out so it is unit-testable on any host.
  static String? assetNameFor({
    required String abiName,
    required bool isWindows,
    required bool isMacOS,
    required bool isLinux,
    bool isMusl = false,
  }) {
    final architecture = architectureFor(abiName);
    if (isWindows) {
      return switch (architecture) {
        'x86_64' => 'yt-dlp.exe',
        'aarch64' => 'yt-dlp_arm64.exe',
        _ => null,
      };
    }
    if (isMacOS) return 'yt-dlp_macos';
    if (isLinux) {
      return switch (architecture) {
        'x86_64' => isMusl ? 'yt-dlp_musllinux' : 'yt-dlp_linux',
        'aarch64' =>
          isMusl ? 'yt-dlp_musllinux_aarch64' : 'yt-dlp_linux_aarch64',
        _ => null,
      };
    }
    return null;
  }

  /// `Abi.current().toString()` looks like `linux_x64`; the suffix maps to the
  /// architecture naming yt-dlp uses in its release assets.
  static String architectureFor(String abiName) {
    final suffix = abiName.split('_').last;
    return switch (suffix) {
      'x64' => 'x86_64',
      'arm64' => 'aarch64',
      'arm' => 'armv7l',
      _ => 'unknown',
    };
  }

  static bool _isMuslLinux() {
    if (!kIsLinux) return false;
    try {
      return File('/etc/alpine-release').existsSync() ||
          File('/lib/ld-musl-x86_64.so.1').existsSync() ||
          File('/lib/ld-musl-aarch64.so.1').existsSync();
    } catch (_) {
      return false;
    }
  }

  /// The executable the provisioner maintains, e.g. `<support>/bin/yt-dlp`.
  Future<File> managedExecutable() async {
    final directory = await _resolveBinDirectory();
    return File(p.join(directory.path, kIsWindows ? 'yt-dlp.exe' : 'yt-dlp'));
  }

  /// Installs yt-dlp if needed, or refreshes it when the recorded install is
  /// older than [maxAge]. Concurrent calls share one download.
  ///
  /// Never throws: failures come back as [YtDlpBinaryResolution.error].
  Future<YtDlpBinaryResolution> ensure({
    bool forceLatest = false,
    void Function(YtDlpInstallStatus status)? onStatus,
    CancelToken? cancelToken,
  }) {
    final running = _inFlight;
    if (running != null) return running;

    final completer = Completer<YtDlpBinaryResolution>();
    _inFlight = completer.future;
    _run(
      forceLatest: forceLatest,
      onStatus: onStatus,
      cancelToken: cancelToken,
    ).then((value) {
      _inFlight = null;
      if (!completer.isCompleted) completer.complete(value);
    }, onError: (Object error, StackTrace stack) {
      _inFlight = null;
      if (!completer.isCompleted) {
        completer.complete(
          YtDlpBinaryResolution(error: 'yt-dlp auto-install failed: $error'),
        );
      }
    });
    return completer.future;
  }

  /// The single entry point used by playback paths: returns a usable binary if
  /// one already exists (user-chosen, self-installed or on `PATH`) and only
  /// downloads anything when there is nothing usable.
  ///
  /// Never throws.
  Future<YtDlpBinaryResolution> resolveOrInstall({
    String? selectedPath,
    bool forceLatest = false,
    void Function(YtDlpInstallStatus status)? onStatus,
    CancelToken? cancelToken,
  }) async {
    if (!forceLatest) {
      final existing = await policy.resolve(selectedPath: selectedPath);
      if (existing.isApproved) {
        await _activate(existing.path!);
        return existing;
      }
      if (!autoProvisionEnabled) return existing;
    } else if (!autoProvisionEnabled) {
      return const YtDlpBinaryResolution(
        error: 'yt-dlp auto-install is disabled',
      );
    }
    return ensure(
      forceLatest: forceLatest,
      onStatus: onStatus,
      cancelToken: cancelToken,
    );
  }

  /// True when a managed install exists and still matches its recorded digest,
  /// without touching the network.
  Future<bool> hasFreshManagedInstall() async {
    final file = await managedExecutable();
    final record = KVStoreService.managedYtDlp;
    if (record == null || !await file.exists()) return false;
    final resolution = await policy.verifyManaged(
      file.path,
      expectedSha256: record['sha256'] as String?,
    );
    return resolution.isApproved;
  }

  Future<YtDlpBinaryResolution> _run({
    required bool forceLatest,
    void Function(YtDlpInstallStatus status)? onStatus,
    CancelToken? cancelToken,
  }) async {
    void status(YtDlpInstallPhase phase,
        {int received = 0, int total = 0, String? version, String? message}) {
      onStatus?.call(YtDlpInstallStatus(
        phase: phase,
        received: received,
        total: total,
        version: version,
        message: message,
      ));
    }

    status(YtDlpInstallPhase.checking);
    try {
      if (!kIsDesktop) {
        return const YtDlpBinaryResolution(
          error: 'yt-dlp can only be installed on desktop platforms',
        );
      }
      final asset = assetNameForCurrentPlatform();
      if (asset == null) {
        return const YtDlpBinaryResolution(
          error: 'yt-dlp publishes no standalone build for this platform',
        );
      }

      final target = await managedExecutable();

      if (!forceLatest) {
        final reusable = await _reusableInstall(
          policy: policy,
          record: KVStoreService.managedYtDlp,
          target: target,
          asset: asset,
        );
        if (reusable != null) {
          status(YtDlpInstallPhase.done, version: reusable.actualVersion);
          return reusable;
        }
      }

      final pinned = policy.hasApprovedBinary;
      final tag = pinned
          ? policy.approvedVersion.trim()
          : await _latestTag(cancelToken: cancelToken);
      final url = tag == null
          ? '$latestAlias/$asset'
          : '$releaseBase/download/${Uri.encodeComponent(tag)}/$asset';
      _assertTrusted(url);

      await target.parent.create(recursive: true);
      final part = File(
        '${target.path}.part-${DateTime.now().microsecondsSinceEpoch}',
      );
      try {
        status(YtDlpInstallPhase.downloading, version: tag);
        await _download(
          url,
          part,
          cancelToken: cancelToken,
          onReceiveProgress: (received, total) => status(
            YtDlpInstallPhase.downloading,
            received: received,
            total: total,
            version: tag,
          ),
        );

        status(YtDlpInstallPhase.verifying, version: tag);
        final sha256 = await _sha256File(part);
        if (pinned && sha256 != policy.approvedSha256) {
          await _deleteQuietly(part);
          return YtDlpBinaryResolution(
            actualSha256: sha256,
            error: 'yt-dlp SHA-256 is not the approved digest for '
                '${policy.approvedVersion.trim()}',
          );
        }

        await _makeExecutable(part);
        final version = await _probeVersion(part.path);
        if (!_versionPattern.hasMatch(version)) {
          await _deleteQuietly(part);
          return YtDlpBinaryResolution(
            actualSha256: sha256,
            error: 'yt-dlp reported an unrecognised version: $version',
          );
        }
        if (pinned && version != policy.approvedVersion.trim()) {
          await _deleteQuietly(part);
          return YtDlpBinaryResolution(
            actualSha256: sha256,
            actualVersion: version,
            error: 'yt-dlp version is not the approved '
                '${policy.approvedVersion.trim()}',
          );
        }

        status(YtDlpInstallPhase.installing, version: version);
        await _promote(part, target);
        await KVStoreService.setManagedYtDlp({
          'schema': 1,
          'path': target.path,
          'sha256': sha256,
          'version': version,
          'asset': asset,
          'url': url,
          'pinned': pinned,
          'installedAt': DateTime.now().toUtc().toIso8601String(),
        });
        await _activate(target.path);
        status(YtDlpInstallPhase.done, version: version);
        AppLogger.log.i(
          'YtDlpProvisioner: installed yt-dlp $version ($asset) at '
          '${target.path}',
        );
        return YtDlpBinaryResolution(
          path: target.path,
          actualSha256: sha256,
          actualVersion: version,
          managed: true,
        );
      } catch (error, stack) {
        await _deleteQuietly(part);
        return _installationFailed(error, stack, onStatus);
      }
    } catch (error, stack) {
      return _installationFailed(error, stack, onStatus);
    }
  }

  YtDlpBinaryResolution _installationFailed(
    Object error,
    StackTrace stack,
    void Function(YtDlpInstallStatus status)? onStatus,
  ) {
    onStatus?.call(YtDlpInstallStatus(
      phase: YtDlpInstallPhase.failed,
      message: error.toString(),
    ));
    AppLogger.log.w('YtDlpProvisioner: install failed: $error');
    AppLogger.reportError(error, stack, 'YtDlpProvisioner install');
    return YtDlpBinaryResolution(error: 'yt-dlp auto-install failed: $error');
  }

  /// Returns the already-installed binary when it is still trustworthy and
  /// fresh, otherwise `null` (meaning: download again).
  Future<YtDlpBinaryResolution?> _reusableInstall({
    required YtDlpBinaryPolicy policy,
    required Map<String, dynamic>? record,
    required File target,
    required String asset,
  }) async {
    if (record == null) return null;
    if (record['path'] != target.path || record['asset'] != asset) return null;

    final installedAt = DateTime.tryParse('${record['installedAt'] ?? ''}');
    if (installedAt == null) return null;
    if (DateTime.now().toUtc().difference(installedAt) > maxAge) {
      AppLogger.log.d(
        'YtDlpProvisioner: managed yt-dlp is older than $maxAge, refreshing',
      );
      return null;
    }

    if (policy.hasApprovedBinary) {
      final resolution = await policy.verify(target.path);
      if (!resolution.isApproved) return null;
      return YtDlpBinaryResolution(
        path: resolution.path,
        actualSha256: resolution.actualSha256,
        actualVersion: resolution.actualVersion,
        managed: true,
      );
    }

    final recordedSha256 = record['sha256'] as String?;
    if (recordedSha256 == null || recordedSha256.isEmpty) return null;
    final resolution = await policy.verifyManaged(
      target.path,
      expectedSha256: recordedSha256,
    );
    if (!resolution.isApproved) return null;
    await _activate(target.path);
    return YtDlpBinaryResolution(
      path: target.path,
      actualSha256: resolution.actualSha256,
      actualVersion: resolution.actualVersion ?? record['version'] as String?,
      managed: true,
    );
  }

  Future<String?> _latestTag({CancelToken? cancelToken}) async {
    final resolver = _latestTagResolver;
    if (resolver != null) return resolver();
    return _resolveLatestTag(cancelToken: cancelToken);
  }

  /// Tag of the newest release, read from the `releases/latest` redirect so the
  /// rate-limited GitHub API is never touched. `null` means "use the
  /// `/releases/latest/download/<asset>` alias", whose version is then taken
  /// from the downloaded binary itself.
  Future<String?> _resolveLatestTag({CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get<void>(
        '$releaseBase/latest',
        cancelToken: cancelToken,
        options: Options(
          followRedirects: false,
          validateStatus: (status) =>
              status != null && status >= 200 && status < 400,
        ),
      );
      final location = response.headers.value('location');
      final segments = location == null ? null : Uri.tryParse(location)?.pathSegments;
      final tag = (segments == null || segments.isEmpty) ? null : segments.last;
      if (tag != null && _tagPattern.hasMatch(tag)) return tag;
      AppLogger.log.d(
        'YtDlpProvisioner: could not read the latest tag from "$location"',
      );
    } catch (error) {
      AppLogger.log.d('YtDlpProvisioner: latest tag lookup failed: $error');
    }
    return null;
  }

  void _assertTrusted(String url) {
    final host = Uri.parse(url).host;
    if (!trustedHosts.contains(host)) {
      throw StateError(
        'Refusing to download yt-dlp from untrusted host: $host',
      );
    }
  }

  Future<void> _activate(String path) async {
    YtDlpBinaryPolicy.approvedPath = path;
    try {
      await YtDlp.instance.setBinaryLocation(path);
    } catch (error) {
      AppLogger.log.d(
        'YtDlpProvisioner: could not hand $path to yt_dlp_dart: $error',
      );
    }
  }

  static Future<Directory> _defaultBinDirectory() async {
    final support = await getApplicationSupportDirectory();
    final directory = Directory(p.join(support.path, 'bin'));
    await directory.create(recursive: true);
    return directory;
  }

  static Future<void> _defaultDownload(
    String url,
    File target, {
    void Function(int received, int total)? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    final response = await globalDio.get<ResponseBody>(
      url,
      cancelToken: cancelToken,
      options: Options(
        responseType: ResponseType.stream,
        followRedirects: true,
        // Idle timeout between chunks: a 40 MB asset must not fail because the
        // whole transfer takes longer than the global receive timeout.
        receiveTimeout: const Duration(seconds: 45),
        headers: const {'Accept': 'application/octet-stream'},
      ),
    );
    for (final redirect in response.redirects) {
      final host = redirect.location.host;
      if (!trustedHosts.contains(host)) {
        throw StateError('Refusing yt-dlp redirect to untrusted host: $host');
      }
    }

    final body = response.data;
    if (body == null) {
      throw StateError('Empty response while downloading yt-dlp');
    }
    final total = int.tryParse(
          _headerValue(body.headers, Headers.contentLengthHeader) ?? '',
        ) ??
        -1;

    final sink = target.openWrite();
    var received = 0;
    try {
      await for (final chunk in body.stream) {
        sink.add(chunk);
        received += chunk.length;
        onReceiveProgress?.call(received, total);
      }
      await sink.flush();
    } finally {
      await sink.close();
    }
  }

  static Future<String> _defaultProbeVersion(String path) async {
    final result = await Process.run(
      path,
      const ['--no-update', '--version'],
      environment: {
        ...Platform.environment,
        'PYTHONNOUSERSITE': '1',
      },
      workingDirectory: Directory.systemTemp.path,
      runInShell: false,
    ).timeout(const Duration(seconds: 60));
    if (result.exitCode != 0) {
      throw ProcessException(
        path,
        const ['--version'],
        '${result.stderr}'.trim(),
        result.exitCode,
      );
    }
    return '${result.stdout}'.trim();
  }

  static Future<void> _makeExecutable(File file) async {
    if (kIsWindows) return;
    final result = await Process.run('chmod', ['0755', file.path]);
    if (result.exitCode != 0) {
      throw ProcessException(
        'chmod',
        ['0755', file.path],
        '${result.stderr}'.trim(),
        result.exitCode,
      );
    }
  }

  static Future<String> _sha256File(File file) async {
    final digest = await _sha256.hash(await file.readAsBytes());
    return digest.bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  /// Case-insensitive lookup in dio's raw response header map.
  static String? _headerValue(Map<String, List<String>> headers, String name) {
    final wanted = name.toLowerCase();
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == wanted) {
        return entry.value.isEmpty ? null : entry.value.first;
      }
    }
    return null;
  }

  static Future<void> _promote(File source, File target) async {
    if (source.path == target.path) return;
    try {
      await source.rename(target.path);
      return;
    } catch (_) {
      if (!await target.exists()) rethrow;
    }
    // Target is on another filesystem or in use: move it aside, then swap.
    final backup = File(
      '${target.path}.old-${DateTime.now().microsecondsSinceEpoch}',
    );
    await target.rename(backup.path);
    try {
      await source.rename(target.path);
    } catch (error, stack) {
      try {
        await backup.rename(target.path);
      } catch (_) {}
      Error.throwWithStackTrace(error, stack);
    }
    await _deleteQuietly(backup);
  }

  static Future<void> _deleteQuietly(FileSystemEntity entity) async {
    try {
      if (await entity.exists()) await entity.delete(recursive: true);
    } catch (_) {}
  }
}

/// Convenience for UI code: a one-liner explaining why an install failed.
String ytDlpInstallErrorMessage(YtDlpBinaryResolution resolution) =>
    resolution.error ?? 'yt-dlp is unavailable';
