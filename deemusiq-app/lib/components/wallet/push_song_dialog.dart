import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:deemusiq/collections/routes.gr.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/provider/wallet/wallet_provider.dart';
import 'package:deemusiq/services/logger/logger.dart';

Future<void> showPushSongDialog(
  BuildContext context, {
  required String songId,
  required String title,
  required String artist,
  String? artistId,
  String? imageUrl,
}) {
  return showDialog(
    context: context,
    builder: (context) => PushSongDialog(
      songId: songId,
      title: title,
      artist: artist,
      artistId: artistId,
      imageUrl: imageUrl,
    ),
  );
}

const _presets = [5, 10, 25, 50, 100];

class PushSongDialog extends HookConsumerWidget {
  final String songId;
  final String title;
  final String artist;
  final String? artistId;
  final String? imageUrl;

  const PushSongDialog({
    super.key,
    required this.songId,
    required this.title,
    required this.artist,
    this.artistId,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(walletProvider.select((s) => s.balance));
    final amount = useState(_presets[1]);
    final canAfford = balance >= amount.value;
    final pushing = useState(false);

    Future<void> push() async {
      // In-flight guard: the Push button must not launch a second spend while
      // the first is still on the wire — two concurrent pushes debit twice.
      if (pushing.value) return;
      pushing.value = true;
      try {
        final ok = await ref.read(walletProvider.notifier).pushSong(
              songId: songId,
              title: title,
              artist: artist,
              artistId: artistId,
              imageUrl: imageUrl,
              tokens: amount.value,
            );
        if (!context.mounted) return;
        if (ok) {
          showWalletToast(
            context,
            context.l10n.push_success(title, amount.value),
            icon: DeeMusiqIcons.boost,
          );
          Navigator.pop(context);
        } else {
          // Online failures (backend refused / unreachable) set lastActionError;
          // otherwise the push was blocked by the local balance check.
          final reason = ref.read(walletProvider.notifier).lastActionError;
          showWalletToast(context, reason ?? context.l10n.push_not_enough);
        }
      } catch (e, stack) {
        AppLogger.reportError(e, stack, 'PushSongDialog.push');
        if (context.mounted) {
          showWalletToast(context, context.l10n.push_failed);
        }
      } finally {
        if (context.mounted) pushing.value = false;
      }
    }

    return AlertDialog(
      title: Row(
        children: [
          const Icon(DeeMusiqIcons.boost, color: deeMusiqOrange),
          const Gap(8),
          Expanded(child: Text(context.l10n.push_dialog_title).large()),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title).semiBold(),
            Text(artist).muted().small(),
            const Gap(16),
            Row(
              children: [
                const Icon(DeeMusiqIcons.token,
                    color: deeMusiqOrange, size: 16),
                const Gap(6),
                Text(context.l10n.token_balance(formatTokens(balance))).small(),
              ],
            ),
            const Gap(12),
            Text(context.l10n.push_how_many).muted().small(),
            const Gap(8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in _presets)
                  Chip(
                    style: p == amount.value
                        ? ButtonVariance.primary
                        : ButtonVariance.outline,
                    onPressed: () => amount.value = p,
                    child: Text("$p"),
                  ),
              ],
            ),
            const Gap(16),
            Card(
              filled: true,
              fillColor: context.theme.colorScheme.muted,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(DeeMusiqIcons.boost, size: 18),
                  const Gap(10),
                  Expanded(
                    child: Text(
                      context.l10n.push_explainer(artist == ""
                          ? context.l10n.push_the_artist
                          : artist),
                    ).muted().small(),
                  ),
                ],
              ),
            ),
            if (!canAfford) ...[
              const Gap(12),
              Text(
                context.l10n.push_need_more(amount.value - balance),
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
          onPressed: canAfford && !pushing.value ? push : null,
          child: Text(pushing.value
              ? context.l10n.push_pushing
              : context.l10n.push_amount(amount.value)),
        ),
      ],
    );
  }
}
