import 'package:auto_route/auto_route.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:deemusiq/collections/routes.gr.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/image/universal_image.dart';
import 'package:deemusiq/extensions/constrains.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/modules/connect/connect_device.dart';
import 'package:deemusiq/modules/root/count_badge.dart';
import 'package:deemusiq/provider/download_manager_provider.dart';
import 'package:deemusiq/provider/metadata_plugin/core/auth.dart';
import 'package:deemusiq/provider/metadata_plugin/core/user.dart';
import 'package:deemusiq/provider/wallet/notifications_provider.dart';

class SidebarFooter extends HookConsumerWidget implements NavigationBarItem {
  const SidebarFooter({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final theme = Theme.of(context);
    final router = AutoRouter.of(context, watch: true);
    final mediaQuery = MediaQuery.of(context);
    final downloadCount = ref
        .watch(downloadManagerProvider)
        .where((e) =>
            e.status == DownloadStatus.downloading ||
            e.status == DownloadStatus.queued)
        .length;
    final userSnapshot = ref.watch(metadataPluginUserProvider);
    final data = userSnapshot.asData?.value;

    final avatarImg = (data?.images).asUrlString(
      index: (data?.images.length ?? 1) - 1,
      placeholder: ImagePlaceholder.artist,
    );

    final authenticated = ref.watch(metadataPluginAuthenticatedProvider);

    final unreadNotifications = ref.watch(
      notificationsProvider.select((s) => s.available ? s.unread : 0),
    );

    // Compact column whenever the NavigationRail is showing (sidebar.dart
    // hides the whole sidebar at mdAndDown and switches rail ↔ full sidebar
    // on lgAndUp).
    if (!mediaQuery.lgAndUp) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          CountBadge(
            count: downloadCount,
            child: IconButton(
              variance: router.topRoute.name == UserDownloadsRoute.name
                  ? ButtonVariance.secondary
                  : ButtonVariance.ghost,
              icon: const Icon(DeeMusiqIcons.download),
              onPressed: () => context.navigateTo(const UserDownloadsRoute()),
            ),
          ),
          CountBadge(
            count: unreadNotifications,
            child: IconButton(
              variance: router.topRoute.name == NotificationsRoute.name
                  ? ButtonVariance.secondary
                  : ButtonVariance.ghost,
              icon: const Icon(FeatherIcons.bell),
              onPressed: () => context.navigateTo(const NotificationsRoute()),
            ),
          ),
          const ConnectDeviceButton.sidebar(),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.only(left: 12),
      width: 180,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          SizedBox(
            width: double.infinity,
            child: Row(
              spacing: 6,
              children: [
                Expanded(
                  child: Button(
                    style: router.topRoute.name == UserDownloadsRoute.name
                        ? ButtonVariance.secondary
                        : ButtonVariance.outline,
                    onPressed: () {
                      context.navigateTo(const UserDownloadsRoute());
                    },
                    leading: const Icon(DeeMusiqIcons.download),
                    trailing: downloadCount > 0
                        ? PrimaryBadge(
                            child: Text(downloadCount.toString()),
                          )
                        : null,
                    child: Text(context.l10n.downloads),
                  ),
                ),
                CountBadge(
                  count: unreadNotifications,
                  child: IconButton(
                    variance: router.topRoute.name == NotificationsRoute.name
                        ? ButtonVariance.secondary
                        : ButtonVariance.outline,
                    icon: const Icon(FeatherIcons.bell),
                    onPressed: () =>
                        context.navigateTo(const NotificationsRoute()),
                  ),
                ),
              ],
            ),
          ),
          const ConnectDeviceButton.sidebar(),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (data != null)
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      context.navigateTo(const ProfileRoute());
                    },
                    child: Row(
                      children: [
                        Avatar(
                          initials: Avatar.getInitials(data.name),
                          provider: UniversalImage.imageProvider(avatarImg),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            data.name,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: theme.typography.normal
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (userSnapshot.hasError)
                Tooltip(
                  tooltip: TooltipContainer(child: Text(context.l10n.retry))
                      .call,
                  child: IconButton.ghost(
                    icon: const Icon(DeeMusiqIcons.refresh),
                    onPressed: () =>
                        ref.invalidate(metadataPluginUserProvider),
                  ),
                )
              else if (authenticated.asData?.value == true)
                const CircularProgressIndicator(),
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool get selectable => false;
}
