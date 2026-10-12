import 'package:auto_route/auto_route.dart';

import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:deemusiq/collections/assets.gen.dart';
import 'package:deemusiq/collections/routes.gr.dart';
import 'package:deemusiq/components/image/universal_image.dart';
import 'package:deemusiq/components/links/artist_link.dart';
import 'package:deemusiq/components/links/link_text.dart';
import 'package:deemusiq/extensions/constrains.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/audio_player/audio_player.dart';
import 'package:deemusiq/services/audio_player/data_saver.dart';

class PlayerTrackDetails extends HookConsumerWidget {
  final Color? color;
  final DeeMusiqTrackObject? track;
  const PlayerTrackDetails({super.key, this.color, this.track});

  @override
  Widget build(BuildContext context, ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final playback = ref.watch(audioPlayerProvider);
    // "Lite" indicator: the active track is playing its data-saver rendition
    // (catalog liteUrl chosen instead of the full source).
    final active = playback.activeTrack;
    final liteUrl = active is DeeMusiqFullTrackObject ? active.liteUrl : null;
    final liteActive = liteUrl != null &&
        liteUrl.isNotEmpty &&
        ref.watch(dataSaverActiveProvider).valueOrNull == true;

    final liteBadge = !liteActive
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Tooltip(
              tooltip: TooltipContainer(
                child: Text(context.l10n.now_playing_lite_tooltip),
              ).call,
              child: OutlineBadge(child: Text(context.l10n.now_playing_lite)),
            ),
          );

    return Row(
      children: [
        if (playback.activeTrack != null)
          Container(
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(
              maxWidth: 80,
              maxHeight: 80,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: UniversalImage(
                path: (track?.album.images)
                    .asUrlString(placeholder: ImagePlaceholder.albumArt),
                placeholder: Assets.images.albumPlaceholder.path,
              ),
            ),
          ),
        if (!mediaQuery.lgAndUp)
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        playback.activeTrack?.name ?? "",
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.normal.copyWith(
                          color: color,
                        ),
                      ),
                    ),
                    liteBadge,
                  ],
                ),
                Text(
                  playback.activeTrack?.artists.asString() ?? "",
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.small.copyWith(color: color),
                )
              ],
            ),
          ),
        if (mediaQuery.lgAndUp)
          Flexible(
            flex: 1,
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: LinkText(
                        playback.activeTrack?.name ?? "",
                        TrackRoute(trackId: playback.activeTrack?.id ?? ""),
                        push: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: color),
                      ),
                    ),
                    liteBadge,
                  ],
                ),
                ArtistLink(
                  artists: playback.activeTrack?.artists ?? [],
                  onRouteChange: (route) {
                    context.router.navigateNamed(route);
                  },
                  onOverflowArtistClick: () =>
                      context.navigateTo(TrackRoute(trackId: track!.id)),
                )
              ],
            ),
          ),
      ],
    );
  }
}
