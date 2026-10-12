import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/modules/settings/section_card_with_heading.dart';
import 'package:deemusiq/services/logger/logger.dart';
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
        final result = await WalletApiClient.instance.fetchConsent();
        if (context.mounted) consent.value = result;
      } catch (e, stack) {
        // Consent UI degrades to the offline/off state, but the failure is
        // still reported — never swallowed.
        AppLogger.reportError(e, stack, 'privacy fetchConsent');
        if (context.mounted) consent.value = null;
      } finally {
        if (context.mounted) loading.value = false;
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
          showWalletToast(
              context,
              grant
                  ? context.l10n.privacy_consent_granted(purpose)
                  : context.l10n.privacy_consent_withdrawn(purpose),
              icon: DeeMusiqIcons.verified);
        }
      } catch (e) {
        if (context.mounted) {
          showWalletToast(context, e.toString(),
              icon: DeeMusiqIcons.info);
        }
      } finally {
        if (context.mounted) busy.value = false;
      }
    }

    bool granted(String purpose) {
      final list = (consent.value?["consents"] as List?) ?? const [];
      return list
          .cast<Map>()
          .any((c) => c["purpose"] == purpose && c["withdrawnAt"] == null);
    }

    return SectionCardWithHeading(
      heading: context.l10n.privacy_heading,
      children: [
        if (!WalletApiClient.instance.isConfigured)
          Text(context.l10n.privacy_offline_body).muted().xSmall()
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
                      Text(_consentPurposeLabel(context, p)).semiBold().small(),
                      Text(_consentBlurb(context, p)).muted().xSmall(),
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
          Text(context.l10n.privacy_email_section).semiBold().small(),
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
                              showWalletToast(
                                  context, context.l10n.privacy_verify_link_sent,
                                  icon: DeeMusiqIcons.verified);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showWalletToast(context, e.toString(),
                                  icon: DeeMusiqIcons.info);
                            }
                          } finally {
                            if (context.mounted) busy.value = false;
                          }
                        },
                  child: Text(context.l10n.privacy_resend_verify),
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
                                  context, context.l10n.privacy_code_sent,
                                  icon: DeeMusiqIcons.verified);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showWalletToast(context, e.toString(),
                                  icon: DeeMusiqIcons.info);
                            }
                          } finally {
                            if (context.mounted) busy.value = false;
                          }
                        },
                  child: Text(context.l10n.privacy_request_code),
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
                  placeholder: Text(context.l10n.privacy_code_hint),
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
                            showWalletToast(
                                context, context.l10n.privacy_code_confirmed,
                                icon: DeeMusiqIcons.verified);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            showWalletToast(context, e.toString(),
                                icon: DeeMusiqIcons.info);
                          }
                        } finally {
                          if (context.mounted) busy.value = false;
                        }
                      },
                child: Text(context.l10n.privacy_confirm_code),
              ),
            ],
          ),
          const Gap(4),
          TextField(
            controller: verifyToken,
            placeholder: Text(context.l10n.privacy_verify_token_hint),
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
                        showWalletToast(
                            context, context.l10n.privacy_email_verified,
                            icon: DeeMusiqIcons.verified);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        showWalletToast(context, e.toString(),
                            icon: DeeMusiqIcons.info);
                      }
                    } finally {
                      if (context.mounted) busy.value = false;
                    }
                  },
            child: Text(context.l10n.privacy_verify_with_token),
          ),
          const Gap(8),
          const Divider(),
          const Gap(4),
          Text(context.l10n.privacy_reset_section).semiBold().small(),
          const Gap(4),
          TextField(
            controller: resetToken,
            placeholder: Text(context.l10n.privacy_reset_token_hint),
          ),
          const Gap(4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: resetPassword,
                  placeholder: Text(context.l10n.privacy_new_password_hint),
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
                              context, context.l10n.privacy_reset_requirements,
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
                            showWalletToast(
                                context, context.l10n.privacy_password_reset,
                                icon: DeeMusiqIcons.verified);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            showWalletToast(context, e.toString(),
                                icon: DeeMusiqIcons.info);
                          }
                        } finally {
                          if (context.mounted) busy.value = false;
                        }
                      },
                child: Text(context.l10n.privacy_reset_action),
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
                              showWalletToast(
                                  context,
                                  context.l10n.privacy_export_ready(
                                      data.keys.length),
                                  icon: DeeMusiqIcons.verified);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showWalletToast(context, e.toString(),
                                  icon: DeeMusiqIcons.info);
                            }
                          } finally {
                            if (context.mounted) busy.value = false;
                          }
                        },
                  child: Text(context.l10n.privacy_export_data),
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
                              title: Text(
                                  context.l10n.account_delete_confirm_title),
                              content:
                                  Text(context.l10n.privacy_delete_body),
                              actions: [
                                Button.secondary(
                                    onPressed: () =>
                                        Navigator.of(c).pop(false),
                                    child: Text(context.l10n.cancel)),
                                Button.destructive(
                                    onPressed: () =>
                                        Navigator.of(c).pop(true),
                                    child: Text(context.l10n.delete)),
                              ],
                            ),
                          );
                          if (ok != true) return;
                          busy.value = true;
                          try {
                            await WalletApiClient.instance.deleteAccount();
                            if (context.mounted) {
                              showWalletToast(
                                  context, context.l10n.account_deleted,
                                  icon: DeeMusiqIcons.verified);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showWalletToast(context, e.toString(),
                                  icon: DeeMusiqIcons.info);
                            }
                          } finally {
                            if (context.mounted) busy.value = false;
                          }
                        },
                  child: Text(context.l10n.account_delete),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

String _consentPurposeLabel(BuildContext context, String purpose) {
  if (purpose == "marketing") return context.l10n.privacy_purpose_marketing;
  if (purpose == "terms") return context.l10n.privacy_purpose_terms;
  return context.l10n.privacy_purpose_privacy;
}

String _consentBlurb(BuildContext context, String purpose) {
  if (purpose == "marketing") return context.l10n.privacy_blurb_marketing;
  if (purpose == "terms") return context.l10n.privacy_blurb_terms;
  return context.l10n.privacy_blurb_privacy;
}
