import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/services/youtube_engine/direct_ytdlp_engine.dart';
import 'package:deemusiq/services/youtube_engine/yt_dlp_provisioner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory workDir;

  const version = '2026.08.19';

  List<int> payload() => List<int>.generate(4096, (index) => index % 256);

  Future<String> digestOf(List<int> bytes) async =>
      (await Sha256().hash(bytes))
          .bytes
          .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
          .join();

  YtDlpDownloader fakeDownloader(List<String> seen) =>
      (url, target, {onReceiveProgress, cancelToken}) async {
        seen.add(url);
        final bytes = payload();
        await target.writeAsBytes(bytes);
        onReceiveProgress?.call(bytes.length, bytes.length);
      };

  YtDlpProvisioner provisioner({
    required List<String> seen,
    Duration maxAge = const Duration(days: 7),
    YtDlpBinaryPolicy? policy,
    String reportedVersion = version,
  }) =>
      YtDlpProvisioner(
        downloader: fakeDownloader(seen),
        versionProbe: (_) async => reportedVersion,
        binDirectoryProvider: () async => workDir,
        // Tests never touch the network: the tag is resolved deterministically.
        latestTagResolver: () async => version,
        policy: policy ?? YtDlpBinaryPolicy(versionReader: (_) async => version),
        maxAge: maxAge,
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await KVStoreService.initialize();
    YtDlpBinaryPolicy.approvedPath = null;
    workDir = await Directory.systemTemp.createTemp('dm-ytdlp-provision');
  });

  tearDown(() async {
    if (workDir.existsSync()) await workDir.delete(recursive: true);
  });

  group('release asset mapping', () {
    test('maps every desktop target yt-dlp publishes a build for', () {
      String? asset({
        required String abi,
        bool windows = false,
        bool macos = false,
        bool linux = false,
        bool musl = false,
      }) =>
          YtDlpProvisioner.assetNameFor(
            abiName: abi,
            isWindows: windows,
            isMacOS: macos,
            isLinux: linux,
            isMusl: musl,
          );

      expect(asset(abi: 'linux_x64', linux: true), 'yt-dlp_linux');
      expect(asset(abi: 'linux_arm64', linux: true), 'yt-dlp_linux_aarch64');
      expect(
        asset(abi: 'linux_x64', linux: true, musl: true),
        'yt-dlp_musllinux',
      );
      expect(asset(abi: 'macos_arm64', macos: true), 'yt-dlp_macos');
      expect(asset(abi: 'macos_x64', macos: true), 'yt-dlp_macos');
      expect(asset(abi: 'windows_x64', windows: true), 'yt-dlp.exe');
      expect(asset(abi: 'windows_arm64', windows: true), 'yt-dlp_arm64.exe');
      // No standalone build exists for these, so callers must fall back.
      expect(asset(abi: 'linux_arm', linux: true), isNull);
      expect(asset(abi: 'android_arm64'), isNull);
      expect(asset(abi: 'ios_arm64'), isNull);
    });

    test('parses the abi suffix into a yt-dlp architecture', () {
      expect(YtDlpProvisioner.architectureFor('linux_x64'), 'x86_64');
      expect(YtDlpProvisioner.architectureFor('macos_arm64'), 'aarch64');
      expect(YtDlpProvisioner.architectureFor('linux_arm'), 'armv7l');
      expect(YtDlpProvisioner.architectureFor('linux_riscv64'), 'unknown');
    });
  });

  group('managed install', () {
    test('downloads the official release, then reuses it untouched', () async {
      final seen = <String>[];
      final phases = <YtDlpInstallPhase>[];
      final installer = provisioner(seen: seen);

      final first = await installer.ensure(
        onStatus: (status) => phases.add(status.phase),
      );

      expect(first.isApproved, isTrue);
      expect(first.managed, isTrue);
      expect(first.actualVersion, version);
      expect(first.path, p.join(workDir.path, 'yt-dlp'));
      expect(
        seen.single,
        'https://github.com/yt-dlp/yt-dlp/releases/download/$version/'
        '${YtDlpProvisioner.assetNameForCurrentPlatform()}',
      );
      expect(phases.first, YtDlpInstallPhase.checking);
      expect(phases.last, YtDlpInstallPhase.done);
      expect(
        workDir.listSync().where((entity) => entity.path.contains('.part-')),
        isEmpty,
        reason: 'a partial download must never survive',
      );

      final record = KVStoreService.managedYtDlp;
      expect(record, isNotNull);
      expect(record!['version'], version);
      expect(record['sha256'], first.actualSha256);
      expect(record['pinned'], isFalse);

      final second = await installer.ensure();
      expect(second.isApproved, isTrue);
      expect(second.actualSha256, first.actualSha256);
      expect(seen, hasLength(1), reason: 'a fresh install is reused offline');
    });

    test('refreshes the binary once it is older than maxAge', () async {
      final seen = <String>[];
      final installer = provisioner(seen: seen, maxAge: Duration.zero);

      await installer.ensure();
      await installer.ensure();

      expect(seen, hasLength(2), reason: 'a stale install is refreshed');
    });

    test('refuses a digest that is not the pinned one', () async {
      final seen = <String>[];
      final installer = provisioner(
        seen: seen,
        policy: YtDlpBinaryPolicy(
          approvedVersion: version,
          configuredSha256: List.filled(64, '0').join(),
        ),
      );

      final resolution = await installer.ensure();

      expect(resolution.isApproved, isFalse);
      expect(resolution.error, contains('SHA-256'));
      expect(seen.single, contains('/download/$version/'));
      expect(File(p.join(workDir.path, 'yt-dlp')).existsSync(), isFalse);
      expect(
        workDir.listSync().where((entity) => entity.path.contains('.part-')),
        isEmpty,
      );
      expect(KVStoreService.managedYtDlp, isNull);
    });

    test('installs the pinned release when the digest matches', () async {
      final seen = <String>[];
      final installer = provisioner(
        seen: seen,
        policy: YtDlpBinaryPolicy(
          approvedVersion: version,
          configuredSha256: await digestOf(payload()),
          versionReader: (_) async => version,
        ),
      );

      final resolution = await installer.ensure();

      expect(resolution.isApproved, isTrue);
      expect(seen.single, contains('/download/$version/'));
      expect(KVStoreService.managedYtDlp?['pinned'], isTrue);
    });

    test('replaces a managed binary whose bytes changed', () async {
      final seen = <String>[];
      final target = File(p.join(workDir.path, 'yt-dlp'));
      await target.writeAsString('tampered');
      await KVStoreService.setManagedYtDlp({
        'schema': 1,
        'path': target.path,
        'sha256': List.filled(64, 'a').join(),
        'version': version,
        'asset': YtDlpProvisioner.assetNameForCurrentPlatform(),
        'installedAt': DateTime.now().toUtc().toIso8601String(),
      });

      final resolution = await provisioner(seen: seen).ensure();

      expect(resolution.isApproved, isTrue);
      expect(seen, hasLength(1), reason: 'tampered binaries are reinstalled');
      expect(await target.readAsBytes(), payload());
    });
  });

  group('policy', () {
    test('verifyManaged enforces the recorded digest', () async {
      final file = File(p.join(workDir.path, 'yt-dlp'));
      await file.writeAsString('binary');
      final policy = YtDlpBinaryPolicy(versionReader: (_) async => version);

      final trusted = await policy.verifyManaged(file.path);
      expect(trusted.isApproved, isTrue);
      expect(trusted.managed, isTrue);

      final mismatch = await policy.verifyManaged(
        file.path,
        expectedSha256: List.filled(64, 'f').join(),
      );
      expect(mismatch.isApproved, isFalse);
      expect(mismatch.error, contains('recorded digest'));
    });

    test('rejects a binary that is not a yt-dlp version', () async {
      final file = File(p.join(workDir.path, 'yt-dlp'));
      await file.writeAsString('binary');
      final policy = YtDlpBinaryPolicy(versionReader: (_) async => 'nope');

      final resolution = await policy.verifyManaged(file.path);

      expect(resolution.isApproved, isFalse);
      expect(resolution.error, contains('unrecognised version'));
    });

    test('resolve() prefers the app-managed binary over PATH', () async {
      final managed = File(p.join(workDir.path, 'yt-dlp'));
      await managed.writeAsString('binary');
      final policy = YtDlpBinaryPolicy(
        versionReader: (_) async => version,
        managedBinary: () => (path: managed.path, sha256: null),
      );

      final resolution = await policy.resolve();

      expect(resolution.path, managed.path);
      expect(resolution.managed, isTrue);
    });
  });
}
