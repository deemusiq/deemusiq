import 'package:shadcn_flutter/shadcn_flutter.dart';

extension DeeMusiqColorScheme on ColorScheme {
  /// shadcn_flutter 0.0.47 marks the destructive-foreground color as legacy
  /// but ships no successor slot, and every DeeMusiq theme still populates
  /// it — centralize the single tolerated read so an upstream removal
  /// touches exactly one place.
  Color get onDestructive =>
      // ignore: deprecated_member_use
      destructiveForeground;
}
