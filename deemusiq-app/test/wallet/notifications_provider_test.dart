import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/provider/wallet/notifications_provider.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

AppNotification _notification(
  String id, {
  bool read = false,
  String kind = "payout_approved",
}) =>
    AppNotification(
      id: id,
      kind: kind,
      title: "Title $id",
      body: "Body $id",
      readAt: read ? DateTime.utc(2026, 9, 29) : null,
      createdAt: DateTime.utc(2026, 9, 30, 12),
    );

class FakeNotificationsGateway implements NotificationsGateway {
  NotificationsInbox inbox;
  Object? fetchError;
  Object? markError;
  final List<List<String>> markCalls = [];

  FakeNotificationsGateway(this.inbox);

  @override
  bool get isAvailable => true;

  @override
  Future<NotificationsInbox> fetch({bool unreadOnly = false}) async {
    if (fetchError != null) throw fetchError!;
    return inbox;
  }

  @override
  Future<int> markRead(List<String> ids) async {
    if (markError != null) throw markError!;
    markCalls.add(ids);
    return ids.isEmpty
        ? inbox.notifications.where((n) => n.isUnread).length
        : ids.length;
  }
}

ProviderContainer _containerWith(FakeNotificationsGateway gateway) {
  final container = ProviderContainer(overrides: [
    notificationsGatewayProvider.overrideWithValue(gateway),
  ]);
  addTearDown(container.dispose);
  return container;
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  test("is unavailable (offline state) when no backend is configured",
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(notificationsProvider);
    expect(state.available, isFalse);
    expect(state.loading, isFalse);
    expect(state.notifications, isEmpty);
    expect(state.unread, 0);
  });

  test("refresh populates the inbox and unread count", () async {
    final gateway = FakeNotificationsGateway(
      NotificationsInbox(
        notifications: [_notification("n1"), _notification("n2", read: true)],
        unread: 1,
      ),
    );
    final container = _containerWith(gateway);
    final sub = container.listen(notificationsProvider, (_, __) {});
    addTearDown(sub.close);
    await _settle();

    final state = sub.read();
    expect(state.loading, isFalse);
    expect(state.error, isNull);
    expect(state.notifications.map((n) => n.id), ["n1", "n2"]);
    expect(state.unread, 1);
  });

  test("refresh failure keeps a previously loaded list", () async {
    final gateway = FakeNotificationsGateway(
      NotificationsInbox(notifications: [_notification("n1")], unread: 1),
    );
    final container = _containerWith(gateway);
    final sub = container.listen(notificationsProvider, (_, __) {});
    addTearDown(sub.close);
    await _settle();
    expect(sub.read().notifications, hasLength(1));

    gateway.fetchError = const WalletApiException(
      "offline",
      isConnectivity: true,
    );
    await container.read(notificationsProvider.notifier).refresh();

    final state = sub.read();
    expect(state.loading, isFalse);
    expect(state.error, isA<WalletApiException>());
    expect(state.notifications, hasLength(1));
  });

  test("markRead marks the tapped notification and updates unread", () async {
    final gateway = FakeNotificationsGateway(
      NotificationsInbox(
        notifications: [_notification("n1"), _notification("n2")],
        unread: 2,
      ),
    );
    final container = _containerWith(gateway);
    final sub = container.listen(notificationsProvider, (_, __) {});
    addTearDown(sub.close);
    await _settle();

    await container.read(notificationsProvider.notifier).markRead(["n1"]);

    final state = sub.read();
    expect(gateway.markCalls, [
      ["n1"]
    ]);
    expect(state.notifications[0].isUnread, isFalse);
    expect(state.notifications[1].isUnread, isTrue);
    expect(state.unread, 1);
  });

  test("markRead with an empty list is a no-op (per-item semantics)",
      () async {
    final gateway = FakeNotificationsGateway(
      NotificationsInbox(notifications: [_notification("n1")], unread: 1),
    );
    final container = _containerWith(gateway);
    final sub = container.listen(notificationsProvider, (_, __) {});
    addTearDown(sub.close);
    await _settle();

    await container.read(notificationsProvider.notifier).markRead(const []);

    expect(gateway.markCalls, isEmpty);
    expect(sub.read().unread, 1);
  });

  test("markAllRead sends an empty ids list (backend mark-all) and zeroes "
      "unread", () async {
    final gateway = FakeNotificationsGateway(
      NotificationsInbox(
        notifications: [_notification("n1"), _notification("n2")],
        unread: 2,
      ),
    );
    final container = _containerWith(gateway);
    final sub = container.listen(notificationsProvider, (_, __) {});
    addTearDown(sub.close);
    await _settle();

    await container.read(notificationsProvider.notifier).markAllRead();

    final state = sub.read();
    expect(gateway.markCalls, [const <String>[]]);
    expect(state.unread, 0);
    expect(state.notifications.every((n) => !n.isUnread), isTrue);
  });

  test("a failed mark rethrows and leaves items unread", () async {
    final gateway = FakeNotificationsGateway(
      NotificationsInbox(notifications: [_notification("n1")], unread: 1),
    )..markError = const WalletApiException(
        "offline",
        isConnectivity: true,
      );
    final container = _containerWith(gateway);
    final sub = container.listen(notificationsProvider, (_, __) {});
    addTearDown(sub.close);
    await _settle();

    await expectLater(
      container.read(notificationsProvider.notifier).markRead(["n1"]),
      throwsA(isA<WalletApiException>()),
    );

    final state = sub.read();
    expect(state.marking, isFalse);
    expect(state.notifications.single.isUnread, isTrue);
    expect(state.unread, 1);
  });

  test("AppNotification parses the backend inbox JSON", () {
    final notification = AppNotification.fromJson({
      "id": "n9",
      "kind": "song_published",
      "title": "Your song is live",
      "body": "Heat was published to the catalog.",
      "targetKind": "track",
      "targetId": "track-1",
      "readAt": null,
      "createdAt": "2026-09-30T12:00:00.000Z",
    });

    expect(notification.id, "n9");
    expect(notification.kind, "song_published");
    expect(notification.title, "Your song is live");
    expect(notification.targetKind, "track");
    expect(notification.targetId, "track-1");
    expect(notification.isUnread, isTrue);
    expect(notification.createdAt, DateTime.utc(2026, 9, 30, 12));
  });
}
