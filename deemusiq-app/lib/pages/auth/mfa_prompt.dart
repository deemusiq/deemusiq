import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/extensions/context.dart';

/// Modal second-factor prompt.
///
/// Used by the sign-in flows that have no inline field to reveal (device and
/// Google login) — the account page reveals a code field in place instead.
///
/// Returns the entered code, or null when the user cancels. A cancelled prompt
/// is a dead end by design: the challenge is single-use and short-lived, so
/// backing out means restarting the login rather than leaving a half-authed
/// session behind.
Future<String?> promptMfaCode(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) => const _MfaPromptDialog(),
  );
}

class _MfaPromptDialog extends HookWidget {
  const _MfaPromptDialog();

  @override
  Widget build(BuildContext context) {
    final code = useTextEditingController();

    void submit() {
      final value = code.text.trim();
      if (value.isEmpty) return;
      Navigator.of(context).pop(value);
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Alert(
        title: Text(context.l10n.auth_mfa_required).h4(),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.auth_mfa_body).muted().small(),
            const Gap(12),
            TextField(
              controller: code,
              placeholder: Text(context.l10n.account_totp_code_hint),
              keyboardType: TextInputType.number,
              autofocus: true,
              onSubmitted: (_) => submit(),
            ),
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
              child: Text(context.l10n.auth_mfa_verify_action),
            ),
          ],
        ),
      ),
    );
  }
}