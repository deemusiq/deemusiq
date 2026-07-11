import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/collections/assets.gen.dart';
import 'package:deemusiq/components/track_presentation/presentation_props.dart';
import 'package:deemusiq/components/track_presentation/track_presentation.dart';
import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/pages/playlist/playlist.dart';
import 'package:deemusiq/provider/local_favorites/local_favorites_provider.dart';
import 'package:deemusiq/provider/metadata_plugin/library/tracks.dart';
import 'package:auto_route/auto_route.dart';
import 'package:deemusiq/provider/metadata_plugin/utils/common.dart';

@RoutePage()
class LikedPlaylistPage extends HookConsumerWidget {
  static const name = PlaylistPage.name;

  final DeeMusiqSimplePlaylistObject playlist;
  const LikedPlaylistPage({
    super.key,
    required this.playlist,
  });

  @override
  Widget build(BuildContext context, ref) {
    final likedTracks = ref.watch(metadataPluginSavedTracksProvider);
    final likedTracksNotifier =
        ref.watch(metadataPluginSavedTracksProvider.notifier);
    final localFavorites = ref.watch(localFavoritesProvider);

    final tracks = useMemoized(() {
      if (likedTracks.hasError || (likedTracks.asData?.value.items.isEmpty ?? true)) {
        if (localFavorites.isNotEmpty) {
          return localFavorites.map(_toFullTrack).toList();
        }
      }
      return likedTracks.asData?.value.items ?? [];
    }, [likedTracks, localFavorites]);

    final hasFallback = likedTracks.hasError || (likedTracks.asData?.value.items.isEmpty ?? true);
    final showPagination = !hasFallback;

    return material.RefreshIndicator.adaptive(
      onRefresh: () async {
        ref.invalidate(metadataPluginSavedTracksProvider);
        ref.invalidate(localFavoritesProvider);
      },
      child: TrackPresentation(
        options: TrackPresentationOptions(
          collection: playlist,
          image: Assets.images.likedTracks.path,
          pagination: PaginationProps(
            hasNextPage: showPagination ? (likedTracks.asData?.value.hasMore ?? false) : false,
            isLoading: likedTracks.isLoadingNextPage && !likedTracks.isLoading,
            onFetchMore: showPagination
                ? () {
                    likedTracksNotifier.fetchMore();
                  }
                : () {},
            onFetchAll: showPagination
                ? () => likedTracksNotifier.fetchAll()
                : () async => [],
            onRefresh: () async {
              ref.invalidate(metadataPluginSavedTracksProvider);
              ref.invalidate(localFavoritesProvider);
            },
          ),
          title: playlist.name,
          description: playlist.description,
          tracks: tracks,
          error: hasFallback ? null : likedTracks.error,
          routePath: '/playlist/${playlist.id}',
          isLiked: false,
          shareUrl: null,
          onHeart: null,
          owner: playlist.owner.name,
        ),
      ),
    );
  }
}

DeeMusiqFullTrackObject _toFullTrack(FavoritesTableData fav) {
  return DeeMusiqFullTrackObject(
    id: fav.trackId,
    name: fav.trackName,
    externalUri: fav.sourceUri ?? '',
    artists: [
      DeeMusiqSimpleArtistObject(
        id: fav.artistName,
        name: fav.artistName,
        externalUri: fav.sourceUri ?? '',
      ),
    ],
    album: DeeMusiqSimpleAlbumObject(
      albumType: DeeMusiqAlbumType.album,
      id: fav.albumName ?? 'unknown',
      name: fav.albumName ?? 'Unknown Album',
      externalUri: '',
      artists: [
        DeeMusiqSimpleArtistObject(
          id: fav.artistName,
          name: fav.artistName,
          externalUri: '',
        ),
      ],
      images: fav.thumbnailUrl != null
          ? [
              DeeMusiqImageObject(
                url: fav.thumbnailUrl!,
                width: 300,
                height: 300,
              ),
            ]
          : [],
      releaseDate: '1970-01-01',
    ),
    durationMs: fav.durationMs ?? 0,
    isrc: '',
    explicit: false,
  );
}
