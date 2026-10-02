import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/provider/wallet/comments_provider.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

TrackComment _comment(
  String id, {
  String? parentId,
  int replyCount = 0,
}) =>
    TrackComment(
      id: id,
      body: "body of $id",
      authorId: "author-$id",
      authorLabel: "abcd1234…",
      parentId: parentId,
      replyCount: replyCount,
      createdAt: DateTime.utc(2026, 9, 30, 12),
    );

class FakeCommentsGateway implements CommentsGateway {
  final Map<String?, CommentsPage> pages;
  final List<String?> requestedCursors = [];
  final List<({String body, String? parentId})> posts = [];
  Object? fetchError;
  Object? loadMoreError;
  Object? postError;
  int _postCounter = 0;

  FakeCommentsGateway(this.pages);

  @override
  bool get isAvailable => true;

  @override
  Future<CommentsPage> fetchPage(
    CommentTarget target, {
    String? cursor,
    int limit = 20,
  }) async {
    requestedCursors.add(cursor);
    final error = cursor == null ? fetchError : loadMoreError;
    if (error != null) throw error;
    final page = pages[cursor];
    if (page == null) throw StateError("No page stubbed for cursor $cursor");
    return page;
  }

  @override
  Future<TrackComment> post(
    CommentTarget target,
    String body, {
    String? parentId,
  }) async {
    if (postError != null) throw postError!;
    posts.add((body: body, parentId: parentId));
    return _comment("posted-${_postCounter++}", parentId: parentId);
  }

  @override
  Future<List<TrackComment>> fetchReplies(String parentId) async => const [];
}

ProviderContainer _containerWith(FakeCommentsGateway gateway) {
  final container = ProviderContainer(overrides: [
    commentsGatewayProvider.overrideWithValue(gateway),
  ]);
  addTearDown(container.dispose);
  return container;
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  const target = CommentTarget.track("track-1");

  test("is unavailable (hides) when no backend is configured", () async {
    // No gateway override: the default WalletCommentsGateway reads
    // DEEMUSIQ_BACKEND_URL, which is empty in tests.
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(commentsProvider(target));
    expect(state.available, isFalse);
    expect(state.loading, isFalse);
    expect(state.comments, isEmpty);
  });

  test("initial load fetches the first page without a cursor", () async {
    final gateway = FakeCommentsGateway({
      null: CommentsPage(
        comments: [_comment("c1"), _comment("c2")],
        nextCursor: "c2",
      ),
    });
    final container = _containerWith(gateway);
    final sub = container.listen(commentsProvider(target), (_, __) {});
    addTearDown(sub.close);
    await _settle();

    final state = sub.read();
    expect(state.available, isTrue);
    expect(state.loading, isFalse);
    expect(state.error, isNull);
    expect(state.comments.map((c) => c.id), ["c1", "c2"]);
    expect(state.nextCursor, "c2");
    expect(state.hasMore, isTrue);
    expect(gateway.requestedCursors, [null]);
  });

  test("loadMore appends the next cursor page and clears hasMore", () async {
    final gateway = FakeCommentsGateway({
      null: CommentsPage(comments: [_comment("c1")], nextCursor: "c1"),
      "c1": CommentsPage(comments: [_comment("c2")]),
    });
    final container = _containerWith(gateway);
    final sub = container.listen(commentsProvider(target), (_, __) {});
    addTearDown(sub.close);
    await _settle();

    await container.read(commentsProvider(target).notifier).loadMore();

    final state = sub.read();
    expect(state.comments.map((c) => c.id), ["c1", "c2"]);
    expect(state.nextCursor, isNull);
    expect(state.hasMore, isFalse);
    expect(state.loadingMore, isFalse);
    expect(gateway.requestedCursors, [null, "c1"]);
  });

  test("loadMore is a no-op when there is no next cursor", () async {
    final gateway = FakeCommentsGateway({
      null: CommentsPage(comments: [_comment("c1")]),
    });
    final container = _containerWith(gateway);
    final sub = container.listen(commentsProvider(target), (_, __) {});
    addTearDown(sub.close);
    await _settle();

    await container.read(commentsProvider(target).notifier).loadMore();

    expect(gateway.requestedCursors, [null]);
  });

  test("initial load failure surfaces an error state without spinning",
      () async {
    final gateway = FakeCommentsGateway({})
      ..fetchError =
          const WalletApiException("nope", code: "server_error");
    final container = _containerWith(gateway);
    final sub = container.listen(commentsProvider(target), (_, __) {});
    addTearDown(sub.close);
    await _settle();

    final state = sub.read();
    expect(state.loading, isFalse);
    expect(state.error, isA<WalletApiException>());
    expect(state.comments, isEmpty);
  });

  test("loadMore failure keeps loaded comments and flags loadMoreError",
      () async {
    final gateway = FakeCommentsGateway({
      null: CommentsPage(comments: [_comment("c1")], nextCursor: "c1"),
    })..loadMoreError = const WalletApiException(
        "offline",
        isConnectivity: true,
      );
    final container = _containerWith(gateway);
    final sub = container.listen(commentsProvider(target), (_, __) {});
    addTearDown(sub.close);
    await _settle();

    await container.read(commentsProvider(target).notifier).loadMore();

    final state = sub.read();
    expect(state.comments.map((c) => c.id), ["c1"]);
    expect(state.loadingMore, isFalse);
    expect(state.loadMoreError, isA<WalletApiException>());
    // The cursor is preserved so a retry can resume.
    expect(state.nextCursor, "c1");
  });

  test("posting a top-level comment prepends it", () async {
    final gateway = FakeCommentsGateway({
      null: CommentsPage(comments: [_comment("c1")]),
    });
    final container = _containerWith(gateway);
    final sub = container.listen(commentsProvider(target), (_, __) {});
    addTearDown(sub.close);
    await _settle();

    await container
        .read(commentsProvider(target).notifier)
        .post("hello world");

    final state = sub.read();
    expect(state.comments.map((c) => c.id), ["posted-0", "c1"]);
    expect(state.posting, isFalse);
    expect(gateway.posts.single.body, "hello world");
    expect(gateway.posts.single.parentId, isNull);
  });

  test("posting a reply bumps the parent's replyCount", () async {
    final gateway = FakeCommentsGateway({
      null: CommentsPage(comments: [_comment("c1", replyCount: 2)]),
    });
    final container = _containerWith(gateway);
    final sub = container.listen(commentsProvider(target), (_, __) {});
    addTearDown(sub.close);
    await _settle();

    await container
        .read(commentsProvider(target).notifier)
        .post("a reply", parentId: "c1");

    final state = sub.read();
    expect(state.comments.single.replyCount, 3);
    expect(gateway.posts.single.parentId, "c1");
  });

  test("a failed post rethrows and resets the posting flag", () async {
    final gateway = FakeCommentsGateway({
      null: CommentsPage(comments: [_comment("c1")]),
    })..postError = const WalletApiException(
        "auth",
        code: "not_authenticated",
      );
    final container = _containerWith(gateway);
    final sub = container.listen(commentsProvider(target), (_, __) {});
    addTearDown(sub.close);
    await _settle();

    await expectLater(
      container.read(commentsProvider(target).notifier).post("hi"),
      throwsA(isA<WalletApiException>()),
    );

    final state = sub.read();
    expect(state.posting, isFalse);
    expect(state.comments.map((c) => c.id), ["c1"]);
  });

  test("TrackComment parses the backend serializer JSON", () {
    final comment = TrackComment.fromJson({
      "id": "c9",
      "body": "great track",
      "authorId": "user-1",
      "author": {"id": "user-1", "deviceId": "abcd1234…"},
      "trackId": "track-1",
      "albumId": null,
      "artistId": null,
      "parentId": null,
      "hidden": false,
      "replyCount": 4,
      "createdAt": "2026-09-30T12:00:00.000Z",
    });

    expect(comment.id, "c9");
    expect(comment.body, "great track");
    expect(comment.authorId, "user-1");
    expect(comment.authorLabel, "abcd1234…");
    expect(comment.parentId, isNull);
    expect(comment.replyCount, 4);
    expect(comment.createdAt, DateTime.utc(2026, 9, 30, 12));
  });
}
