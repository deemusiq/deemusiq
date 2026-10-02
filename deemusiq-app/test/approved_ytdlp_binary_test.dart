import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:deemusiq/services/youtube_engine/direct_ytdlp_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts only the approved digest and version', () async {
    final directory = await Directory.systemTemp.createTemp('dm-ytdlp-test');
    addTearDown(() => directory.delete(recursive: true));
    final executable = File('${directory.path}/yt-dlp');
    final bytes = List<int>.generate(256, (index) => index % 256);
    await executable.writeAsBytes(bytes);
    final digest = (await Sha256().hash(bytes))
        .bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    var versionChecks = 0;
    final policy = YtDlpBinaryPolicy(
      approvedVersion: '2026.08.19',
      configuredSha256: digest,
      versionReader: (_) async {
        versionChecks++;
        return '2026.08.19';
      },
    );

    final resolution = await policy.verify(executable.path);
    expect(resolution.isApproved, isTrue);
    expect(resolution.actualSha256, digest);
    expect(versionChecks, 1);
  });

  test('rejects a digest mismatch before version execution', () async {
    final directory = await Directory.systemTemp.createTemp('dm-ytdlp-test');
    addTearDown(() => directory.delete(recursive: true));
    final executable = File('${directory.path}/yt-dlp');
    await executable.writeAsString('unapproved');
    var versionChecks = 0;
    final policy = YtDlpBinaryPolicy(
      approvedVersion: '2026.08.19',
      configuredSha256: List.filled(64, '0').join(),
      versionReader: (_) async {
        versionChecks++;
        return '2026.08.19';
      },
    );

    final resolution = await policy.verify(executable.path);
    expect(resolution.isApproved, isFalse);
    expect(resolution.error, contains('SHA-256'));
    expect(versionChecks, 0);
  });

  test('reports missing approved build metadata as unavailable', () async {
    final resolution = await const YtDlpBinaryPolicy().verify('/missing');
    expect(resolution.isApproved, isFalse);
    expect(resolution.error, contains('No approved'));
  });
}
