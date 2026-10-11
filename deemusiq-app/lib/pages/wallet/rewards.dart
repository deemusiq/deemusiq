import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/titlebar/titlebar.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/provider/wallet/rewards_provider.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

@RoutePage()
class RewardsPage extends ConsumerWidget {
  static const name = "rewards";

  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(rewardsStatusProvider);

    return SafeArea(
      bottom: false,
      child: Scaffold(
        headers: [
          TitleBar(title: Text(context.l10n.rewards_title)),
        ],
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: status.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => _ErrorCard(
                    error: error,
                    onRetry: () => ref.invalidate(rewardsStatusProvider),
                  ),
                  // Null = feature off / endpoint absent / signed out — the
                  // nav entry hides too, so this is only reachable from a
                  // stale route; render the explainer without numbers.
                  data: (value) => value == null
                      ? const _ExplainerCard(status: null)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Card(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.l10n.rewards_earned_today(
                                        value.earnedToday, value.dailyCap),
                                  ).semiBold(),
                                  const Gap(4),
                                  Text(
                                    context.l10n.rewards_lifetime(
                                        value.lifetimeEarned),
                                  ).muted().small(),
                                ],
                              ),
                            ),
                            const Gap(16),
                            _ExplainerCard(status: value),
                            const Gap(40),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExplainerCard extends StatelessWidget {
  final RewardsStatus? status;
  const _ExplainerCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final status = this.status;
    return Card(
      filled: true,
      fillColor: context.theme.colorScheme.muted,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(DeeMusiqIcons.gift, color: deeMusiqOrange),
              const Gap(10),
              Expanded(child: Text(context.l10n.rewards_explainer)),
            ],
          ),
          if (status != null) ...[
            const Gap(10),
            Text(context.l10n.rewards_per_play(status.perPlay)).muted().small(),
            if (status.newAccountTaper) ...[
              const Gap(6),
              Row(
                children: [
                  const Icon(DeeMusiqIcons.info,
                      size: 14, color: deeMusiqOrange),
                  const Gap(6),
                  Expanded(
                    child: Text(context.l10n.rewards_taper_notice).small(),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const _ErrorCard({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final error = this.error;
    return Card(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(DeeMusiqIcons.info, size: 28, color: deeMusiqOrange),
          const Gap(10),
          Text(context.l10n.rewards_load_failed).semiBold(),
          const Gap(4),
          Text(
            error is WalletApiException
                ? error.friendlyMessage
                : error.toString(),
            textAlign: TextAlign.center,
          ).muted().small(),
          const Gap(12),
          Button.outline(
            onPressed: onRetry,
            child: Text(context.l10n.retry),
          ),
        ],
      ),
    );
  }
}
