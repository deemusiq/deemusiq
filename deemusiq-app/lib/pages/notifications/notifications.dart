import 'package:auto_route/auto_route.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/fallbacks/error_box.dart';
import 'package:deemusiq/components/titlebar/titlebar.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/provider/wallet/notifications_provider.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

@RoutePage()
class NotificationsPage extends HookConsumerWidget {
  static const name = "notifications";

  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);

    Widget body;
    if (!state.available) {
      body = _card(
        icon: FeatherIcons.bellOff,
        title: "You're offline",
        message: "Notifications live on DeeMusiq — connect to the internet "
            "and they'll show up here.",
      );
    } else if (state.loading && state.notifications.isEmpty) {
      body = const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (state.error != null && state.notifications.isEmpty) {
      body = Center(
        child: ErrorBox(
          error: state.error!,
          userMessage: state.error is WalletApiException
              ? (state.error as WalletApiException).friendlyMessage
              : null,
          onRetry: notifier.refresh,
        ),
      );
    } else if (state.notifications.isEmpty) {
      body = _card(
        icon: FeatherIcons.bell,
        title: "No notifications yet",
        message: "Payouts, publishes, follows and replies will land here.",
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(DeeMusiqIcons.warning,
                        size: 16, color: deeMusiqOrange),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        state.error is WalletApiException
                            ? (state.error as WalletApiException)
                                .friendlyMessage
                            : "Couldn't refresh notifications.",
                      ).small(),
                    ),
                    Button.ghost(
                      leading: const Icon(DeeMusiqIcons.refresh, size: 14),
                      onPressed: notifier.refresh,
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            ),
          for (final notification in state.notifications)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _NotificationTile(notification: notification),
            ),
        ],
      );
    }

    return SafeArea(
      bottom: false,
      child: Scaffold(
        headers: [
          TitleBar(
            title: const Text("Notifications"),
            trailing: [
              if (state.available)
                IconButton.ghost(
                  icon: const Icon(DeeMusiqIcons.refresh, size: 18),
                  onPressed: notifier.refresh,
                ),
              if (state.available && state.unread > 0)
                Button.ghost(
                  leading: const Icon(DeeMusiqIcons.done, size: 16),
                  onPressed: () async {
                    try {
                      await notifier.markAllRead();
                    } on WalletApiException catch (e) {
                      if (context.mounted) {
                        showWalletToast(context, e.friendlyMessage,
                            icon: DeeMusiqIcons.error);
                      }
                    }
                  },
                  child: const Text("Mark all read"),
                ),
            ],
          ),
        ],
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: body,
              ),
            ),
            const Gap(40),
          ],
        ),
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Card(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(icon, size: 32, color: deeMusiqOrange),
          const Gap(10),
          Text(title).semiBold(),
          const Gap(4),
          Text(message, textAlign: TextAlign.center).muted().small(),
        ],
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final AppNotification notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    Future<void> markRead() async {
      if (!notification.isUnread) return;
      try {
        await ref
            .read(notificationsProvider.notifier)
            .markRead([notification.id]);
      } on WalletApiException catch (e) {
        if (context.mounted) {
          showWalletToast(context, e.friendlyMessage,
              icon: DeeMusiqIcons.error);
        }
      }
    }

    return GestureDetector(
      onTap: markRead,
      child: Card(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: notification.isUnread
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: deeMusiqOrange,
                        shape: BoxShape.circle,
                      ),
                    )
                  : const SizedBox(width: 8),
            ),
            const Gap(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    notification.title,
                    style: notification.isUnread
                        ? const TextStyle(fontWeight: FontWeight.w700)
                        : null,
                  ),
                  if (notification.body.isNotEmpty) ...[
                    const Gap(2),
                    Text(notification.body).muted().small(),
                  ],
                  if (notification.createdAt != null) ...[
                    const Gap(4),
                    Text(
                      relativeTime(notification.createdAt!.toLocal()),
                      style: TextStyle(
                        color: theme.colorScheme.mutedForeground,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
