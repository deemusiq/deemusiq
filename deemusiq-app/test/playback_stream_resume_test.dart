import 'dart:async';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deemusiq/provider/server/routes/playback.dart';

Uint8List _bytes(int start, int length) =>
    Uint8List.fromList(List.generate(length, (i) => (start + i) % 256));

Stream<Uint8List> _stream(
  List<Uint8List> chunks, {
  Object? errorAtEnd,
}) async* {
  for (final chunk in chunks) {
    yield chunk;
  }
  if (errorAtEnd != null) throw errorAtEnd;
}

Future<Uint8List> _collect(Stream<Uint8List> stream) async {
  final builder = BytesBuilder(copy: false);
  await for (final chunk in stream) {
    builder.add(chunk);
  }
  return builder.toBytes();
}

void main() {
  group('resumableCheckedStream', () {
    test('passes a complete body through without resuming', () async {
      var reopenCalls = 0;
      final result = await _collect(
        resumableCheckedStream(
          _stream([_bytes(0, 4), _bytes(4, 4)]),
          expectedLength: 8,
          reopen: (offset) async {
            reopenCalls++;
            return _stream([]);
          },
        ),
      );
      expect(result, _bytes(0, 8));
      expect(reopenCalls, 0);
    });

    test('resumes with a Range offset after a mid-stream error', () async {
      final offsets = <int>[];
      final resumed = <int, List<Uint8List>>{
        4: [_bytes(4, 4)],
      };
      final result = await _collect(
        resumableCheckedStream(
          _stream([_bytes(0, 4)], errorAtEnd: StateError('connection reset')),
          expectedLength: 8,
          reopen: (offset) async {
            offsets.add(offset);
            return _stream(resumed[offset]!);
          },
        ),
      );
      expect(result, _bytes(0, 8));
      expect(offsets, [4]);
    });

    test('resumes after a clean but truncated body (early EOF)', () async {
      final offsets = <int>[];
      final result = await _collect(
        resumableCheckedStream(
          _stream([_bytes(0, 6)]),
          expectedLength: 8,
          reopen: (offset) async {
            offsets.add(offset);
            return _stream([_bytes(6, 2)]);
          },
        ),
      );
      expect(result, _bytes(0, 8));
      expect(offsets, [6]);
    });

    test('resumes across multiple interruptions within the limit', () async {
      final parts = <int, List<Uint8List>>{
        2: [_bytes(2, 2)],
        4: [_bytes(4, 4)],
      };
      final emissions = <int, int>{};
      final result = await _collect(
        resumableCheckedStream(
          _stream([_bytes(0, 2)], errorAtEnd: StateError('reset 1')),
          expectedLength: 8,
          maxResumes: 3,
          reopen: (offset) async {
            final attempt = (emissions[offset] ?? 0) + 1;
            emissions[offset] = attempt;
            // First resume stream delivers 2 bytes then dies; second finishes.
            return _stream(parts[offset]!, errorAtEnd: offset == 2 ? StateError('reset 2') : null);
          },
        ),
      );
      expect(result, _bytes(0, 8));
      expect(emissions.keys, containsAll([2, 4]));
    });

    test('sha256 is verified over the stitched body', () async {
      final full = _bytes(0, 8);
      final hash = sha256.convert(full).toString();
      final result = await _collect(
        resumableCheckedStream(
          _stream([_bytes(0, 5)], errorAtEnd: StateError('reset')),
          expectedLength: 8,
          expectedHash: hash,
          reopen: (offset) async => _stream([_bytes(5, 3)]),
        ),
      );
      expect(result, full);
    });

    test('fails when the stitched body does not match the advertised hash',
        () async {
      await expectLater(
        _collect(
          resumableCheckedStream(
            _stream([_bytes(0, 5)], errorAtEnd: StateError('reset')),
            expectedLength: 8,
            expectedHash: sha256.convert(_bytes(100, 8)).toString(),
            reopen: (offset) async => _stream([_bytes(5, 3)]),
          ),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('gives up after maxResumes and reports the shortfall', () async {
      var reopenCalls = 0;
      await expectLater(
        _collect(
          resumableCheckedStream(
            _stream([_bytes(0, 4)], errorAtEnd: StateError('reset')),
            expectedLength: 8,
            maxResumes: 2,
            reopen: (offset) async {
              reopenCalls++;
              return _stream(const [], errorAtEnd: StateError('reset again'));
            },
          ),
        ),
        throwsA(isA<StateError>()),
      );
      expect(reopenCalls, 2);
    });

    test('never resumes a body that exceeds the expected length', () async {
      var reopenCalls = 0;
      await expectLater(
        _collect(
          resumableCheckedStream(
            _stream([_bytes(0, 10)]),
            expectedLength: 8,
            reopen: (offset) async {
              reopenCalls++;
              return _stream([]);
            },
          ),
        ),
        throwsA(isA<StateError>()),
      );
      expect(reopenCalls, 0);
    });

    test('adds baseOffset to resume ranges (player Range requests)', () async {
      final offsets = <int>[];
      await expectLater(
        _collect(
          resumableCheckedStream(
            _stream([_bytes(0, 4)], errorAtEnd: StateError('reset')),
            baseOffset: 100,
            expectedLength: 8,
            maxResumes: 1,
            reopen: (offset) async {
              offsets.add(offset);
              // Still short: 4 of 8 delivered, resume limited to 1.
              return _stream(const [], errorAtEnd: StateError('reset again'));
            },
          ),
        ),
        throwsA(isA<StateError>()),
      );
      expect(offsets, [104]);
    });

    test('keeps the no-known-length behavior: error without resume, empty fails',
        () async {
      var reopenCalls = 0;
      await expectLater(
        _collect(
          resumableCheckedStream(
            _stream([_bytes(0, 4)], errorAtEnd: StateError('reset')),
            reopen: (offset) async {
              reopenCalls++;
              return _stream([]);
            },
          ),
        ),
        throwsA(isA<StateError>()),
      );
      expect(reopenCalls, 0);

      await expectLater(
        _collect(
          resumableCheckedStream(
            _stream(const []),
            reopen: (offset) async => _stream([]),
          ),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('reports interruptions through onResume', () async {
      final events = <(int, int, Object?)>[];
      await _collect(
        resumableCheckedStream(
          _stream([_bytes(0, 4)], errorAtEnd: StateError('reset')),
          expectedLength: 8,
          onResume: (received, attempt, error) =>
              events.add((received, attempt, error)),
          reopen: (offset) async => _stream([_bytes(4, 4)]),
        ),
      );
      expect(events, hasLength(1));
      expect(events.single.$1, 4);
      expect(events.single.$2, 1);
      expect(events.single.$3, isA<StateError>());
    });
  });
}
