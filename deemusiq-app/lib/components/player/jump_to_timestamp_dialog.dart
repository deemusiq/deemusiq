import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/extensions/duration.dart';
import 'package:deemusiq/services/logger/logger.dart';

/// Jump-to-timestamp prompt (accepts `ss`, `mm:ss`, `h:mm:ss`).
///
/// Returns the parsed [Duration], or null when the user cancels. An invalid
/// entry stays in the dialog with an inline error instead of closing — the
/// parse failure is logged with context and never crashes the player.
Future<Duration?> promptJumpToTimestamp(BuildContext context) {
  return showDialog<Duration>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) => const _JumpToTimestampDialog(),
  );
}

class _JumpToTimestampDialog extends HookWidget {
  const _JumpToTimestampDialog();

  @override
  Widget build(BuildContext context) {
    final input = useTextEditingController();
    final error = useState<String?>(null);
    final theme = Theme.of(context);

    void submit() {
      final raw = input.text.trim();
      if (raw.isEmpty) return;
      try {
        final target = ParseDuration.fromString(raw);
        if (!context.mounted) return;
        Navigator.of(context).pop(target);
      } on FormatException catch (e) {
        AppLogger.log.w('[JumpToTimestamp] invalid timestamp "$raw": $e');
        error.value = context.l10n.seek_timestamp_invalid;
      }
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Alert(
        title: Text(context.l10n.seek_to_timestamp).h4(),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: input,
              placeholder: Text(context.l10n.seek_timestamp_hint),
              autofocus: true,
              onSubmitted: (_) => submit(),
              onChanged: (_) {
                if (error.value != null) error.value = null;
              },
            ),
            if (error.value != null) ...[
              const Gap(8),
              Text(
                error.value!,
                style: theme.typography.small.copyWith(
                  color: theme.colorScheme.destructive,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Button.outline(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.cancel),
            ),
            const Gap(8),
            Button.primary(
              onPressed: submit,
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
