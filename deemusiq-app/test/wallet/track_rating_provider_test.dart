import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/provider/wallet/track_rating_provider.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

TrackRating _rating({
  int likes = 3,
  int dislikes = 1,
  TrackRatingValue? myRating,
}) =>
    TrackRating(
      likes: likes,
      dislikes: dislikes,
      total: likes + dislikes,
      likeRatio: likes / (likes + dislikes),
      myRating: myRating,
    );

class FakeTrackRatingsGateway implements TrackRatingsGateway {
  TrackRating fetchResult;
  Object? fetchError;
  Object? writeError;
  final List<TrackRatingValue> writes = [];
  int clears = 0;

  FakeTrackRatingsGateway(this.fetchResult);

  @override
  bool get isAvailable => true;

  @override
  Future<TrackRating> fetch(String trackId) async {
    final error = fetchError;
    if (error != null) throw error;
    return fetchResult;
  }

  @override
  Future<TrackRating> setRating(
    String trackId,
    TrackRatingValue value,
  ) async {
    final error = writeError;
    if (error != null) throw error;
    writes.add(value);
    return _rating(
      likes: value == TrackRatingValue.like ? 4 : 3,
      dislikes: value == TrackRatingValue.dislike ? 2 : 1,
      myRating: value,
    );
  }

  @override
  Future<TrackRating> clear(String trackId) async {
    final error = writeError;
    if (error != null) throw error;
    clears++;
    return _rating();
  }
}

ProviderContainer _containerWith(FakeTrackRatingsGateway gateway) {
  final container = ProviderContainer(overrides: [
    trackRatingsGatewayProvider.overrideWithValue(gateway),
  ]);
  addTearDown(container.dispose);
  return container;
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  const trackId = "track-1";

  test("is unavailable (hides) when no backend is configured", () async {
    // No gateway override: the default WalletTrackRatingsGateway reads
    // DEEMUSIQ_BACKEND_URL, which is empty in tests.
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(trackRatingProvider(trackId));
    expect(state.available, isFalse);
    expect(state.loading, isFalse);
    expect(state.rating, isNull);
  });

  test("initial load populates the aggregates and my rating", () async {
    final gateway =
        FakeTrackRatingsGateway(_rating(myRating: TrackRatingValue.like));
    final container = _containerWith(gateway);
    final sub = container.listen(trackRatingProvider(trackId), (_, __) {});
    addTearDown(sub.close);
    await _settle();

    final state = sub.read();
    expect(state.available, isTrue);
    expect(state.loading, isFalse);
    expect(state.error, isNull);
    expect(state.rating?.likes, 3);
    expect(state.rating?.dislikes, 1);
    expect(state.rating?.total, 4);
    expect(state.rating?.myRating, TrackRatingValue.like);
  });

  test("initial load failure surfaces an error state without spinning",
      () async {
    final gateway = FakeTrackRatingsGateway(_rating())
      ..fetchError = const WalletApiException("nope", code: "server_error");
    final container = _containerWith(gateway);
    final sub = container.listen(trackRatingProvider(trackId), (_, __) {});
    addTearDown(sub.close);
    await _settle();

    final state = sub.read();
    expect(state.loading, isFalse);
    expect(state.error, isA<WalletApiException>());
    expect(state.rating, isNull);
  });

  test("setRating folds the returned aggregates into state", () async {
    final gateway = FakeTrackRatingsGateway(_rating());
    final container = _containerWith(gateway);
    final sub = container.listen(trackRatingProvider(trackId), (_, __) {});
    addTearDown(sub.close);
    await _settle();

    await container
        .read(trackRatingProvider(trackId).notifier)
        .setRating(TrackRatingValue.dislike);

    final state = sub.read();
    expect(gateway.writes, [TrackRatingValue.dislike]);
    expect(state.mutating, isFalse);
    expect(state.rating?.myRating, TrackRatingValue.dislike);
    expect(state.rating?.dislikes, 2);
  });

  test("clear resets my rating and keeps the aggregates", () async {
    final gateway =
        FakeTrackRatingsGateway(_rating(myRating: TrackRatingValue.like));
    final container = _containerWith(gateway);
    final sub = container.listen(trackRatingProvider(trackId), (_, __) {});
    addTearDown(sub.close);
    await _settle();

    await container.read(trackRatingProvider(trackId).notifier).clear();

    final state = sub.read();
    expect(gateway.clears, 1);
    expect(state.mutating, isFalse);
    expect(state.rating?.myRating, isNull);
    expect(state.rating?.total, 4);
  });

  test("a failed mutation rethrows and resets the mutating flag", () async {
    final gateway = FakeTrackRatingsGateway(_rating())
      ..writeError = const WalletApiException(
        "signed out",
        code: "logged_out",
      );
    final container = _containerWith(gateway);
    final sub = container.listen(trackRatingProvider(trackId), (_, __) {});
    addTearDown(sub.close);
    await _settle();

    await expectLater(
      container
          .read(trackRatingProvider(trackId).notifier)
          .setRating(TrackRatingValue.like),
      throwsA(isA<WalletApiException>()),
    );

    final state = sub.read();
    expect(state.mutating, isFalse);
    expect(state.rating?.myRating, isNull);
  });

  test("TrackRating parses the GET /ratings/:trackId shape", () {
    final rating = TrackRating.fromJson({
      "trackId": "track-1",
      "likes": 8,
      "dislikes": 2,
      "total": 10,
      "likeRatio": 0.8,
      "myRating": "dislike",
    });

    expect(rating.likes, 8);
    expect(rating.dislikes, 2);
    expect(rating.total, 10);
    expect(rating.likeRatio, 0.8);
    expect(rating.myRating, TrackRatingValue.dislike);
  });

  test("TrackRating parses the write-response shape", () {
    final rating = TrackRating.fromWriteResponse({
      "ok": true,
      "rating": "like",
      "stats": {"likes": 5, "dislikes": 0, "total": 5, "likeRatio": 1.0},
    });

    expect(rating.likes, 5);
    expect(rating.total, 5);
    expect(rating.myRating, TrackRatingValue.like);
  });

  test("TrackRating parses a clear-response (rating: null)", () {
    final rating = TrackRating.fromWriteResponse({
      "ok": true,
      "rating": null,
      "stats": {"likes": 5, "dislikes": 0, "total": 5, "likeRatio": 1.0},
    });

    expect(rating.myRating, isNull);
    expect(rating.total, 5);
  });
}
