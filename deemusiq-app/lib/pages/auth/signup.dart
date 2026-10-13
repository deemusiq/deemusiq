import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/collections/routes.gr.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/pages/auth/birth_year.dart';
import 'package:deemusiq/provider/local_favorites/local_favorites_provider.dart';
import 'package:deemusiq/provider/wallet/wallet_provider.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';
import 'package:deemusiq/l10n/l10n.dart';

/// Create a DeeMusiq account from an email + password.
///
/// This is the entrypoint for someone WITHOUT a device already bound to a
/// wallet. Until this existed the only way to get an account was the Ed25519
/// device handshake behind "Continue with device", so a new user had to trust
/// a device with a wallet before they could even be offered an email form.
///
/// The flow is two steps because the backend hands back NO session from
/// `/auth/signup`: the account is created unverified, and `/auth/signup/verify`
/// — which needs the 6-digit code that was emailed — is what signs the user
/// in. Showing the code field only after signup mirrors that exactly.
@RoutePage(name: "signup")
class SignupPage extends HookConsumerWidget {
  const SignupPage({super.key});

  /// Longest string the backend's `zod` schema will accept.
  static const _maxEmail = 320;
  static const _maxPassword = 256;

  /// Mirrors the server's `emailSchema` closely enough to catch a typo before
  /// a round-trip, without pretending to be RFC 5322. The server remains the
  /// authority — this only saves the user a failed request.
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s.]+(\.[^@\s.]+)+$');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final codeController = useTextEditingController();
    final birthYearController = useTextEditingController();

    final acceptTerms = useState(false);
    final busy = useState(false);
    final errorText = useState<String?>(null);
    /// False until the address has been accepted; flips the form into the
    /// code-entry step and is never reset, so the code screen can't be reached
    /// without having created an account first.
    final awaitingCode = useState(false);
    final submittedEmail = useState<String?>(null);

    useEffect(() {
      // The password never leaves this screen except in the signup POST itself.
      passwordController.clear();
      return null;
    }, const []);

    Future<void> finishSignIn() async {
      final birthYear = parseBirthYearInput(birthYearController.text);
      if (birthYear == null) {
        errorText.value = l10n.must_enter_valid_birth_year;
        showWalletToast(context, l10n.must_enter_valid_birth_year,
            icon: DeeMusiqIcons.error);
        return;
      }
      await KVStoreService.setAgeVerified(true);
      await KVStoreService.setPrivacyConsentGiven(true);

      final birthYearResult = await submitBirthYearToServer(birthYear);
      if (!context.mounted) return;
      switch (birthYearResult.status) {
        case BirthYearSubmitStatus.underMinAge:
          await KVStoreService.setAgeVerified(false);
          // The write above is an await, so the mount check from before the
          // switch no longer holds for anything that touches context after it.
          if (!context.mounted) return;
          showWalletToast(context, l10n.under_min_age_message,
              icon: DeeMusiqIcons.error);
          return;
        case BirthYearSubmitStatus.error:
          showWalletToast(
            context,
            birthYearResult.message ?? l10n.wallet_sync_failed_retry,
            icon: DeeMusiqIcons.error,
          );
          return;
        case BirthYearSubmitStatus.connectivity:
          AppLogger.log
              .w('SignupPage: birth-year submission deferred (backend unreachable)');
        case BirthYearSubmitStatus.success:
      }

      await KVStoreService.setDoneGettingStarted(true);
      try {
        await syncFavoritesFromBackend(
          ref.read(localFavoritesProvider.notifier),
        );
        await ref.read(walletProvider.notifier).syncFromBackend();
      } catch (e) {
        AppLogger.log.w('SignupPage: post-signup sync failed: $e');
      }

      if (context.mounted) {
        context.router.replaceAll([const HomeRoute()]);
      }
    }

    Future<void> handleSignup() async {
      if (busy.value) return;
      final email = emailController.text.trim();
      if (!_emailPattern.hasMatch(email) || email.length > _maxEmail) {
        errorText.value = l10n.signup_invalid_email;
        return;
      }
      final password = passwordController.text;
      if (password.isEmpty || password.length > _maxPassword) {
        errorText.value = l10n.signup_enter_password;
        return;
      }
      if (!acceptTerms.value) {
        errorText.value = l10n.must_agree_privacy_policy;
        showWalletToast(context, l10n.must_agree_privacy_policy,
            icon: DeeMusiqIcons.error);
        return;
      }

      busy.value = true;
      errorText.value = null;
      try {
        await WalletApiClient.instance.signupEmail(
          email: email,
          password: password,
          acceptTerms: true,
        );
        submittedEmail.value = email;
        awaitingCode.value = true;
        // Don't keep a password in memory once it has been sent.
        passwordController.clear();
        if (context.mounted) {
          showWalletToast(context, l10n.signup_code_sent(email),
              icon: DeeMusiqIcons.info);
        }
      } on WalletApiException catch (e, stack) {
        AppLogger.log.w('SignupPage: signup failed: ${e.message}');
        AppLogger.reportError(e, stack, 'SignupPage signupEmail');
        errorText.value = e.friendlyMessage;
      } catch (e, stack) {
        AppLogger.reportError(e, stack, 'SignupPage signupEmail');
        errorText.value = l10n.something_went_wrong;
      } finally {
        if (context.mounted) busy.value = false;
      }
    }

    Future<void> handleVerify() async {
      if (busy.value) return;
      final email = submittedEmail.value;
      if (email == null) return;
      final code = codeController.text.trim();
      if (code.length != 6 || int.tryParse(code) == null) {
        errorText.value = l10n.signup_code_length;
        return;
      }

      busy.value = true;
      errorText.value = null;
      try {
        await WalletApiClient.instance
            .verifySignupCode(email: email, code: code);
        if (!context.mounted) return;
        await finishSignIn();
      } on WalletApiException catch (e, stack) {
        AppLogger.log.w('SignupPage: verification failed: ${e.message}');
        AppLogger.reportError(e, stack, 'SignupPage verifySignupCode');
        errorText.value = e.friendlyMessage;
      } catch (e, stack) {
        AppLogger.reportError(e, stack, 'SignupPage verifySignupCode');
        errorText.value = l10n.something_went_wrong;
      } finally {
        if (context.mounted) busy.value = false;
      }
    }

    Future<void> handleResend() async {
      if (busy.value) return;
      final email = submittedEmail.value;
      if (email == null) return;
      busy.value = true;
      try {
        await WalletApiClient.instance.resendSignupCode(email: email);
        if (context.mounted) {
          showWalletToast(context, l10n.signup_code_resent,
              icon: DeeMusiqIcons.info);
        }
      } on WalletApiException catch (e, stack) {
        AppLogger.reportError(e, stack, 'SignupPage resendSignupCode');
        if (context.mounted) {
          showWalletToast(context, e.friendlyMessage,
              icon: DeeMusiqIcons.error);
        }
      } finally {
        if (context.mounted) busy.value = false;
      }
    }

    final canSubmit = !busy.value;

    return Scaffold(
      headers: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                variance: ButtonVariance.ghost,
                icon: const Icon(Icons.arrow_back),
                onPressed:
                    busy.value ? null : () => context.router.maybePop(),
              ),
            ),
          ),
        ),
      ],
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.signup_title).xLarge.bold(),
                  const Gap(8),
                  Text(awaitingCode.value
                          ? l10n.signup_enter_code(
                              submittedEmail.value ?? '')
                          : l10n.signup_subtitle)
                      .muted(),
                  const Gap(24),
                  if (awaitingCode.value) ...[
                    TextField(
                      controller: codeController,
                      placeholder: Text(l10n.signup_code_hint),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      maxLength: 6,
                      enabled: !busy.value,
                      onSubmitted: (_) => handleVerify(),
                    ),
                    const Gap(8),
                    Button.primary(
                      onPressed: canSubmit ? handleVerify : null,
                      child: busy.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.signup_confirm),
                    ),
                    const Gap(8),
                    TextButton(
                      onPressed: canSubmit ? handleResend : null,
                      child: Text(l10n.signup_resend_code).muted(),
                    ),
                  ] else ...[
                    TextField(
                      controller: emailController,
                      placeholder: Text(l10n.signup_email_hint),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !busy.value,
                      onChanged: (_) => errorText.value = null,
                    ),
                    const Gap(12),
                    TextField(
                      controller: passwordController,
                      placeholder: Text(l10n.signup_password_hint),
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      enabled: !busy.value,
                      onChanged: (_) => errorText.value = null,
                    ),
                    const Gap(6),
                    Text(l10n.signup_password_rule).muted().small,
                    const Gap(16),
                    TextField(
                      controller: birthYearController,
                      placeholder: Text(l10n.birth_year_hint),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      enabled: !busy.value,
                    ),
                    const Gap(8),
                    Row(
                      children: [
                        Checkbox(
                          state: acceptTerms.value
                              ? CheckboxState.checked
                              : CheckboxState.unchecked,
                          onChanged: busy.value
                              ? null
                              : (v) => acceptTerms.value =
                                  v == CheckboxState.checked,
                        ),
                        const Gap(8),
                        Expanded(
                          child: TextButton(
                            onPressed: busy.value
                                ? null
                                : () =>
                                    acceptTerms.value = !acceptTerms.value,
                            child: Text(l10n.agree_privacy_policy).muted(),
                          ),
                        ),
                      ],
                    ),
                    const Gap(16),
                    Button.primary(
                      onPressed: canSubmit ? handleSignup : null,
                      child: busy.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.signup_create_account),
                    ),
                    const Gap(8),
                    TextButton(
                      onPressed:
                          busy.value ? null : () => context.router.maybePop(),
                      child: Text(l10n.signup_back_to_sign_in).muted(),
                    ),
                  ],
                  if (errorText.value != null) ...[
                    const Gap(12),
                    Text(
                      errorText.value!,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.destructive,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
