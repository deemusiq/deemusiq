import 'dart:convert';

import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/offline_queue/offline_action_queue.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';
import 'package:deemusiq/services/wallet/payment_service.dart'
    show PaymentGatewayConfig;
import 'package:crypto/crypto.dart' as crypto;

/// Anonymous data sync service for liked songs and playlists.
///
/// All data is anonymized before syncing:
/// - Song IDs are SHA-256 hashed before sending (only hashes are stored server-side)
/// - Playlist names are plaintext FIELDS, but the request body rides inside the
///   sealed AES-256-GCM channel envelope when the secure channel is configured
///   (in-transit protection — they are not separately encrypted at rest)
/// - No personal information is ever included
///
/// Communication with the backend is encrypted via the secure channel
/// (AES-256-GCM) when configured.
class DataSyncService {
  DataSyncService._();
  static final DataSyncService instance = DataSyncService._();

  bool get isConfigured =>
      PaymentGatewayConfig.backendBaseUrl.isNotEmpty;

  /// Hash a song/track ID using SHA-256. The raw ID never leaves the device.
  static String hashSongId(String songId) {
    final bytes = utf8.encode(songId);
    final hash = crypto.sha256.convert(bytes);
    return hash.toString();
  }

  /// Convert bytes to lowercase hex string.
  static String hexFromBytes(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  // ── Liked Songs ──────────────────────────────────────────────────────────

  /// Sync a liked song to the backend (idempotent). When the backend is
  /// unreachable due to connectivity, the action is queued for FIFO replay
  /// (see [OfflineActionQueue]) instead of being dropped.
  Future<void> likeSong(String songId) async {
    if (!isConfigured) return;
    try {
      await WalletApiClient.instance.syncLikeSong(hashSongId(songId));
    } on WalletApiException catch (e) {
      // Best-effort — never blocks the UI — but the failure is visible.
      AppLogger.log.d('DataSync.likeSong failed: ${e.message}');
      if (e.isConnectivity) {
        await OfflineActionQueue.instance.enqueue(
          OfflineActionType.syncLike,
          OfflineActionQueue.likedEntityKey(hashSongId(songId)),
          {'songHash': hashSongId(songId)},
        );
      }
    }
  }

  /// Remove a liked song from the backend.
  Future<void> unlikeSong(String songId) async {
    if (!isConfigured) return;
    try {
      await WalletApiClient.instance.syncUnlikeSong(hashSongId(songId));
    } on WalletApiException catch (e) {
      AppLogger.log.d('DataSync.unlikeSong failed: ${e.message}');
      if (e.isConnectivity) {
        await OfflineActionQueue.instance.enqueue(
          OfflineActionType.syncUnlike,
          OfflineActionQueue.likedEntityKey(hashSongId(songId)),
          {'songHash': hashSongId(songId)},
        );
      }
    }
  }

  /// Fetch all liked song hashes from the backend.
  Future<List<String>> fetchLikedSongs() async {
    if (!isConfigured) return [];
    try {
      return await WalletApiClient.instance.syncFetchLikedSongs();
    } on WalletApiException catch (e) {
      AppLogger.log.w('DataSync.fetchLikedSongs failed: ${e.message}');
      return [];
    }
  }

  // ── User Playlists ───────────────────────────────────────────────────────

  /// Create a new playlist on the backend.
  /// [name] is plaintext on-device; transmitted encrypted via secure channel.
  /// [songIds] are raw IDs; they are SHA-256 hashed before sending.
  /// Offline: the create is queued for replay and a placeholder (no server id
  /// yet) is returned, mirroring the unconfigured-backend shape.
  Future<Map<String, dynamic>> createPlaylist({
    required String name,
    required List<String> songIds,
  }) async {
    if (!isConfigured) {
      return {'id': '', 'name': name, 'songHashes': []};
    }
    final hashes = songIds.map(hashSongId).toList();
    try {
      return await WalletApiClient.instance.syncCreatePlaylist(
        name: name,
        songHashes: hashes,
      );
    } on WalletApiException catch (e) {
      if (e.isConnectivity) {
        AppLogger.log.d('DataSync.createPlaylist queued (offline)');
        await OfflineActionQueue.instance.enqueue(
          OfflineActionType.syncPlaylistCreate,
          OfflineActionQueue.playlistCreateEntityKey(name),
          {'name': name, 'songHashes': hashes},
        );
        return {'id': '', 'name': name, 'songHashes': hashes, 'queued': true};
      }
      rethrow;
    }
  }

  /// Update a playlist (name and/or song list).
  Future<void> updatePlaylist({
    required String id,
    String? name,
    List<String>? songIds,
  }) async {
    if (!isConfigured) return;
    final hashes = songIds?.map(hashSongId).toList();
    try {
      await WalletApiClient.instance.syncUpdatePlaylist(
        id: id,
        name: name,
        songHashes: hashes,
      );
    } on WalletApiException catch (e) {
      AppLogger.log.d('DataSync.updatePlaylist failed: ${e.message}');
      if (e.isConnectivity) {
        await OfflineActionQueue.instance.enqueue(
          OfflineActionType.syncPlaylistUpdate,
          OfflineActionQueue.playlistEntityKey(id),
          {
            'id': id,
            if (name != null) 'name': name,
            if (hashes != null) 'songHashes': hashes,
          },
        );
      }
    }
  }

  /// Delete a playlist from the backend.
  Future<void> deletePlaylist(String id) async {
    if (!isConfigured) return;
    try {
      await WalletApiClient.instance.syncDeletePlaylist(id);
    } on WalletApiException catch (e) {
      AppLogger.log.d('DataSync.deletePlaylist failed: ${e.message}');
      if (e.isConnectivity) {
        // Tombstone: replaces any pending update for this playlist.
        await OfflineActionQueue.instance.enqueue(
          OfflineActionType.syncPlaylistDelete,
          OfflineActionQueue.playlistEntityKey(id),
          {'id': id},
        );
      }
    }
  }

  /// Fetch all user playlists from the backend.
  Future<List<Map<String, dynamic>>> fetchPlaylists() async {
    if (!isConfigured) return [];
    try {
      return await WalletApiClient.instance.syncFetchPlaylists();
    } on WalletApiException catch (e) {
      AppLogger.log.w('DataSync.fetchPlaylists failed: ${e.message}');
      return [];
    }
  }
}
