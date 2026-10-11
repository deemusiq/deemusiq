import 'package:duration/locale.dart';
import 'package:duration/duration.dart';

extension DurationToHumanReadableString on Duration {
  String toHumanReadableString({padZero = true}) {
    final mm = inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, !padZero && inHours == 0 ? '' : "0");
    final ss = inSeconds.remainder(60).toString().padLeft(2, "0");

    if (inHours > 0) {
      final hh = inHours.toString().padLeft(2, !padZero ? '' : "0");
      return "$hh:$mm:$ss";
    }

    return "$mm:$ss";
  }

  String format({
    DurationTersity tersity = DurationTersity.second,
    DurationTersity upperTersity = DurationTersity.week,
    DurationLocale locale = const EnglishDurationLocale(),
    String? spacer,
    String? delimiter,
    String? conjugation,
    bool abbreviated = false,
  }) =>
      printDuration(
        this,
        tersity: tersity,
        upperTersity: upperTersity,
        locale: locale,
        spacer: spacer,
        delimiter: delimiter,
        conjugation: conjugation,
        abbreviated: abbreviated,
      );
}

extension ParseDuration on Duration {
  /// Parses `ss`, `mm:ss` or `h:mm:ss` (whitespace trimmed). Throws a
  /// [FormatException] with context on bad input — callers must catch and
  /// show a user-visible fallback, never let it crash the player.
  static Duration fromString(String duration) {
    final parts = duration.trim().split(':').reversed.toList();
    if (parts.isEmpty || parts.length > 3) {
      throw FormatException('Expected ss, mm:ss or h:mm:ss', duration);
    }
    final numbers = <int>[];
    for (final part in parts) {
      final value = int.tryParse(part.trim());
      if (value == null || value < 0) {
        throw FormatException('Expected ss, mm:ss or h:mm:ss', duration);
      }
      numbers.add(value);
    }
    if (numbers.length > 1 && (numbers[0] > 59 || numbers[1] > 59)) {
      throw FormatException('Minutes and seconds must be 0-59', duration);
    }
    return Duration(
      hours: numbers.length > 2 ? numbers[2] : 0,
      minutes: numbers.length > 1 ? numbers[1] : 0,
      seconds: numbers[0],
    );
  }
}
