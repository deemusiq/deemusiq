import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/assets.gen.dart';
import 'package:deemusiq/collections/motion.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/modules/getting_started/action_bar.dart';
import 'package:deemusiq/modules/getting_started/blur_card.dart';
import 'package:deemusiq/pages/getting_started/sections/artwork.dart';
import 'package:deemusiq/utils/platform.dart';

class GettingStartedPageGreetingSection extends HookConsumerWidget {
  final VoidCallback onNext;
  const GettingStartedPageGreetingSection({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, ref) {
    final entrance = useAnimationController(duration: AppMotion.slow);
    useEffect(() {
      entrance.forward();
      return null;
    }, [entrance]);

    Widget stagger(int index, Widget child) {
      if (reduceMotion(context)) return child;
      final animation = CurvedAnimation(
        parent: entrance,
        curve: Interval(
          0.16 * index,
          (0.55 + 0.16 * index).clamp(0.0, 1.0),
          curve: AppMotion.emphasized,
        ),
      );
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: BlurCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      stagger(
                        0,
                        Assets.branding.deemusiqLogoPng.image(height: 200),
                      ),
                      const Gap(24),
                      stagger(1, const Text("DeeMusiq").semiBold().h4()),
                      const Gap(4),
                      stagger(
                        2,
                        Text(
                          kIsMobile
                              ? context.l10n.freedom_of_music_palm
                              : context.l10n.freedom_of_music,
                          textAlign: TextAlign.center,
                        ).light().large().italic(),
                      ),
                      const Gap(24),
                      stagger(3, const GettingStartedArtworkStrip()),
                    ],
                  ),
                ),
              ),
            ),
          ),
          GettingStartedActionBar(
            onPrimary: onNext,
            primaryLabel: context.l10n.get_started,
          ),
        ],
      ),
    );
  }
}
