import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/services/logger/logger.dart';

/// South Africa Films and Publications Act (FPB) compliance:
/// Dialog shown on first launch requiring users to confirm they are
/// 18 years or older to access explicit content.
class AgeRestrictionDialog extends StatelessWidget {
  const AgeRestrictionDialog({super.key});

  static Future<bool> showIfNeeded(BuildContext context) async {
    if (KVStoreService.ageVerified) return true;

    if (!context.mounted) return false;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AgeRestrictionDialog(),
    );

    if (result == true) {
      await KVStoreService.setAgeVerified(true);
      AppLogger.log.i('User confirmed age 18+');
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(DeeMusiqIcons.warning, color: Colors.amber),
          const Gap(8),
          Text(context.l10n.age_restriction_title).semiBold(),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.age_restriction_explicit).large(),
          const Gap(8),
          Text(context.l10n.age_restriction_fpb).muted(),
          const Gap(12),
          Text(context.l10n.age_restriction_confirm).semiBold(),
        ],
      ),
      actions: [
        Button.secondary(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.age_restriction_under),
        ),
        Button.primary(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(context.l10n.confirm_age_18),
        ),
      ],
    );
  }
}
