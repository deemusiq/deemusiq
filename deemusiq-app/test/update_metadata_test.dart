import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:deemusiq/utils/service_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the Cloudflare site version response', () async {
    final body = Uint8List.fromList(
      utf8.encode(
        jsonEncode({
          'versions': {'android': '1.2.0', 'linux': '1.1.1'},
        }),
      ),
    );
    final metadata = await parseAppUpdateMetadata(body, Headers());
    expect(metadata.versions['android'], '1.2.0');
    expect(metadata.releaseFor('linux')?.version, '1.1.1');
    expect(metadata.signatureVerified, isFalse);
  });

  test('validates optional release digest and metadata digest', () async {
    final body = Uint8List.fromList(
      utf8.encode(
        jsonEncode({
          'versions': {'android': '1.2.0'},
          'releases': {
            'android': {
              'version': '1.2.0',
              'build_number': 49,
              'download_url': 'https://deemusiq.co.za/downloads/android',
              'sha256': List.filled(64, 'a').join(),
            },
          },
        }),
      ),
    );
    final digest = await Sha256().hash(body);
    final headers = Headers()
      ..set(
        'x-deemusiq-content-sha256',
        digest.bytes
            .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
            .join(),
      );
    final metadata = await parseAppUpdateMetadata(body, headers);
    expect(metadata.digestVerified, isTrue);
    expect(metadata.releaseFor('android')?.buildNumber, 49);
    expect(
      metadata.releaseFor('android')?.sha256,
      List.filled(64, 'a').join(),
    );
  });

  test('verifies detached Ed25519 metadata signatures', () async {
    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    final body = Uint8List.fromList(
      utf8.encode(jsonEncode({
        'versions': {'windows': '2.0.0'}
      })),
    );
    final signature = await algorithm.sign(body, keyPair: keyPair);
    final headers = Headers()
      ..set('x-deemusiq-signature', base64Encode(signature.bytes));
    final metadata = await parseAppUpdateMetadata(
      body,
      headers,
      publicKeyBase64: base64Encode(publicKey.bytes),
    );
    expect(metadata.signatureVerified, isTrue);
    expect(metadata.releaseFor('windows')?.version, '2.0.0');
  });

  test('rejects tampered signed metadata', () async {
    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    final body = Uint8List.fromList(
      utf8.encode(jsonEncode({
        'versions': {'android': '1.2.0'}
      })),
    );
    final signature = await algorithm.sign(body, keyPair: keyPair);
    final headers = Headers()
      ..set('x-deemusiq-signature', base64Encode(signature.bytes));
    final tampered = Uint8List.fromList(body);
    tampered[0] ^= 1;
    await expectLater(
      parseAppUpdateMetadata(
        tampered,
        headers,
        publicKeyBase64: base64Encode(publicKey.bytes),
      ),
      throwsA(isA<FormatException>()),
    );
  });
}
