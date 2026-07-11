import 'dart:async';

import 'package:drift/drift.dart' hide Table;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/database/database.dart';
import 'package:deemusiq/provider/metadata_plugin/library/tracks.dart';
import 'package:deemusiq/services/auth/data_sync.dart';
import 'package:deemusiq/services/logger/logger.dart';

final localFavoritesProvider =
    StateNotifierProvider.autoDispose<LocalFavoritesNotifier,
        List<FavoritesTableData>>(
  (ref) {
    final database = ref.read(databaseProvider);
    return LocalFavoritesNotifier(database);
  },
);

/// Device-local liked tracks (Drift), the offline source of truth for the
/// heart button. Survives metadata-plugin outages and feeds the Liked Tracks
/// page fallback.
class LocalFavoritesNotifier extends StateNotifier<List<FavoritesTableData>> {
  final AppDatabase _database;
  StreamSubscription<List<FavoritesTableData>>? _subscription;

  LocalFavoritesNotifier(this._database) : super([]) {
    _subscription =
        _database.select(_database.favoritesTable).watch().listen((data) {
      if (mounted) state = data;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> addFavorite(DeeMusiqTrackObject track) async {
    if (await isFavorite(track.id)) return; // idempotent

    final thumbnailUrl = track.album.images.isNotEmpty
        ? track.album.images.first.url
        : null;

    await _database.into(_database.favoritesTable).insert(
          FavoritesTableCompanion.insert(
            trackId: track.id,
            trackName: track.name,
            artistName: track.artists.map((a) => a.name).join(', '),
            albumName: Value<String?>(track.album.name),
            thumbnailUrl: Value<String?>(thumbnailUrl),
            sourceUri: Value<String?>(track.externalUri),
            durationMs: Value<int?>(track.durationMs),
          ),
        );
  }

  Future<void> removeFavorite(String trackId) async {
    await (_database.delete(_database.favoritesTable)
          ..where((tbl) => tbl.trackId.equals(trackId)))
        .go();
  }

  Future<bool> isFavorite(String trackId) async {
    final result = await (_database.select(_database.favoritesTable)
          ..where((tbl) => tbl.trackId.equals(trackId)))
        .get();
    return result.isNotEmpty;
  }
}

/// Local-first like toggle shared by the heart button and the track options
/// menu. The Drift favorites table is the offline source of truth; the
/// metadata plugin and the anonymous backend sync ([DataSyncService]) are
/// best-effort so a dead plugin or unreachable backend can never break likes.
/// Returns the new liked state.
Future<bool> toggleTrackFavorite({
  required LocalFavoritesNotifier localFavorites,
  required MetadataPluginSavedTracksNotifier savedTracks,
  required DeeMusiqTrackObject track,
  required bool isLiked,
}) async {
  if (isLiked) {
    await localFavorites.removeFavorite(track.id);
    unawaited(DataSyncService.instance.unlikeSong(track.id).catchError((e) {
      AppLogger.log.d('Liked-song backend sync failed: ${e.toString()}');
    }));
    try {
      await savedTracks.removeFavorite([track]);
    } catch (e, stack) {
      AppLogger.log.w('Plugin removeFavorite failed: ${e.toString()}');
      AppLogger.reportError(e, stack, 'toggleTrackFavorite remove');
    }
    return false;
  } else {
    await localFavorites.addFavorite(track);
    unawaited(DataSyncService.instance.likeSong(track.id).catchError((e) {
      AppLogger.log.d('Liked-song backend sync failed: ${e.toString()}');
    }));
    try {
      await savedTracks.addFavorite([track]);
    } catch (e, stack) {
      AppLogger.log.w('Plugin addFavorite failed: ${e.toString()}');
      AppLogger.reportError(e, stack, 'toggleTrackFavorite add');
    }
    return true;
  }
}
