import 'dart:async';

import 'package:bramble_dart/bramble_dart.dart';
import 'package:test/test.dart';

/// Cross-wired in-memory transport pair for handshake tests.
class _Pipe implements TransportConnection {
  final StreamController<List<int>> _incoming;
  final StreamController<List<int>> _outgoing;
  bool _closed = false;

  _Pipe(this._incoming, this._outgoing);

  @override
  Stream<List<int>> get incoming => _incoming.stream;

  @override
  Future<void> send(List<int> bytes) async {
    if (_closed) throw StateError('connection closed');
    _outgoing.add(bytes);
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    // Fire-and-forget: awaiting the controller's close future deadlocks when
    // the peer's reader has a pending moveNext() that only resolves on done.
    unawaited(_outgoing.close());
  }
}

(TransportConnection, TransportConnection) _transportPair() {
  final a = StreamController<List<int>>();
  final b = StreamController<List<int>>();
  return (_Pipe(a, b), _Pipe(b, a));
}

Future<({BrambleHandshakeResult a, BrambleHandshakeResult b})> _runPair({
  BrambleIdentity? a,
  BrambleIdentity? b,
  List<int>? bSeesA,
}) async {
  a ??= await BrambleIdentity.generate();
  b ??= await BrambleIdentity.generate();
  final (connA, connB) = _transportPair();

  final handshakeA = BrambleHandshake(
    localIdentity: a,
    remoteLongTermPublicKey: await b.agreementPublicKeyBytes(),
    connection: connA,
  );
  final handshakeB = BrambleHandshake(
    localIdentity: b,
    remoteLongTermPublicKey: bSeesA ?? await a.agreementPublicKeyBytes(),
    connection: connB,
  );

  final results = await Future.wait([
    handshakeA.run(),
    handshakeB.run(),
  ]);
  return (a: results[0], b: results[1]);
}

void main() {
  group('BrambleHandshake (BHP 0.1)', () {
    test('happy path: both peers derive the same master key', () async {
      final results = await _runPair();
      expect(results.a.masterKey, results.b.masterKey);
      expect(results.a.masterKey, hasLength(32));
      // Roles are complementary and follow the key order.
      expect(results.a.isAlice, isNot(results.b.isAlice));
    });

    test('Alice is always the peer with the earlier long-term key', () async {
      // Run several pairs: the alice flag must track the key order, not
      // identity generation order.
      for (var i = 0; i < 4; i++) {
        final a = await BrambleIdentity.generate();
        final b = await BrambleIdentity.generate();
        final results = await _runPair(a: a, b: b);
        final aPub = await a.agreementPublicKeyBytes();
        final bPub = await b.agreementPublicKeyBytes();
        final aIsEarlier = _lexCompare(aPub, bPub) < 0;
        expect(results.a.isAlice, aIsEarlier);
        expect(results.b.isAlice, !aIsEarlier);
      }
    });

    test('different runs produce different master keys (fresh ephemerals)',
        () async {
      final a = await BrambleIdentity.generate();
      final b = await BrambleIdentity.generate();
      final first = await _runPair(a: a, b: b);
      final second = await _runPair(a: a, b: b);
      expect(first.a.masterKey, isNot(second.a.masterKey));
    });

    test('wrong expected long-term key → proof mismatch aborts both sides',
        () async {
      final a = await BrambleIdentity.generate();
      final b = await BrambleIdentity.generate();

      // B is configured with a bogus key for A that is strictly GREATER than
      // B's own key (first differing byte bumped by one), so B consistently
      // takes the Alice role — the masters differ either way and the proofs
      // fail on both sides without any role-assignment deadlock.
      final bogusA = List<int>.from(await b.agreementPublicKeyBytes());
      for (var i = 0; i < bogusA.length; i++) {
        if (bogusA[i] < 255) {
          bogusA[i]++;
          break;
        }
      }

      final (connA, connB) = _transportPair();
      final resultA = BrambleHandshake(
        localIdentity: a,
        remoteLongTermPublicKey: await b.agreementPublicKeyBytes(),
        connection: connA,
      ).run();
      final resultB = BrambleHandshake(
        localIdentity: b,
        remoteLongTermPublicKey: bogusA,
        connection: connB,
      ).run();

      // Attach both error handlers eagerly: whichever future fails first must
      // not surface as an unhandled async error while the other is awaited.
      final expectA =
          expectLater(resultA, throwsA(isA<BrambleHandshakeException>()));
      final expectB =
          expectLater(resultB, throwsA(isA<BrambleHandshakeException>()));
      await expectA;
      await expectB;
    });

    test('handshaking with oneself is rejected', () async {
      final a = await BrambleIdentity.generate();
      final (connA, _) = _transportPair();
      await expectLater(
        BrambleHandshake(
          localIdentity: a,
          remoteLongTermPublicKey: await a.agreementPublicKeyBytes(),
          connection: connA,
        ).run(),
        throwsA(isA<BrambleHandshakeException>()),
      );
    });

    test('a peer that never sends a minor version aborts the run', () async {
      final a = await BrambleIdentity.generate();
      final b = await BrambleIdentity.generate();
      final (connA, connB) = _transportPair();

      // Rogue peer: sends an ephemeral key but no MINOR_VERSION record, then
      // a proof — must never complete.
      final rogue = () async {
        final eph = await BrambleKeyAgreement.generateEphemeralKeyPair();
        final ephPub = (await eph.extractPublicKey()).bytes;
        await connB.send(
          HandshakeRecord(
            type: HandshakeRecord.typeEphemeralPublicKey,
            payload: ephPub,
          ).encode(),
        );
        await connB.send(
          HandshakeRecord(
            type: HandshakeRecord.typeProofOfOwnership,
            payload: List.filled(32, 0),
          ).encode(),
        );
        // Keep the connection open: A must not complete without the minor
        // version. Close after a beat so the test ends.
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await connB.close();
      }();

      await expectLater(
        BrambleHandshake(
          localIdentity: a,
          remoteLongTermPublicKey: await b.agreementPublicKeyBytes(),
          connection: connA,
        ).run(),
        throwsA(isA<BrambleHandshakeException>()),
      );
      await rogue;
    });

    test('record with an unsupported protocol version aborts the run',
        () async {
      final a = await BrambleIdentity.generate();
      final b = await BrambleIdentity.generate();
      final (connA, connB) = _transportPair();

      unawaited(() async {
        await connB.send(
          HandshakeRecord(
            type: HandshakeRecord.typeEphemeralPublicKey,
            payload: List.filled(32, 1),
            version: 9,
          ).encode(),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await connB.close();
      }());

      await expectLater(
        BrambleHandshake(
          localIdentity: a,
          remoteLongTermPublicKey: await b.agreementPublicKeyBytes(),
          connection: connA,
        ).run(),
        throwsA(isA<BrambleHandshakeException>()),
      );
    });
  });

  group('HandshakeRecord framing', () {
    test('encode/decode round-trips, chunked arbitrarily', () async {
      final controller = StreamController<List<int>>();
      final reader = StreamHandshakeRecordReader(controller.stream);
      addTearDown(() async {
        await reader.dispose();
        await controller.close();
      });

      final firstRecord = HandshakeRecord(
        type: HandshakeRecord.typeEphemeralPublicKey,
        payload: List.generate(32, (i) => i),
      ).encode();
      final secondRecord = HandshakeRecord(
        type: HandshakeRecord.typeMinorVersion,
        payload: [1],
      ).encode();
      final record = [...firstRecord, ...secondRecord];

      // Feed byte-by-byte to prove the reader reassembles across chunks.
      for (final byte in record) {
        controller.add([byte]);
      }

      final first = await reader.read();
      expect(first!.type, HandshakeRecord.typeEphemeralPublicKey);
      expect(first.payload, List.generate(32, (i) => i));
      final second = await reader.read();
      expect(second!.type, HandshakeRecord.typeMinorVersion);
      expect(second.payload, [1]);
    });

    test('oversized payload length is rejected', () {
      expect(
        () => HandshakeRecord(
          type: 0,
          payload: List.filled(HandshakeRecord.maxPayloadLength + 1, 0),
        ),
        throwsArgumentError,
      );
    });
  });
}

int _lexCompare(List<int> a, List<int> b) {
  for (var i = 0; i < 32; i++) {
    if (a[i] != b[i]) return a[i] < b[i] ? -1 : 1;
  }
  return 0;
}
