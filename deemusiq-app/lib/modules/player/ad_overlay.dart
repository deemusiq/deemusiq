import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/services/ad_roll/ad_roll_service.dart';

/// Full-player interstitial shown while an ad break is running. Purely
/// presentational: [AdRollService] owns the countdown and ends the break even
/// when this overlay is not on screen — the local timer only repaints the
/// progress bar and unlocks the skip button.
class AdOverlay extends HookConsumerWidget {
  final VoidCallback? onSkip;

  const AdOverlay({super.key, this.onSkip});

  static const _skipAfterSeconds = 5;

  @override
  Widget build(BuildContext context, ref) {
    final theme = Theme.of(context);
    final currentAd = AdRollService.instance.currentAd;

    if (currentAd == null) {
      return const SizedBox.shrink();
    }

    final duration = currentAd.durationSeconds;
    final skippable = currentAd.skippable;
    final initialElapsed = AdRollService.instance.adElapsedSeconds;
    final elapsed = useState(initialElapsed);
    final canSkip = useState(initialElapsed >= _skipAfterSeconds);

    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        elapsed.value = AdRollService.instance.adElapsedSeconds;
        if (elapsed.value >= _skipAfterSeconds) {
          canSkip.value = true;
        }
        if (elapsed.value >= duration) {
          timer.cancel();
        }
      });

      return () => timer.cancel();
    }, []);

    final progress =
        duration > 0 ? (elapsed.value / duration).clamp(0.0, 1.0) : 0.0;
    final remaining = (duration - elapsed.value).clamp(0, duration);

    return Container(
      color: theme.colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Gap(32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.ad_units,
                    size: 16, color: theme.colorScheme.primary),
                const Gap(6),
                Text(
                  'Ad',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: theme.colorScheme.primary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const Gap(48),
          Text(
            currentAd.label,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ).withPadding(horizontal: 32),
          const Gap(8),
          Text(
            currentAd.tagline,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ).withPadding(horizontal: 32),
          const Gap(32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
              ),
            ),
          ),
          const Gap(8),
          Text(
            '${remaining}s',
            style: TextStyle(
                fontSize: 12, color: theme.colorScheme.mutedForeground),
          ),
          const Gap(24),
          if (skippable && canSkip.value)
            Button.outline(
              onPressed: () {
                AdRollService.instance.onSkipAd();
                onSkip?.call();
              },
              child: const Text('Skip Ad'),
            ).withPadding(horizontal: 48),
          if (skippable && !canSkip.value)
            Button.outline(
              onPressed: null,
              child: Text(
                'Skip in ${(_skipAfterSeconds - elapsed.value).clamp(0, _skipAfterSeconds)}s',
              ),
            ).withPadding(horizontal: 48),
          const Gap(32),
        ],
      ),
    );
  }
}
