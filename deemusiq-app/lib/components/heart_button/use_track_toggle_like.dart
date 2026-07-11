import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/local_favorites/local_favorites_provider.dart';
import 'package:deemusiq/provider/metadata_plugin/library/tracks.dart';

typedef UseTrackToggleLike = ({
  bool isLiked,
  bool isLoading,
  Future<void> Function(DeeMusiqTrackObject track) toggleTrackLike,
});

UseTrackToggleLike useTrackToggleLike(DeeMusiqTrackObject track, WidgetRef ref) {
  final savedTracksNotifier =
      ref.watch(metadataPluginSavedTracksProvider.notifier);

  final isSavedTrack = ref.watch(metadataPluginIsSavedTrackProvider(track.id));
  // Local favorites keep hearts filled when the metadata plugin is down.
  final isLocalFavorite = ref.watch(
    localFavoritesProvider.select(
      (favorites) => favorites.any((fav) => fav.trackId == track.id),
    ),
  );

  final isLiked = (isSavedTrack.asData?.value ?? false) || isLocalFavorite;

  return (
    isLiked: isLiked,
    isLoading: isSavedTrack.isLoading,
    toggleTrackLike: (track) async {
      await toggleTrackFavorite(
        localFavorites: ref.read(localFavoritesProvider.notifier),
        savedTracks: savedTracksNotifier,
        track: track,
        isLiked: isLiked,
      );
    },
  );
}
