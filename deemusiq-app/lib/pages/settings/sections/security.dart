import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/modules/settings/section_card_with_heading.dart';
import 'package:deemusiq/services/auth/biometric_lock.dart';
import 'package:deemusiq/services/auth/google_auth.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';

/// Security section: fingerprint unlock + Gmail personalization status.
/// Fingerprint uses the OS biometric prompt (local_auth); Gmail sign-in drives
/// cross-device recommendations on the backend (`gmailLinked`).
class SettingsSecuritySection extends HookConsumerWidget {
  const SettingsSecuritySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lockEnabled = useState<bool?>(null);
    final canBiometric = useState(false);
    final biometrics = useState<String>("…");
    final gmail = useState<Map<String, dynamic>?>(null);
    final testing = useState(false);

    useEffect(() {
      () async {
        lockEnabled.value = await BiometricLockService.instance.isEnabled();
        canBiometric.value =
            await BiometricLockService.instance.canCheckBiometrics();
        final types =
            await BiometricLockService.instance.availableBiometrics();
        biometrics.value = types.isEmpty
            ? l10n.security_biometrics_none
            : types.map((t) => t.name).join(", ");
        if (WalletApiClient.instance.isConfigured) {
          try {
            gmail.value = await WalletApiClient.instance
                .fetchRecommendationProfile();
          } catch (e) {
            // The linked-account badge is decorative here — the settings page
            // still renders without it.
            AppLogger.log.w('[SecuritySettings] recommendation profile fetch failed: $e');
          }
        }
      }();
      return null;
    }, const []);

    Future<void> toggle(bool v) async {
      if (v && !canBiometric.value) {
        showToast(
          context: context,
          location: ToastLocation.topRight,
          builder: (context, overlay) {
            return SurfaceCard(
              child: Basic(
                title: Text(context.l10n.security_biometrics_unavailable),
                subtitle: Text(context.l10n.security_no_biometrics_enrolled),
              ),
            );
          },
        );
        return;
      }
      if (v) {
        testing.value = true;
        final ok = await BiometricLockService.instance.authenticate(
          reason: context.l10n.security_unlock_prompt_reason,
        );
        if (!context.mounted) return;
        testing.value = false;
        if (!ok) return;
      }
      await BiometricLockService.instance.setEnabled(v);
      if (context.mounted) lockEnabled.value = v;
    }

    return SectionCardWithHeading(
      heading: context.l10n.security_heading,
      children: [
        Checkbox(
          state: lockEnabled.value == true
              ? CheckboxState.checked
              : CheckboxState.unchecked,
          onChanged: (s) => toggle(s == CheckboxState.checked),
          trailing: Text(context.l10n.security_fingerprint_unlock),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40, bottom: 8),
          child: Text(
            lockEnabled.value == true
                ? "${context.l10n.security_lock_enabled}${testing.value ? " ${context.l10n.verifying}" : ""}"
                : canBiometric.value
                    ? context.l10n
                        .security_biometrics_available(biometrics.value)
                    : context.l10n.security_no_biometrics(biometrics.value),
          ).muted().xSmall(),
        ),
        const Divider(),
        Row(
          children: [
            const Icon(DeeMusiqIcons.google, size: 16),
            const Gap(8),
            Expanded(child: Text(context.l10n.security_gmail_title)),
            if (gmail.value != null)
              Text(
                (gmail.value!["gmailLinked"] == true)
                    ? context.l10n.security_gmail_linked(
                        (gmail.value!["likes"] as num?)?.toInt() ?? 0)
                    : context.l10n.security_gmail_not_linked,
              ).muted().xSmall(),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32, top: 4),
          child: Text(context.l10n.security_gmail_body).muted().xSmall(),
        ),
        const Gap(4),
        FutureBuilder<bool>(
          future: GoogleAuthService.instance.isSignedIn(),
          builder: (context, snap) => Text(
            snap.data == true
                ? context.l10n.security_google_active
                : context.l10n.security_google_inactive,
          ).muted().xSmall(),
        ),
      ],
    );
  }
}
