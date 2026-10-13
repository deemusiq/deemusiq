import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/collections/routes.gr.dart';
import 'package:deemusiq/main.dart' as app;
import 'package:deemusiq/pages/auth/auth.dart';

import 'audit_harness.dart';

/// Creator Studio audit — the email + password gate.
///
/// What a real person does, step by step, on the Linux desktop build:
///   first run → skip onboarding → (relaunch lands on Home) → open the
///   sidebar's Creator Studio tile → the email sign-in gate is shown, the
///   dashboard is NOT → sign in with an email + password account whose
///   address was already confirmed → claim an artist name → the studio
///   dashboard shows stats + the song-submission form → the verification
///   entry point is reachable.
///
/// The verified account is seeded by the runner (tool/audit/) because the
/// emailed code lands in a mailbox the harness cannot open; scenario
/// verify_email_audit_test.dart exercises the actual code-entry flow.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final cfg = AuditConfig.fromEnv();

  testWidgets("creator studio: email gate -> sign in -> claim -> submit form",
      (tester) async {
    useDesktopViewport(tester);
    app.main([]);
    final l10n = await auditL10n(tester);
    final d = AuditDriver(tester, l10n, cfg);
    await d.settle();
    // The update announcement pops a few seconds after launch — clear it
    // before anything else.
    await d.clearBlockingDialogs();
    await d.screenshot("01_first_screen");

    // ── 1. First-run onboarding (a person taps Skip, then the final CTA).
    //       The CTA persists onboarding state and routes onward; taps can
    //       lose races with the section's entrance animation, so the step is
    //       retried until the app has actually left the wizard. ──
    if (find.text(l10n.skip_this_nonsense).evaluate().isNotEmpty) {
      await d.tapText(l10n.skip_this_nonsense);
      await d.waitFor(find.text(l10n.install_a_metadata_provider),
          what: "onboarding final page");
      await d.screenshot("02_onboarding_final");
      for (var attempt = 0; attempt < 3; attempt++) {
        final onAuth = find.byType(AuthPage).evaluate().isNotEmpty;
        final onHome = find.byIcon(DeeMusiqIcons.upload).evaluate().isNotEmpty;
        if (onAuth || onHome) break;
        await d.clearBlockingDialogs();
        await d.tapText(l10n.install_a_metadata_provider);
        await d.waitForEither(
          find.byType(AuthPage),
          "auth page after onboarding",
          find.byIcon(DeeMusiqIcons.upload),
          "home sidebar after onboarding",
          timeout: const Duration(seconds: 20),
        );
      }
    }
    await d.screenshot("03_after_onboarding");

    // ── 2. If onboarding ended on the auth page, simulate an app relaunch:
    //       the launch guard only checks onboarding state, so a person who
    //       reopens the app lands on Home with the sidebar, still signed out.
    if (find.byType(AuthPage).evaluate().isNotEmpty) {
      final ctx = tester.element(find.byType(AuthPage));
      ctx.router.replaceAll([const HomeRoute()]);
      await d.settle();
    }

    // ── 3. A person closes whatever modal pops over Home (e.g. the update
    //       announcement) before aiming at the sidebar tile ──
    await d.clearBlockingDialogs();
    await d.screenshot("04_home_with_sidebar");
    await d.tapSidebarTile(DeeMusiqIcons.upload,
        what: "sidebar Creator Studio tile");
    // A dialog may have raced the navigation — clear it and make sure the
    // studio actually opened.
    await d.clearBlockingDialogs();

    if (!cfg.hasBackend) {
      // No backend configured: the studio must say so, not show a broken form.
      await d.waitFor(find.text(l10n.creator_connect_title),
          what: "offline connect card");
      await d.screenshot("05_offline_gate");
      return;
    }

    // ── 4. Which gate does the person see? The app silently device-logs-in
    //       when Home loads (wallet sync), so a fresh install usually arrives
    //       with a session: the ADD-EMAIL gate. The signed-out EMAIL SIGN-IN
    //       gate only appears when no session could be acquired. Both are
    //       audited; the dashboard must never leak through either.
    final whichGate = await d.waitForEither(
      find.text(l10n.creator_email_gate_title),
      "email sign-in gate",
      find.text(l10n.creator_add_email_title),
      "add-email gate (silent device session)",
    );
    expect(find.text(l10n.creator_your_songs).evaluate().isEmpty,
        isTrue,
        reason: "gated person must never see the creator dashboard");
    await d.screenshot("05_gate");

    if ((cfg.email ?? "").isEmpty || (cfg.password ?? "").isEmpty) {
      fail("audit: AUDIT_EMAIL/AUDIT_PASSWORD not set by the runner");
    }

    // ── 5. Through the gate to a verified email account ──
    if (whichGate == "a") {
      await d.typeIntoFieldAt(0, cfg.email!);
      await d.typeIntoFieldAt(1, cfg.password!);
      await d.screenshot("06_gate_filled");
      await d.tapText(l10n.creator_sign_in_cta);
    } else {
      await d.attachEmailAndVerify();
    }

    // ── 6. First login: claim the artist name (the creator sets it) ──
    await d.waitFor(find.text(l10n.creator_claim_title),
        what: "claim-your-artist-name form", timeout: const Duration(seconds: 60));
    await d.screenshot("07_claim_profile");
    await d.typeIntoFieldAt(0, cfg.artistName!);
    await d.tapText(l10n.creator_create_profile);

    // ── 7. Claimed: the dashboard shows the profile + song pipeline ──
    await d.waitFor(find.text(l10n.creator_your_songs),
        what: "claimed studio dashboard", timeout: const Duration(seconds: 60));
    await d.screenshot("08_dashboard");

    // ── 8. The song-submission form is present (native file picker out of
    //       scope for the harness — a person picks files themselves) ──
    await d.scrollUntilText(l10n.creator_submit_song_title);
    await d.screenshot("09_submit_song_form");
    expect(find.text(l10n.creator_pick_audio).hitTestable().evaluate(),
        isNotEmpty,
        reason: "song form must offer the audio picker");
    expect(find.text(l10n.creator_pick_cover).hitTestable().evaluate(),
        isNotEmpty,
        reason: "song form must offer the cover picker");

    // ── 9. Verification entry point is reachable ──
    await d.scrollUntilText(l10n.creator_get_verified);
    await d.tapText(l10n.creator_get_verified);
    await d.screenshot("10_verification_page");
    d.reportAppErrors();
  });
}

