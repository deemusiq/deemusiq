import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/services/auth/biometric_lock.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';

/// Full-screen gate shown on cold start (and after a 2-min background gap)
/// when fingerprint unlock is enabled in Settings → Security.
class AppLockScreen extends HookConsumerWidget {
  final VoidCallback onUnlocked;
  const AppLockScreen({super.key, required this.onUnlocked});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = useState(false);
    final failed = useState(false);
    final checked = useState(false);

    Future<void> prompt() async {
      if (busy.value) return;
      busy.value = true;
      failed.value = false;
      try {
        final ok = await BiometricLockService.instance.authenticate();
        if (!context.mounted) return;
        if (ok) {
          onUnlocked();
        } else {
          failed.value = true;
        }
      } finally {
        if (context.mounted) {
          busy.value = false;
          checked.value = true;
        }
      }
    }

    useEffect(() {
      // Auto-prompt once when the gate appears.
      Future.microtask(prompt);
      return null;
    }, const []);

    return Scaffold(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(DeeMusiqIcons.verified, size: 48),
              const Gap(16),
              const Text("DeeMusiq is locked").large().semiBold(),
              const Gap(6),
              const Text(
                "Use your fingerprint, face or device PIN to continue.",
                textAlign: TextAlign.center,
              ).muted().small(),
              const Gap(20),
              Button.primary(
                onPressed: busy.value ? null : prompt,
                child: Text(busy.value ? "Verifying…" : "Unlock"),
              ),
              if (failed.value && checked.value) ...[
                const Gap(8),
                const Text("Unlock failed — try again.").muted().xSmall(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
