import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/modules/settings/section_card_with_heading.dart';
import 'package:deemusiq/services/auth/biometric_lock.dart';
import 'package:deemusiq/services/auth/google_auth.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';

/// Security section: fingerprint unlock + Gmail personalization status.
/// Fingerprint uses the OS biometric prompt (local_auth); Gmail sign-in drives
/// cross-device recommendations on the backend (`gmailLinked`).
class SettingsSecuritySection extends HookConsumerWidget {
  const SettingsSecuritySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        biometrics.value =
            types.isEmpty ? "none detected" : types.map((t) => t.name).join(", ");
        if (WalletApiClient.instance.isConfigured) {
          try {
            gmail.value = await WalletApiClient.instance
                .fetchRecommendationProfile();
          } catch (_) {}
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
            return const SurfaceCard(
              child: Basic(
                title: Text("Biometrics unavailable"),
                subtitle: Text(
                  "No fingerprint or face unlock is enrolled on this device. "
                  "Set one up in your system settings first.",
                ),
              ),
            );
          },
        );
        return;
      }
      if (v) {
        testing.value = true;
        final ok = await BiometricLockService.instance.authenticate(
          reason: 'Enable fingerprint unlock for DeeMusiq',
        );
        testing.value = false;
        if (!ok) return;
      }
      await BiometricLockService.instance.setEnabled(v);
      lockEnabled.value = v;
    }

    return SectionCardWithHeading(
      heading: "Security & personalization",
      children: [
        Checkbox(
          state: lockEnabled.value == true
              ? CheckboxState.checked
              : CheckboxState.unchecked,
          onChanged: (s) => toggle(s == CheckboxState.checked),
          trailing: const Text("Fingerprint unlock"),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40, bottom: 8),
          child: Text(
            lockEnabled.value == true
                ? "DeeMusiq locks on start and after 2 min away. ${testing.value ? "Verifying…" : ""}"
                : canBiometric.value
                    ? "Available on this device (${biometrics.value}). Enable to require fingerprint / face / PIN on start."
                    : "No biometrics enrolled on this device (${biometrics.value}).",
          ).muted().xSmall(),
        ),
        const Divider(),
        Row(
          children: [
            const Icon(DeeMusiqIcons.google, size: 16),
            const Gap(8),
            const Expanded(child: Text("Gmail personalization")),
            if (gmail.value != null)
              Text(
                (gmail.value!["gmailLinked"] == true)
                    ? "linked · ${gmail.value!["likes"] ?? 0} likes"
                    : "not linked",
              ).muted().xSmall(),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32, top: 4),
          child: const Text(
            "Sign in with Google (Creator Studio or Account) to carry likes and listening history "
            "across devices — For You recommendations follow your Gmail identity.",
          ).muted().xSmall(),
        ),
        const Gap(4),
        FutureBuilder<bool>(
          future: GoogleAuthService.instance.isSignedIn(),
          builder: (context, snap) => Text(
            snap.data == true ? "Google session active on this device." : "Google session not active.",
          ).muted().xSmall(),
        ),
      ],
    );
  }
}
