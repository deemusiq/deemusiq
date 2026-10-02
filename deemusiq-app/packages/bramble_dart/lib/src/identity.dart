import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// A peer's long-term Bramble identity: an Ed25519 signing keypair and an
/// X25519 key-agreement keypair.
///
/// BHP (the handshake) uses the agreement keypair; the signing keypair is the
/// stable identity later milestones (BSP) sign with. Both keypairs can be
/// regenerated deterministically from their 32-byte seeds so an identity can
/// be backed up as two base64 strings.
class BrambleIdentity {
  final SimpleKeyPair _signingKeyPair;
  final SimpleKeyPair _agreementKeyPair;

  BrambleIdentity._(this._signingKeyPair, this._agreementKeyPair);

  /// Generates a fresh random identity.
  static Future<BrambleIdentity> generate() async {
    final signing = await Ed25519().newKeyPair();
    final agreement = await X25519().newKeyPair();
    return BrambleIdentity._(signing, agreement);
  }

  /// Rebuilds an identity from its 32-byte seeds (see [seeds]).
  static Future<BrambleIdentity> fromSeeds(BrambleIdentitySeeds seeds) async {
    final signing = await Ed25519().newKeyPairFromSeed(seeds.signingSeed);
    final agreement = await X25519().newKeyPairFromSeed(seeds.agreementSeed);
    return BrambleIdentity._(signing, agreement);
  }

  /// The 32-byte seeds of both keypairs (secret — never leave the device
  /// unencrypted). Copied out of the keypairs' sensitive buffers so the seeds
  /// stay valid even if the keypairs are later destroyed.
  Future<BrambleIdentitySeeds> seeds() async {
    return BrambleIdentitySeeds(
      signingSeed:
          Uint8List.fromList(await _signingKeyPair.extractPrivateKeyBytes()),
      agreementSeed:
          Uint8List.fromList(await _agreementKeyPair.extractPrivateKeyBytes()),
    );
  }

  /// Long-term X25519 public key — the key BHP handshakes authenticate.
  Future<List<int>> agreementPublicKeyBytes() async =>
      (await _agreementKeyPair.extractPublicKey()).bytes;

  /// Long-term Ed25519 public key — the signing identity.
  Future<List<int>> signingPublicKeyBytes() async =>
      (await _signingKeyPair.extractPublicKey()).bytes;

  /// Signs [message] with the long-term Ed25519 key (used by later
  /// milestones; BHP itself authenticates via proof-of-ownership MACs).
  Future<List<int>> sign(List<int> message) async {
    final signature =
        await Ed25519().sign(message, keyPair: _signingKeyPair);
    return signature.bytes;
  }

  /// Verifies an Ed25519 [signature] over [message] by the owner of
  /// [signingPublicKey].
  static Future<bool> verify(
    List<int> message,
    List<int> signature,
    List<int> signingPublicKey,
  ) {
    return Ed25519().verify(
      message,
      signature: Signature(
        signature,
        publicKey: SimplePublicKey(
          signingPublicKey,
          type: KeyPairType.ed25519,
        ),
      ),
    );
  }

  SimpleKeyPair get agreementKeyPair => _agreementKeyPair;
  SimpleKeyPair get signingKeyPair => _signingKeyPair;

  /// base64 encoding of both public keys for out-of-band exchange
  /// (QR code, link, …): `{"sign": "...", "agree": "..."}` as JSON.
  Future<String> encodePublicKeys() async {
    return jsonEncode({
      'sign': base64Encode(await signingPublicKeyBytes()),
      'agree': base64Encode(await agreementPublicKeyBytes()),
    });
  }

  /// Parses [encodePublicKeys] output. Throws [FormatException] when the
  /// encoding or key lengths are wrong.
  static BramblePublicKeys decodePublicKeys(String encoded) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(encoded);
    } catch (e) {
      throw FormatException('Invalid public key encoding: $e');
    }
    if (decoded is! Map) {
      throw const FormatException('Invalid public key encoding: not a map');
    }
    List<int> key(String name) {
      final value = decoded[name];
      if (value is! String) {
        throw FormatException('Missing "$name" public key');
      }
      final bytes = base64Decode(value);
      if (bytes.length != 32) {
        throw FormatException('"$name" public key must be 32 bytes');
      }
      return bytes;
    }

    return BramblePublicKeys(signing: key('sign'), agreement: key('agree'));
  }
}

/// The two 32-byte seeds backing a [BrambleIdentity].
class BrambleIdentitySeeds {
  final List<int> signingSeed;
  final List<int> agreementSeed;

  const BrambleIdentitySeeds({
    required this.signingSeed,
    required this.agreementSeed,
  })  : assert(signingSeed.length == 32, 'signing seed must be 32 bytes'),
        assert(agreementSeed.length == 32, 'agreement seed must be 32 bytes');
}

/// A peer's public identity material after [BrambleIdentity.decodePublicKeys].
class BramblePublicKeys {
  final List<int> signing;
  final List<int> agreement;

  const BramblePublicKeys({required this.signing, required this.agreement});
}
