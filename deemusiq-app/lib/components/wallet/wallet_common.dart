import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/l10n/generated/app_localizations.dart';

/// Brand accent used across the wallet feature.
const deeMusiqOrange = Color(0xFFFF5722);

/// Formats a token count with thousands separators, e.g. 1234 -> "1,234".
String formatTokens(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i != 0 && (digits.length - i) % 3 == 0) buffer.write(",");
    buffer.write(digits[i]);
  }
  return "${value < 0 ? "-" : ""}$buffer";
}

/// Human, compact relative time, e.g. "just now", "5m ago", "3d ago".
String relativeTime(AppLocalizations l10n, DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inSeconds < 45) return l10n.time_just_now;
  if (diff.inMinutes < 60) return l10n.time_minutes_ago(diff.inMinutes);
  if (diff.inHours < 24) return l10n.time_hours_ago(diff.inHours);
  if (diff.inDays < 7) return l10n.time_days_ago(diff.inDays);
  if (diff.inDays < 30) return l10n.time_weeks_ago((diff.inDays / 7).floor());
  if (diff.inDays < 365) return l10n.time_months_ago((diff.inDays / 30).floor());
  return l10n.time_years_ago((diff.inDays / 365).floor());
}

/// A small confirmation toast in DeeMusiq style.
void showWalletToast(
  BuildContext context,
  String message, {
  IconData icon = DeeMusiqIcons.token,
}) {
  showToast(
    context: context,
    location: ToastLocation.bottomCenter,
    builder: (context, overlay) {
      return SurfaceCard(
        child: Basic(
          leading: Icon(icon, color: deeMusiqOrange),
          title: Text(message),
        ),
      );
    },
  );
}
