import 'package:auto_route/auto_route.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';

import 'package:deemusiq/collections/routes.gr.dart';
import 'package:deemusiq/collections/side_bar_tiles.dart';
import 'package:deemusiq/extensions/constrains.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/modules/root/count_badge.dart';
import 'package:deemusiq/provider/download_manager_provider.dart';
import 'package:deemusiq/provider/user_preferences/user_preferences_provider.dart';
import 'package:deemusiq/provider/wallet/notifications_provider.dart';

final navigationPanelHeight = StateProvider<double>((ref) => 50);

class DeeMusiqNavigationBar extends HookConsumerWidget {
  const DeeMusiqNavigationBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final mediaQuery = MediaQuery.of(context);

    final downloadCount = ref
        .watch(downloadManagerProvider)
        .where((e) =>
            e.status == DownloadStatus.downloading ||
            e.status == DownloadStatus.queued)
        .length;
    final layoutMode =
        ref.watch(userPreferencesProvider.select((s) => s.layoutMode));

    final navbarTileList = useMemoized(
      () => getNavbarTileList(context.l10n),
      [context.l10n],
    );

    final panelHeight = ref.watch(navigationPanelHeight);

    final router = context.watchRouter;
    final selectedIndex = navbarTileList.indexWhere(
      (e) => router.currentPath.startsWith(e.pathPrefix),
    );

    final unreadNotifications = ref.watch(
      notificationsProvider.select((s) => s.available ? s.unread : 0),
    );

    if (layoutMode == LayoutMode.extended ||
        (mediaQuery.mdAndUp && layoutMode == LayoutMode.adaptive) ||
        panelHeight < 10) {
      return const SizedBox();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      height: panelHeight,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Divider(),
            NavigationBar(
              index: selectedIndex >= 0 ? selectedIndex : 0,
              surfaceBlur: context.theme.surfaceBlur,
              surfaceOpacity: context.theme.surfaceOpacity,
              children: [
                for (final tile in navbarTileList)
                  NavigationButton(
                    style: selectedIndex >= 0 && navbarTileList[selectedIndex] == tile
                        ? const ButtonStyle.fixed(density: ButtonDensity.icon)
                        : const ButtonStyle.muted(density: ButtonDensity.icon),
                    child: CountBadge(
                      count: tile.id == "library" ? downloadCount : 0,
                      child: Icon(tile.icon),
                    ),
                    onPressed: () {
                      context.navigateTo(tile.route);
                    },
                  ),
                NavigationButton(
                  style: router.currentPath.startsWith("/notifications")
                      ? const ButtonStyle.fixed(density: ButtonDensity.icon)
                      : const ButtonStyle.muted(density: ButtonDensity.icon),
                  child: CountBadge(
                    count: unreadNotifications,
                    child: const Icon(FeatherIcons.bell),
                  ),
                  onPressed: () {
                    context.navigateTo(const NotificationsRoute());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
