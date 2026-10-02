import 'dart:async';
import 'dart:convert';

import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/offline_queue/offline_action_queue.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// Replays the Drift-backed offline action outbox ([OfflineActionQueue]) FIFO
/// through the existing `/sync/*` and `/recommendations/*` endpoints once
/// connectivity returns.
///
/// Per action, one of three outcomes:
/// - success → the row is removed;
/// - connectivity failure ([WalletApiException.isConnectivity]) → replay stops
///   immediately (the rest of the queue keeps its order) and the row is kept
///   untouched so the next flush retries it;
/// - any other failure (4xx, malformed payload, …) → `retryCount` is bumped and
///   the row is dropped once it exceeds [maxRetries], so one poisoned action
///   can't wedge the queue forever.
class OfflineActionReplayService {
  OfflineActionReplayService({
    required OfflineActionQueue queue,
    Future<void> Function(OfflineActionType type, Map<String, dynamic> payload)?
        runner,
  })  : _queue = queue,
        _runner = runner ?? _defaultRunner;

  final OfflineActionQueue _queue;
  final Future<void> Function(
    OfflineActionType type,
    Map<String, dynamic> payload,
  ) _runner;

  /// After this many non-connectivity failures the action is dropped.
  static const maxRetries = 5;

  StreamSubscription<bool>? _connectivitySub;
  bool _flushing = false;

  /// Subscribes to the app's connectivity signal (see
  /// `ConnectionCheckerService.onConnectivityChanged`) and flushes on every
  /// offline→online transition.
  void start(Stream<bool> onOnline) {
    _connectivitySub ??= onOnline.listen((connected) {
      if (connected) unawaited(flush());
    });
  }

  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  /// Drains the queue in FIFO order. Returns the number of actions replayed.
  /// Safe to call concurrently — a flush already in flight wins.
  Future<int> flush() async {
    if (_flushing) return 0;
    _flushing = true;
    var replayed = 0;
    try {
      final actions = await _queue.pending();
      for (final action in actions) {
        final OfflineActionType type;
        final Map<String, dynamic> payload;
        try {
          type = OfflineActionType.fromWireName(action.actionType);
          final decoded = jsonDecode(action.payloadJson);
          if (decoded is! Map) {
            throw const FormatException('payload is not a JSON object');
          }
          payload = Map<String, dynamic>.from(decoded);
        } catch (e, stack) {
          // Corrupt row — drop it instead of retrying forever.
          AppLogger.reportError(
            e,
            stack,
            'OfflineActionReplay: dropping unreadable action ${action.id}',
          );
          await _queue.remove(action.id);
          continue;
        }

        try {
          await _runner(type, payload);
          await _queue.remove(action.id);
          replayed++;
        } on WalletApiException catch (e) {
          if (e.isConnectivity) {
            // Still offline (or backend down): keep this row and everything
            // after it in order; the next connectivity event retries.
            AppLogger.log.d(
              'OfflineActionReplay: stopped at ${action.id} — offline',
            );
            break;
          }
          await _handleFailure(action, e.message);
        } catch (e, stack) {
          AppLogger.reportError(e, stack, 'OfflineActionReplay');
          await _handleFailure(action, e.toString());
        }
      }
      if (replayed > 0) {
        AppLogger.log.i('OfflineActionReplay: replayed $replayed action(s)');
      }
      return replayed;
    } finally {
      _flushing = false;
    }
  }

  Future<void> _handleFailure(
    PendingActionsTableData action,
    String reason,
  ) async {
    await _queue.bumpRetryCount(action.id);
    if (action.retryCount + 1 > maxRetries) {
      AppLogger.log.w(
        'OfflineActionReplay: dropping ${action.actionType} '
        '(${action.entityKey}) after $maxRetries retries — $reason',
      );
      await _queue.remove(action.id);
    } else {
      AppLogger.log.w(
        'OfflineActionReplay: ${action.actionType} (${action.entityKey}) '
        'failed (${action.retryCount + 1}/$maxRetries) — $reason',
      );
    }
  }

  /// Maps a queued action back onto the matching WalletApiClient call.
  static Future<void> _defaultRunner(
    OfflineActionType type,
    Map<String, dynamic> payload,
  ) async {
    final api = WalletApiClient.instance;
    switch (type) {
      case OfflineActionType.syncLike:
        await api.syncLikeSong(payload['songHash'] as String);
        break;
      case OfflineActionType.syncUnlike:
        await api.syncUnlikeSong(payload['songHash'] as String);
        break;
      case OfflineActionType.syncPlaylistCreate:
        await api.syncCreatePlaylist(
          name: payload['name'] as String,
          songHashes: (payload['songHashes'] as List).cast<String>(),
        );
        break;
      case OfflineActionType.syncPlaylistUpdate:
        await api.syncUpdatePlaylist(
          id: payload['id'] as String,
          name: payload['name'] as String?,
          songHashes: (payload['songHashes'] as List?)?.cast<String>(),
        );
        break;
      case OfflineActionType.syncPlaylistDelete:
        await api.syncDeletePlaylist(payload['id'] as String);
        break;
      case OfflineActionType.recommendationsLike:
        await api.likeTrack(
          payload['trackId'] as String,
          title: payload['title'] as String?,
          artist: payload['artist'] as String?,
        );
        break;
      case OfflineActionType.recommendationsUnlike:
        await api.unlikeTrack(payload['trackId'] as String);
        break;
    }
  }
}
