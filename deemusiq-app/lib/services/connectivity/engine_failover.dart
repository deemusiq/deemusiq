
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/connectivity/connection_checker.dart';
import 'package:deemusiq/services/youtube_engine/youtube_engine.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart'
    show RequestLimitExceededException, VideoUnplayableException;

/// Wraps YouTube engine calls with automatic failover and retry logic.
///
/// ## Failover order
/// 1. youtube_explode_dart (primary — fastest, best quality)
/// 2. yt-dlp (fallback 1 — broad compatibility)
/// 3. NewPipe extractor (fallback 2 — lightweight)
///
/// ## Retry logic
/// - Each engine is retried up to [maxRetries] times with exponential
///   backoff (1s → 2s → 4s, clamped at 16s); rate limits wait longer.
/// - Permanent failures ([VideoUnplayableException]: removed, region-locked,
///   purchase-only) skip straight to the next engine — retrying the same
///   video on the same engine can never succeed.
/// - Before any attempt, checks internet connectivity via [ConnectionChecker].
///   If no internet, fails immediately with a clear message.
/// - On each failure, calls [onRetry] callback for UI feedback.
/// - Every attempt/success/failure is counted in [EngineMetrics].
///
/// ## Usage
/// ```dart
/// final result = await EngineFailover.tryEngines(
///   engines: [youtubeExplode, ytDlp, newPipe],
///   operation: (engine) => engine.getStreamManifest(videoId),
///   onRetry: (msg, attempt) => showToast(msg),
/// );
/// ```
class EngineFailover {
  EngineFailover._();

  static const maxRetries = 3;
  static const _backoffBase = Duration(seconds: 1);

  /// Tries [operation] on each engine in [engines] sequentially. If an engine
  /// fails, moves to the next one. Each engine is retried up to
  /// [maxRetries] times with exponential backoff.
  ///
  /// Returns the first successful result, or throws [EngineFailoverException]
  /// if all engines + retries are exhausted.
  static Future<T> tryEngines<T>({
    required List<YouTubeEngine> engines,
    required Future<T> Function(YouTubeEngine engine) operation,
    void Function(String message, int attempt)? onRetry,
    String noInternetMessage = 'Sorry, no internet',
  }) async {
    // Check internet first
    final conn = await ConnectionChecker.instance.check();
    if (!conn.hasInternet) {
      AppLogger.log.w('EngineFailover: no internet connection — aborting');
      throw EngineFailoverException(
        noInternetMessage,
        isNoInternet: true,
      );
    }

    // Pre-filter: skip engines that aren't available or installed
    final availableEngines = <YouTubeEngine>[];
    for (final engine in engines) {
      if (!engine.isAvailableForPlatform) {
        AppLogger.log.d('EngineFailover: skipping ${engine.runtimeType} — not available for platform');
        continue;
      }
      if (!(await engine.isInstalled())) {
        AppLogger.log.d('EngineFailover: skipping ${engine.runtimeType} — not installed');
        continue;
      }
      availableEngines.add(engine);
    }

    if (availableEngines.isEmpty) {
      AppLogger.log.e('EngineFailover: no available engines');
      throw EngineFailoverException(
        'No available engines for this platform',
        errors: ['all engines unavailable or not installed'],
      );
    }

    final errors = <String>[];
    final unplayableEngines = <YouTubeEngine>{};

    for (final engine in availableEngines) {
      AppLogger.log.i('EngineFailover: trying ${engine.runtimeType}...');
      for (var attempt = 1; attempt <= maxRetries; attempt++) {
        EngineMetrics.recordAttempt(engine.runtimeType.toString());
        try {
          final result = await operation(engine).timeout(
            Duration(seconds: 15 + (attempt * 5)), // Progressive timeout
          );
          EngineMetrics.recordSuccess(engine.runtimeType.toString());
          AppLogger.log.i(
            'EngineFailover: success on ${engine.runtimeType} attempt $attempt',
          );
          return result;
        } catch (e, stack) {
          EngineMetrics.recordFailure(engine.runtimeType.toString(), e);
          final msg = 'Bad connection, retrying... (attempt $attempt/$maxRetries)';
          AppLogger.log.w(
            'EngineFailover: ${engine.runtimeType} attempt $attempt failed: $e',
          );
          AppLogger.reportError(e, stack, 'EngineFailover: ${engine.runtimeType} attempt $attempt');

          // Permanent failures (video removed, region-locked, purchase-only,
          // unplayable): retrying the same engine against the same video can
          // never succeed — skip straight to the next engine.
          if (e is VideoUnplayableException) {
            AppLogger.log.w(
              'EngineFailover: ${engine.runtimeType} reports the video as unplayable — moving to next engine',
            );
            errors.add('${engine.runtimeType}: ${_shortError(e)}');
            unplayableEngines.add(engine);
            break;
          }

          onRetry?.call(msg, attempt);

          if (attempt < maxRetries) {
            // Rate-limiting needs a markedly longer wait than the standard
            // 1s → 2s → 4s exponential progression.
            final backoff = e is RequestLimitExceededException
                ? _backoffBase * (1 << (attempt + 2))
                : _backoffBase * (1 << (attempt - 1));
            await Future.delayed(
              backoff > const Duration(seconds: 16)
                  ? const Duration(seconds: 16)
                  : backoff,
            );
          } else {
            errors.add('${engine.runtimeType}: ${_shortError(e)}');
          }
        }
      }
    }

    // Re-check internet before giving up — maybe it came back
    // and a retry with any engine would succeed. Try all engines again,
    // except the ones that reported the video as permanently unplayable.
    ConnectionChecker.instance.clearCache();
    final reconnect = await ConnectionChecker.instance.check();
    if (reconnect.hasInternet && availableEngines.isNotEmpty) {
      AppLogger.log.w(
        'EngineFailover: re-checking internet — it came back, retrying all engines',
      );
      for (final engine in availableEngines) {
        if (unplayableEngines.contains(engine)) continue;
        EngineMetrics.recordAttempt(engine.runtimeType.toString());
        try {
          final result = await operation(engine).timeout(
            const Duration(seconds: 30),
          );
          EngineMetrics.recordSuccess(engine.runtimeType.toString());
          AppLogger.log.i('EngineFailover: success on reconnect retry with ${engine.runtimeType}');
          return result;
        } catch (e) {
          EngineMetrics.recordFailure(engine.runtimeType.toString(), e);
          AppLogger.log.w('EngineFailover: reconnect retry on ${engine.runtimeType} failed: $e');
          AppLogger.reportError(e, StackTrace.current, 'EngineFailover reconnect retry ${engine.runtimeType}');
          errors.add('reconnect-retry-${engine.runtimeType}: ${_shortError(e)}');
        }
      }
    }

    AppLogger.log.e(
      'EngineFailover: all engines exhausted. Errors: ${errors.join(" | ")}',
    );
    final metricsSummary = EngineMetrics.summary();
    if (metricsSummary.isNotEmpty) {
      AppLogger.log.w('EngineFailover: engine health — $metricsSummary');
    }
    throw EngineFailoverException(
      'Something went wrong — please try again later',
      errors: errors,
    );
  }

  static String _shortError(Object e) {
    final s = e.toString();
    return s.length > 80 ? '${s.substring(0, 80)}...' : s;
  }
}

class EngineFailoverException implements Exception {
  final String message;
  final bool isNoInternet;
  final List<String> errors;

  EngineFailoverException(
    this.message, {
    this.isNoInternet = false,
    this.errors = const [],
  });

  @override
  String toString() => message;
}

/// In-memory per-engine extraction health counters. Recorded by
/// [EngineFailover]; surfaced in logs and the developer settings section so
/// "YouTube playback broke" reports carry data, not vibes.
class EngineStats {
  int attempts = 0;
  int successes = 0;
  int failures = 0;
  String? lastError;
  DateTime? lastFailureAt;

  double get successRate => attempts == 0 ? 0 : successes / attempts;
}

class EngineMetrics {
  EngineMetrics._();

  static final Map<String, EngineStats> _stats = {};

  static void recordAttempt(String engine) =>
      _stats.putIfAbsent(engine, EngineStats.new).attempts++;

  static void recordSuccess(String engine) =>
      _stats.putIfAbsent(engine, EngineStats.new).successes++;

  static void recordFailure(String engine, Object error) {
    final stats = _stats.putIfAbsent(engine, EngineStats.new);
    stats.failures++;
    stats.lastError = EngineFailover._shortError(error);
    stats.lastFailureAt = DateTime.now().toUtc();
  }

  static Map<String, EngineStats> snapshot() => Map.unmodifiable(_stats);

  static String summary() => _stats.entries
      .map((e) =>
          '${e.key}: ${e.value.successes}/${e.value.attempts} ok'
          '${e.value.lastError == null ? '' : ', last error: ${e.value.lastError}'}')
      .join(' | ');

  /// Test hook.
  static void reset() => _stats.clear();
}
