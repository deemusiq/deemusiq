import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, TextInputType;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide join;
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/titlebar/titlebar.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/provider/database/database.dart';
import 'package:deemusiq/provider/local_favorites/local_favorites_provider.dart';
import 'package:deemusiq/provider/wallet/wallet_provider.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';
import 'package:deemusiq/services/auth/google_auth.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/models/wallet/linked_account.dart';
import 'package:deemusiq/utils/platform.dart';

/// Account & security: email/password sign-in, 2FA (TOTP) enrollment, recovery,
/// and security actions. Drives the `WalletApiClient` auth endpoints. All of it
/// requires a configured backend; with none, the API calls surface a clear error.
@RoutePage()
class AccountPage extends HookConsumerWidget {
  static const name = "account";
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        headers: [TitleBar(title: Text(context.l10n.account_security))],
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _EmailPasswordCard(),
                    Gap(12),
                    _GoogleSignInCard(),
                    Gap(12),
                    _TotpCard(),
                    Gap(12),
                    _RecoveryCard(),
                    Gap(12),
                    _SecurityActionsCard(),
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

Future<void> _guard(
  BuildContext context,
  ValueNotifier<bool> loading,
  Future<void> Function() action,
  String successMessage,
) async {
  if (loading.value) return;
  loading.value = true;
  try {
    await action();
    if (context.mounted) showWalletToast(context, successMessage);
  } on WalletApiException catch (e) {
    if (context.mounted) {
      showWalletToast(context, e.message, icon: DeeMusiqIcons.error);
    }
  } catch (e) {
    AppLogger.log.w('Account op failed: ${e.toString()}');
    if (context.mounted) {
      showWalletToast(context, context.l10n.something_went_wrong,
          icon: DeeMusiqIcons.error);
    }
  } finally {
    if (context.mounted) loading.value = false;
  }
}

class _EmailPasswordCard extends HookConsumerWidget {
  const _EmailPasswordCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRegister = useState(true);
    final email = useTextEditingController();
    final password = useTextEditingController();
    final acceptedTerms = useState(false);
    final loading = useState(false);
    // Second factor: set when /auth/login answers with a challenge instead of
    // a session token (the account has 2FA enabled).
    final mfaToken = useState<String?>(null);
    final mfaCode = useTextEditingController();

    Future<void> verifyMfa() async {
      final challenge = mfaToken.value;
      if (challenge == null) return;
      loading.value = true;
      try {
        await WalletApiClient.instance.mfaVerify(
          mfaToken: challenge,
          code: mfaCode.text.trim(),
        );
        mfaCode.clear();
        mfaToken.value = null;
        await ref.read(walletProvider.notifier).syncFromBackend();
        if (context.mounted) {
          showWalletToast(context, context.l10n.account_signed_in);
        }
      } on WalletApiException catch (e) {
        if (context.mounted) {
          showWalletToast(context, e.message, icon: DeeMusiqIcons.error);
        }
      } finally {
        if (context.mounted) loading.value = false;
      }
    }

    Future<void> submit() => _guard(context, loading, () async {
          if (mfaToken.value != null) {
            await verifyMfa();
            return;
          }
          if (isRegister.value) {
            await WalletApiClient.instance.registerEmail(
              email: email.text.trim(),
              password: password.text,
              acceptTerms: acceptedTerms.value,
            );
          } else {
            try {
              await WalletApiClient.instance.loginEmail(
                email: email.text.trim(),
                password: password.text,
              );
            } on WalletApiException catch (e) {
              // Reveal the code field instead of toasting a dead end — the
              // user retries once with the authenticator's code attached.
              if (e.code == "mfa_required" && e.mfaToken != null) {
                mfaToken.value = e.mfaToken;
                return;
              }
              rethrow;
            }
          }
          await ref.read(walletProvider.notifier).syncFromBackend();
        },
            isRegister.value
                ? context.l10n.account_created_verify
                : context.l10n.account_signed_in);

    return Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(DeeMusiqIcons.user, color: deeMusiqOrange),
              const Gap(8),
              Expanded(
                child: Text(isRegister.value
                        ? context.l10n.account_create_email_title
                        : context.l10n.sign_in)
                    .semiBold(),
              ),
              Button.ghost(
                onPressed: () {
                  isRegister.value = !isRegister.value;
                  acceptedTerms.value = false;
                },
                child: Text(isRegister.value
                    ? context.l10n.account_have_one_sign_in
                    : context.l10n.create),
              ),
            ],
          ),
          const Gap(4),
          Text(context.l10n.account_email_body).muted().small(),
          const Gap(12),
          TextField(
            controller: email,
            placeholder: Text(context.l10n.email),
            keyboardType: TextInputType.emailAddress,
          ),
          const Gap(8),
          TextField(
            controller: password,
            placeholder: Text(context.l10n.account_password_hint),
            obscureText: true,
          ),
          if (isRegister.value) ...[
            const Gap(8),
            Row(
              children: [
                Checkbox(
                  state: acceptedTerms.value
                      ? CheckboxState.checked
                      : CheckboxState.unchecked,
                  onChanged: (value) =>
                      acceptedTerms.value = value == CheckboxState.checked,
                ),
                const Gap(8),
                Expanded(
                  child: TextButton(
                    onPressed: () => acceptedTerms.value = !acceptedTerms.value,
                    child: Text(context.l10n.account_accept_terms),
                  ),
                ),
              ],
            ),
          ],
          if (mfaToken.value != null) ...[
            const Gap(8),
            Text(context.l10n.auth_mfa_required).muted().small(),
            const Gap(8),
            TextField(
              controller: mfaCode,
              placeholder: Text(context.l10n.account_totp_code_hint),
              keyboardType: TextInputType.number,
            ),
          ],
          const Gap(12),
          Button.primary(
            onPressed:
                loading.value || (isRegister.value && !acceptedTerms.value)
                    ? null
                    : submit,
            child: Text(loading.value
                ? context.l10n.please_wait
                : (mfaToken.value != null
                    ? context.l10n.auth_mfa_verify_action
                    : (isRegister.value
                        ? context.l10n.account_create
                        : context.l10n.sign_in))),
          ),
        ],
      ),
    );
  }
}

class _TotpCard extends HookConsumerWidget {
  const _TotpCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = useState<Map<String, dynamic>?>(null);
    final code = useTextEditingController();
    final stepUpPassword = useTextEditingController();
    final stepUpCode = useTextEditingController();
    final needPassword = useState(false);
    final needCode = useState(false);
    final loading = useState(false);

    Future<void> startSetup() => _guard(context, loading, () async {
          try {
            setup.value = await WalletApiClient.instance.totpSetup(
              password: needPassword.value ? stepUpPassword.text : null,
              code: needCode.value ? stepUpCode.text.trim() : null,
            );
            needPassword.value = false;
            needCode.value = false;
            stepUpPassword.clear();
            stepUpCode.clear();
          } on WalletApiException catch (e) {
            // Step-up: reveal the exact field instead of toasting a dead
            // end — the user retries with the missing proof attached.
            if (e.code == "step_up_password_required") {
              needPassword.value = true;
              return;
            }
            if (e.code == "step_up_code_required") {
              needCode.value = true;
              return;
            }
            rethrow;
          }
        }, context.l10n.account_totp_scan_hint);

    Future<void> enable() => _guard(context, loading, () async {
          await WalletApiClient.instance.totpEnable(code.text.trim());
          setup.value = null;
          code.clear();
        }, context.l10n.account_totp_enabled);

    final s = setup.value;
    return Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(DeeMusiqIcons.shield, color: deeMusiqOrange),
              const Gap(8),
              // .semiBold() is an extension call — not const-evaluable.
              Expanded(
                child: Text(context.l10n.account_totp_title).semiBold(),
              ),
            ],
          ),
          const Gap(4),
          Text(context.l10n.account_totp_body).muted().small(),
          const Gap(12),
          if (s == null) ...[
            if (needPassword.value)
              Text(context.l10n.account_stepup_password_body).muted().small(),
            if (needPassword.value) const Gap(6),
            if (needPassword.value)
              TextField(
                controller: stepUpPassword,
                placeholder: Text(context.l10n.account_stepup_password_hint),
                obscureText: true,
              ),
            if (needCode.value)
              Text(context.l10n.account_stepup_code_body).muted().small(),
            if (needCode.value) const Gap(6),
            if (needCode.value)
              TextField(
                controller: stepUpCode,
                placeholder: Text(context.l10n.account_stepup_code_hint),
                keyboardType: TextInputType.number,
              ),
            if (needPassword.value || needCode.value) const Gap(6),
            Button.outline(
              onPressed: loading.value ? null : startSetup,
              child: Text(
                needPassword.value || needCode.value
                    ? context.l10n.continue_action
                    : context.l10n.account_totp_setup,
              ),
            ),
          ] else ...[
            Text(context.l10n.account_totp_secret_body).muted().small(),
            const Gap(6),
            Card(
              filled: true,
              fillColor: context.theme.colorScheme.muted,
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(child: Text("${s["secret"]}").small()),
                  IconButton.ghost(
                    icon: const Icon(DeeMusiqIcons.clipboard),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: "${s["secret"]}"));
                      showWalletToast(context, context.l10n.account_secret_copied);
                    },
                  ),
                ],
              ),
            ),
            const Gap(10),
            TextField(
              controller: code,
              placeholder: Text(context.l10n.account_totp_code_hint),
              keyboardType: TextInputType.number,
            ),
            const Gap(10),
            Button.primary(
              onPressed: loading.value ? null : enable,
              child: Text(context.l10n.account_totp_verify_enable),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecoveryCard extends HookConsumerWidget {
  const _RecoveryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = useTextEditingController();
    final password = useTextEditingController();
    final code = useTextEditingController();
    final loading = useState(false);

    Future<void> recover() => _guard(context, loading, () async {
          await WalletApiClient.instance.totpRecover(
            email: email.text.trim(),
            password: password.text,
            code: code.text.trim(),
          );
          password.clear();
          await ref.read(walletProvider.notifier).syncFromBackend();
        }, context.l10n.account_recovered);

    return Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(DeeMusiqIcons.refresh, color: deeMusiqOrange),
              const Gap(8),
              Expanded(
                child: Text(context.l10n.account_recovery_title).semiBold(),
              ),
            ],
          ),
          const Gap(4),
          Text(context.l10n.account_recovery_body).muted().small(),
          const Gap(12),
          TextField(
            controller: email,
            placeholder: Text(context.l10n.account_email_hint),
            keyboardType: TextInputType.emailAddress,
          ),
          const Gap(8),
          // Password is a REQUIRED second factor for recovery: the server
          // rejects a TOTP code on its own, since a code alone is a single
          // factor (phishable / readable off an authenticator screen).
          TextField(
            controller: password,
            placeholder: Text(context.l10n.account_stepup_password_hint),
            obscureText: true,
            autofillHints: const [AutofillHints.password],
          ),
          const Gap(8),
          TextField(
            controller: code,
            placeholder: Text(context.l10n.account_totp_code_hint),
            keyboardType: TextInputType.number,
          ),
          const Gap(12),
          Button.outline(
            onPressed: loading.value ? null : recover,
            child: Text(context.l10n.account_recover_action),
          ),
        ],
      ),
    );
  }
}

class _GoogleSignInCard extends HookConsumerWidget {
  const _GoogleSignInCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = useState(false);
    final signedIn = useState(false);
    final isConfigured = GoogleAuthService.instance.isConfigured;
    // google_sign_in has no Linux/Windows implementation — offer the
    // mobile-only notice there instead of a button that would throw.
    final isSupported = GoogleAuthService.instance.isPlatformSupported;

    // Check if already signed in with Google.
    useEffect(() {
      GoogleAuthService.instance.isSignedIn().then((v) {
        if (context.mounted) signedIn.value = v;
      });
      return null;
    }, []);

    Future<void> handleGoogleSignIn() => _guard(context, loading, () async {
          if (!GoogleAuthService.instance.isPlatformSupported) {
            showWalletToast(context, context.l10n.google_sign_in_mobile_only,
                icon: DeeMusiqIcons.info);
            return;
          }
          final result = await GoogleAuthService.instance.signIn();
          signedIn.value = true;
          final wallet = ref.read(walletProvider.notifier);
          // Only record a Google link when the full OAuth flow ran — the
          // device-based fallback has no Google profile to link.
          if (result.displayName != null || result.email != null) {
            await wallet.linkAccount(
              LinkedProvider.google,
              displayName: result.displayName ?? result.email ?? 'Google User',
              externalId: result.email,
            );
          }
          await wallet.syncFromBackend();
          // Pull account-carried favorites down onto this device.
          await syncFavoritesFromBackend(
            ref.read(localFavoritesProvider.notifier),
          );
        }, context.l10n.account_google_signed_in);

    Future<void> handleSignOut() => _guard(context, loading, () async {
          await GoogleAuthService.instance.signOut();
          signedIn.value = false;
          // H2: purge account-derived local state; the tombstone set by
          // signOut() blocks silent re-auth until an explicit sign-in.
          await ref.read(walletProvider.notifier).reset();
          await ref.read(databaseProvider).deleteAllData();
          await KVStoreService.clearAccountState();
        }, context.l10n.account_google_signed_out);

    return Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(DeeMusiqIcons.google, color: deeMusiqOrange),
              const Gap(8),
              Expanded(
                child: Text(context.l10n.account_google_title).semiBold(),
              ),
              if (signedIn.value) ...[
                const Icon(DeeMusiqIcons.verified,
                    size: 14, color: Color(0xFF2E7D32)),
              ],
            ],
          ),
          const Gap(4),
          Text(
            !isSupported
                ? context.l10n.google_sign_in_mobile_only
                : isConfigured
                    ? (signedIn.value
                        ? context.l10n.account_google_connected_body
                        : context.l10n.account_google_connect_body)
                    : context.l10n.account_google_unconfigured_body,
          ).muted().small(),
          const Gap(12),
          if (signedIn.value)
            Button.outline(
              onPressed: loading.value ? null : handleSignOut,
              child: Text(context.l10n.sign_out),
            )
          else if (isSupported)
            Button.primary(
              onPressed:
                  (loading.value || !isConfigured) ? null : handleGoogleSignIn,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(DeeMusiqIcons.google, size: 18),
                  const Gap(8),
                  Text(context.l10n.sign_in_with_google),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SecurityActionsCard extends HookConsumerWidget {
  const _SecurityActionsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resetEmail = useTextEditingController();
    final loading = useState(false);

    Future<void> resend() => _guard(
        context,
        loading,
        () => WalletApiClient.instance.requestVerify(),
        context.l10n.account_verify_link_sent);

    Future<void> reset() => _guard(
        context,
        loading,
        () => WalletApiClient.instance.forgotPassword(resetEmail.text.trim()),
        context.l10n.account_reset_link_sent);

    Future<void> logoutEverywhere() => _guard(
        context,
        loading,
        () async {
          await WalletApiClient.instance.logoutAll();
          await ref.read(walletProvider.notifier).reset();
          // H2: purge account-derived local state so nothing synced survives
          // the sign-out. clearAccountState keeps the device identity seed
          // (else the tombstone is meaningless) and the DRM keyring (else
          // encrypted downloads brick) — logout revokes sessions, not the
          // device or its paid-for content.
          await ref.read(databaseProvider).deleteAllData();
          await KVStoreService.clearAccountState();
        },
        context.l10n.account_logged_out_all);

    /// POPIA s. 11 / GDPR Art. 20: pull the server-side dump and hand it to
    /// the user as a JSON file. Mirrors `_guard`, but a cancelled save dialog
    /// must not show the success toast, so the flow is spelled out here.
    Future<void> exportData() async {
      if (loading.value) return;
      loading.value = true;
      try {
        final data = await WalletApiClient.instance.exportMyData();
        final jsonText = const JsonEncoder.withIndent("  ").convert(data);
        final fileName = "deemusiq-export-"
            "${DateTime.now().millisecondsSinceEpoch}.json";
        final String savedPath;
        if (kIsDesktop) {
          final location = await getSaveLocation(suggestedName: fileName);
          if (location == null) return; // user cancelled — stay silent
          await File(location.path).writeAsString(jsonText);
          savedPath = location.path;
        } else {
          final dir = await getApplicationDocumentsDirectory();
          final file = File(join(dir.path, fileName));
          await file.writeAsString(jsonText);
          savedPath = file.path;
        }
        if (context.mounted) {
          showWalletToast(context, context.l10n.account_data_exported(savedPath));
        }
      } on WalletApiException catch (e) {
        if (context.mounted) {
          showWalletToast(context, e.message, icon: DeeMusiqIcons.error);
        }
      } catch (e) {
        AppLogger.log.w('Data export failed: ${e.toString()}');
        if (context.mounted) {
          showWalletToast(context, context.l10n.account_export_failed,
              icon: DeeMusiqIcons.error);
        }
      } finally {
        if (context.mounted) loading.value = false;
      }
    }

    Future<void> deleteAccount() async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.account_delete_confirm_title).large(),
          content: Text(context.l10n.account_delete_confirm_body)
              .muted()
              .small(),
          actions: [
            Button.outline(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel),
            ),
            Button.destructive(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.account_delete_forever),
            ),
          ],
        ),
      );
      if (ok != true) return;
      if (!context.mounted) return;
      await _guard(context, loading, () async {
        await WalletApiClient.instance.deleteAccount();
        await ref.read(walletProvider.notifier).reset();
        // POPIA: no local trace of the account may outlive the server-side
        // deletion — wipe Drift rows, SharedPreferences and the keystore.
        await ref.read(databaseProvider).deleteAllData();
        await KVStoreService.clearAll();
      }, context.l10n.account_deleted);
    }

    return Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(DeeMusiqIcons.lock, color: deeMusiqOrange),
              const Gap(8),
              Expanded(child: Text(context.l10n.account_security_card_title).semiBold()),
            ],
          ),
          const Gap(12),
          Button.outline(
            onPressed: loading.value ? null : resend,
            child: Text(context.l10n.account_resend_verification),
          ),
          const Gap(8),
          TextField(
            controller: resetEmail,
            placeholder: Text(context.l10n.account_reset_email_hint),
            keyboardType: TextInputType.emailAddress,
          ),
          const Gap(8),
          Button.outline(
            onPressed: loading.value ? null : reset,
            child: Text(context.l10n.account_send_reset_link),
          ),
          const Gap(8),
          Button.outline(
            onPressed: loading.value ? null : logoutEverywhere,
            child: Text(context.l10n.account_logout_all),
          ),
          const Gap(8),
          Button.outline(
            onPressed: loading.value ? null : exportData,
            child: Text(context.l10n.account_export_data),
          ),
          const Gap(8),
          Button.destructive(
            onPressed: loading.value ? null : deleteAccount,
            child: Text(context.l10n.account_delete),
          ),
        ],
      ),
    );
  }
}
