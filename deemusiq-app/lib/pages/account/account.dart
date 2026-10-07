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
        headers: const [TitleBar(title: Text("Account & security"))],
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
      showWalletToast(context, "Something went wrong.",
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

    Future<void> submit() => _guard(context, loading, () async {
          if (isRegister.value) {
            await WalletApiClient.instance.registerEmail(
              email: email.text.trim(),
              password: password.text,
              acceptTerms: acceptedTerms.value,
            );
          } else {
            await WalletApiClient.instance.loginEmail(
              email: email.text.trim(),
              password: password.text,
            );
          }
          await ref.read(walletProvider.notifier).syncFromBackend();
        },
            isRegister.value
                ? "Account created — check your email to verify."
                : "Signed in.");

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
                        ? "Create an email account"
                        : "Sign in")
                    .semiBold(),
              ),
              Button.ghost(
                onPressed: () {
                  isRegister.value = !isRegister.value;
                  acceptedTerms.value = false;
                },
                child: Text(isRegister.value ? "Have one? Sign in" : "Create"),
              ),
            ],
          ),
          const Gap(4),
          const Text(
            "An email + password lets you use this wallet on another device "
            "and recover it. Your password is never stored — only a hash.",
          ).muted().small(),
          const Gap(12),
          TextField(
            controller: email,
            placeholder: const Text("Email"),
            keyboardType: TextInputType.emailAddress,
          ),
          const Gap(8),
          TextField(
            controller: password,
            placeholder: const Text("Password (12+ characters)"),
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
                    child: const Text(
                      "I accept the DeeMusiq Terms of Service and Privacy Policy.",
                    ),
                  ),
                ),
              ],
            ),
          ],
          const Gap(12),
          Button.primary(
            onPressed:
                loading.value || (isRegister.value && !acceptedTerms.value)
                    ? null
                    : submit,
            child: Text(loading.value
                ? "Please wait…"
                : (isRegister.value ? "Create account" : "Sign in")),
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
        }, "Scan or enter the secret in your authenticator app.");

    Future<void> enable() => _guard(context, loading, () async {
          await WalletApiClient.instance.totpEnable(code.text.trim());
          setup.value = null;
          code.clear();
        }, "Two-factor authentication enabled.");

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
                child: const Text("Two-factor authentication (2FA)").semiBold(),
              ),
            ],
          ),
          const Gap(4),
          const Text(
            "Use any authenticator app (Google Authenticator, Authy, Aegis…). "
            "2FA also lets you recover your wallet on a new device.",
          ).muted().small(),
          const Gap(12),
          if (s == null) ...[
            if (needPassword.value)
              const Text(
                "Confirm your account password to continue.",
              ).muted().small(),
            if (needPassword.value) const Gap(6),
            if (needPassword.value)
              TextField(
                controller: stepUpPassword,
                placeholder: const Text("Account password"),
                obscureText: true,
              ),
            if (needCode.value)
              const Text(
                "Enter a code from your current authenticator app to replace it.",
              ).muted().small(),
            if (needCode.value) const Gap(6),
            if (needCode.value)
              TextField(
                controller: stepUpCode,
                placeholder: const Text("Current 6-digit code"),
                keyboardType: TextInputType.number,
              ),
            if (needPassword.value || needCode.value) const Gap(6),
            Button.outline(
              onPressed: loading.value ? null : startSetup,
              child: Text(
                needPassword.value || needCode.value
                    ? "Continue"
                    : "Set up 2FA",
              ),
            ),
          ] else ...[
            const Text("Add this secret to your authenticator app:")
                .muted()
                .small(),
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
                      showWalletToast(context, "Secret copied.");
                    },
                  ),
                ],
              ),
            ),
            const Gap(10),
            TextField(
              controller: code,
              placeholder: const Text("6-digit code"),
              keyboardType: TextInputType.number,
            ),
            const Gap(10),
            Button.primary(
              onPressed: loading.value ? null : enable,
              child: const Text("Verify & enable"),
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
    final code = useTextEditingController();
    final loading = useState(false);

    Future<void> recover() => _guard(context, loading, () async {
          await WalletApiClient.instance.totpRecover(
            email: email.text.trim(),
            code: code.text.trim(),
          );
          await ref.read(walletProvider.notifier).syncFromBackend();
        }, "Recovered — welcome back.");

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
                child: const Text("Recover with your authenticator").semiBold(),
              ),
            ],
          ),
          const Gap(4),
          const Text(
            "On a new device? Enter your account email and a current 2FA code "
            "to restore your wallet.",
          ).muted().small(),
          const Gap(12),
          TextField(
            controller: email,
            placeholder: const Text("Account email"),
            keyboardType: TextInputType.emailAddress,
          ),
          const Gap(8),
          TextField(
            controller: code,
            placeholder: const Text("6-digit code"),
            keyboardType: TextInputType.number,
          ),
          const Gap(12),
          Button.outline(
            onPressed: loading.value ? null : recover,
            child: const Text("Recover wallet"),
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

    // Check if already signed in with Google.
    useEffect(() {
      GoogleAuthService.instance.isSignedIn().then((v) {
        if (context.mounted) signedIn.value = v;
      });
      return null;
    }, []);

    Future<void> handleGoogleSignIn() => _guard(context, loading, () async {
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
        }, "Signed in with Google.");

    Future<void> handleSignOut() => _guard(context, loading, () async {
          await GoogleAuthService.instance.signOut();
          signedIn.value = false;
          // H2: purge account-derived local state; the tombstone set by
          // signOut() blocks silent re-auth until an explicit sign-in.
          await ref.read(walletProvider.notifier).reset();
          await ref.read(databaseProvider).deleteAllData();
          await KVStoreService.clearAccountState();
        }, "Signed out of Google. Synced data on this device was cleared.");

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
                child: const Text("Google Sign-In").semiBold(),
              ),
              if (signedIn.value) ...[
                const Icon(DeeMusiqIcons.verified,
                    size: 14, color: Color(0xFF2E7D32)),
              ],
            ],
          ),
          const Gap(4),
          Text(
            isConfigured
                ? (signedIn.value
                    ? "Connected. Your liked songs and playlists sync "
                        "anonymously — only hashed IDs are stored, and "
                        "playlist names travel inside the encrypted channel. "
                        "No personal data leaves your device."
                    : "Sign in with Google to sync your library across "
                        "devices. We only store anonymized data (hashed song "
                        "IDs; playlist names travel inside the encrypted "
                        "channel). No email, name, or location is ever stored.")
                : "Google Sign-In needs backend connectivity. "
                    "Connect to the DeeMusiq server to enable.",
          ).muted().small(),
          const Gap(12),
          if (signedIn.value)
            Button.outline(
              onPressed: loading.value ? null : handleSignOut,
              child: const Text("Sign out"),
            )
          else
            Button.primary(
              onPressed:
                  (loading.value || !isConfigured) ? null : handleGoogleSignIn,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(DeeMusiqIcons.google, size: 18),
                  Gap(8),
                  Text("Sign in with Google"),
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
        "If your email needs verifying, a link is on its way.");

    Future<void> reset() => _guard(
        context,
        loading,
        () => WalletApiClient.instance.forgotPassword(resetEmail.text.trim()),
        "If that email has an account, a reset link is on its way.");

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
        "Signed out on all devices. Synced data on this device was cleared.");

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
          showWalletToast(context, "Data exported to $savedPath");
        }
      } on WalletApiException catch (e) {
        if (context.mounted) {
          showWalletToast(context, e.message, icon: DeeMusiqIcons.error);
        }
      } catch (e) {
        AppLogger.log.w('Data export failed: ${e.toString()}');
        if (context.mounted) {
          showWalletToast(context, "Export failed.", icon: DeeMusiqIcons.error);
        }
      } finally {
        if (context.mounted) loading.value = false;
      }
    }

    Future<void> deleteAccount() async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Delete account?").large(),
          content: const Text(
            "This permanently deletes your DeeMusiq account, wallet balance, "
            "history and linked accounts. This cannot be undone.",
          ).muted().small(),
          actions: [
            Button.outline(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            Button.destructive(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete forever"),
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
      }, "Account deleted.");
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
              Expanded(child: const Text("Security").semiBold()),
            ],
          ),
          const Gap(12),
          Button.outline(
            onPressed: loading.value ? null : resend,
            child: const Text("Resend verification email"),
          ),
          const Gap(8),
          TextField(
            controller: resetEmail,
            placeholder: const Text("Email for password reset"),
            keyboardType: TextInputType.emailAddress,
          ),
          const Gap(8),
          Button.outline(
            onPressed: loading.value ? null : reset,
            child: const Text("Email me a password reset link"),
          ),
          const Gap(8),
          Button.outline(
            onPressed: loading.value ? null : logoutEverywhere,
            child: const Text("Log out on all devices"),
          ),
          const Gap(8),
          Button.outline(
            onPressed: loading.value ? null : exportData,
            child: const Text("Export my data (JSON)"),
          ),
          const Gap(8),
          Button.destructive(
            onPressed: loading.value ? null : deleteAccount,
            child: const Text("Delete account"),
          ),
        ],
      ),
    );
  }
}
