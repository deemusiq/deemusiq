import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:deemusiq/hooks/configurators/use_check_yt_dlp_installed.dart';
import 'package:deemusiq/extensions/constrains.dart';
import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/modules/root/deemusiq_navigation_bar.dart';
import 'package:deemusiq/modules/root/bottom_player.dart';
import 'package:deemusiq/modules/root/sidebar/sidebar.dart';
import 'package:deemusiq/hooks/configurators/use_endless_playback.dart';
import 'package:deemusiq/modules/root/use_global_subscriptions.dart';
import 'package:deemusiq/provider/audio_player/audio_player.dart';
import 'package:deemusiq/provider/glance/glance.dart';
import 'package:deemusiq/provider/user_preferences/user_preferences_provider.dart';

@RoutePage()
class RootAppPage extends HookConsumerWidget {
  const RootAppPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final backgroundColor = Theme.of(context).colorScheme.background;
    final brightness = Theme.of(context).brightness;

    ref.listen(glanceProvider, (_, __) {});

    useGlobalSubscriptions(ref);
    useEndlessPlayback(ref);
    useCheckYtDlpInstalled(ref);

    useEffect(() {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: backgroundColor, // status bar color
          statusBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ),
      );
      return null;
    }, [backgroundColor, brightness]);

    final scaffold = MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: SafeArea(
        top: false,
        child: Scaffold(
          footers: const [
            BottomPlayer(),
            DeeMusiqNavigationBar(),
          ],
          floatingFooter: true,
          child: Sidebar(
            child: Builder(builder: (context) {
              // Reserve exactly what the floating footers occupy so content
              // never hides behind them. Compact chrome = collapsed
              // PlayerOverlay (63, but 0 tall when no track is active) +
              // navigation bar; desktop chrome = tall player card and no
              // navigation bar. Must mirror the chrome decision in
              // bottom_player.dart.
              final layoutMode = ref.watch(
                userPreferencesProvider.select((s) => s.layoutMode),
              );
              final compactChrome = layoutMode == LayoutMode.compact ||
                  (MediaQuery.sizeOf(context).mdAndDown &&
                      layoutMode == LayoutMode.adaptive);
              final hasActiveTrack = ref.watch(
                audioPlayerProvider.select((s) => s.activeTrack != null),
              );
              final navHeight =
                  compactChrome ? ref.watch(navigationPanelHeight) : 0.0;
              final playerHeight = compactChrome
                  ? (hasActiveTrack ? 63.0 : 0.0)
                  : 104.0;
              final bottomPadding =
                  (playerHeight + navHeight) * context.theme.scaling;
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  padding: MediaQuery.paddingOf(context)
                      .copyWith(bottom: bottomPadding),
                ),
                child: const AutoRouter(),
              );
            }),
          ),
        ),
      ),
    );

    return scaffold;
  }
}
