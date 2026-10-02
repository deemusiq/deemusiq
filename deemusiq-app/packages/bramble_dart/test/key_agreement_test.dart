import 'package:bramble_dart/bramble_dart.dart';
import 'package:test/test.dart';

void main() {
  group('BrambleIdentity', () {
    test('generates distinct identities with 32-byte public keys', () async {
      final a = await BrambleIdentity.generate();
      final b = await BrambleIdentity.generate();
      expect(await a.agreementPublicKeyBytes(), hasLength(32));
      expect(await a.signingPublicKeyBytes(), hasLength(32));
      expect(
        await a.agreementPublicKeyBytes(),
        isNot(await b.agreementPublicKeyBytes()),
      );
    });

    test('regenerates deterministically from seeds', () async {
      final original = await BrambleIdentity.generate();
      final restored = await BrambleIdentity.fromSeeds(await original.seeds());
      expect(
        await restored.agreementPublicKeyBytes(),
        await original.agreementPublicKeyBytes(),
      );
      expect(
        await restored.signingPublicKeyBytes(),
        await original.signingPublicKeyBytes(),
      );
    });

    test('public key encoding round-trips and validates', () async {
      final identity = await BrambleIdentity.generate();
      final encoded = await identity.encodePublicKeys();
      final decoded = BrambleIdentity.decodePublicKeys(encoded);
      expect(decoded.agreement, await identity.agreementPublicKeyBytes());
      expect(decoded.signing, await identity.signingPublicKeyBytes());

      expect(() => BrambleIdentity.decodePublicKeys('not json'),
          throwsFormatException);
      expect(() => BrambleIdentity.decodePublicKeys('{"sign":"AA=="}'),
          throwsFormatException);
    });

    test('signs and verifies with the Ed25519 identity key', () async {
      final identity = await BrambleIdentity.generate();
      final message = [1, 2, 3];
      final signature = await identity.sign(message);
      expect(
        await BrambleIdentity.verify(
          message,
          signature,
          await identity.signingPublicKeyBytes(),
        ),
        isTrue,
      );
      expect(
        await BrambleIdentity.verify(
          [1, 2, 4],
          signature,
          await identity.signingPublicKeyBytes(),
        ),
        isFalse,
      );
    });
  });

  group('BrambleKeyAgreement', () {
    test('two parties derive the same X25519 shared secret', () async {
      final a = await BrambleKeyAgreement.generateEphemeralKeyPair();
      final b = await BrambleKeyAgreement.generateEphemeralKeyPair();
      final aPub = (await a.extractPublicKey()).bytes;
      final bPub = (await b.extractPublicKey()).bytes;

      final ab = await BrambleKeyAgreement.dh(a, bPub);
      final ba = await BrambleKeyAgreement.dh(b, aPub);
      expect(ab, ba);
      expect(ab, hasLength(32));
    });

    test('all-zero shared secret (low-order public key) aborts', () async {
      final a = await BrambleKeyAgreement.generateEphemeralKeyPair();
      // The all-zero X25519 public key is the canonical low-order input.
      await expectLater(
        BrambleKeyAgreement.dh(a, List.filled(32, 0)),
        throwsA(isA<BrambleKeyAgreementException>()),
      );
    });

    test('HASH length-prefixes arguments (no boundary ambiguity)', () async {
      final xy = await BrambleKeyAgreement.hash([
        [1, 2],
        [3],
      ]);
      final xYz = await BrambleKeyAgreement.hash([
        [1],
        [2, 3],
      ]);
      expect(xy, isNot(xYz));
      expect(xy, hasLength(32));
    });

    test('KDF is keyed and label-separated', () async {
      final key = List.filled(32, 7);
      final alice = await BrambleKeyAgreement.proofOfOwnership(key, alice: true);
      final bob = await BrambleKeyAgreement.proofOfOwnership(key, alice: false);
      expect(alice, isNot(bob));

      final otherKey = List.filled(32, 8);
      expect(
        await BrambleKeyAgreement.proofOfOwnership(otherKey, alice: true),
        isNot(alice),
      );
    });
  });
}
