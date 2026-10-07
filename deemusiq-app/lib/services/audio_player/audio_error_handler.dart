import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:deemusiq/services/logger/logger.dart';

const audioPlaybackUnavailableStateHeader = 'x-deemusiq-playback-state';
const audioPlaybackDownloadActionHeader = 'x-deemusiq-playback-action';
const audioPlaybackPrimaryErrorHeader = 'x-deemusiq-playback-primary-error';
const audioPlaybackOfflineHeader = 'x-deemusiq-playback-offline';

class PlaybackUnavailableError {
  final int statusCode;
  final String state;
  final String action;
  final String trackId;
  final Object primaryError;
  final String? message;
  final bool requiresConsent;

  /// True when the failure is network-level (DeeMusiq servers unreachable) —
  /// the user needs a clear "check your connection" message, not a retry loop.
  final bool offline;

  const PlaybackUnavailableError({
    required this.statusCode,
    required this.state,
    required this.action,
    required this.trackId,
    required this.primaryError,
    this.message,
    this.requiresConsent = true,
    this.offline = false,
  });

  static PlaybackUnavailableError? fromResponse({
    required int statusCode,
    required Map<String, dynamic> headers,
    String? body,
    String? source,
    Object? originalError,
  }) {
    final decoded = _decodeObject(body);
    final state = _metadataValue(
      headers,
      null,
      'state',
      audioPlaybackUnavailableStateHeader,
    );
    final action = _metadataValue(
      headers,
      null,
      'action',
      audioPlaybackDownloadActionHeader,
    );
    if (statusCode != 503 ||
        state?.trim().toLowerCase() != 'unavailable' ||
        action?.trim().toLowerCase() != 'offer_download') {
      return null;
    }

    final primary = _metadataValue(
      headers,
      decoded,
      'primaryError',
      audioPlaybackPrimaryErrorHeader,
    );
    final trackId = _metadataValue(
      headers,
      decoded,
      'trackId',
      null,
    );
    final resolvedTrackId =
        trackId?.isNotEmpty == true ? trackId! : _trackIdFromSource(source);
    final message = _metadataValue(headers, decoded, 'message', null);
    final consentValue = decoded?['requiresConsent'];
    final requiresConsent = switch (consentValue) {
      bool value => value,
      String value => !const {'false', '0', 'no'}.contains(
          value.trim().toLowerCase(),
        ),
      _ => true,
    };
    final offlineValue = _metadataValue(
      headers,
      decoded,
      'offline',
      audioPlaybackOfflineHeader,
    );
    final offline = offlineValue != null &&
        const {'true', '1', 'yes'}.contains(offlineValue.trim().toLowerCase());

    return PlaybackUnavailableError(
      statusCode: statusCode,
      state: state!,
      action: action!,
      trackId: resolvedTrackId ?? '',
      primaryError: primary ?? originalError ?? 'Remote playback source failed',
      message: message,
      requiresConsent: requiresConsent,
      offline: offline,
    );
  }

  static PlaybackUnavailableError? fromText(
    Object error, {
    String? source,
  }) {
    final text = error.toString();
    final headers = <String, dynamic>{};
    for (final name in const [
      audioPlaybackUnavailableStateHeader,
      audioPlaybackDownloadActionHeader,
      audioPlaybackPrimaryErrorHeader,
      audioPlaybackOfflineHeader,
    ]) {
      final value = _textValue(text, name);
      if (value != null) headers[name] = value;
    }

    final headerState = _metadataValue(
      headers,
      null,
      'state',
      audioPlaybackUnavailableStateHeader,
    );
    final headerAction = _metadataValue(
      headers,
      null,
      'action',
      audioPlaybackDownloadActionHeader,
    );
    final hasContract =
        headerState?.trim().toLowerCase() == 'unavailable' &&
            headerAction?.trim().toLowerCase() == 'offer_download';
    if (!hasContract) return null;

    final statusCode = _statusCode(text, _decodeObject(text)) ?? 503;
    return fromResponse(
      statusCode: statusCode,
      headers: headers,
      body: text,
      source: source,
      originalError: error,
    );
  }

  static Future<PlaybackUnavailableError?> resolve(
    Object error, {
    String? source,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final parsed = fromText(error, source: source);
    if (parsed != null) return parsed;
    if (!isPotentialPlaybackUnavailable(error) || source == null) {
      return null;
    }

    final uri = Uri.tryParse(source);
    if (uri == null ||
        !_isLoopbackHost(uri.host) ||
        (uri.hasPort && uri.port <= 0)) {
      return null;
    }

    final client = HttpClient();
    try {
      final request = await client.headUrl(uri).timeout(timeout);
      final response = await request.close().timeout(timeout);
      final headers = <String, dynamic>{};
      for (final name in const [
        audioPlaybackUnavailableStateHeader,
        audioPlaybackDownloadActionHeader,
        audioPlaybackPrimaryErrorHeader,
        audioPlaybackOfflineHeader,
      ]) {
        final value = response.headers.value(name);
        if (value != null) headers[name] = value;
      }

      String? body;
      if (response.statusCode == 503) {
        try {
          body = await response.transform(utf8.decoder).join().timeout(timeout);
        } catch (_) {}
      } else {
        await response.drain<void>().timeout(timeout);
      }

      return fromResponse(
        statusCode: response.statusCode,
        headers: headers,
        body: body,
        source: source,
        originalError: error,
      );
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }

  static bool isPotentialPlaybackUnavailable(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains(audioPlaybackUnavailableStateHeader) ||
        text.contains(audioPlaybackDownloadActionHeader) ||
        text.contains('offer_download') ||
        RegExp(r'\b503\b|\b5xx\b|service unavailable').hasMatch(text);
  }

  @override
  String toString() {
    return 'PlaybackUnavailableError($trackId): $primaryError';
  }

  static Map<String, dynamic>? _decodeObject(String? value) {
    if (value == null) return null;
    final start = value.indexOf('{');
    final end = value.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    try {
      final decoded = jsonDecode(value.substring(start, end + 1));
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }

  static String? _metadataValue(
    Map<String, dynamic> headers,
    Map<String, dynamic>? body,
    String bodyKey,
    String? headerName,
  ) {
    final bodyValue = body?[bodyKey]?.toString().trim();
    if (bodyValue != null && bodyValue.isNotEmpty) return bodyValue;
    if (headerName == null) return null;
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == headerName) {
        final rawValue = entry.value;
        final value = rawValue is Iterable
            ? rawValue.map((item) => item.toString()).join(',').trim()
            : rawValue?.toString().trim();
        if (value != null && value.isNotEmpty) return value;
      }
    }

    return null;
  }

  static String? _textValue(String text, String name) {
    final quotedMatch = RegExp(
      "${RegExp.escape(name)}\\s*[\"']?\\s*[:=]\\s*[\"']([^\"']+)[\"']",
      caseSensitive: false,
    ).firstMatch(text);
    final quotedValue = quotedMatch?.group(1)?.trim();
    if (quotedValue != null) return quotedValue;

    final match = RegExp(
      "${RegExp.escape(name)}\\s*[\"']?\\s*[:=]\\s*[\"']?([^,;}\\r\\n]+)",
      caseSensitive: false,
    ).firstMatch(text);
    final value = match?.group(1)?.trim();
    if (value == null) return null;
    return value.replaceFirst(RegExp(r'''^["']+|["']+$'''), '').trim();
  }

  static int? _statusCode(String text, Map<String, dynamic>? body) {
    final bodyValue = body?['statusCode'] ?? body?['status'];
    final parsedBody = int.tryParse(bodyValue?.toString() ?? '');
    if (parsedBody != null) return parsedBody;
    final match = RegExp(r'\b(5\d\d)\b').firstMatch(text);
    return int.tryParse(match?.group(1) ?? '');
  }

  static String? _trackIdFromSource(String? source) {
    if (source == null) return null;
    final uri = Uri.tryParse(source);
    final segments = uri?.pathSegments ?? const <String>[];
    final index = segments.lastIndexOf('stream');
    if (index < 0 || index + 1 >= segments.length) return null;
    try {
      return Uri.decodeComponent(segments[index + 1]);
    } catch (_) {
      return segments[index + 1];
    }
  }

  static bool _isLoopbackHost(String host) {
    return host == '127.0.0.1' || host == 'localhost' || host == '::1';
  }
}

enum AudioUnavailableAction {
  retry,
  downloadQueued,
}

/// Centralized error handler for the audio pipeline.
///
/// Every error in the audio pipeline flows through here so we can:
/// - Log what failed and why
/// - Attempt recovery (retry with backoff, skip track, degrade quality)
/// - Notify the user with a clear message (never silently fail)
/// - Never crash the app
class AudioErrorHandler {
  AudioErrorHandler._();

  static final _instance = AudioErrorHandler._();
  static AudioErrorHandler get instance => _instance;

  DateTime? _lastErrorTime;
  bool _handlingUnavailable = false;

  /// Persistent failure counters. [handleError] is invoked once per player
  /// error event with `attempt: 1`, so without these the retry budget resets
  /// on every event and a persistent failure (e.g. backend unreachable)
  /// retries/skips forever. Reset via [notifyPlaybackHealthy] or after the
  /// failure windows expire.
  int _consecutiveNetworkFailures = 0;
  DateTime? _lastNetworkFailureTime;
  static const _networkFailureWindow = Duration(seconds: 90);

  int _consecutiveSkips = 0;
  DateTime? _lastSkipTime;
  static const _maxConsecutiveSkips = 3;
  static const _skipWindow = Duration(seconds: 60);

  /// Called when playback actually starts — clears the retry/skip budgets so
  /// a recovered connection re-arms automatic recovery.
  void notifyPlaybackHealthy() {
    _consecutiveNetworkFailures = 0;
    _lastNetworkFailureTime = null;
    _consecutiveSkips = 0;
    _lastSkipTime = null;
  }

  /// Surfaces an informational message through the same channel as playback
  /// errors. Used for silent source switches — e.g. the direct-YouTube
  /// fallback when the DeeMusiq backend is unreachable — so the user can see
  /// why the track is still playing.
  void notifyPlaybackFallback(String message) =>
      _notifyUser(message, AudioErrorSeverity.info);

  /// Callback invoked when the user should be shown a message.
  /// Set this from the UI layer (e.g., to show a toast/snackbar).
  void Function(String message, AudioErrorSeverity severity)? onUserMessage;

  /// Callback invoked when the player should skip to the next track
  /// because the current one is unplayable.
  void Function()? onSkipRequested;

  /// Callback invoked when playback should be retried on the current source.
  Future<bool> Function()? onRetryPlayback;

  Future<AudioUnavailableAction?> Function(PlaybackUnavailableError error)?
      onPlaybackUnavailable;

  /// Maps error types to user-friendly messages.
  static String userMessageFor(
    Object error,
    AudioErrorCategory category,
  ) {
    if (error is PlaybackUnavailableError) {
      if (error.offline) {
        return "Couldn't reach DeeMusiq servers — check your connection and try again";
      }
      return 'Playback unavailable — retry or download this track';
    }

    // Network / connectivity errors
    if (category == AudioErrorCategory.network) {
      final s = error.toString().toLowerCase();
      if (s.contains('timeout') || s.contains('timed out')) {
        return 'Connection timed out — retrying...';
      }
      if (s.contains('refused') || s.contains('reset')) {
        return 'Connection refused — trying another source...';
      }
      if (s.contains('no internet') ||
          s.contains('host') ||
          s.contains('resolve') ||
          s.contains('dns')) {
        return 'No internet connection — please check your network';
      }
      return 'Network error — retrying...';
    }

    // Stream / source errors
    if (category == AudioErrorCategory.source) {
      final s = error.toString().toLowerCase();
      // Never surface upstream-provider failures (or any residual diagnostics
      // that mention them) — clients only ever see generic playback copy.
      if (s.contains('youtube') ||
          s.contains('googlevideo') ||
          s.contains('yt-dlp') ||
          s.contains('ytdl') ||
          s.contains('innertube') ||
          s.contains('resolver')) {
        return 'Unable to play this track — trying next source...';
      }
      if (s.contains('403') || s.contains('forbidden')) {
        return 'This track is unavailable — skipping to next';
      }
      if (s.contains('404') || s.contains('not found')) {
        return 'Track not found — skipping to next';
      }
      if (s.contains('410') || s.contains('gone')) {
        return 'This track has been removed — skipping to next';
      }
      if (s.contains('429') || s.contains('too many')) {
        return 'Rate limited — waiting before retrying...';
      }
      if (s.contains('drm') || s.contains('protected') || s.contains('encrypted')) {
        return 'This track is protected and cannot be played';
      }
      if (s.contains('corrupt') || s.contains('invalid') || s.contains('decode')) {
        return 'Track file appears to be corrupt — skipping to next';
      }
      return 'Unable to play this track — trying next source...';
    }

    // Player / mpv errors
    if (category == AudioErrorCategory.player) {
      final s = error.toString().toLowerCase();
      if (s.contains('init') || s.contains('load') || s.contains('library')) {
        return 'Audio engine failed to start — please restart the app';
      }
      if (s.contains('device') || s.contains('output')) {
        return 'Audio output error — check your speakers or headphones';
      }
      if (s.contains('format') || s.contains('codec') || s.contains('unsupported')) {
        return 'Unsupported audio format — skipping to next';
      }
      return 'Playback error — retrying...';
    }

    return 'Something went wrong — please try again';
  }

  /// Determines the category of an error based on its type and message.
  static AudioErrorCategory _categorize(Object error) {
    final s = error.toString().toLowerCase();

    // Network errors
    if (s.contains('timeout') ||
        s.contains('timed out') ||
        s.contains('connection') ||
        s.contains('network') ||
        s.contains('socket') ||
        s.contains('host') ||
        s.contains('resolve') ||
        s.contains('dns') ||
        s.contains('no internet') ||
        s.contains('refused') ||
        s.contains('reset') ||
        s.contains('unreachable') ||
        error is TimeoutException) {
      return AudioErrorCategory.network;
    }

    // Source / HTTP errors
    if (s.contains('403') ||
        s.contains('404') ||
        s.contains('410') ||
        s.contains('429') ||
        s.contains('500') ||
        s.contains('502') ||
        s.contains('503') ||
        s.contains('forbidden') ||
        s.contains('not found') ||
        s.contains('gone') ||
        s.contains('drm') ||
        s.contains('protected') ||
        s.contains('encrypted') ||
        s.contains('corrupt') ||
        s.contains('decode') ||
        s.contains('youtube') ||
        s.contains('googlevideo') ||
        s.contains('yt-dlp') ||
        s.contains('ytdl') ||
        s.contains('source_unavailable') ||
        s.contains('resolver')) {
      return AudioErrorCategory.source;
    }

    // Player errors
    if (s.contains('mpv') ||
        s.contains('player') ||
        s.contains('playback') ||
        s.contains('init') ||
        s.contains('load') ||
        s.contains('library') ||
        s.contains('device') ||
        s.contains('output') ||
        s.contains('format') ||
        s.contains('codec') ||
        s.contains('unsupported')) {
      return AudioErrorCategory.player;
    }

    return AudioErrorCategory.unknown;
  }

  /// Handles an audio pipeline error: logs it, notifies user, attempts recovery.
  ///
  /// Returns `true` if recovery was attempted and the caller should not
  /// propagate the error further.
  Future<bool> handleError(
    Object error,
    StackTrace stack, {
    String context = '',
    int attempt = 1,
    int maxRetries = 3,
    bool canSkipTrack = true,
  }) async {
    final now = DateTime.now();
    final isUnavailable = error is PlaybackUnavailableError;
    if (!isUnavailable &&
        _lastErrorTime != null &&
        now.difference(_lastErrorTime!) < const Duration(milliseconds: 500)) {
      AppLogger.log.d('[AudioError] deduplicated — last error <500ms ago');
      return false;
    }
    _lastErrorTime = now;

    if (error is PlaybackUnavailableError) {
      return _handlePlaybackUnavailable(error, stack, context);
    }

    final category = _categorize(error);
    final message = userMessageFor(error, category);

    AppLogger.reportError(
      error,
      stack,
      '[AudioError] $context',
    );

    // Always notify user
    _notifyUser(message, category.toSeverity());

    // Attempt recovery based on category
    switch (category) {
      case AudioErrorCategory.network:
        return await _recoverNetwork(error, maxRetries);

      case AudioErrorCategory.source:
        if (canSkipTrack) {
          // Skip-storm guard: if every track in the queue fails the same way
          // (e.g. backend unreachable), skipping to the next one just retries
          // forever. After a few consecutive skips, stop and tell the user.
          final skipNow = DateTime.now();
          if (_lastSkipTime == null ||
              skipNow.difference(_lastSkipTime!) > _skipWindow) {
            _consecutiveSkips = 0;
          }
          _consecutiveSkips++;
          _lastSkipTime = skipNow;
          if (_consecutiveSkips > _maxConsecutiveSkips) {
            _notifyUser(
              'Multiple tracks failed to play — check your connection and try again',
              AudioErrorSeverity.error,
            );
            return true;
          }
          _notifyUser('Switching to next track...', AudioErrorSeverity.info);
          onSkipRequested?.call();
          return true;
        }
        return false;

      case AudioErrorCategory.player:
        if (attempt < maxRetries) {
          final retryOk = await _retryWithBackoff(attempt, maxRetries);
          if (retryOk) {
            final success = await onRetryPlayback?.call() ?? false;
            if (success) {
              _notifyUser('Playback restored', AudioErrorSeverity.info);
              return true;
            }
          }
        }
        _notifyUser(
          'Audio engine error — please restart the app if this persists',
          AudioErrorSeverity.error,
        );
        return false;

      case AudioErrorCategory.unknown:
        if (attempt < maxRetries) {
          return await _retryWithBackoff(attempt, maxRetries);
        }
        return false;
    }
  }

  Future<bool> _handlePlaybackUnavailable(
    PlaybackUnavailableError error,
    StackTrace stack,
    String context,
  ) async {
    if (_handlingUnavailable) return true;
    _handlingUnavailable = true;
    try {
      AppLogger.reportError(
        error.primaryError,
        stack,
        '[AudioError] $context primary remote playback error',
      );

      // Network-level failure: the servers can't be reached, so retrying or
      // offering a download is pointless — say so and stop.
      if (error.offline) {
        _noteNetworkFailure();
        _notifyUser(
          error.message ??
              "Couldn't reach DeeMusiq servers — check your connection and try again",
          AudioErrorSeverity.error,
        );
        return true;
      }

      AudioUnavailableAction? action;
      try {
        action = await onPlaybackUnavailable?.call(error);
      } catch (callbackError, callbackStack) {
        AppLogger.reportError(
          callbackError,
          callbackStack,
          '[AudioError] playback unavailable consent',
        );
      }

      switch (action ?? AudioUnavailableAction.retry) {
        case AudioUnavailableAction.retry:
          _notifyUser(
            'Playback unavailable — retry or download this track',
            AudioErrorSeverity.warning,
          );
          break;
        case AudioUnavailableAction.downloadQueued:
          _notifyUser(
            'Download requested — retry when it is ready',
            AudioErrorSeverity.info,
          );
          break;
      }
      return true;
    } finally {
      _handlingUnavailable = false;
    }
  }

  void _noteNetworkFailure() {
    final now = DateTime.now();
    if (_lastNetworkFailureTime == null ||
        now.difference(_lastNetworkFailureTime!) > _networkFailureWindow) {
      _consecutiveNetworkFailures = 0;
    }
    _lastNetworkFailureTime = now;
    _consecutiveNetworkFailures++;
  }

  Future<bool> _recoverNetwork(
    Object error,
    int maxRetries,
  ) async {
    // Use the persistent counter rather than the per-event attempt number:
    // every player error event arrives with attempt == 1, so a per-call
    // budget alone retries a persistently-failing network forever.
    _noteNetworkFailure();
    if (_consecutiveNetworkFailures > maxRetries) {
      _notifyUser(
        "Couldn't reach DeeMusiq servers — check your connection and try again",
        AudioErrorSeverity.error,
      );
      return true;
    }

    final success =
        await _retryWithBackoff(_consecutiveNetworkFailures, maxRetries);
    if (success) {
      final retryOk = await onRetryPlayback?.call() ?? false;
      if (retryOk) return true;
    }
    return false;
  }

  /// Delays with exponential backoff and returns `true` if the delay completed.
  Future<bool> _retryWithBackoff(int attempt, int maxRetries) async {
    try {
      final backoff = Duration(milliseconds: 1000 * (1 << (attempt - 1)));
      // Clamp to max 16 seconds
      final delay =
          backoff > const Duration(seconds: 16)
              ? const Duration(seconds: 16)
              : backoff;
      _notifyUser(
        'Retrying in ${delay.inSeconds}s... ($attempt/$maxRetries)',
        AudioErrorSeverity.warning,
      );
      await Future.delayed(delay);
      return true;
    } catch (e, stack) {
      AppLogger.log.w('_retryWithBackoff delay interrupted: $e');
      AppLogger.reportError(e, stack, '_retryWithBackoff delay');
      return false;
    }
  }

  void _notifyUser(String message, AudioErrorSeverity severity) {
    onUserMessage?.call(message, severity);
  }

  void dispose() {
    onUserMessage = null;
    onSkipRequested = null;
    onRetryPlayback = null;
    onPlaybackUnavailable = null;
    _lastErrorTime = null;
    _handlingUnavailable = false;
    notifyPlaybackHealthy();
  }
}

enum AudioErrorCategory {
  network,
  source,
  player,
  unknown;

  AudioErrorSeverity toSeverity() {
    switch (this) {
      case AudioErrorCategory.network:
        return AudioErrorSeverity.warning;
      case AudioErrorCategory.source:
        return AudioErrorSeverity.info;
      case AudioErrorCategory.player:
        return AudioErrorSeverity.error;
      case AudioErrorCategory.unknown:
        return AudioErrorSeverity.error;
    }
  }
}

enum AudioErrorSeverity {
  info,
  warning,
  error,
}
