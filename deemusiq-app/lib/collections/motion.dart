import 'package:flutter/widgets.dart';

/// Single source of truth for animation durations and curves.
/// Material 3 motion: entrances decelerate, exits accelerate, and nothing
/// interactive runs longer than 500 ms.
class AppMotion {
  AppMotion._();

  // Durations
  static const Duration micro = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration stagger = Duration(milliseconds: 60);

  // Material 3 easing curves
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve emphasizedAccelerate = Cubic(0.3, 0.0, 0.8, 0.15);
  static const Curve standard = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve entrance = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
}

/// True when the user enabled "reduce motion" in system accessibility settings.
bool reduceMotion(BuildContext context) {
  return MediaQuery.maybeOf(context)?.disableAnimations == true;
}

/// [duration] when animations are enabled, [Duration.zero] under reduce-motion.
Duration motionDuration(BuildContext context, Duration duration) {
  return reduceMotion(context) ? Duration.zero : duration;
}
