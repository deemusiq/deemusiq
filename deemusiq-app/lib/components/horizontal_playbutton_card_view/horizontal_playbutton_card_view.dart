import 'dart:ui';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:deemusiq/collections/fake.dart';
import 'package:deemusiq/components/dialogs/prompt_dialog.dart';
import 'package:deemusiq/components/dialogs/select_device_dialog.dart';
import 'package:deemusiq/components/playbutton_view/playbutton_card.dart';
import 'package:deemusiq/components/track_tile/track_tile.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/models/connect/connect.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/modules/album/album_card.dart';
import 'package:deemusiq/modules/artist/artist_card.dart';
import 'package:deemusiq/modules/playlist/playlist_card.dart';
import 'package:deemusiq/provider/audio_player/audio_player.dart';
import 'package:deemusiq/provider/connect/connect.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class HorizontalPlaybuttonCardView<T> extends HookWidget {
  final Widget title;
  final List<T> items;
  final Widget? error;
  final VoidCallback onFetchMore;
  final bool isLoadingNextPage;
  final bool hasNextPage;
  final Widget? titleTrailing;

  HorizontalPlaybuttonCardView({
    required this.title,
    required this.items,
    required this.hasNextPage,
    required this.onFetchMore,
    required this.isLoadingNextPage,
    this.titleTrailing,
    this.error,
    super.key,
  }) : assert(
          items.every(
            (item) =>
                item is DeeMusiqSimpleAlbumObject ||
                item is DeeMusiqSimplePlaylistObject ||
                item is DeeMusiqFullArtistObject ||
                item is DeeMusiqFullTrackObject,
          ),
        );

  /// Skeleton twin of [HorizontalPlaybuttonCardView] — same scaffold, same rail
  /// height, cards replaced by real [PlaybuttonCard]s under a [Skeletonizer].
  ///
  /// Built from the real presentational card rather than hand-placed boxes so
  /// the placeholder cannot drift from the loaded layout, and pointed at the
  /// bundled collection placeholder so no artwork is fetched for imagery the
  /// skeleton discards. [AlbumCard] is deliberately not used here: it watches
  /// the audio player, so a skeleton made of real album cards would stand up and
  /// tear down player subscriptions for content it throws away — and throws in
  /// any test that has not initialised media_kit.
  ///
  /// A static method rather than a named constructor because a factory must
  /// return an instance of the enclosing class, and the skeleton is not a
  /// [HorizontalPlaybuttonCardView] — it has no items and no paging.
  static Widget skeleton({
    required Widget title,
    Key? key,
  }) =>
      _HorizontalPlaybuttonCardSkeleton(title: title, key: key);

  /// Single source of truth for rail height, shared by the loaded view and its
  /// skeleton so the two cannot disagree.
  static double railHeight(
    double scale, {
    required bool isTrack,
    required bool isArtist,
  }) =>
      isTrack ? 76 * scale : (isArtist ? 250 * scale : 225 * scale);

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    final isArtist = T == DeeMusiqFullArtistObject ||
        items.every((s) => s is DeeMusiqFullArtistObject);
    final isTrack = T == DeeMusiqFullTrackObject ||
        (items.isNotEmpty && items.every((s) => s is DeeMusiqFullTrackObject));
    final scale = context.theme.scaling;

    return _SectionScaffold(
      title: title,
      titleTrailing: titleTrailing,
      child: error != null
          ? error!
          : SizedBox(
              height: railHeight(scale, isTrack: isTrack, isArtist: isArtist),
              child: NotificationListener(
                // disable multiple scrollbar to use this
                onNotification: (notification) => true,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: PointerDeviceKind.values.toSet(),
                  ),
                  child: items.isEmpty
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return switch (T) {
                              const (DeeMusiqFullArtistObject) =>
                                ArtistCard(FakeData.artist),
                              const (DeeMusiqFullTrackObject) =>
                                _TrackTileCard(FakeData.track),
                              const (DeeMusiqSimplePlaylistObject) =>
                                PlaylistCard(FakeData.playlistSimple),
                              _ => AlbumCard(FakeData.albumSimple),
                            };
                          },
                        )
                      : InfiniteList(
                          scrollController: scrollController,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          itemCount: items.length,
                          onFetchData: onFetchMore,
                          loadingBuilder: (context) => Skeletonizer(
                                enabled: true,
                                child: isArtist
                                    ? ArtistCard(FakeData.artist)
                                    : AlbumCard(FakeData.albumSimple),
                              ),
                          isLoading: isLoadingNextPage,
                          hasReachedMax: !hasNextPage,
                          separatorBuilder: (context, index) => Gap(12 * scale),
                          itemBuilder: (context, index) {
                            final item = items[index];

                            return switch (item) {
                              DeeMusiqSimplePlaylistObject() => PlaylistCard(
                                  item as DeeMusiqSimplePlaylistObject),
                              DeeMusiqSimpleAlbumObject() =>
                                AlbumCard(item as DeeMusiqSimpleAlbumObject),
                              DeeMusiqFullArtistObject() =>
                                ArtistCard(item as DeeMusiqFullArtistObject),
                              DeeMusiqFullTrackObject() =>
                                _TrackTileCard(item as DeeMusiqFullTrackObject),
                              _ => const SizedBox.shrink(),
                            };
                          }),
                ),
              ),
            ),
    );
  }
}

/// Header + rail chrome shared by [HorizontalPlaybuttonCardView] and its
/// skeleton, so the two share one definition of the section layout.
class _SectionScaffold extends StatelessWidget {
  final Widget title;
  final Widget? titleTrailing;
  final Widget child;

  const _SectionScaffold({
    required this.title,
    required this.child,
    this.titleTrailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: DefaultTextStyle(
                  style: context.theme.typography.h4.copyWith(
                    color: context.theme.colorScheme.foreground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: title,
                ),
              ),
              if (titleTrailing != null) titleTrailing!,
            ],
          ),
          child,
        ],
      ),
    );
  }
}

/// See [HorizontalPlaybuttonCardView.skeleton].
class _HorizontalPlaybuttonCardSkeleton extends StatelessWidget {
  final Widget title;

  const _HorizontalPlaybuttonCardSkeleton({required this.title, super.key});

  /// Cards per rail — enough to fill a wide desktop window without a scrollbar
  /// depending on how far it would have to be dragged.
  static const int _cardCount = 8;

  @override
  Widget build(BuildContext context) {
    final scale = context.theme.scaling;
    return _SectionScaffold(
      title: title,
      child: SizedBox(
        height: HorizontalPlaybuttonCardView.railHeight(
          scale,
          isTrack: false,
          isArtist: false,
        ),
        child: Skeletonizer(
          enabled: true,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: _cardCount,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: PlaybuttonCard(
                // An empty box, not a URL or an asset path: [PlaybuttonCard]
                // sizes the image slot itself, and Skeletonizer paints over it
                // regardless. Resolving a real image here would fetch cover art
                // (or fail to load an asset in tests) for a placeholder that
                // never shows artwork.
                image: const SizedBox.shrink(),
                title: context.l10n.loading,
                description: context.l10n.loading,
                isPlaying: false,
                isLoading: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A track rendered inside a [HorizontalPlaybuttonCardView] (e.g. the
/// backend's "New releases" tracks section). Fixed width so it can scroll
/// horizontally next to the card-shaped sections.
class _TrackTileCard extends HookConsumerWidget {
  final DeeMusiqFullTrackObject track;

  const _TrackTileCard(this.track);

  @override
  Widget build(BuildContext context, ref) {
    final playlist = ref.watch(audioPlayerProvider);
    final playlistNotifier = ref.watch(audioPlayerProvider.notifier);
    final scale = context.theme.scaling;

    return SizedBox(
      width: 340 * scale,
      child: TrackTile(
        track: track,
        playlist: playlist,
        onTap: () async {
          final isRemoteDevice = await showSelectDeviceDialog(context, ref);
          if (isRemoteDevice == null) return;
          if (!context.mounted) return;

          if (isRemoteDevice) {
            final remotePlayback = ref.read(connectProvider.notifier);
            await remotePlayback.load(
              WebSocketLoadEventData.playlist(tracks: [track]),
            );
          } else {
            final isTrackPlaying = playlist.activeTrack?.id == track.id;
            if (!isTrackPlaying && context.mounted) {
              final shouldPlay = playlist.tracks.length > 20
                  ? await showPromptDialog(
                      context: context,
                      title: context.l10n.playing_track(track.name),
                      message: context.l10n
                          .queue_clear_alert(playlist.tracks.length),
                    )
                  : true;

              if (shouldPlay) {
                await playlistNotifier.load([track], autoPlay: true);
              }
            }
          }
        },
      ),
    );
  }
}
