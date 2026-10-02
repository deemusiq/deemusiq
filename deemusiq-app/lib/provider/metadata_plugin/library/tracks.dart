import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/metadata_plugin/core/auth.dart';
import 'package:deemusiq/provider/metadata_plugin/utils/common.dart';
import 'package:deemusiq/provider/metadata_plugin/utils/paginated.dart';
import 'package:deemusiq/services/logger/logger.dart';

class MetadataPluginSavedTracksNotifier
    extends AutoDisposePaginatedAsyncNotifier<DeeMusiqFullTrackObject> {
  MetadataPluginSavedTracksNotifier() : super();

  @override
  fetch(offset, limit) async {
    final tracks = await (await metadataPlugin).user.savedTracks(
          offset: offset,
          limit: limit,
        );

    return tracks;
  }

  @override
  build() async {
    ref.cacheFor();

    await ref.watch(metadataPluginAuthenticatedProvider.future);
    return await fetch(0, 20);
  }

  Future<void> addFavorite(List<DeeMusiqTrackObject> tracks) async {
    if (state.value == null) {
      return;
    }

    final oldState = state.value;
    state = AsyncData(
      state.value!.copyWith(
        items: [
          ...tracks.whereType<DeeMusiqFullTrackObject>(),
          ...state.value!.items
        ],
      ),
    );

    try {
      await (await metadataPlugin).track.save(tracks.map((e) => e.id).toList());
    } catch (e) {
      AppLogger.log.w('Failed to save tracks: ${e.toString()}');
      state = AsyncData(oldState!);
      rethrow;
    }
  }

  Future<void> removeFavorite(List<DeeMusiqTrackObject> tracks) async {
    if (state.value == null) {
      return;
    }

    final oldState = state.value;
    state = AsyncData(
      state.value!.copyWith(
        items: state.value!.items
            .where(
              (savedTrack) => !tracks.any((track) => track.id == savedTrack.id),
            )
            .toList(),
      ),
    );

    try {
      await (await metadataPlugin)
          .track
          .unsave(tracks.map((e) => e.id).toList());
    } catch (e) {
      AppLogger.log.w('Failed to unsave tracks: ${e.toString()}');
      state = AsyncData(oldState!);
      rethrow;
    }
  }
}

final metadataPluginSavedTracksProvider = AutoDisposeAsyncNotifierProvider<
    MetadataPluginSavedTracksNotifier,
    DeeMusiqPaginationResponseObject<DeeMusiqFullTrackObject>>(
  () => MetadataPluginSavedTracksNotifier(),
);

/// Set of every saved-track id, loaded ONCE for the whole tree.
///
/// Heart buttons used to each open a family provider that re-ran
/// `fetchAll()` (full library paging) per track id — N tiles ⇒ N storms.
/// This shared provider does at most one `fetchAll()` per library revision;
/// membership checks become a Set lookup.
final metadataPluginSavedTrackIdsProvider = FutureProvider<Set<String>>(
  (ref) async {
    final savedTracks = await ref.watch(metadataPluginSavedTracksProvider.future);
    if (!savedTracks.hasMore) {
      return savedTracks.items.map((t) => t.id).toSet();
    }
    try {
      final all =
          await ref.read(metadataPluginSavedTracksProvider.notifier).fetchAll();
      return all.map((t) => t.id).toSet();
    } catch (_) {
      // Partial library is better than failing every heart button.
      return savedTracks.items.map((t) => t.id).toSet();
    }
  },
);

final metadataPluginIsSavedTrackProvider =
    FutureProvider.autoDispose.family<bool, String>(
  (ref, trackId) async {
    final ids = await ref.watch(metadataPluginSavedTrackIdsProvider.future);
    return ids.contains(trackId);
  },
);
