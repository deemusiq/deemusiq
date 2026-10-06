import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/assets.gen.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/modules/getting_started/action_bar.dart';
import 'package:deemusiq/modules/getting_started/blur_card.dart';
import 'package:deemusiq/utils/platform.dart';

class GettingStartedPageGreetingSection extends HookConsumerWidget {
  final VoidCallback onNext;
  const GettingStartedPageGreetingSection({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, ref) {
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
                      Assets.branding.deemusiqLogoPng.image(height: 200),
                      const Gap(24),
                      const Text("DeeMusiq").semiBold().h4(),
                      const Gap(4),
                      Text(
                        kIsMobile
                            ? context.l10n.freedom_of_music_palm
                            : context.l10n.freedom_of_music,
                        textAlign: TextAlign.center,
                      ).light().large().italic(),
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
