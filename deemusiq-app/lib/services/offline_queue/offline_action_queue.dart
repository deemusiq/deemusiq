import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/services/kv_store/encrypted_kv_store.dart';
import 'package:deemusiq/services/logger/logger.dart';

/// Payload blobs are stored AES-256-GCM encrypted under the same key material
/// as the rest of the encrypted store.
///
/// Playlist payloads carry user-authored NAMES, which are personal data under
/// POPIA. The Drift database is plaintext (no SQLCipher), so those names sat
/// on disk in the clear — and because `/me/export` returns SERVER state, a
/// playlist that only ever existed in the offline queue was invisible in the
/// user's own data export. Encrypting the payload closes both gaps.
///
/// `q1:` marks an encrypted blob. Values without the prefix are plaintext rows
/// written by older builds and stay readable forever, so upgrading cannot
/// strand a pending action.
const _payloadPrefix = 'q1:';

enc.Encrypter? _queueEncrypter;

/// The queue cipher. Falls back to NO encryption when the store key is
/// unavailable: losing a queued action is worse than storing it in the clear,
/// and it is logged rather than silent.
enc.Encrypter? get _queueCipher {
  try {
    _queueEncrypter ??= enc.Encrypter(
      enc.AES(
        enc.Key(EncryptedKvStoreService.aesKeyBytes),
        mode: enc.AESMode.gcm,
      ),
    );
    return _queueEncrypter;
  } catch (e) {
    AppLogger.log.w(
        'OfflineActionQueue: encryption key unavailable; queue payloads will '
        'be stored in plaintext: ${e.toString()}');
    return null;
  }
}

String _sealPayload(Map<String, dynamic> payload) {
  final json = jsonEncode(payload);
  final cipher = _queueCipher;
  if (cipher == null) return json;
  try {
    final iv = enc.IV.fromSecureRandom(12);
    final combined = [...iv.bytes, ...cipher.encrypt(json, iv: iv).bytes];
    return '$_payloadPrefix${base64Encode(combined)}';
  } catch (e) {
    AppLogger.log.w('OfflineActionQueue: payload encryption failed: ${e.toString()}');
    return json;
  }
}

/// Inverse of [_sealPayload]; plaintext legacy values pass through unchanged.
Map<String, dynamic> openActionPayload(String raw) => _openPayload(raw);

Map<String, dynamic> _openPayload(String raw) {
  if (!raw.startsWith(_payloadPrefix)) {
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }
  final combined = base64Decode(raw.substring(_payloadPrefix.length));
  final iv = enc.IV(combined.sublist(0, 12));
  final decrypted = _queueCipher?.decrypt(
    enc.Encrypted(combined.sublist(12)),
    iv: iv,
  );
  if (decrypted == null) {
    throw StateError('queue_payload_key_unavailable');
  }
  return Map<String, dynamic>.from(jsonDecode(decrypted) as Map);
}

/// The backend-bound user actions that can be queued while offline and
/// replayed FIFO once connectivity returns. Payloads are JSON objects whose
/// keys mirror the replay call arguments (see [OfflineActionQueue.enqueue]).
enum OfflineActionType {
  /// POST /sync/liked {songHash}
  syncLike('sync.like'),

  /// DELETE /sync/liked?songHash=
  syncUnlike('sync.unlike'),

  /// POST /sync/playlists {name, songHashes}
  syncPlaylistCreate('sync.playlist.create'),

  /// PATCH /sync/playlists/:id {name?, songHashes?}
  syncPlaylistUpdate('sync.playlist.update'),

  /// DELETE /sync/playlists/:id
  syncPlaylistDelete('sync.playlist.delete'),

  /// POST /recommendations/like {trackId, title?, artist?}
  recommendationsLike('recommendations.like'),

  /// POST /recommendations/unlike {trackId}
  recommendationsUnlike('recommendations.unlike');

  final String wireName;
  const OfflineActionType(this.wireName);

  static OfflineActionType fromWireName(String value) {
    return OfflineActionType.values.firstWhere(
      (t) => t.wireName == value,
      orElse: () => throw ArgumentError('Unknown offline action type: $value'),
    );
  }
}

/// Drift-backed FIFO outbox for backend-bound user actions.
///
/// Enqueueing collapses per [entityKey] (last-write-wins): a newer action for
/// the same entity replaces any pending ones, so a delete/unlike tombstones an
/// earlier add/like for that entity instead of both replaying in order.
/// The table is capped at [maxPendingActions]; once full, the oldest row is
/// dropped (and logged) to keep the outbox bounded.
///
/// Singleton because the enqueue call sites ([DataSyncService],
/// `toggleTrackFavorite`) are themselves singletons without a WidgetRef.
/// [attach] is called once from `main.dart` after the database is opened;
/// before that (and in tests that never attach) enqueueing is a logged no-op
/// so likes still succeed locally.
class OfflineActionQueue {
  OfflineActionQueue._();
  static final OfflineActionQueue instance = OfflineActionQueue._();

  static const maxPendingActions = 500;

  AppDatabase? _db;

  void attach(AppDatabase db) {
    _db = db;
  }

  /// Test hook: detach so one test's database doesn't leak into the next.
  void detach() {
    _db = null;
  }

  /// Collapse an entity's pending actions and append [type] with [payload].
  /// Returns the new row id, or null when no database is attached.
  Future<int?> enqueue(
    OfflineActionType type,
    String entityKey,
    Map<String, dynamic> payload,
  ) async {
    final db = _db;
    if (db == null) {
      AppLogger.log.w(
        'OfflineActionQueue: no database attached — dropping ${type.wireName}',
      );
      return null;
    }

    return db.transaction(() async {
      // Last-write-wins: a delete/unlike enqueued now tombstones any pending
      // add/like for the same entity (and vice versa — the newest wins).
      await (db.delete(db.pendingActionsTable)
            ..where((t) => t.entityKey.equals(entityKey)))
          .go();

      final id = await db.into(db.pendingActionsTable).insert(
            PendingActionsTableCompanion.insert(
              actionType: type.wireName,
              entityKey: entityKey,
              payloadJson: _sealPayload(payload),
            ),
          );

      // Bounded outbox: drop the oldest rows beyond the cap.
      final count = await db.pendingActionsTable.count().getSingle();
      if (count > maxPendingActions) {
        final overflow = count - maxPendingActions;
        final oldest = await (db.select(db.pendingActionsTable)
              ..orderBy([(t) => OrderingTerm.asc(t.id)])
              ..limit(overflow))
            .get();
        for (final row in oldest) {
          await (db.delete(db.pendingActionsTable)
                ..where((t) => t.id.equals(row.id)))
              .go();
          AppLogger.log.w(
            'OfflineActionQueue: cap $maxPendingActions exceeded — '
            'dropped oldest ${row.actionType} (${row.entityKey})',
          );
        }
      }
      return id;
    });
  }

  /// All pending actions in FIFO order (oldest first).
  Future<List<PendingActionsTableData>> pending() async {
    final db = _db;
    if (db == null) return const [];
    return (db.select(db.pendingActionsTable)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  Future<int> pendingCount() async {
    final db = _db;
    if (db == null) return 0;
    return db.pendingActionsTable.count().getSingle();
  }

  Future<void> remove(int id) async {
    final db = _db;
    if (db == null) return;
    await (db.delete(db.pendingActionsTable)..where((t) => t.id.equals(id)))
        .go();
  }

  Future<void> bumpRetryCount(int id) async {
    final db = _db;
    if (db == null) return;
    await db.customUpdate(
      'UPDATE pending_actions_table SET retry_count = retry_count + 1 '
      'WHERE id = ?',
      variables: [Variable.withInt(id)],
      updates: {db.pendingActionsTable},
    );
  }

  /// Entity key for the anonymous liked-songs sync (`/sync/liked`).
  static String likedEntityKey(String songHash) => 'liked:$songHash';

  /// Entity key for the account-carried like (`/recommendations/like`).
  static String trackLikeEntityKey(String trackId) => 'rectrack:$trackId';

  /// Entity key for edits to an existing server playlist.
  static String playlistEntityKey(String playlistId) => 'playlist:$playlistId';

  /// Entity key for playlist creation (server assigns the id, so collapse on
  /// the normalized name to avoid duplicates when replaying after reconnect).
  static String playlistCreateEntityKey(String name) =>
      'playlist-new:${name.trim().toLowerCase()}';
}
