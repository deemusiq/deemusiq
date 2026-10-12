import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:deemusiq/collections/routes.gr.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/image/universal_image.dart';
import 'package:deemusiq/components/titlebar/titlebar.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/models/wallet/supported_creator.dart';
import 'package:deemusiq/provider/wallet/wallet_provider.dart';
import 'package:deemusiq/services/logger/logger.dart';

const _supportPresets = [5, 10, 25, 50];

@RoutePage()
class CreatorsSupportedPage extends HookConsumerWidget {
  static const name = "creators-supported";

  const CreatorsSupportedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creators =
        ref.watch(walletProvider.select((s) => s.supportedCreators));
    final totalToCreators =
        creators.fold<int>(0, (sum, c) => sum + c.totalTokens);
    // The share bars below divide by the top supporter's total — clamp so a
    // creator list whose best total is 0 can't produce a NaN widthFactor.
    final topTokens =
        creators.isEmpty ? 1 : math.max(1, creators.first.totalTokens);

    return SafeArea(
      bottom: false,
      child: Scaffold(
        headers: [
          TitleBar(title: Text(context.l10n.wallet_creators_supported)),
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
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          _stat("$totalToCreators",
                              context.l10n.supported_tokens_given),
                          const Gap(24),
                          _stat("${creators.length}",
                              context.l10n.supported_creators_backed),
                        ],
                      ),
                    ),
                    const Gap(16),
                    if (creators.isEmpty)
                      Card(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(DeeMusiqIcons.heart,
                                size: 32, color: deeMusiqOrange),
                            const Gap(10),
                            Text(context.l10n.supported_empty_title).semiBold(),
                            const Gap(4),
                            Text(
                              context.l10n.supported_empty_body,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      for (final creator in creators)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _CreatorTile(
                            creator: creator,
                            share: creator.totalTokens / topTokens,
                          ),
                        ),
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

  Widget _stat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value).h3(),
        Text(label).muted().small(),
      ],
    );
  }
}

class _CreatorTile extends ConsumerWidget {
  final SupportedCreator creator;
  final double share;

  const _CreatorTile({required this.creator, required this.share});

  Future<void> _support(BuildContext context, WidgetRef ref) async {
    final tokens = await showDialog<int>(
      context: context,
      builder: (context) => _SupportDialog(creator: creator),
    );
    if (tokens == null) return;
    bool ok;
    try {
      ok = await ref.read(walletProvider.notifier).supportCreator(
            creatorId: creator.id,
            name: creator.name,
            imageUrl: creator.imageUrl,
            tokens: tokens,
          );
    } catch (e, stack) {
      // Non-API failures (e.g. local persistence) escape supportCreator —
      // surface them instead of throwing into the button handler.
      AppLogger.reportError(e, stack, 'CreatorsSupported.support');
      ok = false;
    }
    if (context.mounted) {
      // Online failures (backend refused / unreachable) set lastActionError;
      // otherwise the spend was blocked by the local balance check.
      final reason = ref.read(walletProvider.notifier).lastActionError;
      showWalletToast(
        context,
        ok
            ? context.l10n.supported_sent(tokens, creator.name)
            : reason ?? context.l10n.supported_send_failed,
        icon: DeeMusiqIcons.heart,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: creator.imageUrl != null
                    ? UniversalImage(
                        path: creator.imageUrl!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 44,
                        height: 44,
                        color: deeMusiqOrange.withValues(alpha: 0.15),
                        child: const Icon(DeeMusiqIcons.artist,
                            color: deeMusiqOrange),
                      ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(creator.name).semiBold(),
                    Text(
                      context.l10n.supported_contributions(
                          creator.contributions,
                          relativeTime(
                              context.l10n, creator.lastSupportedAt)),
                    ).muted().xSmall(),
                  ],
                ),
              ),
              const Gap(8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatTokens(creator.totalTokens),
                    style: const TextStyle(
                      color: deeMusiqOrange,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Text(context.l10n.tokens_label).muted().xSmall(),
                ],
              ),
            ],
          ),
          const Gap(10),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: context.theme.colorScheme.muted,
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: share.clamp(0.04, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: deeMusiqOrange,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const Gap(8),
          Align(
            alignment: Alignment.centerRight,
            child: Button.ghost(
              leading: const Icon(DeeMusiqIcons.heart, size: 14),
              onPressed: () => _support(context, ref),
              child: Text(context.l10n.supported_support_more),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportDialog extends HookConsumerWidget {
  final SupportedCreator creator;
  const _SupportDialog({required this.creator});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(walletProvider.select((s) => s.balance));
    final amount = useState(_supportPresets[1]);
    final canAfford = balance >= amount.value;
    return AlertDialog(
      title: Text(context.l10n.supported_dialog_title(creator.name)).large(),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.supported_dialog_body).muted().small(),
            const Gap(12),
            Row(
              children: [
                const Icon(DeeMusiqIcons.token,
                    color: deeMusiqOrange, size: 16),
                const Gap(6),
                Text(context.l10n.token_balance(formatTokens(balance))).small(),
              ],
            ),
            const Gap(12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in _supportPresets)
                  Chip(
                    style: p == amount.value
                        ? ButtonVariance.primary
                        : ButtonVariance.outline,
                    onPressed: () => amount.value = p,
                    child: Text("$p"),
                  ),
              ],
            ),
            if (!canAfford) ...[
              const Gap(12),
              Text(
                context.l10n.supported_need_more(amount.value - balance),
                style: TextStyle(
                  color: context.theme.colorScheme.destructive,
                ),
              ).small(),
            ],
          ],
        ),
      ),
      actions: [
        Button.outline(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        if (!canAfford)
          Button.secondary(
            onPressed: () {
              Navigator.pop(context);
              context.navigateTo(const TokenStoreRoute());
            },
            child: Text(context.l10n.get_tokens),
          ),
        Button.primary(
          onPressed:
              canAfford ? () => Navigator.pop(context, amount.value) : null,
          child: Text(context.l10n.supported_send_amount(amount.value)),
        ),
      ],
    );
  }
}
