import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';

import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/dialogs/prompt_dialog.dart';
import 'package:deemusiq/components/dialogs/select_device_dialog.dart';
import 'package:deemusiq/components/fallbacks/error_box.dart';
import 'package:deemusiq/components/image/universal_image.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/collections/assets.gen.dart';
import 'package:deemusiq/models/connect/connect.dart';
import 'package:deemusiq/provider/audio_player/audio_player.dart';
import 'package:deemusiq/provider/catalog/catalog_provider.dart';
import 'package:deemusiq/provider/connect/connect.dart';
import 'package:deemusiq/provider/database/database.dart';
import 'package:deemusiq/provider/metadata_plugin/metadata_plugin_provider.dart';
import 'package:deemusiq/provider/ratings/track_ratings_provider.dart';
import 'package:deemusiq/services/ratings/track_ratings_api.dart';

/// Home "Trending" section: the backend's most-liked tracks of the trending
/// window (falling back to the all-time top feed while the window is empty),
/// as a horizontal card row with a like-ratio badge on each card. Hidden
/// while loading and when there is nothing rated yet — same contract as the
/// other home sections.
class TrendingSection extends HookConsumerWidget {
  const TrendingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trending = ref.watch(trendingTracksProvider);
    final scale = context.theme.scaling;

    if (trending.isLoading) return const SizedBox.shrink();

    if (trending.hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ErrorBox(
          error: trending.error!,
          onRetry: () => ref.invalidate(trendingTracksProvider),
        ),
      );
    }

    final items = trending.asData?.value ?? const <RatedTrack>[];
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(DeeMusiqIcons.trending, size: 18),
              const Gap(8),
              Expanded(
                child: Text("Trending", style: context.theme.typography.h4),
              ),
              Button.ghost(
                onPressed: () => ref.invalidate(trendingTracksProvider),
                leading: const Icon(DeeMusiqIcons.refresh, size: 14),
                child: const Text("Refresh"),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200 * scale,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: items.length,
            separatorBuilder: (context, index) => Gap(12 * scale),
            itemBuilder: (context, index) => _TrendingCard(items[index]),
          ),
        ),
      ],
    );
  }
}

class _TrendingCard extends HookConsumerWidget {
  final RatedTrack item;

  const _TrendingCard(this.item);

  Future<void> _play(BuildContext context, WidgetRef ref) async {
    final playlist = ref.read(audioPlayerProvider);
    final playlistNotifier = ref.read(audioPlayerProvider.notifier);

    final isRemoteDevice = await showSelectDeviceDialog(context, ref);
    if (isRemoteDevice == null) return;

    // Map through the shared catalog-feed mapper so the source-match cache is
    // seeded and the track plays exactly like a catalog-page row.
    final db = ref.read(databaseProvider);
    final audioCfg = await ref.read(
      metadataPluginsProvider.selectAsync((d) => d.defaultAudioSourcePluginConfig),
    );
    final track = await catalogFeedItemToTrack(
      item.toFeedJson(),
      db: db,
      audioSourceSlug: audioCfg?.slug,
    );

    if (isRemoteDevice) {
      final remotePlayback = ref.read(connectProvider.notifier);
      await remotePlayback.load(
        WebSocketLoadEventData.playlist(tracks: [track]),
      );
      return;
    }

    final isTrackPlaying = playlist.activeTrack?.id == track.id;
    if (isTrackPlaying || !context.mounted) return;
    final shouldPlay = playlist.tracks.length > 20
        ? await showPromptDialog(
            context: context,
            title: context.l10n.playing_track(track.name),
            message: context.l10n.queue_clear_alert(playlist.tracks.length),
          )
        : true;
    if (shouldPlay) {
      await playlistNotifier.load([track], autoPlay: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData(:colorScheme) = Theme.of(context);
    final scale = context.theme.scaling;
    final likePercent = item.rating?.likePercent;

    final coverProvider = useMemoized(
      () => UniversalImage.imageProvider(
        item.coverUrl ?? Assets.images.placeholder.path,
        height: 150,
        width: 150,
      ),
      [item.coverUrl],
    );

    return SizedBox(
      width: 150 * scale,
      child: Button(
        style: ButtonVariance.ghost.copyWith(
          padding: (context, states, value) => EdgeInsets.zero,
        ),
        onPressed: () => _play(context, ref),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 150 * scale,
                  width: 150 * scale,
                  decoration: BoxDecoration(
                    borderRadius: Theme.of(context).borderRadiusMd,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: coverProvider,
                    ),
                  ),
                ),
                if (likePercent != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        "$likePercent%",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primaryForeground,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const Gap(4),
            Text(
              item.title.isEmpty ? "Unknown title" : item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              item.artistName.isEmpty ? "Unknown artist" : item.artistName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ).muted().xSmall(),
          ],
        ),
      ),
    );
  }
}
