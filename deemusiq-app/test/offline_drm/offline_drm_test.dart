import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deemusiq/services/offline_drm/offline_drm.dart';
import 'package:deemusiq/services/offline_drm/offline_license.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory documentsDirectory;

  final secureStore = <String, String>{};
  final drm = OfflineTrackEncryption.instance;
  final license = OfflineLicenseManager.instance;

  setUp(() async {
    documentsDirectory = await Directory.systemTemp.createTemp(
      'deemusiq-drm-test-',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return documentsDirectory.path;
      }
      return null;
    });

    secureStore.clear();
    drm.resetForTesting();
    drm.readOverride = (key) async => secureStore[key];
    drm.writeOverride = (key, value) async => secureStore[key] = value;

    license.readOverride = (key) async => secureStore[key];
    license.writeOverride = (key, value) async => secureStore[key] = value;
    license.clockOverride = null;
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    drm.resetForTesting();
    license.readOverride = null;
    license.writeOverride = null;
    license.clockOverride = null;
    await license.dispose();
    if (await documentsDirectory.exists()) {
      await documentsDirectory.delete(recursive: true);
    }
  });

  group('OfflineTrackEncryption', () {
    test('encrypt/decrypt round-trips through the v2 envelope', () async {
      final plain = List<int>.generate(4096, (i) => i % 251);
      final path = await drm.encryptAndSave(
        Uint8List.fromList(plain),
        'some track.audio',
      );
      expect(path.endsWith('.deemusiq'), isTrue);

      // v2 header: 'DM' + version + generation byte.
      final raw = await File(path).readAsBytes();
      expect(raw[0], 0x44);
      expect(raw[1], 0x4d);
      expect(raw[2], 2);
      expect(raw[3], 0);

      final decrypted = await drm.decrypt(path);
      expect(decrypted, plain);
    });

    test('files from older key generations stay decryptable after rekey',
        () async {
      final first = await drm.encryptAndSave(
        Uint8List.fromList(List.filled(128, 7)),
        'gen0.audio',
      );
      final gen = await drm.rekey();
      expect(gen, 1);
      expect(drm.currentGeneration, 1);

      final second = await drm.encryptAndSave(
        Uint8List.fromList(List.filled(128, 9)),
        'gen1.audio',
      );
      expect((await File(second).readAsBytes())[3], 1);

      expect(await drm.decrypt(first), List.filled(128, 7));
      expect(await drm.decrypt(second), List.filled(128, 9));
    });

    test('retired generations fail with a clear re-download error', () async {
      final path = await drm.encryptAndSave(
        Uint8List.fromList(List.filled(64, 3)),
        'old.audio',
      );
      // Push generation 0 beyond the 4-generation retention window.
      for (var i = 0; i < 4; i++) {
        await drm.rekey();
      }
      expect(drm.currentGeneration, 4);

      await expectLater(
        drm.decrypt(path),
        throwsA(
          isA<OfflineTrackDecryptException>().having(
            (e) => e.message,
            'message',
            contains('re-download'),
          ),
        ),
      );
      // New files still work with the current generation.
      final fresh = await drm.encryptAndSave(
        Uint8List.fromList(List.filled(64, 5)),
        'fresh.audio',
      );
      expect(await drm.decrypt(fresh), List.filled(64, 5));
    });

    test('decrypt honours the license gate (locked → clear exception)',
        () async {
      final path = await drm.encryptAndSave(
        Uint8List.fromList(List.filled(32, 1)),
        'gated.audio',
      );
      OfflineTrackEncryption.playbackGate = () async {
        throw OfflineTrackLicenseException('locked for test');
      };
      await expectLater(
        drm.decrypt(path),
        throwsA(isA<OfflineTrackLicenseException>()),
      );
    });

    test('path traversal attempts are sanitized to the documents dir',
        () async {
      final path = await drm.encryptAndSave(
        Uint8List.fromList(List.filled(8, 1)),
        '../../../etc/evil.audio',
      );
      expect(path, startsWith(documentsDirectory.path));
      expect(await drm.decrypt(path), List.filled(8, 1));
    });

    test('encryptedPathFor matches encryptAndSave output (replace-check parity)',
        () async {
      const name = 'Some Song - Some Artist.mp3';
      final predicted = await drm.encryptedPathFor(name);
      expect(predicted.endsWith('.deemusiq'), isTrue);
      final actual = await drm.encryptAndSave(
        Uint8List.fromList(List.filled(64, 11)),
        name,
      );
      expect(actual, predicted);
    });

    test('play path round trip: /offline route resolves by file name',
        () async {
      // The playback server's /offline/<name> route calls decrypt() with the
      // URL path segment (a bare file name), not a full path — simulate that.
      final plain = List<int>.generate(8192, (i) => (i * 31) % 253);
      final saved = await drm.encryptAndSave(
        Uint8List.fromList(plain),
        'Song - Artist.opus',
      );
      expect(drm.isEncryptedTrack(saved), isTrue);
      expect(drm.isEncryptedTrack('plain.mp3'), isFalse);

      final fileName = saved.split(Platform.pathSeparator).last;
      expect(fileName, 'Song - Artist.opus.deemusiq');
      final played = await drm.decrypt(fileName);
      expect(played, plain);
    });

    test('play path refuses when the license is locked (route answers 403)',
        () async {
      final saved = await drm.encryptAndSave(
        Uint8List.fromList(List.filled(32, 2)),
        'locked track.mp3',
      );
      final fileName = saved.split(Platform.pathSeparator).last;

      // Drive the real license manager into `locked` (past validity + grace)
      // and register its gate exactly like OfflineLicenseManager.start() does.
      final now = DateTime.now().toUtc();
      license.clockOverride = () => now;
      secureStore['deemusiq_offline_license_last_confirm'] = now
          .subtract(
            OfflineLicenseManager.licenseValidity +
                OfflineLicenseManager.gracePeriod +
                const Duration(days: 1),
          )
          .toIso8601String();
      license.start(const Stream<bool>.empty());
      addTearDown(license.dispose);

      await expectLater(
        drm.decrypt(fileName),
        throwsA(isA<OfflineTrackLicenseException>()),
      );
      // And encrypting NEW downloads is gated the same way.
      await expectLater(
        drm.encryptAndSave(Uint8List.fromList(List.filled(8, 1)), 'new.mp3'),
        throwsA(isA<OfflineTrackLicenseException>()),
      );
    });

    test('whole-blob legacy format fails closed (path removed, L5)', () async {
      // Pre-keyring "legacy" blobs (ciphertext without an IV prefix) can no
      // longer be decrypted with a reused static IV — they fail closed with a
      // clear re-download error instead of a GCM nonce-reuse gamble.
      final path = await drm.encryptAndSave(
        Uint8List.fromList(List.filled(16, 4)),
        'legacy seed.mp3',
      );
      final raw = await File(path).readAsBytes();
      // Strip the v2 header + iv, leaving only ciphertext: not any known
      // envelope shape for this content.
      final blobOnly = File(
        '${documentsDirectory.path}${Platform.pathSeparator}blob.deemusiq',
      );
      await blobOnly.writeAsBytes(raw.sublist(16));
      await expectLater(
        drm.decrypt('blob.deemusiq'),
        throwsA(isA<OfflineTrackDecryptException>()),
      );
    });
  });

  group('OfflineLicenseManager', () {
    Future<void> setLastConfirmed(DateTime when) async {
      secureStore['deemusiq_offline_license_last_confirm'] =
          when.toUtc().toIso8601String();
    }

    test('fresh install is unconfirmed and playable (fail-open)', () async {
      final status = await license.status();
      expect(status.state, OfflineLicenseState.unconfirmed);
      expect(await license.isPlaybackAllowed(), isTrue);
    });

    test('within validity window → valid', () async {
      final now = DateTime.now().toUtc();
      license.clockOverride = () => now;
      await setLastConfirmed(now.subtract(const Duration(days: 3)));
      final status = await license.status();
      expect(status.state, OfflineLicenseState.valid);
      expect(await license.isPlaybackAllowed(), isTrue);
    });

    test('past validity but within grace → grace, still playable', () async {
      final now = DateTime.now().toUtc();
      license.clockOverride = () => now;
      await setLastConfirmed(
        now.subtract(
          OfflineLicenseManager.licenseValidity + const Duration(days: 5),
        ),
      );
      final status = await license.status();
      expect(status.state, OfflineLicenseState.grace);
      expect(await license.isPlaybackAllowed(), isTrue);
    });

    test('past grace → locked; assertPlayable throws the UI-facing state',
        () async {
      final now = DateTime.now().toUtc();
      license.clockOverride = () => now;
      await setLastConfirmed(
        now.subtract(
          OfflineLicenseManager.licenseValidity +
              OfflineLicenseManager.gracePeriod +
              const Duration(days: 1),
        ),
      );
      final status = await license.status();
      expect(status.state, OfflineLicenseState.locked);
      expect(await license.isPlaybackAllowed(), isFalse);
      await expectLater(
        license.assertPlayable(),
        throwsA(
          isA<OfflineTrackLicenseException>().having(
            (e) => e.message,
            'message',
            contains('Connect to the internet'),
          ),
        ),
      );
    });

    test('no backend configured → confirmLicense is a no-op, stays fail-open',
        () async {
      // WalletApiClient is inert without a backend URL (no --dart-define in
      // tests), so no network is touched.
      final confirmed = await license.confirmLicense();
      expect(confirmed, isFalse);
      expect(secureStore['deemusiq_offline_license_last_confirm'], isNull);
      expect((await license.status()).state, OfflineLicenseState.unconfirmed);
    });

    test('start() registers the playback gate on the encryption service',
        () async {
      expect(OfflineTrackEncryption.playbackGate, isNull);
      final connectivity = StreamController<bool>();
      addTearDown(connectivity.close);
      license.start(connectivity.stream);
      expect(OfflineTrackEncryption.playbackGate, isNotNull);
      // An online transition triggers a best-effort confirm (no backend →
      // no-op) without throwing.
      connectivity.add(true);
      await Future<void>.delayed(Duration.zero);
    });
  });
}
