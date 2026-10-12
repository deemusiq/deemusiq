import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:deemusiq/collections/routes.gr.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/titlebar/titlebar.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/models/wallet/token_transaction.dart';
import 'package:deemusiq/provider/wallet/region_provider.dart';
import 'package:deemusiq/provider/wallet/rewards_provider.dart';
import 'package:deemusiq/provider/wallet/wallet_provider.dart';
import 'package:deemusiq/services/integrity/integrity_service.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

@RoutePage()
class WalletPage extends HookConsumerWidget {
  static const name = "wallet";

  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final region = ref.watch(regionTierProvider);

    // Full-screen spinner only while the first sync after opening the page is
    // in flight, and never longer than a few seconds: the sync itself keeps
    // running in the background and failures surface in the banner below
    // (wallet.syncError) while the persisted local state renders immediately.
    final initialSync = useState(WalletApiClient.instance.isConfigured);
    final retrying = useState(false);

    useEffect(() {
      if (!initialSync.value) return null;
      var cancelled = false;
      () async {
        await ref.read(walletProvider.notifier).syncFromBackend().timeout(
              const Duration(seconds: 3),
              onTimeout: () {},
            );
        if (!cancelled) initialSync.value = false;
      }();
      return () => cancelled = true;
    }, const []);

    Future<void> retrySync() async {
      if (retrying.value) return;
      retrying.value = true;
      try {
        await ref.read(walletProvider.notifier).syncFromBackend();
      } finally {
        if (context.mounted) retrying.value = false;
      }
    }

    if (initialSync.value) {
      return const SafeArea(
        bottom: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final showAllActivity = useState(false);
    final recent = showAllActivity.value
        ? wallet.transactions
        : wallet.transactions.take(8).toList();

    return SafeArea(
      bottom: false,
      child: Scaffold(
        headers: [
          TitleBar(title: Text(context.l10n.wallet)),
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
                    const _IntegrityBanner(),
                    if (wallet.syncError != null) ...[
                      _SyncErrorBanner(
                        message: wallet.syncError!,
                        retrying: retrying.value,
                        onRetry: retrySync,
                      ),
                      const Gap(12),
                    ],
                    _BalanceHero(
                      balance: wallet.balance,
                      regionLabel: region.label,
                    ),
                    const Gap(16),
                    _QuickActions(linkedCount: wallet.linkedAccounts.length),
                    const Gap(20),
                    const _RewardsSummary(),
                    Row(
                      children: [
                        Expanded(
                            child: Text(context.l10n.wallet_recent_activity)
                                .large()),
                        if (wallet.transactions.isNotEmpty)
                          Text(
                            context.l10n.wallet_activity_totals(
                                wallet.totalPurchased, wallet.totalSpent),
                          ).muted().small(),
                        if (wallet.transactions.length > 8) ...[
                          const Gap(8),
                          Button.ghost(
                            onPressed: () => showAllActivity.value =
                                !showAllActivity.value,
                            child: Text(
                              showAllActivity.value
                                  ? context.l10n.wallet_show_less
                                  : context.l10n.wallet_see_all,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Gap(8),
                    if (recent.isEmpty)
                      _EmptyActivity(
                        onBuy: () =>
                            context.navigateTo(const TokenStoreRoute()),
                      )
                    else
                      ...recent.map((tx) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _ActivityTile(tx: tx),
                          )),
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

/// Shown when the last backend sync failed (wallet.syncError). Local wallet
/// state keeps rendering underneath; retry re-runs the sync, which clears the
/// error on success.
class _SyncErrorBanner extends StatelessWidget {
  final String message;
  final bool retrying;
  final VoidCallback onRetry;
  const _SyncErrorBanner({
    required this.message,
    required this.retrying,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFF59E0B);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: amber),
      ),
      child: Row(
        children: [
          const Icon(DeeMusiqIcons.info, color: amber),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n.wallet_refresh_failed).semiBold().small(),
                Text(message).muted().xSmall(),
              ],
            ),
          ),
          const Gap(8),
          Button.outline(
            onPressed: retrying ? null : onRetry,
            child: Text(retrying
                ? context.l10n.wallet_retrying
                : context.l10n.retry),
          ),
        ],
      ),
    );
  }
}

class _BalanceHero extends StatelessWidget {
  final int balance;
  final String regionLabel;
  const _BalanceHero({required this.balance, required this.regionLabel});

  static const _white = Color(0xFFFFFFFF);
  static const _deep = Color(0xFFE64A19);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF7043), _deep],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(DeeMusiqIcons.token, color: _white, size: 18),
              const Gap(8),
              Text(context.l10n.wallet_tokens_title,
                  style: const TextStyle(color: _white)),
            ],
          ),
          const Gap(10),
          Text(
            formatTokens(balance),
            style: const TextStyle(
              color: _white,
              fontSize: 44,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            context.l10n.wallet_prices_region(regionLabel),
            style: TextStyle(color: _white.withValues(alpha: 0.85)),
          ).small(),
          const Gap(16),
          Row(
            children: [
              Card(
                filled: true,
                fillColor: _white,
                borderColor: _white,
                padding: EdgeInsets.zero,
                child: Button.ghost(
                  onPressed: () =>
                      context.navigateTo(const TokenStoreRoute()),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(DeeMusiqIcons.add, color: _deep, size: 16),
                        const Gap(6),
                        Text(
                          context.l10n.wallet_buy_tokens,
                          style: const TextStyle(
                            color: _deep,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Gap(10),
              Button.ghost(
                onPressed: () =>
                    context.navigateTo(const PushLeaderboardRoute()),
                child: Text(context.l10n.wallet_trending,
                    style: const TextStyle(color: _white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final int linkedCount;
  const _QuickActions({required this.linkedCount});

  @override
  Widget build(BuildContext context) {
    final actions = <(IconData, String, String, PageRouteInfo)>[
      (
        DeeMusiqIcons.shoppingBag,
        context.l10n.wallet_token_store,
        context.l10n.wallet_token_store_sub,
        const TokenStoreRoute()
      ),
      (
        DeeMusiqIcons.connect,
        context.l10n.wallet_linked_accounts,
        linkedCount == 0
            ? context.l10n.wallet_linked_connect
            : context.l10n.wallet_linked_connected(linkedCount),
        const LinkedAccountsRoute()
      ),
      (
        DeeMusiqIcons.shield,
        context.l10n.account_security,
        context.l10n.wallet_security_sub,
        const AccountRoute()
      ),
      (
        DeeMusiqIcons.heart,
        context.l10n.wallet_creators_supported,
        context.l10n.wallet_creators_sub,
        const CreatorsSupportedRoute()
      ),
      (
        DeeMusiqIcons.trophy,
        context.l10n.wallet_trending_pushes,
        context.l10n.wallet_pushes_sub,
        const PushLeaderboardRoute()
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final (icon, title, subtitle, route) in actions)
          SizedBox(
            width: 224,
            child: Card(
              padding: EdgeInsets.zero,
              child: Button.ghost(
                onPressed: () => context.navigateTo(route),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: deeMusiqOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: deeMusiqOrange, size: 18),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(title).semiBold(),
                            Text(subtitle).muted().xSmall(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final TokenTransaction tx;
  const _ActivityTile({required this.tx});

  IconData get _icon {
    switch (tx.type) {
      case TokenTransactionType.topUp:
        return DeeMusiqIcons.creditCard;
      case TokenTransactionType.push:
        return DeeMusiqIcons.boost;
      case TokenTransactionType.support:
        return DeeMusiqIcons.heart;
      case TokenTransactionType.bonus:
        return DeeMusiqIcons.gift;
      case TokenTransactionType.refund:
        return DeeMusiqIcons.refresh;
    }
  }

  @override
  Widget build(BuildContext context) {
    final credit = tx.tokens >= 0;
    final color = credit
        ? const Color(0xFF2E7D32)
        : context.theme.colorScheme.foreground;
    return Card(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(_icon, size: 18, color: deeMusiqOrange),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tx.description).semiBold(),
                Text("${tx.type.label} · ${relativeTime(context.l10n, tx.timestamp)}")
                    .muted()
                    .xSmall(),
              ],
            ),
          ),
          const Gap(8),
          Text(
            "${credit ? "+" : ""}${formatTokens(tx.tokens)}",
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  final VoidCallback onBuy;
  const _EmptyActivity({required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(DeeMusiqIcons.token, size: 32, color: deeMusiqOrange),
          const Gap(10),
          Text(context.l10n.wallet_no_activity).semiBold(),
          const Gap(4),
          Text(
            context.l10n.wallet_no_activity_body,
            textAlign: TextAlign.center,
          ).muted().small(),
          const Gap(14),
          Button.primary(
            leading: const Icon(DeeMusiqIcons.add),
            onPressed: onBuy,
            child: Text(context.l10n.wallet_buy_first),
          ),
        ],
      ),
    );
  }
}

/// Compact earn-to-listen summary. Hidden unless the backend has the feature
/// enabled for this account — the provider folds unconfigured, disabled,
/// absent (404) and signed-out (401) to null, so this widget renders nothing
/// in all of those cases. Loading shows a slim spinner card (leaderboard
/// idiom); errors offer a retry without taking the wallet page down.
class _RewardsSummary extends ConsumerWidget {
  const _RewardsSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(rewardsStatusProvider);
    return status.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Card(
          padding: EdgeInsets.all(14),
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Card(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(DeeMusiqIcons.info, color: deeMusiqOrange, size: 18),
              const Gap(10),
              Expanded(
                child: Text(context.l10n.rewards_load_failed).muted().small(),
              ),
              Button.ghost(
                onPressed: () => ref.invalidate(rewardsStatusProvider),
                child: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
      ),
      data: (value) {
        if (value == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Card(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(DeeMusiqIcons.gift,
                        color: deeMusiqOrange, size: 18),
                    const Gap(8),
                    Expanded(
                      child: Text(context.l10n.rewards_title).semiBold(),
                    ),
                    Button.ghost(
                      onPressed: () =>
                          context.navigateTo(const RewardsRoute()),
                      child: Text(context.l10n.rewards_details),
                    ),
                  ],
                ),
                const Gap(6),
                Text(
                  context.l10n
                      .rewards_earned_today(value.earnedToday, value.dailyCap),
                ).small(),
                Text(
                  context.l10n.rewards_lifetime(value.lifetimeEarned),
                ).muted().xSmall(),
                const Gap(6),
                Text(context.l10n.rewards_explainer).muted().xSmall(),
                if (value.newAccountTaper) ...[
                  const Gap(4),
                  Text(context.l10n.rewards_taper_notice).muted().xSmall(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Warns the user (and disables purchases) when the integrity monitor has
/// flagged a tampered/repackaged build. Hidden when everything checks out.
class _IntegrityBanner extends StatelessWidget {
  const _IntegrityBanner();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<IntegrityVerdict>(
      valueListenable: IntegrityService.instance.verdict,
      builder: (context, verdict, _) {
        if (verdict == IntegrityVerdict.ok) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFB3261E).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFB3261E)),
          ),
          child: Row(
            children: [
              const Icon(DeeMusiqIcons.shield, color: Color(0xFFB3261E)),
              const Gap(10),
              Expanded(
                child: Text(context.l10n.wallet_integrity_warning).small(),
              ),
            ],
          ),
        );
      },
    );
  }
}
