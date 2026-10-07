import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/collections/motion.dart';
import 'package:deemusiq/collections/routes.gr.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/models/wallet/linked_account.dart';
import 'package:deemusiq/pages/auth/birth_year.dart';
import 'package:deemusiq/provider/local_favorites/local_favorites_provider.dart';
import 'package:deemusiq/provider/wallet/wallet_provider.dart';
import 'package:deemusiq/services/auth/google_auth.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';
import 'package:deemusiq/l10n/l10n.dart';
import 'package:deemusiq/services/logger/logger.dart';

@RoutePage(name: "auth")
class AuthPage extends HookConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ageVerified = useState(false);
    final privacyConsent = useState(false);
    // Which flow is busy (null = idle). Buttons stay visible with an inline
    // spinner instead of the whole form being swapped for a loader.
    final busyWith = useState<String?>(null);
    final birthYearError = useState<String?>(null);
    final birthYearController = useTextEditingController();
    final theme = Theme.of(context);
    final entrance = useAnimationController(duration: AppMotion.slow);
    useEffect(() {
      entrance.forward();
      return null;
    }, [entrance]);

    Future<void> handleSignIn({required bool google}) async {
      final l10n = AppLocalizations.of(context)!;
      if (busyWith.value != null) return;
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
      final birthYear = parseBirthYearInput(birthYearController.text);
      if (birthYear == null) {
        birthYearError.value = l10n.must_enter_valid_birth_year;
        showWalletToast(context, l10n.must_enter_valid_birth_year,
            icon: DeeMusiqIcons.error);
        return;
      }
      birthYearError.value = null;
      busyWith.value = google ? 'google' : 'device';
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
          // Pull account-carried favorites down onto this device.
          await syncFavoritesFromBackend(
            ref.read(localFavoritesProvider.notifier),
          );
        } else if (WalletApiClient.instance.isConfigured) {
          // "Continue with device (limited)" still gets a real backend
          // account via the Ed25519 challenge login when the server answers.
          // Without it the device stays signed OUT: no backend token is ever
          // minted, so the Home guard (`isConfigured && !hasToken()`)
          // redirects straight back to Auth and the taps look dead. A
          // connectivity failure keeps the app in offline mode — playback
          // works client-side and the wallet syncs once the backend is back.
          try {
            await WalletApiClient.instance.deviceLogin();
          } on WalletApiException catch (e, stack) {
            AppLogger.log.w('AuthPage: device login failed: ${e.message}');
            AppLogger.reportError(e, stack, 'AuthPage deviceLogin');
            if (e.isConnectivity) {
              if (context.mounted) {
                showWalletToast(
                  context,
                  AppLocalizations.of(context)!.offline_staying_on_device,
                  icon: DeeMusiqIcons.info,
                );
              }
            } else if (context.mounted) {
              showWalletToast(context, e.message,
                  icon: DeeMusiqIcons.error);
              return;
            }
          } catch (e, stack) {
            AppLogger.log.w('AuthPage: device login failed, continuing offline: $e');
            AppLogger.reportError(e, stack, 'AuthPage deviceLogin');
          }
        }

        // Server is the source of truth for age verification — the local KV
        // flag set above is only a cache. A definitive under-age rejection
        // blocks entry; connectivity failures defer to the offline flow.
        if (WalletApiClient.instance.isConfigured) {
          final birthYearResult = await submitBirthYearToServer(birthYear);
          if (!context.mounted) return;
          switch (birthYearResult.status) {
            case BirthYearSubmitStatus.underMinAge:
              await KVStoreService.setAgeVerified(false);
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
              AppLogger.log.w(
                  'AuthPage: birth-year submission deferred (backend unreachable)');
            case BirthYearSubmitStatus.success:
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
      } on Exception catch (e, stack) {
        AppLogger.reportError(e, stack, 'AuthPage handleSignIn');
        if (context.mounted) {
          showWalletToast(context, l10n.something_went_wrong,
              icon: DeeMusiqIcons.error);
        }
      } finally {
        if (context.mounted) busyWith.value = null;
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
                  _Entrance(
                    controller: entrance,
                    index: 0,
                    child: Column(
                      children: [
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
                      ],
                    ),
                  ),
                  const Gap(32),
                  _Entrance(
                    controller: entrance,
                    index: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: birthYearController,
                          placeholder: Text(l10n.birth_year_hint),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          onChanged: (_) {
                            if (birthYearError.value != null) {
                              birthYearError.value = null;
                            }
                          },
                          onSubmitted: (_) => handleSignIn(
                            google:
                                GoogleAuthService.instance.isPlatformSupported,
                          ),
                        ),
                        if (birthYearError.value != null) ...[
                          const Gap(6),
                          Text(
                            birthYearError.value!,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.destructive,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Gap(12),
                  _Entrance(
                    controller: entrance,
                    index: 2,
                    child: Column(
                      children: [
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
                      ],
                    ),
                  ),
                  const Gap(24),
                  _Entrance(
                    controller: entrance,
                    index: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (GoogleAuthService.instance.isPlatformSupported) ...[
                          Button.primary(
                            onPressed: busyWith.value == null
                                ? () => handleSignIn(google: true)
                                : null,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (busyWith.value == 'google')
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                else
                                  const Icon(DeeMusiqIcons.google, size: 18),
                                const Gap(8),
                                Text(l10n.sign_in_with_google),
                              ],
                            ),
                          ),
                          const Gap(8),
                        ],
                        Button.outline(
                          onPressed: busyWith.value == null
                              ? () => handleSignIn(google: false)
                              : null,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (busyWith.value == 'device') ...[
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                ),
                                const Gap(8),
                              ],
                              Text(l10n.continue_with_device_limited),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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


/// Staggered fade+rise entrance used by the auth form sections.
class _Entrance extends StatelessWidget {
  const _Entrance({
    required this.controller,
    required this.index,
    required this.child,
  });

  final Animation<double> controller;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return child;
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        0.14 * index,
        (0.6 + 0.14 * index).clamp(0.0, 1.0),
        curve: AppMotion.emphasized,
      ),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}
