import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/image/universal_image.dart';
import 'package:deemusiq/components/titlebar/titlebar.dart';
import 'package:deemusiq/components/wallet/boost_artist_dialog.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/provider/creator/creator_provider.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// The yearly artist leaderboard: users boost the artists they love with tokens,
/// and the top artist each calendar year is crowned "Best Artist". The board
/// resets every year (the backend windows by calendar year); past winners live
/// in the Hall of Fame.
@RoutePage()
class ArtistLeaderboardPage extends HookConsumerWidget {
  static const name = "artist-leaderboard";

  const ArtistLeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = WalletApiClient.instance.isConfigured;
    final board = ref.watch(artistLeaderboardProvider(null));
    final hof = ref.watch(hallOfFameProvider);

    return SafeArea(
      bottom: false,
      child: Scaffold(
        headers: [TitleBar(title: const Text("Artists of the Year"))],
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!online)
                      const _InfoCard(
                        title: "Connect to see the board",
                        body:
                            "The artist leaderboard is live once DeeMusiq's backend is configured.",
                      )
                    else ...[
                      board.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, _) => _ErrorCard(
                          message: error is WalletApiException
                              ? error.message
                              : error.toString(),
                          onRetry: () =>
                              ref.invalidate(artistLeaderboardProvider(null)),
                        ),
                        data: (data) => _board(context, ref, data),
                      ),
                      const Gap(24),
                      const Text("Hall of Fame").large().semiBold(),
                      const Gap(4),
                      const Text("Best Artist of each past year.")
                          .muted()
                          .small(),
                      const Gap(10),
                      hof.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (winners) => winners.isEmpty
                            ? const Text("No past winners yet.").muted().small()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (final w in winners)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8),
                                      child: _HallOfFameTile(winner: w),
                                    ),
                                ],
                              ),
                      ),
                    ],
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

  Widget _board(BuildContext context, WidgetRef ref, ArtistLeaderboard data) {
    if (data.entries.isEmpty) {
      return _InfoCard(
        title: "No boosts yet in ${data.year}",
        body: "Boost an artist you love to start the ${data.year} race.",
      );
    }
    final leader = data.entries.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Leader banner — the current front-runner for Best Artist of the year.
        Card(
          filled: true,
          fillColor: deeMusiqOrange.withValues(alpha: 0.12),
          borderColor: deeMusiqOrange,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(DeeMusiqIcons.trophy, color: deeMusiqOrange, size: 32),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Leading ${data.year}").muted().xSmall(),
                    const Gap(2),
                    Text(leader.name, maxLines: 1).large().semiBold(),
                    Text(
                      "${formatTokens(leader.totalTokens)} tokens · ${leader.supporters} supporter${leader.supporters == 1 ? "" : "s"}",
                    ).muted().small(),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Gap(16),
        for (final entry in data.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ArtistTile(entry: entry),
          ),
      ],
    );
  }
}

class _ArtistTile extends ConsumerWidget {
  final ArtistLeaderEntry entry;
  const _ArtistTile({required this.entry});

  Color _rankColor() {
    switch (entry.rank) {
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
      borderColor: entry.rank <= 3 ? _rankColor() : null,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              "#${entry.rank}",
              style: TextStyle(color: _rankColor(), fontWeight: FontWeight.w800),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: entry.imageUrl != null
                ? UniversalImage(
                    path: entry.imageUrl!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 44,
                    height: 44,
                    color: deeMusiqOrange.withValues(alpha: 0.15),
                    child:
                        const Icon(DeeMusiqIcons.artist, color: deeMusiqOrange),
                  ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: Text(entry.name, maxLines: 1).semiBold()),
                    if (entry.verified) ...[
                      const Gap(4),
                      const Icon(DeeMusiqIcons.verified,
                          size: 13, color: deeMusiqOrange),
                    ],
                  ],
                ),
                Text(
                  "${formatTokens(entry.totalTokens)} tokens · ${entry.supporters} supporter${entry.supporters == 1 ? "" : "s"}",
                  maxLines: 1,
                ).muted().xSmall(),
              ],
            ),
          ),
          const Gap(8),
          Button.ghost(
            leading: const Icon(DeeMusiqIcons.boost, size: 14),
            onPressed: () => showBoostArtistDialog(
              context,
              ref,
              artistId: entry.artistId,
              artistName: entry.name,
            ),
            child: const Text("Boost"),
          ),
        ],
      ),
    );
  }
}

class _HallOfFameTile extends StatelessWidget {
  final HallOfFameEntry winner;
  const _HallOfFameTile({required this.winner});

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 48,
            alignment: Alignment.center,
            child: Text(
              "${winner.year}",
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const Icon(DeeMusiqIcons.trophy, color: Color(0xFFFFC107)),
          const Gap(12),
          Expanded(child: Text(winner.name, maxLines: 1).semiBold()),
          Text("${formatTokens(winner.totalTokens)} tokens").muted().xSmall(),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String body;
  const _InfoCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(DeeMusiqIcons.trophy, size: 32, color: deeMusiqOrange),
          const Gap(10),
          Text(title).semiBold(),
          const Gap(4),
          Text(body, textAlign: TextAlign.center).muted().small(),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(DeeMusiqIcons.info, size: 28, color: deeMusiqOrange),
          const Gap(10),
          const Text("Couldn't load the board").semiBold(),
          const Gap(4),
          Text(message, textAlign: TextAlign.center).muted().small(),
          const Gap(12),
          Button.outline(onPressed: onRetry, child: const Text("Retry")),
        ],
      ),
    );
  }
}
