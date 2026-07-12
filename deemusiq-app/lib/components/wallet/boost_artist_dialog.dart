import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/provider/wallet/wallet_provider.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

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
    builder: (context) => _BoostDialog(artistName: artistName),
  );
  if (tokens == null) return;
  try {
    await WalletApiClient.instance.boostArtist(artistId: artistId, tokens: tokens);
    await ref.read(walletProvider.notifier).syncFromBackend();
    if (context.mounted) {
      showWalletToast(
        context,
        "Boosted $artistName with $tokens tokens",
        icon: DeeMusiqIcons.boost,
      );
    }
  } on WalletApiException catch (e) {
    if (context.mounted) {
      showWalletToast(context, e.message, icon: DeeMusiqIcons.info);
    }
  } catch (e, stack) {
    AppLogger.reportError(e, stack, 'boostArtist');
    if (context.mounted) {
      showWalletToast(context, "Couldn't boost right now", icon: DeeMusiqIcons.info);
    }
  }
}

class _BoostDialog extends HookWidget {
  final String artistName;
  const _BoostDialog({required this.artistName});

  @override
  Widget build(BuildContext context) {
    final amount = useState(_boostPresets[1]);
    return AlertDialog(
      title: Text("Boost $artistName").large(),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Spend tokens to move this artist up the yearly leaderboard.",
            ).muted().small(),
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
          child: const Text("Cancel"),
        ),
        Button.primary(
          onPressed: () => Navigator.pop(context, amount.value),
          child: Text("Boost ${amount.value}"),
        ),
      ],
    );
  }
}
