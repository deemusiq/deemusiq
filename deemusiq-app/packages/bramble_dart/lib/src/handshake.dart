import 'package:cryptography/cryptography.dart';

import 'identity.dart';
import 'key_agreement.dart';
import 'records.dart';
import 'transport.dart';

/// The result of a successful BHP run: the ephemeral master key, the role the
/// local peer played, and the (still open) transport connection. The caller
/// may derive communication keys from the master key and continue using the
/// connection (BHP §2.4).
///
/// [reader] holds the handshake's subscription on the connection's byte
/// stream — keep reading through it, and dispose it when the connection is
/// torn down (its paused subscription otherwise blocks a clean close).
class BrambleHandshakeResult {
  final List<int> masterKey;
  final bool isAlice;
  final TransportConnection connection;
  final StreamHandshakeRecordReader reader;

  const BrambleHandshakeResult({
    required this.masterKey,
    required this.isAlice,
    required this.connection,
    required this.reader,
  });
}

class BrambleHandshakeException implements Exception {
  final String message;
  const BrambleHandshakeException(this.message);
  @override
  String toString() => 'BrambleHandshakeException: $message';
}

class _PeerHello {
  final List<int> ephemeralPublicKey;
  final int minorVersion;
  const _PeerHello(this.ephemeralPublicKey, this.minorVersion);
}

/// Bramble Handshake Protocol 0.1 state machine
/// (https://code.briarproject.org/briar/briar-spec — protocols/BHP.md).
///
/// Roles come from the lexicographic order of the two long-term (X25519
/// agreement) public keys (BHP §1.2): the earlier key is Alice. Both peers
/// must already know each other's long-term public key — BHP does not
/// specify how that exchange happens.
///
/// The four protocol steps (BHP §2.2): Alice sends her ephemeral key, Bob
/// answers with his, Alice proves ownership, Bob proves ownership. Each peer
/// additionally sends a MINOR_VERSION record right after its ephemeral key;
/// a missing minor version aborts the run (BHP §2.1).
///
/// No timeouts are imposed here — wrap [run] in your own deadline. Any
/// protocol violation aborts the run with [BrambleHandshakeException] and
/// closes the connection.
class BrambleHandshake {
  final BrambleIdentity localIdentity;

  /// The remote peer's long-term X25519 public key (32 bytes).
  final List<int> remoteLongTermPublicKey;
  final TransportConnection connection;

  /// Safety bound on how many records we read while waiting for the expected
  /// ones (unknown record types are legal and skipped, BHP §2.1).
  final int maxRecords;

  BrambleHandshake({
    required this.localIdentity,
    required this.remoteLongTermPublicKey,
    required this.connection,
    this.maxRecords = 32,
  });

  Future<BrambleHandshakeResult> run() async {
    if (remoteLongTermPublicKey.length != 32) {
      throw ArgumentError(
        'Remote long-term public key must be 32 bytes, '
        'got ${remoteLongTermPublicKey.length}',
      );
    }
    final localPublicKey = await localIdentity.agreementPublicKeyBytes();
    final order = _compareBytes(localPublicKey, remoteLongTermPublicKey);
    if (order == 0) {
      throw const BrambleHandshakeException(
        'Remote long-term public key equals ours — cannot handshake with self',
      );
    }
    final isAlice = order < 0;

    final ephemeral = await BrambleKeyAgreement.generateEphemeralKeyPair();
    final ephemeralPublicKey =
        (await ephemeral.extractPublicKey()).bytes;
    final reader = StreamHandshakeRecordReader(connection.incoming);

    try {
      if (isAlice) {
        // Step 1: Alice sends her ephemeral public key (+ minor version).
        await _sendRecord(
          HandshakeRecord.typeEphemeralPublicKey,
          ephemeralPublicKey,
        );
        await _sendMinorVersion();

        // Step 2: Bob answers with his ephemeral public key.
        final peerHello = await _awaitPeerHello(reader);

        // Step 3: Alice derives the master key and proves ownership.
        final masterKey = await _deriveMasterKey(
          ephemeral: ephemeral,
          localLongTermPublic: localPublicKey,
          ephemeralPublic: ephemeralPublicKey,
          remoteEphemeralPublic: peerHello.ephemeralPublicKey,
          isAlice: true,
        );
        await _sendRecord(
          HandshakeRecord.typeProofOfOwnership,
          await BrambleKeyAgreement.proofOfOwnership(masterKey, alice: true),
        );

        // Step 4: Bob's proof must match what Alice expects.
        final peerProof = await _awaitProof(reader);
        final expected =
            await BrambleKeyAgreement.proofOfOwnership(masterKey, alice: false);
        if (!BrambleKeyAgreement.constantTimeEquals(peerProof, expected)) {
          throw const BrambleHandshakeException(
            'Proof of ownership mismatch — wrong long-term key or MITM',
          );
        }
        return BrambleHandshakeResult(
          masterKey: masterKey,
          isAlice: true,
          connection: connection,
          reader: reader,
        );
      } else {
        // Bob waits for Alice's ephemeral key before revealing his (step order).
        final peerHello = await _awaitPeerHello(reader);
        await _sendRecord(
          HandshakeRecord.typeEphemeralPublicKey,
          ephemeralPublicKey,
        );
        await _sendMinorVersion();

        final masterKey = await _deriveMasterKey(
          ephemeral: ephemeral,
          localLongTermPublic: localPublicKey,
          ephemeralPublic: ephemeralPublicKey,
          remoteEphemeralPublic: peerHello.ephemeralPublicKey,
          isAlice: false,
        );

        // Verify Alice's proof before sending ours (BHP §2.2 step order).
        final peerProof = await _awaitProof(reader);
        final expected =
            await BrambleKeyAgreement.proofOfOwnership(masterKey, alice: true);
        if (!BrambleKeyAgreement.constantTimeEquals(peerProof, expected)) {
          throw const BrambleHandshakeException(
            'Proof of ownership mismatch — wrong long-term key or MITM',
          );
        }
        await _sendRecord(
          HandshakeRecord.typeProofOfOwnership,
          await BrambleKeyAgreement.proofOfOwnership(masterKey, alice: false),
        );
        return BrambleHandshakeResult(
          masterKey: masterKey,
          isAlice: false,
          connection: connection,
          reader: reader,
        );
      }
    } catch (e) {
      await reader.dispose();
      await connection.close();
      if (e is BrambleHandshakeException) rethrow;
      throw BrambleHandshakeException('Handshake aborted: $e');
    } finally {
      // BHP §2.3: ephemeral private keys are deleted after use.
      try {
        ephemeral.destroy();
      } catch (_) {}
    }
  }

  /// Reads records until the peer's ephemeral public key AND minor version
  /// have arrived (either order). Unknown record types of a supported
  /// protocol version are ignored (BHP §2.1 forward compatibility).
  Future<_PeerHello> _awaitPeerHello(StreamHandshakeRecordReader reader) async {
    List<int>? ephemeralPublicKey;
    var minorVersion = 0;
    var records = 0;
    while (ephemeralPublicKey == null || minorVersion == 0) {
      if (++records > maxRecords) {
        throw const BrambleHandshakeException(
          'Peer sent too many records without completing its hello',
        );
      }
      final record = await reader.read();
      if (record == null) {
        throw const BrambleHandshakeException(
          'Connection closed during handshake',
        );
      }
      if (record.version != HandshakeRecord.protocolVersion) {
        throw BrambleHandshakeException(
          'Unsupported protocol version: ${record.version}',
        );
      }
      switch (record.type) {
        case HandshakeRecord.typeEphemeralPublicKey:
          if (record.payload.length != 32) {
            throw const BrambleHandshakeException(
              'Ephemeral public key must be 32 bytes',
            );
          }
          ephemeralPublicKey = record.payload;
          break;
        case HandshakeRecord.typeMinorVersion:
          if (record.payload.length != 1 || record.payload[0] == 0) {
            throw const BrambleHandshakeException(
              'Invalid MINOR_VERSION record',
            );
          }
          minorVersion = record.payload[0];
          break;
        default:
          // Unrecognised record type with a supported version → ignore.
          break;
      }
    }
    return _PeerHello(ephemeralPublicKey, minorVersion);
  }

  Future<List<int>> _awaitProof(StreamHandshakeRecordReader reader) async {
    var records = 0;
    while (true) {
      if (++records > maxRecords) {
        throw const BrambleHandshakeException(
          'Peer sent too many records without its proof of ownership',
        );
      }
      final record = await reader.read();
      if (record == null) {
        throw const BrambleHandshakeException(
          'Connection closed during handshake',
        );
      }
      if (record.version != HandshakeRecord.protocolVersion) {
        throw BrambleHandshakeException(
          'Unsupported protocol version: ${record.version}',
        );
      }
      if (record.type != HandshakeRecord.typeProofOfOwnership) {
        continue; // ignore unknown/unrelated records
      }
      if (record.payload.length != 32) {
        throw const BrambleHandshakeException(
          'Proof of ownership must be 32 bytes',
        );
      }
      return record.payload;
    }
  }

  /// BHP §2.3: the three raw DH secrets differ per role; the master key
  /// formula always orders both peers' public keys Alice-first.
  Future<List<int>> _deriveMasterKey({
    required SimpleKeyPair ephemeral,
    required List<int> localLongTermPublic,
    required List<int> ephemeralPublic,
    required List<int> remoteEphemeralPublic,
    required bool isAlice,
  }) async {
    final localAgreement = localIdentity.agreementKeyPair;

    final List<int> rawEphemeral;
    final List<int> rawStaticEphemeral;
    final List<int> rawEphemeralStatic;
    if (isAlice) {
      rawEphemeral = await BrambleKeyAgreement.dh(
        ephemeral,
        remoteEphemeralPublic,
      );
      rawStaticEphemeral = await BrambleKeyAgreement.dh(
        localAgreement,
        remoteEphemeralPublic,
      );
      rawEphemeralStatic = await BrambleKeyAgreement.dh(
        ephemeral,
        remoteLongTermPublicKey,
      );
    } else {
      rawEphemeral = await BrambleKeyAgreement.dh(
        ephemeral,
        remoteEphemeralPublic,
      );
      rawStaticEphemeral = await BrambleKeyAgreement.dh(
        ephemeral,
        remoteLongTermPublicKey,
      );
      rawEphemeralStatic = await BrambleKeyAgreement.dh(
        localAgreement,
        remoteEphemeralPublic,
      );
    }

    try {
      return await BrambleKeyAgreement.deriveMasterKey(
        rawEphemeral: rawEphemeral,
        rawStaticEphemeral: rawStaticEphemeral,
        rawEphemeralStatic: rawEphemeralStatic,
        longTermPubAlice:
            isAlice ? localLongTermPublic : remoteLongTermPublicKey,
        longTermPubBob:
            isAlice ? remoteLongTermPublicKey : localLongTermPublic,
        ephemeralPubAlice: isAlice ? ephemeralPublic : remoteEphemeralPublic,
        ephemeralPubBob: isAlice ? remoteEphemeralPublic : ephemeralPublic,
      );
    } finally {
      // BHP §2.3: raw shared secrets are deleted once cooked into the master.
      _zero(rawEphemeral);
      _zero(rawStaticEphemeral);
      _zero(rawEphemeralStatic);
    }
  }

  Future<void> _sendRecord(int type, List<int> payload) {
    return connection.send(HandshakeRecord(type: type, payload: payload).encode());
  }

  Future<void> _sendMinorVersion() {
    return _sendRecord(
      HandshakeRecord.typeMinorVersion,
      [HandshakeRecord.minorVersion],
    );
  }

  static int _compareBytes(List<int> a, List<int> b) {
    final length = a.length < b.length ? a.length : b.length;
    for (var i = 0; i < length; i++) {
      if (a[i] != b[i]) return a[i] < b[i] ? -1 : 1;
    }
    if (a.length != b.length) return a.length < b.length ? -1 : 1;
    return 0;
  }

  static void _zero(List<int> bytes) {
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = 0;
    }
  }
}
