/// Transport abstraction for Bramble protocols. BHP "can operate over any
/// connection-oriented, bidirectional transport protocol" (§1.2) — M1 defines
/// the seam only; Bluetooth/WiFi implementations arrive in later milestones.
library;

/// A bidirectional byte-stream connection to a peer.
abstract class TransportConnection {
  /// Incoming bytes, in arrival order. Completes when the peer closes.
  Stream<List<int>> get incoming;

  /// Queues [bytes] for transmission.
  Future<void> send(List<int> bytes);

  /// Closes the connection (both directions).
  Future<void> close();
}

/// Reads framed protocol records from a transport's byte stream.
/// The M1 handshake uses `StreamHandshakeRecordReader` (records.dart) as the
/// BHP implementation; the interface exists so transports with their own
/// framing (e.g. datagram-based) can plug in later.
abstract class TransportReader<T> {
  /// The next record, or null on clean end-of-stream.
  Future<T?> read();
}
