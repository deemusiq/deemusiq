import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';

import 'package:deemusiq/collections/side_bar_tiles.dart';
import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/extensions/constrains.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/modules/root/sidebar/sidebar_footer.dart';

import 'package:deemusiq/modules/root/deemusiq_navigation_bar.dart';
import 'package:deemusiq/provider/user_preferences/user_preferences_provider.dart';

class Sidebar extends HookConsumerWidget {
  final Widget child;

  const Sidebar({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData(:colorScheme) = Theme.of(context);
    final mediaQuery = MediaQuery.sizeOf(context);

    final layoutMode =
        ref.watch(userPreferencesProvider.select((s) => s.layoutMode));

    final sidebarTileList = useMemoized(
      () => getSidebarTileList(context.l10n),
      [context.l10n],
    );

    final sidebarLibraryTileList = useMemoized(
      () => getSidebarLibraryTileList(context.l10n),
      [context.l10n],
    );

    final tileList = [...sidebarTileList, ...sidebarLibraryTileList];

    final router = context.watchRouter;

    final selectedIndex = tileList.indexWhere(
      (e) => router.currentPath.startsWith(e.pathPrefix),
    );

    // Hide at mdAndDown to match bottom_player.dart and
    // deemusiq_navigation_bar.dart, which switch to the mobile chrome
    // (collapsed PlayerOverlay + bottom NavigationBar) at the same
    // breakpoint — otherwise rail and bottom bar render together at
    // 640-820px.
    if (layoutMode == LayoutMode.compact ||
        (mediaQuery.mdAndDown && layoutMode == LayoutMode.adaptive)) {
      return child;
    }

    final navigationButtons = [
      NavigationLabel(
        child: mediaQuery.lgAndUp
            ? DefaultTextStyle(
                style: TextStyle(
                  fontFamily: "Cookie",
                  fontSize: 30 * context.theme.scaling,
                  letterSpacing: 1.8,
                  color: colorScheme.foreground,
                ),
                child: const Text("DeeMusiq"),
              )
            : const Text(""),
      ),
      for (final tile in sidebarTileList)
        NavigationButton(
          style: router.currentPath.startsWith(tile.pathPrefix)
              ? const ButtonStyle.secondary()
              : null,
          label: mediaQuery.lgAndUp ? Text(tile.title) : null,
          child: Tooltip(
            tooltip: TooltipContainer(child: Text(tile.title)).call,
            child: Icon(tile.icon),
          ),
          onPressed: () {
            context.navigateTo(tile.route);
          },
        ),
      const NavigationDivider(),
      if (mediaQuery.lgAndUp)
        NavigationLabel(child: Text(context.l10n.library)),
      for (final tile in sidebarLibraryTileList)
        NavigationButton(
          style: router.currentPath.startsWith(tile.pathPrefix)
              ? const ButtonStyle.secondary()
              : null,
          label: mediaQuery.lgAndUp ? Text(tile.title) : null,
          onPressed: () {
            context.navigateTo(tile.route);
          },
          child: Tooltip(
            tooltip: TooltipContainer(child: Text(tile.title)).call,
            child: Icon(tile.icon),
          ),
        ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          children: [
            Expanded(
              child: mediaQuery.lgAndUp
                  ? NavigationSidebar(
                      index: selectedIndex >= 0 ? selectedIndex : 0,
                      onSelected: (index) {
                        final tile = tileList[index];
                        context.navigateTo(tile.route);
                      },
                      children: navigationButtons,
                    )
                  : NavigationRail(
                      alignment: NavigationRailAlignment.start,
                      index: selectedIndex >= 0 ? selectedIndex : 0,
                      onSelected: (index) {
                        final tile = tileList[index];
                        context.navigateTo(tile.route);
                      },
                      children: navigationButtons,
                    ),
            ),
            const SidebarFooter(),
            // Matches root_app.dart's bottom inset: compact chrome is the
            // collapsed player (63) + nav bar; desktop chrome is the tall
            // player card with no nav bar. Mirror bottom_player.dart.
            SizedBox(
              height: ((layoutMode == LayoutMode.compact ||
                          (mediaQuery.mdAndDown &&
                              layoutMode == LayoutMode.adaptive)
                      ? ref.watch(navigationPanelHeight) + 63
                      : 104.0) *
                  context.theme.scaling),
            ),
          ],
        ),
        const VerticalDivider(),
        Expanded(child: child),
      ],
    );
  }
}
