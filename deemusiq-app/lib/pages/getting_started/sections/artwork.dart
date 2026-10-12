import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/assets.gen.dart';

/// First-run artwork strip: the bundled onboarding/splash art, shown on the
/// greeting step so the shipped images are previewed instead of dead weight.
/// Purely decorative — excluded from semantics.
class GettingStartedArtworkStrip extends StatelessWidget {
  const GettingStartedArtworkStrip({super.key});

  // Not const: AssetGenImage getters are not constant expressions.
  static final _art = [
    Assets.images.onboard1,
    Assets.images.onboard2,
    Assets.images.onboard3,
    Assets.images.onboard4,
    Assets.images.onboard5,
    Assets.images.splash1,
    Assets.images.splash2,
    Assets.images.splash3,
    Assets.images.splash4,
  ];

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: SizedBox(
        height: 132,
        child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: _art.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final art = _art[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: art.image(
              height: 132,
              width: 110,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
          );
        },
        ),
      ),
    );
  }
}
