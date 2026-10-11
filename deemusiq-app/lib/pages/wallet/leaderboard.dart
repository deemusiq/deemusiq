import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/image/universal_image.dart';
import 'package:deemusiq/components/titlebar/titlebar.dart';
import 'package:deemusiq/components/wallet/push_song_dialog.dart';
import 'package:deemusiq/components/wallet/region_filter_chips.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/models/wallet/pushed_song.dart';
import 'package:deemusiq/provider/wallet/leaderboard_provider.dart';
import 'package:deemusiq/provider/wallet/wallet_provider.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

@RoutePage()
class PushLeaderboardPage extends HookConsumerWidget {
  static const name = "push-leaderboard";

  const PushLeaderboardPage({super.key});

  /// Adapts a global entry to the tile's [PushedSong] shape (lastPushedAt is
  /// not shown on the board, so a zero epoch placeholder is fine).
  static PushedSong _toSong(LeaderboardEntry e) => PushedSong(
        id: e.songId,
        title: e.title,
        artist: e.artist,
        artistId: e.artistId,
        imageUrl: e.imageUrl,
        totalTokens: e.totalTokens,
        pushCount: e.pushCount,
        lastPushedAt: DateTime.fromMillisecondsSinceEpoch(0),
      );

  Widget _emptyCard(BuildContext context) {
    return Card(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(DeeMusiqIcons.boost, size: 32, color: deeMusiqOrange),
          const Gap(10),
          Text(context.l10n.leaderboard_empty_title).semiBold(),
          const Gap(4),
          Text(
            context.l10n.leaderboard_empty_body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = WalletApiClient.instance.isConfigured;
    // Null = the global board; a chip selects an ISO alpha-2 region and the
    // board refetches with `?region=`.
    final region = useState<String?>(null);

    return SafeArea(
      bottom: false,
      child: Scaffold(
        headers: [
          TitleBar(title: Text(context.l10n.wallet_trending_pushes)),
        ],
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      filled: true,
                      fillColor: context.theme.colorScheme.muted,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(DeeMusiqIcons.trophy,
                              color: deeMusiqOrange),
                          const Gap(10),
                          Expanded(
                            child: Text(context.l10n.leaderboard_explainer),
                          ),
                          if (online)
                            Button.ghost(
                              leading:
                                  const Icon(DeeMusiqIcons.refresh, size: 16),
                              onPressed: () => ref.invalidate(
                                  leaderboardProvider(region.value)),
                              child: Text(context.l10n.refresh),
                            ),
                        ],
                      ),
                    ),
                    if (online) ...[
                      const Gap(10),
                      RegionFilterChips(
                        selected: region.value,
                        onChanged: (value) => region.value = value,
                      ),
                    ],
                    const Gap(16),
                    if (online)
                      _globalBoard(context, ref, region.value)
                    else
                      _localBoard(context, ref),
                    const Gap(40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The global cross-user board from the backend, with loading/error states.
  Widget _globalBoard(BuildContext context, WidgetRef ref, String? region) {
    final board = ref.watch(leaderboardProvider(region));
    return board.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Card(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(DeeMusiqIcons.info, size: 28, color: deeMusiqOrange),
            const Gap(10),
            Text(context.l10n.leaderboard_load_failed).semiBold(),
            const Gap(4),
            Text(
              error is WalletApiException
                  ? error.friendlyMessage
                  : error.toString(),
              textAlign: TextAlign.center,
            ).muted().small(),
            const Gap(12),
            Button.outline(
              onPressed: () => ref.invalidate(leaderboardProvider(region)),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
      data: (entries) => entries.isEmpty
          ? _emptyCard(context)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final entry in entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _LeaderTile(
                      rank: entry.rank,
                      song: _toSong(entry),
                    ),
                  ),
              ],
            ),
    );
  }

  /// Offline fallback: this device's own pushes, clearly labelled.
  Widget _localBoard(BuildContext context, WidgetRef ref) {
    final pushed = ref.watch(walletProvider.select((s) => s.pushedSongs));
    final ranked = [...pushed]
      ..sort((a, b) => b.totalTokens.compareTo(a.totalTokens));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(context.l10n.leaderboard_offline_title).muted().xSmall(),
        const Gap(8),
        if (ranked.isEmpty)
          _emptyCard(context)
        else
          for (final entry in ranked.asMap().entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LeaderTile(
                rank: entry.key + 1,
                song: entry.value,
              ),
            ),
      ],
    );
  }
}

class _LeaderTile extends ConsumerWidget {
  final int rank;
  final PushedSong song;

  const _LeaderTile({required this.rank, required this.song});

  Color _rankColor() {
    switch (rank) {
      case 1:
        return const Color(0xFFFFC107);
      case 2:
        return const Color(0xFFB0BEC5);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return deeMusiqOrange;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      borderColor: rank <= 3 ? _rankColor() : null,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              "#$rank",
              style: TextStyle(
                color: _rankColor(),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: song.imageUrl != null
                ? UniversalImage(
                    path: song.imageUrl!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 44,
                    height: 44,
                    color: deeMusiqOrange.withValues(alpha: 0.15),
                    child: const Icon(DeeMusiqIcons.music,
                        color: deeMusiqOrange),
                  ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(song.title, maxLines: 1).semiBold(),
                Text(
                  context.l10n
                      .leaderboard_push_count(song.artist, song.pushCount),
                  maxLines: 1,
                ).muted().xSmall(),
              ],
            ),
          ),
          const Gap(8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(DeeMusiqIcons.token,
                      size: 14, color: deeMusiqOrange),
                  const Gap(4),
                  Text(
                    formatTokens(song.totalTokens),
                    style: const TextStyle(
                      color: deeMusiqOrange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Gap(4),
              Button.ghost(
                leading: const Icon(DeeMusiqIcons.boost, size: 14),
                onPressed: () => showPushSongDialog(
                  context,
                  songId: song.id,
                  title: song.title,
                  artist: song.artist,
                  artistId: song.artistId,
                  imageUrl: song.imageUrl,
                ),
                child: Text(context.l10n.push_action),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
