import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/provider/wallet/supporter_provider.dart';
import 'package:deemusiq/provider/wallet/wallet_provider.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';
import 'package:uuid/uuid.dart';

const _boostPresets = [5, 10, 25, 50];

/// Prompts for a token amount and boosts [artistId] toward the yearly artist
/// leaderboard. Requires a configured backend (guard the entry point with
/// [WalletApiClient.instance.isConfigured]).
Future<void> showBoostArtistDialog(
  BuildContext context,
  WidgetRef ref, {
  required String artistId,
  required String artistName,
}) async {
  final tokens = await showDialog<int>(
    context: context,
    builder: (context) => _BoostDialog(artistId: artistId, artistName: artistName),
  );
  if (tokens == null) return;
  // One key per dialog-confirmed boost (backend L2 replay contract): a retry
  // of THIS attempt replays instead of double-debiting; the next boost the
  // user explicitly confirms gets a fresh key. Shape matches the backend's
  // parseIdempotencyKey (/^[A-Za-z0-9_-]{8,64}$/).
  final idempotencyKey = const Uuid().v4();
  try {
    await WalletApiClient.instance
        .boostArtist(artistId: artistId, tokens: tokens, idempotencyKey: idempotencyKey);
    await ref.read(walletProvider.notifier).syncFromBackend();
    // A successful boost changes the caller's supporter standing and the
    // board — drop both caches so the next read refetches.
    ref.invalidate(mySupportProvider(artistId));
    ref.invalidate(supporterBoardProvider(artistId));
    if (context.mounted) {
      showWalletToast(
        context,
        context.l10n.boost_success(artistName, tokens),
        icon: DeeMusiqIcons.boost,
      );
    }
  } on WalletApiException catch (e) {
    if (context.mounted) {
      showWalletToast(context, e.friendlyMessage, icon: DeeMusiqIcons.info);
    }
  } catch (e, stack) {
    AppLogger.reportError(e, stack, 'boostArtist');
    if (context.mounted) {
      showWalletToast(context, context.l10n.boost_failed,
          icon: DeeMusiqIcons.info);
    }
  }
}

class _BoostDialog extends HookConsumerWidget {
  final String artistId;
  final String artistName;
  const _BoostDialog({required this.artistId, required this.artistName});

  String _tierLabel(BuildContext context, SupporterTier tier) {
    switch (tier) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final amount = useState(_boostPresets[1]);
    final mySupport = ref.watch(mySupportProvider(artistId)).valueOrNull;
    final rank = mySupport?.rank;
    final tierLabel =
        mySupport == null ? "" : _tierLabel(context, mySupport.tier);
    return AlertDialog(
      title: Text(context.l10n.boost_dialog_title(artistName)).large(),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.boost_dialog_body).muted().small(),
            if (rank != null) ...[
              const Gap(8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(DeeMusiqIcons.trophy,
                      size: 14, color: deeMusiqOrange),
                  const Gap(6),
                  Flexible(
                    child: Text(
                      tierLabel.isEmpty
                          ? context.l10n.supporter_status_rank_only(rank)
                          : context.l10n
                              .supporter_status_line(rank, tierLabel),
                    ).small(),
                  ),
                ],
              ),
            ],
            const Gap(12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in _boostPresets)
                  Chip(
                    style: p == amount.value
                        ? ButtonVariance.primary
                        : ButtonVariance.outline,
                    onPressed: () => amount.value = p,
                    child: Text("$p"),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Button.outline(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        Button.primary(
          onPressed: () => Navigator.pop(context, amount.value),
          child: Text(context.l10n.boost_amount(amount.value)),
        ),
      ],
    );
  }
}
