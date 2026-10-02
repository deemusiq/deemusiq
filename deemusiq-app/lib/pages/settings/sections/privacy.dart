import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/modules/settings/section_card_with_heading.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';

/// Privacy & data section: POPIA/GDPR consent, export, email verification,
/// email-code hardening, password reset, and account deletion.
/// Every row calls a real backend endpoint (no stubs).
class SettingsPrivacySection extends HookConsumerWidget {
  const SettingsPrivacySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consent = useState<Map<String, dynamic>?>(null);
    final loading = useState(true);
    final busy = useState(false);
    final codeInput = useTextEditingController();
    final resetToken = useTextEditingController();
    final resetPassword = useTextEditingController();
    final verifyToken = useTextEditingController();

    Future<void> load() async {
      if (!WalletApiClient.instance.isConfigured) {
        loading.value = false;
        return;
      }
      try {
        consent.value =
            await WalletApiClient.instance.fetchConsent();
      } catch (_) {
        consent.value = null;
      } finally {
        loading.value = false;
      }
    }

    useEffect(() {
      Future.microtask(load);
      return null;
    }, const []);

    Future<void> setConsent(String purpose, bool grant) async {
      if (busy.value) return;
      busy.value = true;
      try {
        await WalletApiClient.instance.updateConsent(
          purpose: purpose,
          action: grant ? "grant" : "withdraw",
        );
        await load();
        if (context.mounted) {
          showWalletToast(context, "Consent $purpose ${grant ? "granted" : "withdrawn"}",
              icon: DeeMusiqIcons.verified);
        }
      } catch (e) {
        if (context.mounted) {
          showWalletToast(context, e.toString(),
              icon: DeeMusiqIcons.info);
        }
      } finally {
        busy.value = false;
      }
    }

    bool granted(String purpose) {
      final list = (consent.value?["consents"] as List?) ?? const [];
      return list
          .cast<Map>()
          .any((c) => c["purpose"] == purpose && c["withdrawnAt"] == null);
    }

    return SectionCardWithHeading(
      heading: "Privacy & data",
      children: [
        if (!WalletApiClient.instance.isConfigured)
          const Text(
            "Connect a backend to manage consent, export, and deletion.",
          ).muted().xSmall()
        else if (loading.value)
          const Center(child: CircularProgressIndicator())
        else ...[
          for (final p in ["terms", "privacy", "marketing"])
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p).semiBold().small(),
                      Text(_consentBlurb(p)).muted().xSmall(),
                    ],
                  ),
                ),
                Checkbox(
                  state: granted(p)
                      ? CheckboxState.checked
                      : CheckboxState.unchecked,
                  onChanged: busy.value
                      ? null
                      : (s) => setConsent(p, s == CheckboxState.checked),
                ),
              ],
            ),
          const Gap(8),
          const Divider(),
          const Gap(4),
          const Text("Email verification & hardening").semiBold().small(),
          const Gap(4),
          Row(
            children: [
              Expanded(
                child: Button.secondary(
                  onPressed: busy.value
                      ? null
                      : () async {
                          busy.value = true;
                          try {
                            await WalletApiClient.instance.requestVerify();
                            if (context.mounted) {
                              showWalletToast(context, "Verification link sent",
                                  icon: DeeMusiqIcons.verified);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showWalletToast(context, e.toString(),
                                  icon: DeeMusiqIcons.info);
                            }
                          } finally {
                            busy.value = false;
                          }
                        },
                  child: const Text("Resend verify link"),
                ),
              ),
              const Gap(8),
              Expanded(
                child: Button.secondary(
                  onPressed: busy.value
                      ? null
                      : () async {
                          busy.value = true;
                          try {
                            await WalletApiClient.instance
                                .requestEmailCode();
                            if (context.mounted) {
                              showWalletToast(
                                  context, "One-time code sent to email",
                                  icon: DeeMusiqIcons.verified);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showWalletToast(context, e.toString(),
                                  icon: DeeMusiqIcons.info);
                            }
                          } finally {
                            busy.value = false;
                          }
                        },
                  child: const Text("Request login code"),
                ),
              ),
            ],
          ),
          const Gap(4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: codeInput,
                  placeholder: const Text("6-digit email code"),
                ),
              ),
              const Gap(8),
              Button.secondary(
                onPressed: busy.value || codeInput.text.trim().isEmpty
                    ? null
                    : () async {
                        busy.value = true;
                        try {
                          await WalletApiClient.instance.confirmEmailCode(
                              codeInput.text.trim());
                          codeInput.text = "";
                          if (context.mounted) {
                            showWalletToast(context, "Code confirmed",
                                icon: DeeMusiqIcons.verified);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            showWalletToast(context, e.toString(),
                                icon: DeeMusiqIcons.info);
                          }
                        } finally {
                          busy.value = false;
                        }
                      },
                child: const Text("Confirm code"),
              ),
            ],
          ),
          const Gap(4),
          TextField(
            controller: verifyToken,
            placeholder: const Text("Email-verify token (from link)"),
          ),
          const Gap(4),
          Button.secondary(
            onPressed: busy.value || verifyToken.text.trim().isEmpty
                ? null
                : () async {
                    busy.value = true;
                    try {
                      await WalletApiClient.instance
                          .verifyEmail(verifyToken.text.trim());
                      verifyToken.text = "";
                      if (context.mounted) {
                        showWalletToast(context, "Email verified",
                            icon: DeeMusiqIcons.verified);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        showWalletToast(context, e.toString(),
                            icon: DeeMusiqIcons.info);
                      }
                    } finally {
                      busy.value = false;
                    }
                  },
            child: const Text("Verify email with token"),
          ),
          const Gap(8),
          const Divider(),
          const Gap(4),
          const Text("Password reset (emailed token)").semiBold().small(),
          const Gap(4),
          TextField(
            controller: resetToken,
            placeholder: const Text("Reset token from email"),
          ),
          const Gap(4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: resetPassword,
                  placeholder: const Text("New password (12+ chars)"),
                  obscureText: true,
                ),
              ),
              const Gap(8),
              Button.secondary(
                onPressed: busy.value
                    ? null
                    : () async {
                        if (resetToken.text.trim().isEmpty ||
                            resetPassword.text.length < 12) {
                          showWalletToast(
                              context, "Token + 12-char password required",
                              icon: DeeMusiqIcons.info);
                          return;
                        }
                        busy.value = true;
                        try {
                          await WalletApiClient.instance.resetPassword(
                            token: resetToken.text.trim(),
                            password: resetPassword.text,
                          );
                          resetToken.text = "";
                          resetPassword.text = "";
                          if (context.mounted) {
                            showWalletToast(context, "Password reset",
                                icon: DeeMusiqIcons.verified);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            showWalletToast(context, e.toString(),
                                icon: DeeMusiqIcons.info);
                          }
                        } finally {
                          busy.value = false;
                        }
                      },
                child: const Text("Reset"),
              ),
            ],
          ),
          const Gap(8),
          const Divider(),
          const Gap(4),
          Row(
            children: [
              Expanded(
                child: Button.secondary(
                  onPressed: busy.value
                      ? null
                      : () async {
                          busy.value = true;
                          try {
                            final data = await WalletApiClient.instance
                                .exportMyData();
                            if (context.mounted) {
                              showWalletToast(context,
                                  "Export ready: ${(data.keys.length)} sections",
                                  icon: DeeMusiqIcons.verified);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showWalletToast(context, e.toString(),
                                  icon: DeeMusiqIcons.info);
                            }
                          } finally {
                            busy.value = false;
                          }
                        },
                  child: const Text("Export my data"),
                ),
              ),
              const Gap(8),
              Expanded(
                child: Button.destructive(
                  onPressed: busy.value
                      ? null
                      : () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text("Delete account?"),
                              content: const Text(
                                  "Anonymizes everything (GDPR Art. 17). JWT dies immediately. Cannot undo."),
                              actions: [
                                Button.secondary(
                                    onPressed: () =>
                                        Navigator.of(c).pop(false),
                                    child: const Text("Cancel")),
                                Button.destructive(
                                    onPressed: () =>
                                        Navigator.of(c).pop(true),
                                    child: const Text("Delete")),
                              ],
                            ),
                          );
                          if (ok != true) return;
                          busy.value = true;
                          try {
                            await WalletApiClient.instance.deleteAccount();
                            if (context.mounted) {
                              showWalletToast(context, "Account deleted",
                                  icon: DeeMusiqIcons.verified);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showWalletToast(context, e.toString(),
                                  icon: DeeMusiqIcons.info);
                            }
                          } finally {
                            busy.value = false;
                          }
                        },
                  child: const Text("Delete account"),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

String _consentBlurb(String purpose) {
  if (purpose == "marketing") return "Opt-in recommendations and offers.";
  if (purpose == "terms") return "Required to run the account. Withdrawing restricts processing.";
  return "Required privacy policy. Withdrawing restricts processing.";
}
