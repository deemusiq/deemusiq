import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:deemusiq/collections/fake.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/fallbacks/async_value_widget.dart';
import 'package:deemusiq/components/image/universal_image.dart';
import 'package:deemusiq/components/titlebar/titlebar.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/metadata_plugin/core/user.dart';
import 'package:deemusiq/provider/wallet/wallet_provider.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/collections/routes.gr.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class ProfilePage extends HookConsumerWidget {
  static const name = "profile";

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final me = ref.watch(metadataPluginUserProvider);

    final walletBalance = ref.watch(walletProvider.select((s) => s.balance));
    final linkedCount =
        ref.watch(walletProvider.select((s) => s.linkedAccounts.length));

    return SafeArea(
      child: Scaffold(
        headers: [
          TitleBar(
            title: Text(context.l10n.profile),
          )
        ],
        child: AsyncValueWidget(
          value: me,
          onRetry: () => ref.invalidate(metadataPluginUserProvider),
          builder: (meOrNull) {
            // FakeData is skeleton-only: an error takes the ErrorBox branch
            // in AsyncValueWidget and never renders a fabricated profile.
            final meData = meOrNull ?? FakeData.user;
            return Skeletonizer(
              enabled: me.isLoading,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(600),
                          child: UniversalImage(
                            path: meData.images.asUrlString(
                              index: 1,
                              placeholder: ImagePlaceholder.artist,
                            ),
                            width: 300,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SliverGap(10),
                  SliverToBoxAdapter(
                    child: Text(
                      meData.name,
                      textAlign: TextAlign.center,
                    ).h4(),
                  ),
                  const SliverGap(20),
                  SliverCrossAxisConstrained(
                    maxCrossAxisExtent: 500,
                    child: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Button.text(
                            leading: const Icon(DeeMusiqIcons.edit),
                            onPressed: () {
                              launchUrlString(
                                meData.externalUri,
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            child: Text(context.l10n.edit),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverCrossAxisConstrained(
                    maxCrossAxisExtent: 500,
                    child: SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Column(
                          children: [
                            _ProfileNavCard(
                              icon: DeeMusiqIcons.wallet,
                              title: context.l10n.wallet,
                              subtitle: context.l10n.store_pack_tokens(
                                  formatTokens(walletBalance)),
                              onPressed: () =>
                                  context.navigateTo(const WalletRoute()),
                            ),
                            const Gap(8),
                            _ProfileNavCard(
                              icon: DeeMusiqIcons.connect,
                              title: context.l10n.wallet_linked_accounts,
                              subtitle: linkedCount == 0
                                  ? context.l10n.profile_linked_connect_hint
                                  : context.l10n
                                      .wallet_linked_connected(linkedCount),
                              onPressed: () => context
                                  .navigateTo(const LinkedAccountsRoute()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SliverGap(200),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileNavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  const _ProfileNavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: EdgeInsets.zero,
      child: Button.ghost(
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: deeMusiqOrange),
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
              const Icon(DeeMusiqIcons.angleRight, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
