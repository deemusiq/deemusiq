import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// What a comment thread hangs off: exactly one of track/album/artist
/// (the backend rejects anything else with `exactly_one_target_required`).
class CommentTarget {
  final String? trackId;
  final String? albumId;
  final String? artistId;

  const CommentTarget.track(String id)
      : trackId = id,
        albumId = null,
        artistId = null;
  const CommentTarget.album(String id)
      : trackId = null,
        albumId = id,
        artistId = null;
  const CommentTarget.artist(String id)
      : trackId = null,
        albumId = null,
        artistId = id;

  @override
  bool operator ==(Object other) =>
      other is CommentTarget &&
      other.trackId == trackId &&
      other.albumId == albumId &&
      other.artistId == artistId;

  @override
  int get hashCode => Object.hash(trackId, albumId, artistId);
}

/// One comment row. Mirrors the backend serializer in `services/comments.ts`:
/// author device ids arrive pre-truncated ("abcd1234…") so there is no PII
/// to render beyond what the server already exposes publicly.
class TrackComment {
  final String id;
  final String body;
  final String authorId;
  final String? authorLabel;
  final String? parentId;
  final int replyCount;
  final DateTime? createdAt;

  const TrackComment({
    required this.id,
    required this.body,
    required this.authorId,
    this.authorLabel,
    this.parentId,
    this.replyCount = 0,
    this.createdAt,
  });

  factory TrackComment.fromJson(Map<String, dynamic> json) {
    final author = json["author"];
    return TrackComment(
      id: json["id"] as String? ?? "",
      body: json["body"] as String? ?? "",
      authorId: json["authorId"] as String? ?? "",
      authorLabel: author is Map ? author["deviceId"] as String? : null,
      parentId: json["parentId"] as String?,
      replyCount: (json["replyCount"] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json["createdAt"]?.toString() ?? ""),
    );
  }

  TrackComment copyWith({int? replyCount}) => TrackComment(
        id: id,
        body: body,
        authorId: authorId,
        authorLabel: authorLabel,
        parentId: parentId,
        replyCount: replyCount ?? this.replyCount,
        createdAt: createdAt,
      );
}

/// One cursor page of top-level comments (`GET /comments`).
class CommentsPage {
  final List<TrackComment> comments;

  /// Null when there are no more pages.
  final String? nextCursor;

  const CommentsPage({required this.comments, this.nextCursor});
}

/// Network seam for the comments feature. The default implementation talks
/// to [WalletApiClient]; tests substitute a fake — the singleton is `final`
/// and cannot be swapped out directly.
abstract class CommentsGateway {
  /// False when no backend is configured — the UI then hides comments
  /// entirely instead of erroring.
  bool get isAvailable;

  Future<CommentsPage> fetchPage(
    CommentTarget target, {
    String? cursor,
    int limit = 20,
  });

  /// Throws [WalletApiException] on failure (e.g. `not_authenticated`).
  Future<TrackComment> post(
    CommentTarget target,
    String body, {
    String? parentId,
  });

  Future<List<TrackComment>> fetchReplies(String parentId);
}

class WalletCommentsGateway implements CommentsGateway {
  @override
  bool get isAvailable => WalletApiClient.instance.isConfigured;

  @override
  Future<CommentsPage> fetchPage(
    CommentTarget target, {
    String? cursor,
    int limit = 20,
  }) async {
    final data = await WalletApiClient.instance.listComments(
      trackId: target.trackId,
      albumId: target.albumId,
      artistId: target.artistId,
      cursor: cursor,
      limit: limit,
    );
    final raw = data["comments"] as List? ?? const [];
    return CommentsPage(
      comments: raw
          .map((e) => TrackComment.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      nextCursor: data["nextCursor"] as String?,
    );
  }

  @override
  Future<TrackComment> post(
    CommentTarget target,
    String body, {
    String? parentId,
  }) async {
    final data = await WalletApiClient.instance.postComment(
      body: body,
      trackId: target.trackId,
      albumId: target.albumId,
      artistId: target.artistId,
      parentId: parentId,
    );
    return TrackComment.fromJson(data);
  }

  @override
  Future<List<TrackComment>> fetchReplies(String parentId) async {
    final raw = await WalletApiClient.instance.listCommentReplies(parentId);
    return raw
        .map((e) => TrackComment.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}

final commentsGatewayProvider = Provider<CommentsGateway>(
  (ref) => WalletCommentsGateway(),
);

class CommentsState {
  /// False when no backend is configured — the section hides.
  final bool available;
  final bool loading;
  final Object? error;
  final List<TrackComment> comments;
  final String? nextCursor;
  final bool loadingMore;
  final Object? loadMoreError;
  final bool posting;

  const CommentsState({
    this.available = true,
    this.loading = false,
    this.error,
    this.comments = const [],
    this.nextCursor,
    this.loadingMore = false,
    this.loadMoreError,
    this.posting = false,
  });

  bool get hasMore => nextCursor != null;

  CommentsState copyWith({
    bool? available,
    bool? loading,
    Object? Function()? error,
    List<TrackComment>? comments,
    String? Function()? nextCursor,
    bool? loadingMore,
    Object? Function()? loadMoreError,
    bool? posting,
  }) {
    return CommentsState(
      available: available ?? this.available,
      loading: loading ?? this.loading,
      error: error != null ? error() : this.error,
      comments: comments ?? this.comments,
      nextCursor: nextCursor != null ? nextCursor() : this.nextCursor,
      loadingMore: loadingMore ?? this.loadingMore,
      loadMoreError:
          loadMoreError != null ? loadMoreError() : this.loadMoreError,
      posting: posting ?? this.posting,
    );
  }
}

/// Cursor-paginated top-level comments for one target. Loads the first page
/// on creation when a backend is configured; otherwise stays inert so the
/// UI can hide the whole section.
class CommentsNotifier
    extends AutoDisposeFamilyNotifier<CommentsState, CommentTarget> {
  CommentsGateway get _gateway => ref.read(commentsGatewayProvider);

  @override
  CommentsState build(CommentTarget arg) {
    final gateway = _gateway;
    if (!gateway.isAvailable) {
      return const CommentsState(available: false);
    }
    state = const CommentsState(loading: true);
    Future.microtask(loadInitial);
    return state;
  }

  Future<void> loadInitial() async {
    if (!_gateway.isAvailable) return;
    state = state.copyWith(loading: true, error: () => null);
    try {
      final page = await _gateway.fetchPage(arg);
      state = state.copyWith(
        loading: false,
        comments: page.comments,
        nextCursor: () => page.nextCursor,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: () => e);
    }
  }

  /// Appends the next cursor page. A failure keeps the loaded comments and
  /// only flags [CommentsState.loadMoreError] — never blanks the list.
  Future<void> loadMore() async {
    final cursor = state.nextCursor;
    if (cursor == null || state.loading || state.loadingMore) return;
    state = state.copyWith(loadingMore: true, loadMoreError: () => null);
    try {
      final page = await _gateway.fetchPage(arg, cursor: cursor);
      state = state.copyWith(
        loadingMore: false,
        comments: [...state.comments, ...page.comments],
        nextCursor: () => page.nextCursor,
      );
    } catch (e) {
      state = state.copyWith(loadingMore: false, loadMoreError: () => e);
    }
  }

  /// Posts a comment and folds it into local state on success. Top-level
  /// comments prepend (list is newest-first); replies invalidate the
  /// parent's replies provider and bump its count. Rethrows so the composer
  /// can show the backend's friendly message.
  Future<void> post(String body, {String? parentId}) async {
    if (state.posting) return;
    state = state.copyWith(posting: true);
    try {
      final comment = await _gateway.post(arg, body, parentId: parentId);
      if (parentId == null) {
        state = state.copyWith(
          posting: false,
          comments: [comment, ...state.comments],
        );
      } else {
        ref.invalidate(commentRepliesProvider(parentId));
        state = state.copyWith(
          posting: false,
          comments: [
            for (final c in state.comments)
              c.id == parentId ? c.copyWith(replyCount: c.replyCount + 1) : c,
          ],
        );
      }
    } catch (e) {
      state = state.copyWith(posting: false);
      rethrow;
    }
  }
}

final commentsProvider = NotifierProvider.autoDispose
    .family<CommentsNotifier, CommentsState, CommentTarget>(
  CommentsNotifier.new,
);

/// Inline replies for one top-level comment (`GET /comments/:id/replies`).
final commentRepliesProvider =
    FutureProvider.autoDispose.family<List<TrackComment>, String>(
  (ref, parentId) => ref.watch(commentsGatewayProvider).fetchReplies(parentId),
);
