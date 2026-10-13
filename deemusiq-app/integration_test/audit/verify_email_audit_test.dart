import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:integration_test/integration_test.dart';

import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/main.dart' as app;

import 'audit_harness.dart';

/// Creator Studio audit — the verify-your-email branch.
///
/// What a person with a device-only account does: sign in with the device
/// (limited), open Creator Studio, attach an email + password, receive a
/// 6-digit code by email, type it in, and land on the claimed studio.
///
/// The "mailbox" is the dev inbox: the backend mints the live code through
/// its own issuer (requires REDIS_URL — the runner wires this). Against a
/// real deployment a person simply reads their mail; the harness reads the
/// dev equivalent so the same UI path is exercised end-to-end.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final cfg = AuditConfig.fromEnv();

  testWidgets("creator studio: attach email -> emailed code -> verified",
      (tester) async {
    if (!cfg.hasBackend) {
      fail("audit: this scenario needs AUDIT_BACKEND_URL (it exercises the "
          "server-verified email flow)");
    }
    if ((cfg.email ?? "").isEmpty || (cfg.password ?? "").isEmpty) {
      fail("audit: AUDIT_EMAIL/AUDIT_PASSWORD not set by the runner");
    }

    useDesktopViewport(tester);
    app.main([]);
    final l10n = await auditL10n(tester);
    final d = AuditDriver(tester, l10n, cfg);
    await d.settle();
    await d.screenshot("b01_first_screen");

    // ── 1. First-run onboarding → ends on the auth page ──
    if (find.text(l10n.skip_this_nonsense).evaluate().isNotEmpty) {
      await d.tapText(l10n.skip_this_nonsense);
      await d.waitFor(find.text(l10n.install_a_metadata_provider),
          what: "onboarding final page");
      await d.tapText(l10n.install_a_metadata_provider);
      await d.settle();
    }

    // ── 2. Sign in with the device (limited) like a person would ──
    await d.waitFor(find.text(l10n.continue_with_device_limited),
        what: "device sign-in button");
    await d.screenshot("b02_auth_page");
    await d.tapText(l10n.continue_with_device_limited);

    // ── 3. Sidebar → Creator Studio → the add-email gate ──
    await d.waitFor(find.text(l10n.browse),
        what: "home sidebar after device sign-in",
        timeout: const Duration(seconds: 60));
    await d.clearBlockingDialogs();
    await d.tapSidebarTile(DeeMusiqIcons.upload,
        what: "sidebar Creator Studio tile");
    await d.clearBlockingDialogs();
    await d.waitFor(find.text(l10n.creator_add_email_title),
        what: "add-email gate for a device-only account",
        timeout: const Duration(seconds: 60));
    await d.screenshot("b03_add_email_gate");

    // ── 4. Attach email + password (consent checkbox included) ──
    await d.typeIntoFieldAt(0, cfg.email!);
    await d.typeIntoFieldAt(1, cfg.password!);
    await d.tapText(l10n.agree_privacy_policy);
    await d.screenshot("b04_credentials_filled");
    await d.tapText(l10n.creator_save_and_email_code);

    // ── 5. Read the emailed code from the dev inbox and type it ──
    await d.waitFor(
        find.byWidgetPredicate((w) =>
            w is TextField &&
            w.placeholder is Text &&
            (w.placeholder as Text).data == l10n.signup_code_hint),
        what: "emailed-code entry field",
        timeout: const Duration(seconds: 60));
    await d.screenshot("b05_code_entry");
    final code = await d.readDevInboxCode(cfg.email!);
    await d.typeIntoPlaceholder(l10n.signup_code_hint, code);

    // ── 6. Verified: the studio dashboard appears ──
    await d.tapText(l10n.signup_confirm);
    await d.waitFor(find.text(l10n.creator_claim_title),
        what: "claimed studio dashboard after verification",
        timeout: const Duration(seconds: 60));
    await d.screenshot("b06_verified_dashboard");
    d.reportAppErrors();
  });
}

