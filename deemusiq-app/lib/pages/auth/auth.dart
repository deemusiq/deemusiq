import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/collections/routes.gr.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/models/wallet/linked_account.dart';
import 'package:deemusiq/provider/wallet/wallet_provider.dart';
import 'package:deemusiq/services/auth/google_auth.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/l10n/l10n.dart';
import 'package:deemusiq/services/logger/logger.dart';

@RoutePage(name: "auth")
class AuthPage extends HookConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ageVerified = useState(false);
    final privacyConsent = useState(false);
    final loading = useState(false);
    final theme = Theme.of(context);

    Future<void> handleSignIn({required bool google}) async {
      final l10n = AppLocalizations.of(context)!;
      if (loading.value) return;
      if (!ageVerified.value) {
        showWalletToast(context, l10n.must_confirm_age,
            icon: DeeMusiqIcons.error);
        return;
      }
      if (!privacyConsent.value) {
        showWalletToast(context, l10n.must_agree_privacy_policy,
            icon: DeeMusiqIcons.error);
        return;
      }
      loading.value = true;
      try {
        await KVStoreService.setAgeVerified(true);
        await KVStoreService.setPrivacyConsentGiven(true);

        if (google) {
          final result = await GoogleAuthService.instance.signIn();
          // Only record a Google link when the full OAuth flow ran — the
          // device-based fallback has no Google profile to link.
          if (result.displayName != null || result.email != null) {
            await ref.read(walletProvider.notifier).linkAccount(
                  LinkedProvider.google,
                  displayName:
                      result.displayName ?? result.email ?? 'Google User',
                  externalId: result.email,
                );
          }
        }

        await KVStoreService.setDoneGettingStarted(true);

        try {
          await ref.read(walletProvider.notifier).syncFromBackend();
        } catch (e) {
          AppLogger.log.w('AuthPage: wallet sync failed: $e');
          if (context.mounted) {
            showWalletToast(context, AppLocalizations.of(context)!.wallet_sync_failed_retry,
                icon: DeeMusiqIcons.error);
          }
        }

        if (context.mounted) {
          context.router.replaceAll([const HomeRoute()]);
        }
      } on Exception catch (e) {
        if (context.mounted) {
          showWalletToast(context, e.toString(), icon: DeeMusiqIcons.error);
        }
      } finally {
        loading.value = false;
      }
    }

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Gap(48),
                  Text(
                    "DeeMusiq",
                    style: TextStyle(
                      fontFamily: "Cookie",
                      fontSize: 52,
                      letterSpacing: 2,
                      color: theme.colorScheme.foreground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(4),
                  Text(l10n.its_a_drop_day)
                      .muted()
                      .semiBold()
                      .center(),
                  const Gap(32),
                  Row(
                    children: [
                      Checkbox(
                        state: ageVerified.value ? CheckboxState.checked : CheckboxState.unchecked,
                        onChanged: (v) => ageVerified.value = v == CheckboxState.checked,
                      ),
                      const Gap(8),
                      Expanded(
                        child: TextButton(
                          onPressed: () =>
                              ageVerified.value = !ageVerified.value,
                          child: Text(l10n.confirm_age_18).muted(),
                        ),
                      ),
                    ],
                  ),
                  const Gap(4),
                  Row(
                    children: [
                      Checkbox(
                        state: privacyConsent.value ? CheckboxState.checked : CheckboxState.unchecked,
                        onChanged: (v) => privacyConsent.value = v == CheckboxState.checked,
                      ),
                      const Gap(8),
                      Expanded(
                        child: TextButton(
                          onPressed: () =>
                              privacyConsent.value = !privacyConsent.value,
                          child: Text(l10n.agree_privacy_policy)
                              .muted(),
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),
                  if (loading.value)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    Button.primary(
                      onPressed: () => handleSignIn(google: true),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(DeeMusiqIcons.google,
                              size: 18),
                          const Gap(8),
                          Text(l10n.sign_in_with_google),
                        ],
                      ),
                    ),
                    const Gap(8),
                    Button.outline(
                      onPressed: () => handleSignIn(google: false),
                      child: Text(l10n.continue_with_device_limited),
                    ),
                  ],
                  const Gap(48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
