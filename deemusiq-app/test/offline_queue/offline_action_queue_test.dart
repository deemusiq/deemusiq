import 'dart:async';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/services/offline_queue/offline_action_queue.dart';
import 'package:deemusiq/services/offline_queue/offline_action_replay.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  final queue = OfflineActionQueue.instance;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase.forTesting(NativeDatabase.memory());
    queue.attach(db);
  });

  tearDown(() async {
    queue.detach();
    await db.close();
  });

  group('OfflineActionQueue', () {
    test('enqueue stores type, entity key, payload and defaults', () async {
      final id = await queue.enqueue(
        OfflineActionType.syncLike,
        OfflineActionQueue.likedEntityKey('hash-1'),
        {'songHash': 'hash-1'},
      );
      expect(id, isNotNull);

      final rows = await queue.pending();
      expect(rows, hasLength(1));
      expect(rows.single.actionType, 'sync.like');
      expect(rows.single.entityKey, 'liked:hash-1');
      expect(rows.single.payloadJson, '{"songHash":"hash-1"}');
      expect(rows.single.retryCount, 0);
      expect(rows.single.createdAt, isNotNull);
    });

    test('enqueue collapses per entity: like then unlike keeps only the last',
        () async {
      final key = OfflineActionQueue.likedEntityKey('hash-1');
      await queue.enqueue(OfflineActionType.syncLike, key, {'songHash': 'h'});
      await queue.enqueue(OfflineActionType.syncUnlike, key, {'songHash': 'h'});

      final rows = await queue.pending();
      expect(rows, hasLength(1));
      expect(rows.single.actionType, 'sync.unlike');
    });

    test('delete tombstones pending playlist updates for the same id',
        () async {
      final key = OfflineActionQueue.playlistEntityKey('pl-1');
      await queue.enqueue(
        OfflineActionType.syncPlaylistUpdate,
        key,
        {'id': 'pl-1', 'name': 'New name'},
      );
      await queue.enqueue(
        OfflineActionType.syncPlaylistDelete,
        key,
        {'id': 'pl-1'},
      );

      final rows = await queue.pending();
      expect(rows, hasLength(1));
      expect(rows.single.actionType, 'sync.playlist.delete');
    });

    test('actions on different entities keep FIFO order', () async {
      await queue.enqueue(
        OfflineActionType.syncLike,
        OfflineActionQueue.likedEntityKey('a'),
        {'songHash': 'a'},
      );
      await queue.enqueue(
        OfflineActionType.recommendationsUnlike,
        OfflineActionQueue.trackLikeEntityKey('t-1'),
        {'trackId': 't-1'},
      );

      final rows = await queue.pending();
      expect(rows, hasLength(2));
      expect(rows[0].entityKey, 'liked:a');
      expect(rows[1].entityKey, 'rectrack:t-1');
    });

    test('queue is capped: oldest rows are dropped beyond the cap', () async {
      for (var i = 0; i < OfflineActionQueue.maxPendingActions + 2; i++) {
        await queue.enqueue(
          OfflineActionType.syncLike,
          OfflineActionQueue.likedEntityKey('hash-$i'),
          {'songHash': 'hash-$i'},
        );
      }
      final rows = await queue.pending();
      expect(rows, hasLength(OfflineActionQueue.maxPendingActions));
      // The two oldest enqueues were dropped.
      expect(rows.first.entityKey, 'liked:hash-2');
      expect(rows.last.entityKey,
          'liked:hash-${OfflineActionQueue.maxPendingActions + 1}');
    });
  });

  group('OfflineActionReplayService', () {
    test('replays FIFO and clears the queue', () async {
      final calls = <String>[];
      final service = OfflineActionReplayService(
        queue: queue,
        runner: (type, payload) async {
          calls.add('${type.wireName}:${payload.values.first}');
        },
      );

      await queue.enqueue(
        OfflineActionType.syncLike,
        OfflineActionQueue.likedEntityKey('a'),
        {'songHash': 'a'},
      );
      await queue.enqueue(
        OfflineActionType.syncUnlike,
        OfflineActionQueue.likedEntityKey('b'),
        {'songHash': 'b'},
      );

      final replayed = await service.flush();
      expect(replayed, 2);
      expect(calls, ['sync.like:a', 'sync.unlike:b']);
      expect(await queue.pendingCount(), 0);
    });

    test('connectivity failure stops the flush and keeps the rows', () async {
      var attempts = 0;
      final service = OfflineActionReplayService(
        queue: queue,
        runner: (type, payload) async {
          attempts++;
          throw const WalletApiException('offline', isConnectivity: true);
        },
      );

      await queue.enqueue(
        OfflineActionType.syncLike,
        OfflineActionQueue.likedEntityKey('a'),
        {'songHash': 'a'},
      );
      await queue.enqueue(
        OfflineActionType.syncUnlike,
        OfflineActionQueue.likedEntityKey('b'),
        {'songHash': 'b'},
      );

      final replayed = await service.flush();
      expect(replayed, 0);
      expect(attempts, 1, reason: 'flush stops at the first offline failure');
      expect(await queue.pendingCount(), 2);
      // Not counted as a retry — connectivity is not the action's fault.
      expect((await queue.pending()).first.retryCount, 0);
    });

    test('non-connectivity failures bump retryCount and drop after maxRetries',
        () async {
      final service = OfflineActionReplayService(
        queue: queue,
        runner: (type, payload) async {
          throw const WalletApiException('bad request', statusCode: 400);
        },
      );

      await queue.enqueue(
        OfflineActionType.syncLike,
        OfflineActionQueue.likedEntityKey('a'),
        {'songHash': 'a'},
      );

      for (var i = 1; i <= OfflineActionReplayService.maxRetries; i++) {
        await service.flush();
        final rows = await queue.pending();
        expect(rows, hasLength(1));
        expect(rows.single.retryCount, i);
      }
      // One failure past the cap drops the poisoned action.
      await service.flush();
      expect(await queue.pendingCount(), 0);
    });

    test('corrupt payloads are dropped without invoking the runner', () async {
      var ran = false;
      final service = OfflineActionReplayService(
        queue: queue,
        runner: (type, payload) async {
          ran = true;
        },
      );

      await db.into(db.pendingActionsTable).insert(
            PendingActionsTableCompanion.insert(
              actionType: 'sync.like',
              entityKey: 'liked:corrupt',
              payloadJson: 'not-json{',
            ),
          );

      await service.flush();
      expect(ran, isFalse);
      expect(await queue.pendingCount(), 0);
    });

    test('unknown action types are dropped without invoking the runner',
        () async {
      var ran = false;
      final service = OfflineActionReplayService(
        queue: queue,
        runner: (type, payload) async {
          ran = true;
        },
      );

      await db.into(db.pendingActionsTable).insert(
            PendingActionsTableCompanion.insert(
              actionType: 'sync.fromTheFuture',
              entityKey: 'liked:x',
              payloadJson: '{}',
            ),
          );

      await service.flush();
      expect(ran, isFalse);
      expect(await queue.pendingCount(), 0);
    });

    test('start() flushes when the connectivity signal reports online',
        () async {
      final connectivity = StreamController<bool>();
      addTearDown(connectivity.close);
      final calls = <String>[];
      final service = OfflineActionReplayService(
        queue: queue,
        runner: (type, payload) async {
          calls.add(type.wireName);
        },
      );
      addTearDown(service.dispose);

      await queue.enqueue(
        OfflineActionType.syncLike,
        OfflineActionQueue.likedEntityKey('a'),
        {'songHash': 'a'},
      );

      service.start(connectivity.stream);
      connectivity.add(false); // stays queued
      await Future<void>.delayed(Duration.zero);
      expect(calls, isEmpty);

      connectivity.add(true); // online → flush
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(calls, ['sync.like']);
      expect(await queue.pendingCount(), 0);
    });
  });
}
