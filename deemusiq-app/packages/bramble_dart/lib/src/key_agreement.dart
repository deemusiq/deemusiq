import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// BHP §1.4/§2.3: X25519 key agreement plus the BLAKE2b-based HASH and KDF
/// framing the handshake builds on.
///
/// Pure functions over bytes; key *scheduling* (which DH results and public
/// keys go where) lives in handshake.dart.
class BrambleKeyAgreement {
  BrambleKeyAgreement._();

  static final _x25519 = X25519();
  static final _blake2b = Blake2b(hashLengthInBytes: 32);

  /// Label for the ephemeral master key derivation (BHP §2.3).
  static final List<int> masterKeyLabel = ascii.encode(
    'org.briarproject.bramble.handshake/MASTER_KEY',
  );

  /// Labels for the proof-of-ownership MACs (BHP §2.4).
  static final List<int> aliceProofLabel = ascii.encode(
    'org.briarproject.bramble.handshake/ALICE_PROOF',
  );
  static final List<int> bobProofLabel = ascii.encode(
    'org.briarproject.bramble.handshake/BOB_PROOF',
  );

  /// Generates an ephemeral X25519 keypair for one handshake run.
  static Future<SimpleKeyPair> generateEphemeralKeyPair() =>
      _x25519.newKeyPair();

  /// X25519 ECDH between [localPrivate] and [remotePublicKey].
  ///
  /// Throws [BrambleKeyAgreementException] when the shared secret is all
  /// zeroes — BHP §2.3 requires aborting the handshake in that case (it
  /// signals a low-order/invalid public key).
  static Future<List<int>> dh(
    KeyPair localPrivate,
    List<int> remotePublicKey,
  ) async {
    final secret = await _x25519.sharedSecretKey(
      keyPair: localPrivate,
      remotePublicKey: SimplePublicKey(
        remotePublicKey,
        type: KeyPairType.x25519,
      ),
    );
    try {
      // extractBytes returns a live view of the SecretKey's internal buffer —
      // copy it before destroy() invalidates the view.
      final bytes =
          Uint8List.fromList(await secret.extractBytes());
      if (bytes.every((b) => b == 0)) {
        throw const BrambleKeyAgreementException(
          'X25519 shared secret is all zeroes — aborting',
        );
      }
      return bytes;
    } finally {
      secret.destroy();
    }
  }

  /// BHP §1.4 multi-argument hash:
  /// `HASH(x1..xn) = H(int32be(len(x1)) || x1 || ... || int32be(len(xn)) || xn)`
  /// with H = BLAKE2b-256.
  static Future<List<int>> hash(List<List<int>> arguments) async {
    final h = await _blake2b.hash(_frame(arguments));
    return h.bytes;
  }

  /// BHP §1.4 key derivation:
  /// `KDF(k, x1..xn) = MAC(k, int32be(len(x1)) || x1 || ... )`
  /// with MAC = keyed BLAKE2b-256.
  static Future<List<int>> kdf(List<int> key, List<List<int>> arguments) async {
    final secretKey = SecretKey(key);
    try {
      final mac = await _blake2b.calculateMac(
        _frame(arguments),
        secretKey: secretKey,
      );
      return mac.bytes;
    } finally {
      secretKey.destroy();
    }
  }

  /// BHP §2.3 ephemeral master key:
  /// `HASH(label, raw_ephemeral, raw_static_ephemeral, raw_ephemeral_static,
  /// pub_lt_alice, pub_lt_bob, pub_e_alice, pub_e_bob)`.
  static Future<List<int>> deriveMasterKey({
    required List<int> rawEphemeral,
    required List<int> rawStaticEphemeral,
    required List<int> rawEphemeralStatic,
    required List<int> longTermPubAlice,
    required List<int> longTermPubBob,
    required List<int> ephemeralPubAlice,
    required List<int> ephemeralPubBob,
  }) {
    return hash([
      masterKeyLabel,
      rawEphemeral,
      rawStaticEphemeral,
      rawEphemeralStatic,
      longTermPubAlice,
      longTermPubBob,
      ephemeralPubAlice,
      ephemeralPubBob,
    ]);
  }

  /// BHP §2.4 proofs of ownership.
  static Future<List<int>> proofOfOwnership(
    List<int> masterKey, {
    required bool alice,
  }) {
    return kdf(masterKey, [alice ? aliceProofLabel : bobProofLabel]);
  }

  /// Constant-time comparison — proof verification must not leak timing.
  static bool constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var difference = 0;
    for (var i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }
    return difference == 0;
  }

  static Uint8List _frame(List<List<int>> arguments) {
    final builder = BytesBuilder();
    for (final argument in arguments) {
      final length = ByteData(4)..setUint32(0, argument.length);
      builder.add(length.buffer.asUint8List());
      builder.add(argument);
    }
    return builder.toBytes();
  }
}

class BrambleKeyAgreementException implements Exception {
  final String message;
  const BrambleKeyAgreementException(this.message);
  @override
  String toString() => 'BrambleKeyAgreementException: $message';
}
