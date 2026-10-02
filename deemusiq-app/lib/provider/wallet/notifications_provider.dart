import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// One inbox row (`GET /me/notifications`). `payload` is free-form JSON the
/// backend attaches for the client to render; `readAt` null = unread.
class AppNotification {
  final String id;
  final String kind;
  final String title;
  final String body;
  final String? targetKind;
  final String? targetId;
  final DateTime? readAt;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    this.targetKind,
    this.targetId,
    this.readAt,
    this.createdAt,
  });

  bool get isUnread => readAt == null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json["id"] as String? ?? "",
      kind: json["kind"] as String? ?? "",
      title: json["title"] as String? ?? "",
      body: json["body"] as String? ?? "",
      targetKind: json["targetKind"] as String?,
      targetId: json["targetId"] as String?,
      readAt: DateTime.tryParse(json["readAt"]?.toString() ?? ""),
      createdAt: DateTime.tryParse(json["createdAt"]?.toString() ?? ""),
    );
  }

  AppNotification copyWith({DateTime? Function()? readAt}) => AppNotification(
        id: id,
        kind: kind,
        title: title,
        body: body,
        targetKind: targetKind,
        targetId: targetId,
        readAt: readAt != null ? readAt() : this.readAt,
        createdAt: createdAt,
      );
}

class NotificationsInbox {
  final List<AppNotification> notifications;
  final int unread;

  const NotificationsInbox({required this.notifications, required this.unread});
}

/// Network seam for the inbox. The default implementation talks to
/// [WalletApiClient]; tests substitute a fake — the singleton is `final`
/// and cannot be swapped out directly.
abstract class NotificationsGateway {
  /// False when no backend is configured — the inbox then shows an offline
  /// empty state instead of erroring.
  bool get isAvailable;

  /// Throws [WalletApiException] on failure (e.g. `not_authenticated`).
  Future<NotificationsInbox> fetch({bool unreadOnly = false});

  /// Marks [ids] read; an empty list marks everything (backend semantics of
  /// `POST /me/notifications/mark-read`). Returns the rows updated.
  Future<int> markRead(List<String> ids);
}

class WalletNotificationsGateway implements NotificationsGateway {
  @override
  bool get isAvailable => WalletApiClient.instance.isConfigured;

  @override
  Future<NotificationsInbox> fetch({bool unreadOnly = false}) async {
    final data = await WalletApiClient.instance
        .fetchNotifications(unreadOnly: unreadOnly);
    final raw = data["notifications"] as List? ?? const [];
    return NotificationsInbox(
      notifications: raw
          .map((e) =>
              AppNotification.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      unread: (data["unread"] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<int> markRead(List<String> ids) =>
      WalletApiClient.instance.markNotificationsRead(ids: ids);
}

final notificationsGatewayProvider = Provider<NotificationsGateway>(
  (ref) => WalletNotificationsGateway(),
);

class NotificationsState {
  /// False when no backend is configured — the page shows an offline state.
  final bool available;
  final bool loading;
  final Object? error;
  final List<AppNotification> notifications;
  final int unread;
  final bool marking;

  const NotificationsState({
    this.available = true,
    this.loading = false,
    this.error,
    this.notifications = const [],
    this.unread = 0,
    this.marking = false,
  });

  NotificationsState copyWith({
    bool? available,
    bool? loading,
    Object? Function()? error,
    List<AppNotification>? notifications,
    int? unread,
    bool? marking,
  }) {
    return NotificationsState(
      available: available ?? this.available,
      loading: loading ?? this.loading,
      error: error != null ? error() : this.error,
      notifications: notifications ?? this.notifications,
      unread: unread ?? this.unread,
      marking: marking ?? this.marking,
    );
  }
}

/// The signed-in user's in-app inbox. Kept alive (not autoDispose) so the
/// unread-count badge in the root navigation can watch it from anywhere.
class NotificationsNotifier extends Notifier<NotificationsState> {
  NotificationsGateway get _gateway => ref.read(notificationsGatewayProvider);

  @override
  NotificationsState build() {
    if (!_gateway.isAvailable) {
      return const NotificationsState(available: false);
    }
    state = const NotificationsState(loading: true);
    Future.microtask(refresh);
    return state;
  }

  Future<void> refresh() async {
    if (!_gateway.isAvailable) return;
    state = state.copyWith(loading: true, error: () => null);
    try {
      final inbox = await _gateway.fetch();
      state = state.copyWith(
        loading: false,
        notifications: inbox.notifications,
        unread: inbox.unread,
      );
    } catch (e) {
      // Keep any previously loaded list — a refresh blip must not blank the
      // inbox the user is reading.
      state = state.copyWith(loading: false, error: () => e);
    }
  }

  /// Marks specific notifications read (tap on a row). Rethrows so the UI
  /// can toast the backend's friendly message.
  Future<void> markRead(List<String> ids) async {
    if (ids.isEmpty || state.marking) return;
    await _mark(ids);
  }

  /// Marks the whole inbox read ("mark all" affordance).
  Future<void> markAllRead() async {
    if (state.marking || state.unread == 0) return;
    await _mark(const []);
  }

  Future<void> _mark(List<String> ids) async {
    state = state.copyWith(marking: true);
    try {
      await _gateway.markRead(ids);
      final now = DateTime.now().toUtc();
      final idSet = ids.toSet();
      final updated = [
        for (final n in state.notifications)
          (ids.isEmpty || idSet.contains(n.id)) && n.isUnread
              ? n.copyWith(readAt: () => now)
              : n,
      ];
      state = state.copyWith(
        marking: false,
        notifications: updated,
        unread: updated.where((n) => n.isUnread).length,
      );
    } catch (e) {
      state = state.copyWith(marking: false);
      rethrow;
    }
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, NotificationsState>(
  NotificationsNotifier.new,
);
