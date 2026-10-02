import 'dart:async';
import 'dart:typed_data';

/// BHP §2.1 record framing:
/// `record_header = int8(protocol_version) || int8(record_type) || int16be(len)`
/// followed by the payload. Payloads are capped at 48 KiB.
class HandshakeRecord {
  static const int headerLength = 4;
  static const int maxPayloadLength = 48 * 1024;

  /// BHP protocol major version carried in the record header. Version 0.1
  /// uses 0 here; the minor version travels in a MINOR_VERSION record.
  static const int protocolVersion = 0;

  // Record types of BHP 0.1.
  static const int typeEphemeralPublicKey = 0;
  static const int typeProofOfOwnership = 1;
  static const int typeMinorVersion = 2;

  /// The non-zero minor version this implementation speaks (BHP 0.1).
  static const int minorVersion = 1;

  final int version;
  final int type;
  final Uint8List payload;

  HandshakeRecord({
    required this.type,
    required List<int> payload,
    this.version = protocolVersion,
  }) : payload = Uint8List.fromList(payload) {
    if (payload.length > maxPayloadLength) {
      throw ArgumentError(
        'Record payload exceeds ${maxPayloadLength}B: ${payload.length}',
      );
    }
  }

  Uint8List encode() {
    final out = Uint8List(headerLength + payload.length);
    final view = ByteData.sublistView(out);
    view.setUint8(0, version);
    view.setUint8(1, type);
    view.setUint16(2, payload.length);
    out.setRange(headerLength, out.length, payload);
    return out;
  }
}

/// Reads length-prefixed [HandshakeRecord]s from a byte stream.
/// Returns null on clean end-of-stream (a peer closing mid-handshake aborts
/// the run in the state machine).
///
/// Call [dispose] when the handshake is over: the underlying
/// [StreamIterator] subscription stays paused between reads, which would
/// otherwise keep the source stream from ever completing its `close()`.
class StreamHandshakeRecordReader {
  final StreamIterator<List<int>> _iterator;
  final List<int> _buffer = [];
  bool _streamEnded = false;

  StreamHandshakeRecordReader(Stream<List<int>> incoming)
      : _iterator = StreamIterator(incoming);

  /// Cancels the stream subscription. After dispose, [read] returns null.
  Future<void> dispose() async {
    _streamEnded = true;
    await _iterator.cancel();
  }

  Future<HandshakeRecord?> read() async {
    while (true) {
      if (_buffer.length >= HandshakeRecord.headerLength) {
        final header = ByteData.sublistView(Uint8List.fromList(_buffer));
        final version = header.getUint8(0);
        final type = header.getUint8(1);
        final payloadLength = header.getUint16(2);
        if (payloadLength > HandshakeRecord.maxPayloadLength) {
          throw FormatException(
            'Record payload too large: $payloadLength bytes',
          );
        }
        final totalLength = HandshakeRecord.headerLength + payloadLength;
        if (_buffer.length >= totalLength) {
          final payload = _buffer.sublist(
            HandshakeRecord.headerLength,
            totalLength,
          );
          final rest = _buffer.sublist(totalLength);
          _buffer
            ..clear()
            ..addAll(rest);
          return HandshakeRecord(type: type, payload: payload, version: version);
        }
      }
      if (_streamEnded) {
        if (_buffer.isNotEmpty) {
          throw const FormatException('Truncated record at end of stream');
        }
        return null;
      }
      if (await _iterator.moveNext()) {
        _buffer.addAll(_iterator.current);
      } else {
        _streamEnded = true;
      }
    }
  }
}
