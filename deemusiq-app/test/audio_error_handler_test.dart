import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:deemusiq/services/audio_player/audio_error_handler.dart';
import 'package:deemusiq/services/logger/logger.dart';

void main() {
  setUpAll(() {
    AppLogger.initialize(false);
  });

  setUp(() {
    AudioErrorHandler.instance.dispose();
  });

  tearDown(() {
    AudioErrorHandler.instance.dispose();
  });

  test('resolves playback headers from the local server response', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final subscription = server.listen((request) async {
      request.response.statusCode = 503;
      request.response.headers.set(
        'x-deemusiq-playback-state',
        'unavailable',
      );
      request.response.headers.set(
        'x-deemusiq-playback-action',
        'offer_download',
      );
      request.response.headers.set(
        'x-deemusiq-playback-primary-error',
        'remote source rejected the stream',
      );
      await request.response.close();
    });
    addTearDown(() async {
      await subscription.cancel();
      await server.close(force: true);
    });

    final error = await PlaybackUnavailableError.resolve(
      'Server returned 5XX Server Error reply',
      source: 'http://127.0.0.1:${server.port}/stream/track-4',
      timeout: const Duration(seconds: 1),
    );

    expect(error, isNotNull);
    expect(error!.trackId, 'track-4');
    expect(error.primaryError, 'remote source rejected the stream');
  });

  test('maps the exact 503 playback contract and keeps the primary error', () {
    final error = PlaybackUnavailableError.fromResponse(
      statusCode: 503,
      headers: const {
        'x-deemusiq-playback-state': 'unavailable',
        'x-deemusiq-playback-action': 'offer_download',
        'x-deemusiq-playback-primary-error': 'remote source timed out',
      },
      body: jsonEncode({
        'trackId': 'track-1',
        'requiresConsent': true,
      }),
    );

    expect(error, isNotNull);
    expect(error!.statusCode, 503);
    expect(error.state, 'unavailable');
    expect(error.action, 'offer_download');
    expect(error.trackId, 'track-1');
    expect(error.primaryError, 'remote source timed out');
    expect(error.requiresConsent, isTrue);
  });

  test('does not map a 503 without both playback headers', () {
    final error = PlaybackUnavailableError.fromResponse(
      statusCode: 503,
      headers: const {
        'x-deemusiq-playback-state': 'unavailable',
      },
    );

    expect(error, isNull);
  });

  test('maps structured player text and derives the track id', () {
    final error = PlaybackUnavailableError.fromText(
      '503 Service Unavailable '
      'x-deemusiq-playback-state: unavailable\n'
      'x-deemusiq-playback-action: offer_download\n'
      '{"state":"unavailable","action":"offer_download",'
      '"primaryError":"upstream rejected the stream"}',
      source: 'http://127.0.0.1:12345/stream/track-2',
    );

    expect(error, isNotNull);
    expect(error!.trackId, 'track-2');
    expect(error.primaryError, 'upstream rejected the stream');
  });

  test('download consent is the only accepted unavailable-track outcome',
      () async {
    var consentRequested = false;
    var skipped = false;
    final messages = <String>[];

    AudioErrorHandler.instance.onSkipRequested = () {
      skipped = true;
    };
    AudioErrorHandler.instance.onUserMessage = (message, _) {
      messages.add(message);
    };
    AudioErrorHandler.instance.onPlaybackUnavailable = (_) async {
      consentRequested = true;
      return AudioUnavailableAction.downloadQueued;
    };

    final handled = await AudioErrorHandler.instance.handleError(
      PlaybackUnavailableError.fromResponse(
        statusCode: 503,
        headers: const {
          'x-deemusiq-playback-state': 'unavailable',
          'x-deemusiq-playback-action': 'offer_download',
          'x-deemusiq-playback-primary-error': 'remote source failed',
        },
        body: '{"trackId":"track-3"}',
      )!,
      StackTrace.current,
    );

    expect(handled, isTrue);
    expect(consentRequested, isTrue);
    expect(skipped, isFalse);
    expect(messages, ['Download requested — retry when it is ready']);
  });

  test('cancelling consent returns a retryable unavailable state', () async {
    var skipped = false;
    final messages = <String>[];

    AudioErrorHandler.instance.onSkipRequested = () {
      skipped = true;
    };
    AudioErrorHandler.instance.onUserMessage = (message, _) {
      messages.add(message);
    };
    AudioErrorHandler.instance.onPlaybackUnavailable = (_) async {
      return AudioUnavailableAction.retry;
    };

    final handled = await AudioErrorHandler.instance.handleError(
      PlaybackUnavailableError.fromResponse(
        statusCode: 503,
        headers: const {
          'x-deemusiq-playback-state': 'unavailable',
          'x-deemusiq-playback-action': 'offer_download',
        },
      )!,
      StackTrace.current,
    );

    expect(handled, isTrue);
    expect(skipped, isFalse);
    expect(messages, ['Playback unavailable — retry or download this track']);
  });

  test('maps the offline flag from the playback contract', () {
    final error = PlaybackUnavailableError.fromResponse(
      statusCode: 503,
      headers: const {
        'x-deemusiq-playback-state': 'unavailable',
        'x-deemusiq-playback-action': 'offer_download',
        'x-deemusiq-playback-offline': 'true',
      },
      body: '{"trackId":"track-9","offline":true}',
    );

    expect(error, isNotNull);
    expect(error!.offline, isTrue);
  });

  test('offline failures fail fast with a clear message and no consent dialog',
      () async {
    var consentRequested = false;
    var skipped = false;
    final messages = <String>[];

    AudioErrorHandler.instance.onSkipRequested = () {
      skipped = true;
    };
    AudioErrorHandler.instance.onUserMessage = (message, _) {
      messages.add(message);
    };
    AudioErrorHandler.instance.onPlaybackUnavailable = (_) async {
      consentRequested = true;
      return AudioUnavailableAction.retry;
    };

    final handled = await AudioErrorHandler.instance.handleError(
      PlaybackUnavailableError.fromResponse(
        statusCode: 503,
        headers: const {
          'x-deemusiq-playback-state': 'unavailable',
          'x-deemusiq-playback-action': 'offer_download',
          'x-deemusiq-playback-offline': 'true',
        },
        body: '{"trackId":"track-10"}',
      )!,
      StackTrace.current,
    );

    expect(handled, isTrue);
    expect(consentRequested, isFalse);
    expect(skipped, isFalse);
    expect(messages, [
      "Couldn't reach DeeMusiq servers — check your connection and try again"
    ]);
  });

  test('stops skip-storming after consecutive source failures', () async {
    var skipCount = 0;
    final messages = <String>[];

    AudioErrorHandler.instance.onSkipRequested = () {
      skipCount++;
    };
    AudioErrorHandler.instance.onUserMessage = (message, _) {
      messages.add(message);
    };

    // Errors less than 500ms apart are deduplicated by handleError, so space
    // the simulated track failures out like real playback attempts.
    for (var i = 0; i < 5; i++) {
      await AudioErrorHandler.instance.handleError(
        Exception('HTTP error 403 Forbidden'),
        StackTrace.current,
      );
      await Future.delayed(const Duration(milliseconds: 600));
    }

    expect(skipCount, 3);
    expect(
      messages,
      contains(
        'Multiple tracks failed to play — check your connection and try again',
      ),
    );
  });

  test('network retries stop after the budget is exhausted', () async {
    var retryCount = 0;
    final messages = <String>[];

    AudioErrorHandler.instance.onUserMessage = (message, _) {
      messages.add(message);
    };
    AudioErrorHandler.instance.onRetryPlayback = () async {
      retryCount++;
      return false;
    };

    for (var i = 0; i < 5; i++) {
      await AudioErrorHandler.instance.handleError(
        Exception('Connection refused'),
        StackTrace.current,
      );
    }

    // 3 retries (maxRetries), then a terminal error message and no more
    // retry attempts — the player stays stopped instead of looping forever.
    expect(retryCount, 3);
    expect(
      messages,
      contains(
        "Couldn't reach DeeMusiq servers — check your connection and try again",
      ),
    );
  });

  test('successful playback re-arms automatic recovery', () async {
    var skipCount = 0;

    AudioErrorHandler.instance.onSkipRequested = () {
      skipCount++;
    };

    for (var i = 0; i < 3; i++) {
      await AudioErrorHandler.instance.handleError(
        Exception('HTTP error 403 Forbidden'),
        StackTrace.current,
      );
      await Future.delayed(const Duration(milliseconds: 600));
    }
    AudioErrorHandler.instance.notifyPlaybackHealthy();
    await AudioErrorHandler.instance.handleError(
      Exception('HTTP error 403 Forbidden'),
      StackTrace.current,
    );

    expect(skipCount, 4);
  });
}
