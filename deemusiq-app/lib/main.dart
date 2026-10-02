import 'dart:io';
import 'dart:async';
import 'dart:ui';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter_discord_rpc/flutter_discord_rpc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:home_widget/home_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:media_kit/media_kit.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:smtc_windows/smtc_windows.dart';
import 'package:deemusiq/collections/env.dart';
import 'package:deemusiq/collections/http-override.dart';
import 'package:deemusiq/collections/intents.dart';
import 'package:deemusiq/collections/routes.dart';
import 'package:deemusiq/hooks/configurators/use_close_behavior.dart';
import 'package:deemusiq/hooks/configurators/use_deep_linking.dart';
import 'package:deemusiq/hooks/configurators/use_disable_battery_optimizations.dart';
import 'package:deemusiq/hooks/configurators/use_fix_window_stretching.dart';
import 'package:deemusiq/hooks/configurators/use_get_storage_perms.dart';
import 'package:deemusiq/hooks/configurators/use_has_touch.dart';
import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/modules/settings/color_scheme_picker_dialog.dart';
import 'package:deemusiq/components/auth/app_lock_screen.dart';
import 'package:deemusiq/pages/integrity/tampered.dart';
import 'package:deemusiq/services/auth/biometric_lock.dart';
import 'package:deemusiq/provider/audio_player/audio_player_streams.dart';
import 'package:deemusiq/provider/database/database.dart';
import 'package:deemusiq/provider/glance/glance.dart';
import 'package:deemusiq/provider/metadata_plugin/metadata_plugin_provider.dart';
import 'package:deemusiq/provider/offline_queue/offline_queue_provider.dart';
import 'package:deemusiq/provider/server/bonsoir.dart';
import 'package:deemusiq/provider/server/server.dart';
import 'package:deemusiq/provider/tray_manager/tray_manager.dart';
import 'package:deemusiq/l10n/l10n.dart';
import 'package:deemusiq/provider/connect/clients.dart';
import 'package:deemusiq/provider/user_preferences/user_preferences_provider.dart';
import 'package:deemusiq/services/audio_player/audio_player.dart';
import 'package:deemusiq/services/cli/cli.dart';
import 'package:deemusiq/services/integrity/integrity_service.dart';
import 'package:deemusiq/services/wallet/payment_service.dart'
    show PaymentGatewayConfig;
import 'package:deemusiq/services/youtube_engine/direct_ytdlp_engine.dart';
import 'package:deemusiq/services/youtube_engine/yt_dlp_provisioner.dart';
import 'package:deemusiq/services/kv_store/encrypted_kv_store.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/wm_tools/wm_tools.dart';
import 'package:deemusiq/modules/player/player_controls.dart';
import 'package:deemusiq/services/ad_roll/ad_roll_service.dart';
import 'package:deemusiq/services/connectivity_adapter.dart';
import 'package:deemusiq/utils/deep_link_handler.dart';
import 'package:deemusiq/utils/migrations/sandbox.dart';
import 'package:deemusiq/utils/platform.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:window_manager/window_manager.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:yt_dlp_dart/yt_dlp_dart.dart';
import 'package:flutter_new_pipe_extractor/flutter_new_pipe_extractor.dart';

Future<void> main(List<String> rawArgs) async {
  if (rawArgs.contains("web_view_title_bar")) {
    WidgetsFlutterBinding.ensureInitialized();
    if (runWebViewTitleBarWidget(rawArgs)) {
      return;
    }
  }
  final arguments = await startCLI(rawArgs);
  AppLogger.initialize(arguments["verbose"]);

  AppLogger.runZoned(() async {
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

    // Non-blocking: clean up a stale control server from a previous run.
    // Only PIDs whose cmdline mentions this app are touched, and the whole
    // scan runs off the critical path so startup never stalls on `ss`/awk.
    if (kIsLinux) {
      unawaited(() async {
        try {
          final result = await Process.run('bash', [
            '-c',
            r'''ss -tlnp 2>/dev/null | awk '/:8000|:(1[0-9]{3}|2[0-2][0-9]{2})/{match($0,/pid=([0-9]+)/,a); if(a[1]) print a[1]}' | sort -u''',
          ]);
          for (final line in result.stdout.toString().trim().split('\n')) {
            final pidStr = line.trim();
            if (pidStr.isEmpty) continue;
            final pid = int.tryParse(pidStr);
            if (pid == null) continue;
            // Never kill arbitrary processes that merely share the port range —
            // only our own control-server / app processes.
            String cmdline = '';
            try {
              cmdline =
                  await File('/proc/$pid/cmdline').readAsString().catchError(
                        (_) => '',
                      );
            } catch (_) {}
            final looksLikeOurs = cmdline.contains('deemusiq') ||
                cmdline.contains('spotube') ||
                cmdline.contains('DeeMusiq');
            if (!looksLikeOurs) {
              AppLogger.log.d(
                'Stale-server scan: leaving unrelated pid $pid alone',
              );
              continue;
            }
            try {
              Process.killPid(pid);
              AppLogger.log.i('Cleaned up stale server on pid $pidStr');
            } catch (e) {
              AppLogger.log.w(
                  'Could not kill stale server pid $pidStr: ${e.toString()}');
            }
          }
        } catch (e) {
          AppLogger.log.d('Stale-server scan skipped: ${e.toString()}');
        }
      }());
    }

    // Apply TLS cert pinning in ALL build modes. DeeMusiqHttpOverrides only
    // relaxes validation for Spotify hosts when kDebugMode, and only pins the
    // backend when DEEMUSIQ_SERVER_CERT_SHA256 is set — so this is safe to
    // install unconditionally and gives release builds real MITM protection.
    HttpOverrides.global = DeeMusiqHttpOverrides();

    // await registerWindowsScheme("spotify");

    tz.initializeTimeZones();

    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    MediaKit.ensureInitialized();

    await migrateMacOsFromSandboxToNoSandbox();

    // force High Refresh Rate on some Android devices (like One Plus)
    if (kIsAndroid) {
      await FlutterDisplayMode.setHighRefreshRate();
    }
    if (kIsAndroid || kIsDesktop) {
      await NewPipeExtractor.init();
    }

    if (!kIsWeb) {
      MetadataGod.initialize();
    }

    await KVStoreService.initialize();

    await AdRollService.instance.init();

    if (kIsDesktop || kIsAndroid) {
      try {
        final cacheDir =
            Directory(await UserPreferencesNotifier.getMusicCacheDir());
        if (await cacheDir.exists()) {
          await for (final f in cacheDir.list()) {
            if (f is File && f.path.endsWith('.part')) {
              try {
                await f.delete();
                AppLogger.log.d('Cleaned stale .part file: ${f.path}');
              } catch (e) {
                AppLogger.log.w(
                    'Could not delete stale .part ${f.path}: ${e.toString()}');
              }
            }
          }
        }
      } catch (e) {
        AppLogger.log.d('Stale .part cleanup skipped: ${e.toString()}');
      }
    }

    // Anti-tamper boot gate (Android, offline): refuse to run a build signed
    // with a certificate other than the pinned release certificate. No-op until
    // a permanent keystore + DEEMUSIQ_CERT_SHA256 are configured (see
    // README.DEEMUSIQ.md), so unsigned/dev builds still start.
    if (!await IntegrityService.instance.bootCheckPassed()) {
      FlutterNativeSplash.remove();
      runApp(const TamperBlockedApp());
      return;
    }

    if (kIsDesktop) {
      await windowManager.setPreventClose(true);
      final selectedPath =
          KVStoreService.getYoutubeEnginePath(YoutubeClientEngine.ytDlp);
      // resolveOrInstall() reuses a user-chosen, self-installed or PATH binary
      // and otherwise downloads the official latest release into the app's own
      // folder (recorded + SHA-256 verified), so yt-dlp is always available.
      final resolution = await YtDlpProvisioner.instance
          .resolveOrInstall(selectedPath: selectedPath);
      if (resolution.isApproved) {
        YtDlpBinaryPolicy.approvedPath = resolution.path;
        try {
          await YtDlp.instance.setBinaryLocation(resolution.path!);
        } catch (error, stack) {
          YtDlpBinaryPolicy.approvedPath = null;
          AppLogger.log.w('yt-dlp unavailable: $error');
          AppLogger.reportError(error, stack, 'YtDlp setBinaryLocation');
        }
      } else {
        YtDlpBinaryPolicy.approvedPath = null;
        AppLogger.log.w(
          'yt-dlp unavailable: ${resolution.error}',
        );
      }

      await FlutterDiscordRPC.initialize(Env.discordAppId);
    }

    if (kIsWindows) {
      await SMTCWindows.initialize();
    }

    await EncryptedKvStoreService.initialize();

    await KVStoreService.loadEncryptedFlags();

    final database = AppDatabase();

    if (kIsDesktop) {
      await localNotifier.setup(appName: "DeeMusiq");
      await WindowManagerTools.initialize();
    }

    if (kIsIOS) {
      // Must match the iOS app-group entitlement when an iOS build ships.
      HomeWidget.setAppGroupId("group.deemusiq_home_player_widget");
    }

    runApp(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith((ref) => database),
        ],
        observers: const [
          AppLoggerProviderObserver(),
        ],
        child: const DeeMusiq(),
      ),
    );

    // Start the runtime integrity monitor (online APK-hash check now, then at a
    // random 1–10 minute interval). Locks the wallet on a confirmed mismatch;
    // playback is never interrupted. No-op off Android.
    IntegrityService.instance.startMonitor();

    // ACTIVE backend TLS pin probe: badCertificateCallback alone misses
    // valid-but-wrong certs (it only fires when platform validation fails),
    // so the pinned backend certificate is also verified proactively — now,
    // every 6h, and on connectivity regain. A FAILED probe locks money
    // features via IntegrityService.walletLocked; offline never locks.
    BackendCertPinProbe.start(PaymentGatewayConfig.backendBaseUrl);
  });
}

class DeeMusiq extends HookConsumerWidget {
  const DeeMusiq({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final themeMode =
        ref.watch(userPreferencesProvider.select((s) => s.themeMode));
    final locale = ref.watch(userPreferencesProvider.select((s) => s.locale));
    final accentMaterialColor =
        ref.watch(userPreferencesProvider.select((s) => s.accentColorScheme));
    final router = useMemoized(() => AppRouter(ref), []);
    useEffect(() {
      DeepLinkHandler.setup(router);
      return () {
        DeepLinkHandler.dispose();
        ConnectionCheckerService.instance.dispose();
        AdRollService.instance.dispose();
        PlayerControls.dispose();
        WindowManagerTools.dispose();
      };
    }, []);
    final hasTouchSupport = useHasTouch();

    ref.listen(audioPlayerStreamListenersProvider, (_, __) {});
    ref.listen(bonsoirProvider, (_, __) {});
    ref.listen(connectClientsProvider, (_, __) {});
    ref.listen(serverProvider, (_, __) {});
    ref.listen(trayManagerProvider, (_, __) {});
    ref.listen(metadataPluginsProvider, (_, __) {});
    ref.listen(metadataPluginProvider, (_, __) {});
    ref.listen(audioSourcePluginProvider, (_, __) {});
    ref.listen(offlineSupportProvider, (_, __) {});

    useFixWindowStretching();
    useDisableBatteryOptimizations();
    useDeepLinking(ref, router);
    useCloseBehavior(ref);
    useGetStoragePermissions(ref);

    useEffect(() {
      FlutterNativeSplash.remove();

      if (kIsMobile) {
        HomeWidget.registerInteractivityCallback(glanceBackgroundCallback);
      }

      return () {
        if (!kDebugMode) return;
        audioPlayer.dispose().then((_) {
          MediaKit.ensureInitialized();
        });
      };
    }, []);

    return ShadcnApp.router(
      supportedLocales: L10n.all,
      locale: locale.languageCode == "system" ? null : locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router.config(),
      debugShowCheckedModeBanner: false,
      title: 'DeeMusiq',
      builder: (context, child) {
        child = AppLockGate(child: child!);
        child = ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: hasTouchSupport
                ? {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.stylus,
                    PointerDeviceKind.invertedStylus,
                  }
                : null,
          ),
          child: child,
        );

        if (kIsLinux) {
          child = DragToResizeArea(
            resizeEdgeSize: 2.5,
            child: child,
          );
        }

        return child;
      },
      scaling: const AdaptiveScaling(1),
      theme: ThemeData(
        radius: .5,
        iconTheme: const IconThemeProperties(),
        colorScheme:
            colorSchemeMap[accentMaterialColor.name]?.call(ThemeMode.light) ??
                LegacyColorSchemes.lightSlate(),
        surfaceOpacity: .8,
        surfaceBlur: 10,
      ),
      darkTheme: ThemeData(
        radius: .5,
        iconTheme: const IconThemeProperties(),
        colorScheme:
            colorSchemeMap[accentMaterialColor.name]?.call(ThemeMode.dark) ??
                LegacyColorSchemes.darkSlate(),
        surfaceOpacity: .8,
        surfaceBlur: 10,
      ),
      materialTheme: material.ThemeData(
        brightness: switch (themeMode) {
          ThemeMode.system => MediaQuery.platformBrightnessOf(context),
          ThemeMode.light => Brightness.light,
          ThemeMode.dark => Brightness.dark,
        },
        splashFactory: material.NoSplash.splashFactory,
        appBarTheme: const material.AppBarTheme(
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          shadowColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      themeMode: themeMode,
      shortcuts: {
        ...WidgetsApp.defaultShortcuts.map((key, value) {
          return MapEntry(
            LogicalKeySet.fromSet(key.triggers?.toSet() ?? {}),
            value,
          );
        }),
        LogicalKeySet(LogicalKeyboardKey.space): PlayPauseIntent(ref),
        LogicalKeySet(LogicalKeyboardKey.comma, LogicalKeyboardKey.control):
            NavigationIntent(router, "/settings"),
        LogicalKeySet(
          LogicalKeyboardKey.digit1,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ): HomeTabIntent(router, tab: HomeTabs.browse),
        LogicalKeySet(
          LogicalKeyboardKey.digit2,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ): HomeTabIntent(router, tab: HomeTabs.search),
        LogicalKeySet(
          LogicalKeyboardKey.digit3,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ): HomeTabIntent(router, tab: HomeTabs.lyrics),
        LogicalKeySet(
          LogicalKeyboardKey.digit4,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ): HomeTabIntent(router, tab: HomeTabs.userPlaylists),
        LogicalKeySet(
          LogicalKeyboardKey.digit5,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ): HomeTabIntent(router, tab: HomeTabs.userArtists),
        LogicalKeySet(
          LogicalKeyboardKey.digit6,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ): HomeTabIntent(router, tab: HomeTabs.userAlbums),
        LogicalKeySet(
          LogicalKeyboardKey.digit7,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ): HomeTabIntent(router, tab: HomeTabs.userLocalLibrary),
        LogicalKeySet(
          LogicalKeyboardKey.digit8,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ): HomeTabIntent(router, tab: HomeTabs.userDownloads),
        LogicalKeySet(
          LogicalKeyboardKey.keyW,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ): CloseAppIntent(),
      },
      actions: {
        ...WidgetsApp.defaultActions,
        PlayPauseIntent: PlayPauseAction(),
        NavigationIntent: NavigationAction(),
        HomeTabIntent: HomeTabAction(),
        CloseAppIntent: CloseAppAction(),
      },
    );
  }
}

/// Gate that shows [AppLockScreen] on cold start when fingerprint unlock is
/// enabled. Re-checks on every foreground via [BiometricLockService].
class AppLockGate extends StatefulWidget {
  final Widget child;
  const AppLockGate({super.key, required this.child});

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate>
    with WidgetsBindingObserver {
  bool _locked = false;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    try {
      final needs =
          await BiometricLockService.instance.needsUnlock();
      if (mounted) {
        setState(() {
          _locked = needs;
          _checked = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _checked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) return widget.child;
    if (!_locked) return widget.child;
    return AppLockScreen(
      onUnlocked: () => setState(() => _locked = false),
    );
  }
}
