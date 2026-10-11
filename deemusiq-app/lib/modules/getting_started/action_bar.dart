import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/extensions/context.dart';

/// Bottom-pinned action bar shared by the getting-started sections: a tall,
/// full-width primary CTA with an optional secondary Previous button beside
/// it. Vertical padding of 16 keeps every touch target above 48dp.
class GettingStartedActionBar extends StatelessWidget {
  final VoidCallback onPrimary;
  final VoidCallback? onPrevious;
  final String? primaryLabel;
  final IconData? primaryIcon;

  const GettingStartedActionBar({
    super.key,
    required this.onPrimary,
    this.onPrevious,
    this.primaryLabel,
    this.primaryIcon,
  });

  static final _primaryStyle = ButtonVariance.primary.copyWith(
    padding: (context, states, value) =>
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
  static final _secondaryStyle = ButtonVariance.secondary.copyWith(
    padding: (context, states, value) =>
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  @override
  Widget build(BuildContext context) {
    final icon = primaryIcon;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          spacing: 12,
          children: [
            if (onPrevious != null)
              Expanded(
                child: Button.secondary(
                  style: _secondaryStyle,
                  leading: const Icon(DeeMusiqIcons.angleLeft),
                  onPressed: onPrevious,
                  child: Text(context.l10n.previous),
                ),
              ),
            Expanded(
              flex: 2,
              child: Button.primary(
                style: _primaryStyle,
                leading: icon != null ? Icon(icon) : null,
                trailing: icon == null
                    ? const Icon(DeeMusiqIcons.angleRight)
                    : null,
                onPressed: onPrimary,
                child: Text(primaryLabel ?? context.l10n.next),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
