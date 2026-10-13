import 'dart:io';
import 'dart:ui' show ImageByteFormat;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/l10n/l10n.dart';

/// Person-like audit driver for the real Linux desktop build.
///
/// An AI (or a human) runs the scenarios in this directory via
/// `tool/audit/run_creator_audit.sh`. Every interaction goes through the same
/// primitives a person has — look at a text, tap it, type into a field, flick
/// a list — and every step drops a PNG into the run's screenshot directory so
/// the audit trail can be reviewed without re-running anything.
///
/// This file is test infrastructure, NOT app code: it may shell out to the
/// local backend toolchain (dev "inbox") and degrade gracefully (logged) when
/// the host cannot produce a screenshot.
class AuditConfig {
  final String? backendUrl;
  final String? email;
  final String? password;

  /// A SECOND, unused address for the attach-email gate (the primary seeded
  /// address already belongs to its own account, and emails are unique).
  final String? attachEmail;
  final String? artistName;
  final String shotsDir;

  /// Absolute path to the backend checkout — home of the dev "inbox" mint
  /// (tsx eval against src/util/distributedAbuse.ts) and of npx/tsx.
  final String? backendDir;

  /// Redis URL the backend was started with. When null the backend keeps
  /// email codes in its own process memory and the dev inbox cannot be read.
  final String? redisUrl;

  /// file:// URI of the backend's distributedAbuse.ts for the inbox mint.
  final String? abuseTsUri;

  const AuditConfig({
    required this.backendUrl,
    required this.email,
    required this.password,
    required this.attachEmail,
    required this.artistName,
    required this.shotsDir,
    required this.backendDir,
    required this.redisUrl,
    required this.abuseTsUri,
  });

  bool get hasBackend => (backendUrl ?? "").isNotEmpty;
  bool get canReadDevInbox =>
      hasBackend &&
      (redisUrl ?? "").isNotEmpty &&
      (backendDir ?? "").isNotEmpty &&
      (abuseTsUri ?? "").isNotEmpty;

  static AuditConfig fromEnv() {
    String? env(String key) {
      final v = Platform.environment[key];
      return (v == null || v.isEmpty) ? null : v;
    }

    return AuditConfig(
      backendUrl: env("AUDIT_BACKEND_URL"),
      email: env("AUDIT_EMAIL"),
      password: env("AUDIT_PASSWORD"),
      attachEmail: env("AUDIT_EMAIL2"),
      artistName: env("AUDIT_ARTIST_NAME") ?? "Audit Artist",
      shotsDir:
          env("AUDIT_SHOTS") ?? "${Directory.current.path}/build/audit/manual",
      backendDir: env("AUDIT_BACKEND_DIR"),
      redisUrl: env("AUDIT_REDIS_URL"),
      abuseTsUri: env("AUDIT_ABUSE_TS"),
    );
  }
}

class AuditDriver {
  AuditDriver(this.tester, this.l10n, this.cfg) {
    Directory(cfg.shotsDir).createSync(recursive: true);
    _installErrorCollector();
  }

  final WidgetTester tester;
  final AppLocalizations l10n;
  final AuditConfig cfg;

  void Function(FlutterErrorDetails details)? _previousOnError;

  /// Uncaught app errors are COLLECTED and reported, not swallowed and not
  /// allowed to kill the walk: the default test binding turns every platform
  /// exception (dconf writes, socket hiccups during wallet sync, …) into a
  /// binding assertion that wedges the whole audit. Each error is logged with
  /// its first line here and the full list is summarised by [reportAppErrors]
  /// at the end of the scenario — audit findings, never silent drops.
  final List<String> appErrors = <String>[];

  void _installErrorCollector() {
    // Wrap — never replace — the binding's handler: it owns the test's error
    // accounting and asserts its handler is intact. Full details are logged
    // here for the audit evidence, then forwarded so the binding records the
    // failure with a proper message (an uncaught app error IS a finding).
    _previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      appErrors.add(details.toString());
      debugPrint("[audit] app error (collected):\n${details.toString()}");
      _previousOnError?.call(details);
    };
    addTearDown(() {
      FlutterError.onError = _previousOnError;
    });
  }

  /// Print the collected app-error summary (call at the end of a scenario).
  void reportAppErrors() {
    if (appErrors.isEmpty) {
      debugPrint("[audit] app errors: none");
      return;
    }
    debugPrint("[audit] app errors: ${appErrors.length} collected:");
    for (var i = 0; i < appErrors.length && i < 10; i++) {
      debugPrint("[audit]   #${i + 1}: ${appErrors[i].split("\n").first}");
    }
  }

  /// [tester.runAsync] escapes fake-async for real IO (network, processes,
  /// image encoding). It is nullable; the audit treats null as a hard failure
  /// instead of a mysterious downstream crash.
  Future<T> runAsync<T>(Future<T> Function() fn, {String what = "work"}) async {
    final result = await tester.runAsync(fn);
    if (result == null) {
      fail('audit: runAsync("$what") returned null');
    }
    return result;
  }

  /// Desktop-sized viewport: the sidebar and two-column layouts a desktop
  /// person actually sees, instead of the small default test window.
  Future<void> useDesktopWindow() async {
    tester.view.physicalSize =
        const Size(1440, 900) * tester.view.devicePixelRatio;
    addTearDown(tester.view.reset);
  }

  /// Let animations finish; a never-ending spinner (network wait) must not
  /// fail the audit by itself — the explicit [waitFor]s decide pass/fail.
  Future<void> settle() async {
    try {
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 5),
      );
    } catch (e) {
      debugPrint('[audit] settle: still animating, continuing '
          '(${e.toString().split("\n").first})');
    }
  }

  /// Poll the real (async) app until [finder] matches, pumping frames as the
  /// person's eyes would re-check the screen. Fails the audit with context.
  Future<void> waitFor(Finder finder, {required String what, Duration timeout = const Duration(seconds: 30)}) async {
    final deadline = DateTime.now().add(timeout);
    var warnedAsyncUnavailable = false;
    while (DateTime.now().isBefore(deadline)) {
      if (finder.evaluate().isNotEmpty) {
        await settle();
        debugPrint('[audit] visible: $what');
        return;
      }
      await tester.pump(const Duration(milliseconds: 200));
      // Real-async sleep between pumps; when the binding refuses (its
      // runAsync returns null after reporting an error), pump-only waiting
      // still advances frames — this loop is a poll, not a dependency.
      final tick = await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        return true;
      });
      if (tick != true && !warnedAsyncUnavailable) {
        warnedAsyncUnavailable = true;
        debugPrint("[audit] wait tick: real-async unavailable — pump-only polling");
      }
    }
    await screenshot("FAIL_waiting_for_$what".replaceAll(RegExp(r"\W+"), "_"));
    fail("audit timeout after ${timeout.inSeconds}s waiting for: $what");
  }

  /// A person closes a blocking dialog; so does the audit. Modal AlertDialogs
  /// (e.g. the update announcement) sit above everything with a barrier that
  /// swallows every tap. The update dialog RE-appears seconds after launch
  /// (its metadata is fetched asynchronously), so this polls and pops until
  /// the surface stays clean. Returns the number of dialogs dismissed.
  Future<int> clearBlockingDialogs({int maxPops = 5}) async {
    var dismissed = 0;
    var cleanChecks = 0;
    final deadline = DateTime.now().add(const Duration(seconds: 20));
    while (dismissed < maxPops && DateTime.now().isBefore(deadline)) {
      final dialogs = find.byWidgetPredicate(
        (w) => w is AlertDialog,
        skipOffstage: false,
      );
      if (dialogs.evaluate().isNotEmpty) {
        final ctx = tester.element(dialogs.first);
        final nav = Navigator.of(ctx);
        if (!nav.canPop()) break;
        nav.pop();
        dismissed++;
        cleanChecks = 0;
        await settle();
        debugPrint("[audit] dismissed a blocking dialog");
        continue;
      }
      cleanChecks++;
      if (cleanChecks >= 4) break; // clean for ~2s of checks
      await tester.pump(const Duration(milliseconds: 500));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        return true;
      });
    }
    return dismissed;
  }

  /// Current auto_route path, for diagnosing whether a tap navigated.
  String currentRoutePath() {
    final nav = find.byType(Navigator);
    if (nav.evaluate().isEmpty) return "<no navigator>";
    return tester.element(nav.first).router.currentPath;
  }

  /// Tap a sidebar tile by its icon. The tile's text label is hidden when the
  /// sidebar is collapsed (zero-width), and the NavigationButton's render
  /// object is a sliver (the sidebar scrolls) — so a person aims at the icon,
  /// which is a plain RenderBox.
  Future<void> tapSidebarTile(IconData icon, {required String what}) async {
    final tile = find.ancestor(
      of: find.byIcon(icon),
      matching: find.byType(NavigationButton),
    );
    await waitFor(tile, what: what);
    final iconFinder = find.byIcon(icon);
    final before = currentRoutePath();
    await tester.tap(iconFinder.first, warnIfMissed: true);
    await settle();
    var after = currentRoutePath();
    if (after == before) {
      debugPrint("[audit] tile tap did not change route ($before) — "
          "retrying on the exact icon center");
      final center = tester.getCenter(iconFinder.first);
      await tester.tapAt(center);
      await settle();
      after = currentRoutePath();
    }
    debugPrint("[audit] route after tile tap: $after");
  }

  /// Tap the first visible occurrence of [text] (what a person reads and
  /// taps). Warns (and proceeds) when the string appears more than once.
  Future<void> tapText(String text, {bool last = false}) async {
    final finder = find.text(text);
    final matches = finder.evaluate().length;
    if (matches == 0) {
      fail('audit: no "$text" on screen to tap');
    }
    if (matches > 1) {
      debugPrint('[audit] "$text" occurs $matches times — tapping '
          '${last ? "last" : "first"}');
    }
    await tester.tap(last ? finder.last : finder.first, warnIfMissed: true);
    await settle();
  }

  /// Type into the i-th on-screen text field (document order = visual order
  /// on the gate cards, which have a single Column of fields).
  Future<void> typeIntoFieldAt(int index, String text) async {
    final fields = find.byType(TextField);
    final count = fields.evaluate().length;
    if (count <= index) {
      fail('audit: expected at least ${index + 1} text field(s), found $count');
    }
    await tester.enterText(fields.at(index), text);
    await settle();
    debugPrint('[audit] typed into field #$index');
  }

  /// Type into the field whose placeholder reads [placeholder]. A person
  /// clicks the field first (focus), then types — and the harness reads the
  /// controller back to confirm the value actually committed, retrying once
  /// when the first attempt silently failed (live-window focus races).
  Future<void> typeIntoPlaceholder(String placeholder, String text) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      final fields = find.byType(TextField);
      for (var i = 0; i < fields.evaluate().length; i++) {
        final widget = tester.widget<TextField>(fields.at(i));
        final ph = widget.placeholder;
        if (ph is Text && ph.data == placeholder) {
          if (attempt > 0) {
            final center = tester.getCenter(fields.at(i));
            await tester.tapAt(center);
            await settle();
          } else {
            await tester.tap(fields.at(i), warnIfMissed: true);
            await settle();
          }
          await tester.enterText(fields.at(i), text);
          await settle();
          final committed =
              tester.widget<TextField>(fields.at(i)).controller?.text ?? "";
          debugPrint("[audit] typed into \"$placeholder\" field "
              "(attempt ${attempt + 1}): committed='${committed.isEmpty ? "<empty>" : "ok"}'");
          if (committed == text) return;
          break; // not committed — retry from the top
        }
      }
    }
    fail('audit: could not commit text into the "$placeholder" field');
  }

  /// Flick the page's main list upwards until [text] is on screen (a person
  /// scrolling with the wheel).
  Future<void> scrollUntilText(String text, {int maxFlicks = 15}) async {
    final finder = find.text(text);
    final lists = find.byType(ListView);
    if (lists.evaluate().isEmpty) {
      fail("audit: no scrollable list to search for \"$text\"");
    }
    for (var i = 0; i < maxFlicks; i++) {
      final visible = finder
          .hitTestable(at: Alignment.center)
          .evaluate()
          .isNotEmpty;
      if (visible) {
        debugPrint('[audit] scrolled to: $text');
        return;
      }
      await tester.drag(lists.first, const Offset(0, -320));
      await settle();
    }
    await screenshot("FAIL_scroll_${text.replaceAll(RegExp(r"\W+"), "_")}");
    fail('audit: "$text" never became visible after $maxFlicks flicks');
  }

  /// Capture the biggest repaint boundary as PNG evidence. Best effort by
  /// design — every skip is logged, never silent, and never fails the audit.
  Future<String> screenshot(String name) async {
    final safe = name.replaceAll(RegExp(r"\W+"), "_");
    try {
      RenderRepaintBoundary? best;
      var bestArea = 0.0;
      for (final el in find
          .byType(RepaintBoundary, skipOffstage: false)
          .evaluate()) {
        final ro = el.renderObject;
        if (ro is! RenderRepaintBoundary || !ro.attached) continue;
        final area = ro.size.width * ro.size.height;
        if (area > bestArea) {
          bestArea = area;
          best = ro;
        }
      }
      final view = tester.view.physicalSize / tester.view.devicePixelRatio;
      final screenArea = view.width * view.height;
      if (best != null && bestArea >= screenArea * 0.5) {
        final boundary = best;
        final image = await runAsync(
            () => boundary.toImage(pixelRatio: tester.view.devicePixelRatio),
            what: "frame capture");
        final bytes = await runAsync(
            () => image.toByteData(format: ImageByteFormat.png),
            what: "png encode");
        if (bytes != null) {
          final file = File("${cfg.shotsDir}/$safe.png");
          await file.writeAsBytes(bytes.buffer.asUint8List());
          debugPrint('[audit] screenshot: ${file.path}');
          return file.path;
        }
      }
      final external = await _externalScreenshot(safe);
      if (external.isNotEmpty) return external;
      debugPrint('[audit] screenshot "$safe": no usable capture surface — '
          'state assertions below still hold');
      return "";
    } catch (e) {
      debugPrint('[audit] screenshot "$safe" failed: $e');
      return "";
    }
  }

  /// Poll until either finder matches; returns "a" or "b" for the branch the
  /// person actually sees. Fails with a screenshot on timeout.
  Future<String> waitForEither(
    Finder a,
    String whatA,
    Finder b,
    String whatB, {
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      if (a.evaluate().isNotEmpty) {
        await settle();
        debugPrint("[audit] visible: $whatA");
        return "a";
      }
      if (b.evaluate().isNotEmpty) {
        await settle();
        debugPrint("[audit] visible: $whatB");
        return "b";
      }
      await tester.pump(const Duration(milliseconds: 200));
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 200)));
    }
    await screenshot(
        "FAIL_waiting_for_${whatA}_or_$whatB".replaceAll(RegExp(r"\W+"), "_"));
    fail("audit timeout after ${timeout.inSeconds}s waiting for "
        "'$whatA' or '$whatB'");
  }

  /// The add-email gate (device-session branch): attach the audit email +
  /// password with consent, then confirm with the emailed 6-digit code read
  /// from the dev inbox. Ends right before the claim form appears.
  Future<void> attachEmailAndVerify() async {
    final email = (cfg.attachEmail?.isNotEmpty ?? false)
        ? cfg.attachEmail!
        : (cfg.email ?? "");
    if (email.isEmpty || (cfg.password ?? "").isEmpty) {
      fail("audit: AUDIT_EMAIL/AUDIT_PASSWORD not set by the runner");
    }
    await typeIntoFieldAt(0, email);
    await typeIntoFieldAt(1, cfg.password!);
    await tapText(l10n.agree_privacy_policy);
    await screenshot("gate_credentials_filled");
    await tapText(l10n.creator_save_and_email_code);
    final codeField = find.byWidgetPredicate(
      (w) =>
          w is TextField &&
          w.placeholder is Text &&
          (w.placeholder as Text).data == l10n.signup_code_hint,
    );
    await waitFor(codeField,
        what: "emailed-code entry field",
        timeout: const Duration(seconds: 60));
    await screenshot("gate_code_entry");
    final code = await readDevInboxCode(email);
    await typeIntoPlaceholder(l10n.signup_code_hint, code);
    await tapText(l10n.signup_confirm);
  }

  /// X11 fallback when the widget tree has no full-screen repaint boundary.
  Future<String> _externalScreenshot(String name) async {
    if (Platform.environment["DISPLAY"] == null &&
        Platform.environment["WAYLAND_DISPLAY"] != null) {
      debugPrint('[audit] screenshot "$name": Wayland session — external '
          'capture unavailable');
      return "";
    }
    for (final tool in const ["scrot", "import"]) {
      final which =
          await runAsync(() => Process.run("which", [tool], runInShell: true),
              what: "which $tool");
      if (which.exitCode != 0) continue;
      final path = "${cfg.shotsDir}/$name.png";
      final args = tool == "scrot" ? [path] : ["-window", "root", path];
      final shot = await runAsync(
          () => Process.run(tool, args, runInShell: true),
          what: "$tool capture");
      if (shot.exitCode == 0 && File(path).existsSync()) {
        debugPrint('[audit] screenshot (external $tool): $path');
        return path;
      }
      debugPrint('[audit] $tool capture failed: ${shot.stderr}');
    }
    return "";
  }

  /// The DEV inbox: re-mint the live signup code for [email] through the
  /// backend's own code issuer, so the audit can type what a real person
  /// would read in their mailbox. Requires the backend to run with REDIS_URL
  /// (its KV must be shared, not per-process memory) and npx/tsx on PATH.
  Future<String> readDevInboxCode(String email) async {
    if (!cfg.canReadDevInbox) {
      fail(
        "audit: dev inbox unavailable — start the backend with REDIS_URL set "
        "(tool/audit/run_creator_audit.sh does this) so emailed codes can be "
        "read like a person reads mail",
      );
    }
    final script = File(
        "${Directory.systemTemp.path}/deemusiq-audit-inbox-${DateTime.now().millisecondsSinceEpoch}.mts");
    await script.writeAsString('''
const { issueEmailCode } = await import(process.env.AUDIT_ABUSE_TS);
const code = await issueEmailCode(process.env.AUDIT_INBOX_EMAIL, "signup");
if (!/^\\d{6}\$/.test(code)) {
  console.error("issuer returned a non-code:", code);
  process.exit(1);
}
process.stdout.write("CODE:" + code);
process.exit(0);
''');
    final result = await runAsync(
      () => Process.run(
        "npx",
        ["tsx", script.path],
        workingDirectory: cfg.backendDir,
        environment: {
          ...Platform.environment,
          "REDIS_URL": cfg.redisUrl!,
          "AUDIT_ABUSE_TS": cfg.abuseTsUri!,
          "AUDIT_INBOX_EMAIL": email,
        },
        runInShell: true,
      ),
      what: "dev inbox mint",
    );
    try {
      script.deleteSync();
    } catch (e) {
      debugPrint('[audit] temp inbox script cleanup failed: $e');
    }
    if (result.exitCode != 0) {
      fail("audit: dev inbox mint failed "
          "(exit ${result.exitCode}): ${result.stdout} ${result.stderr}");
    }
    final match = RegExp(r"CODE:(\d{6})").firstMatch(result.stdout);
    if (match == null) {
      fail("audit: dev inbox mint produced no code: ${result.stdout}");
    }
    debugPrint("[audit] dev inbox: collected code for $email");
    return match.group(1)!;
  }
}

/// Desktop-sized viewport BEFORE the first frame, so boot renders at the size
/// a desktop person sees.
void useDesktopViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1440, 900) * tester.view.devicePixelRatio;
  addTearDown(tester.view.reset);
}

/// Wait for the app to actually render: `app.main()` returns while boot is
/// still doing real async work (yt-dlp provisioning, secure storage, splash)
/// before runApp, so the widget tree takes a moment (or minutes on a cold
/// first run) to exist. Polls like a person staring at the splash screen.
Future<AppLocalizations> auditL10n(
  WidgetTester tester, {
  Duration timeout = const Duration(minutes: 5),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    final scaffolds = find.byType(Scaffold);
    if (scaffolds.evaluate().isNotEmpty) {
      final ctx = tester.element(scaffolds.first);
      final l10n = AppLocalizations.of(ctx);
      if (l10n != null) return l10n;
    }
    await tester.pump(const Duration(milliseconds: 250));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 250)));
  }
  fail("audit: the app never rendered a localised screen "
      "within ${timeout.inMinutes} minutes");
}
