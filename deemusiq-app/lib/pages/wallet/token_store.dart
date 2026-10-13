import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/titlebar/titlebar.dart';
import 'package:deemusiq/components/wallet/purchase_dialog.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/models/wallet/region_pricing.dart';
import 'package:deemusiq/models/wallet/token_pack.dart';
import 'package:deemusiq/provider/wallet/region_provider.dart';
import 'package:deemusiq/provider/wallet/server_pricing_provider.dart';
import 'package:deemusiq/provider/wallet/wallet_provider.dart';
import 'package:deemusiq/services/wallet/payment_service.dart'
    show PaymentGatewayConfig;

@RoutePage()
class TokenStorePage extends HookConsumerWidget {
  static const name = "token-store";

  const TokenStorePage({super.key});

  Future<void> _pickRegion(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.choose_your_region).large(),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(context.l10n.store_region_body).muted().small(),
                const Gap(12),
                ...RegionTier.all.map(
                  (tier) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Button.outline(
                      onPressed: () {
                        ref
                            .read(walletProvider.notifier)
                            .setRegionOverride(tier.code);
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Expanded(child: Text(tier.label)),
                          Text(tier.currencyCode).muted().small(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Button.outline(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.close),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final region = ref.watch(regionTierProvider);
    final balance = ref.watch(walletProvider.select((s) => s.balance));
    // Server-authoritative packs/prices when the backend answers; null (and
    // thus the local RegionTier math) while loading, offline or on any error.
    final serverPacks = ref.watch(serverPricingProvider).valueOrNull;

    return SafeArea(
      bottom: false,
      child: Scaffold(
        headers: [
          TitleBar(title: Text(context.l10n.wallet_token_store)),
        ],
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(DeeMusiqIcons.token,
                              color: deeMusiqOrange),
                          const Gap(10),
                          Expanded(
                            child: Text(
                              context.l10n.token_balance(formatTokens(balance)),
                            ).semiBold(),
                          ),
                          Button.ghost(
                            leading: const Icon(DeeMusiqIcons.region, size: 16),
                            onPressed: PaymentGatewayConfig.paymentsZaOnly
                                ? () => showWalletToast(
                                      context,
                                      context.l10n.store_za_only,
                                      icon: DeeMusiqIcons.region,
                                    )
                                : () => _pickRegion(context, ref),
                            child: Text(region.currencyCode),
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),
                    Text(
                      context.l10n.store_prices_for(region.label),
                    ).muted().small(),
                    const Gap(16),
                    if (serverPacks != null)
                      for (final priced in serverPacks)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PackCard(
                            pack: priced.pack,
                            region: region,
                            priceLabel: priced.priceLabel,
                            zeroDecimal: priced.zeroDecimal,
                          ),
                        )
                    else
                      for (final pack in TokenPack.all)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PackCard(pack: pack, region: region),
                        ),
                    const Gap(12),
                    Card(
                      filled: true,
                      fillColor: context.theme.colorScheme.muted,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(DeeMusiqIcons.creditCard, size: 16),
                              const Gap(8),
                              Text(context.l10n.store_payment_methods_title)
                                  .semiBold(),
                            ],
                          ),
                          const Gap(6),
                          Text(context.l10n.store_payment_methods_body)
                              .muted()
                              .small(),
                        ],
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
}

class _PackCard extends StatelessWidget {
  /// Edge length of the token icon tile. Fixed so every pack's artwork matches.
  static const double _iconExtent = 52;

  /// Card padding, mirrored from the [Card] call below.
  static const double _cardPadding = 16;

  /// Tallest card we can build without the text column exceeding the icon: one
  /// title line plus a two-line subtitle. Everything below is clamped to fit,
  /// so a floor (never a hard height) keeps all packs the same size while still
  /// growing gracefully under a large accessibility text scale.
  static const double _minHeight = _iconExtent + _cardPadding * 2;

  /// Shared width for the price button so the column lines up across packs;
  /// long localised prices still grow past it rather than truncating.
  static const double _priceButtonWidth = 88;

  final TokenPack pack;
  final RegionTier region;

  /// Server-formatted price (e.g. "R59.00"). Null = price locally.
  final String? priceLabel;

  /// Server-declared zero-decimal currency flag, threaded through so the
  /// fallback formatting agrees with the server rather than a local list.
  final bool zeroDecimal;

  const _PackCard({
    required this.pack,
    required this.region,
    this.priceLabel,
    this.zeroDecimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _minHeight),
      child: Card(
        borderColor: pack.popular ? deeMusiqOrange : null,
        padding: const EdgeInsets.all(_cardPadding),
        child: Row(
          children: [
            Container(
              width: _iconExtent,
              height: _iconExtent,
              decoration: BoxDecoration(
                color: deeMusiqOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(DeeMusiqIcons.token,
                  color: deeMusiqOrange, size: 26),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          context.l10n.store_pack_tokens(
                              formatTokens(pack.totalTokens)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ).semiBold(),
                      ),
                      if (pack.popular) ...[
                        const Gap(8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: deeMusiqOrange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            context.l10n.store_popular,
                            style: const TextStyle(
                                color: Color(0xFFFFFFFF), fontSize: 11),
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Clamped to two lines: pack labels and the bonus string are
                  // locale-dependent and otherwise push some cards taller than
                  // others, which is the ragged sizing this floor hides.
                  Text(
                    pack.bonusTokens > 0
                        ? context.l10n.store_pack_bonus(
                            pack.label, pack.tokens, pack.bonusTokens)
                        : pack.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ).muted().xSmall(),
                ],
              ),
            ),
            const Gap(12),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: _priceButtonWidth),
              child: Button.primary(
                onPressed: () => showPurchaseTokensDialog(context, pack: pack),
                child: Text(
                  priceLabel ??
                      region.formatPrice(pack.basePriceZar,
                          zeroDecimal: zeroDecimal),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
