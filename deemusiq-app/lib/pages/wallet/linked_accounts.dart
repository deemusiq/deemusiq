import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/titlebar/titlebar.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/models/wallet/linked_account.dart';
import 'package:deemusiq/provider/wallet/wallet_provider.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:url_launcher/url_launcher_string.dart';

@RoutePage()
class LinkedAccountsPage extends HookConsumerWidget {
  static const name = "linked-accounts";

  const LinkedAccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(walletProvider.select((s) => s.linkedAccounts));
    final byProvider = {for (final a in accounts) a.provider: a};
    final backendConfigured = WalletApiClient.instance.isConfigured;

    return SafeArea(
      bottom: false,
      child: Scaffold(
        headers: [
          TitleBar(title: Text(context.l10n.wallet_linked_accounts)),
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
                      filled: true,
                      fillColor: context.theme.colorScheme.muted,
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        backendConfigured
                            ? context.l10n.linked_connect_body
                            : context.l10n.linked_offline_body,
                      ).small(),
                    ),
                    const Gap(16),
                    // DeeMusiq is standalone — external music services are not
                    // link targets. Google is the only identity provider
                    // offered (backend `linking.ts` supports it). A non-Google
                    // row only renders when that account is ALREADY linked, so
                    // a legacy link can still be disconnected — never connected.
                    for (final provider in LinkedProvider.values)
                      if (provider == LinkedProvider.google ||
                          byProvider[provider] != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ProviderTile(
                            provider: provider,
                            account: byProvider[provider],
                            backendConfigured: backendConfigured,
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

class _ProviderTile extends HookConsumerWidget {
  final LinkedProvider provider;
  final LinkedAccount? account;
  final bool backendConfigured;

  const _ProviderTile({
    required this.provider,
    required this.backendConfigured,
    this.account,
  });

  /// Starts the real OAuth flow: the backend returns an authorize URL that we
  /// open in the external browser. The provider redirects back through the
  /// backend, which deep-links into the app (`deemusiq://link`) — the
  /// deep-link handler (see use_deep_linking.dart) then re-syncs the
  /// authoritative linked-accounts list.
  Future<void> _connect(BuildContext context, WidgetRef ref) async {
    try {
      final url = await WalletApiClient.instance.startLinking(provider.name);
      final opened =
          await launchUrlString(url, mode: LaunchMode.externalApplication);
      if (context.mounted) {
        showWalletToast(
          context,
          opened
              ? context.l10n.linked_finish_browser(provider.label)
              : context.l10n.linked_browser_failed,
          icon: provider.icon,
        );
      }
    } on WalletApiException catch (e) {
      if (!context.mounted) return;
      showWalletToast(
        context,
        // The backend's `provider_not_configured` means the operator hasn't
        // enabled this provider — linking itself IS implemented.
        e.code == 'provider_not_configured'
            ? context.l10n.linked_provider_not_enabled
            : e.friendlyMessage,
        icon: DeeMusiqIcons.info,
      );
    } catch (e) {
      AppLogger.log.w('Linked accounts load failed: ${e.toString()}');
      if (!context.mounted) return;
      showWalletToast(context, context.l10n.linked_load_failed,
          icon: DeeMusiqIcons.info);
    }
  }

  Future<void> _disconnect(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(walletProvider.notifier).unlinkAccount(provider);
      if (context.mounted) {
        showWalletToast(context, context.l10n.linked_disconnected(provider.label),
            icon: provider.icon);
      }
    } on WalletApiException catch (e) {
      if (context.mounted) {
        showWalletToast(context, e.friendlyMessage, icon: DeeMusiqIcons.info);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connected = account != null;
    // Double-taps (or a slow OAuth round-trip) must not fire the action twice.
    final busy = useState(false);

    Future<void> guard(Future<void> Function() action) async {
      if (busy.value) return;
      busy.value = true;
      try {
        await action();
      } finally {
        if (context.mounted) busy.value = false;
      }
    }
    return Card(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: provider.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(provider.icon, color: provider.accent),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(provider.label).semiBold(),
                    if (connected) ...[
                      const Gap(6),
                      const Icon(DeeMusiqIcons.verified,
                          size: 14, color: Color(0xFF2E7D32)),
                    ],
                  ],
                ),
                Text(
                  connected
                      ? context.l10n.linked_connected_as(account!.displayName)
                      : provider.description,
                ).muted().xSmall(),
              ],
            ),
          ),
          const Gap(10),
          if (connected)
            Button.outline(
              onPressed:
                  busy.value ? null : () => guard(() => _disconnect(context, ref)),
              child: Text(busy.value
                  ? context.l10n.linked_disconnecting
                  : context.l10n.disconnect),
            )
          else
            Button.primary(
              onPressed: backendConfigured && !busy.value
                  ? () => guard(() => _connect(context, ref))
                  : null,
              child: Text(busy.value
                  ? context.l10n.linked_connecting
                  : context.l10n.connect),
            ),
        ],
      ),
    );
  }
}
