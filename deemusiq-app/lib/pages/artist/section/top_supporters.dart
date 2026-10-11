import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/provider/wallet/supporter_provider.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// The "Top Supporters" section on the artist page: the artist's ranked
/// supporter board (`GET /artists/:id/supporters`) with tier badges. Hidden
/// entirely when no backend is configured (provider answers null).
class ArtistPageSupporters extends ConsumerWidget {
  final String artistId;
  const ArtistPageSupporters({super.key, required this.artistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(supporterBoardProvider(artistId));

    return board.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Card(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(DeeMusiqIcons.info, size: 28, color: deeMusiqOrange),
            const Gap(10),
            Text(context.l10n.supporters_load_failed).semiBold(),
            const Gap(4),
            Text(
              error is WalletApiException
                  ? error.friendlyMessage
                  : error.toString(),
              textAlign: TextAlign.center,
            ).muted().small(),
            const Gap(12),
            Button.outline(
              onPressed: () =>
                  ref.invalidate(supporterBoardProvider(artistId)),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
      data: (data) {
        if (data == null) return const SizedBox.shrink();
        return Card(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(DeeMusiqIcons.trophy,
                      size: 18, color: deeMusiqOrange),
                  const Gap(8),
                  Text(context.l10n.supporters_section_title).semiBold(),
                ],
              ),
              const Gap(10),
              if (data.entries.isEmpty)
                Text(
                  context.l10n.supporters_empty,
                  textAlign: TextAlign.center,
                ).muted().small()
              else
                for (final entry in data.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: _SupporterRow(entry: entry),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _SupporterRow extends StatelessWidget {
  final SupporterEntry entry;
  const _SupporterRow({required this.entry});

  Color _tierColor() {
    switch (entry.tier) {
      case SupporterTier.gold:
        return const Color(0xFFFFC107);
      case SupporterTier.silver:
        return const Color(0xFFB0BEC5);
      case SupporterTier.bronze:
        return const Color(0xFFCD7F32);
      case SupporterTier.none:
        return deeMusiqOrange;
    }
  }

  String _tierLabel(BuildContext context) {
    switch (entry.tier) {
      case SupporterTier.gold:
        return context.l10n.supporter_tier_gold;
      case SupporterTier.silver:
        return context.l10n.supporter_tier_silver;
      case SupporterTier.bronze:
        return context.l10n.supporter_tier_bronze;
      case SupporterTier.none:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final tierLabel = _tierLabel(context);
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            "#${entry.rank}",
            style: TextStyle(color: _tierColor(), fontWeight: FontWeight.w800),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: Text(entry.name, maxLines: 1).semiBold()),
              if (entry.isTopSupporter) ...[
                const Gap(4),
                Tooltip(
                  tooltip: TooltipContainer(
                    child: Text(context.l10n.supporter_top_badge),
                  ).call,
                  child: const Icon(
                    DeeMusiqIcons.trophy,
                    size: 14,
                    color: Color(0xFFFFC107),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (tierLabel.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _tierColor().withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _tierColor()),
            ),
            child: Text(
              tierLabel,
              style: TextStyle(
                color: _tierColor(),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Gap(8),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(DeeMusiqIcons.token, size: 14, color: deeMusiqOrange),
            const Gap(4),
            Text(
              formatTokens(entry.totalTokens),
              style: const TextStyle(
                color: deeMusiqOrange,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
