import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/provider/ratings/track_ratings_provider.dart';
import 'package:deemusiq/services/ratings/track_ratings_api.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

class _FakeRatingsApi extends TrackRatingsApi {
  _FakeRatingsApi({Map<String, TrackRatingValue>? mineResult})
      : mineResult = mineResult ?? const {};

  Map<String, TrackRatingValue> mineResult;
  Object? rateError;
  Object? removeError;
  final calls = <String>[];

  @override
  bool get isConfigured => true;

  @override
  Future<Map<String, TrackRatingValue>> mine() async {
    calls.add('mine');
    return Map.of(mineResult);
  }

  @override
  Future<TrackRatingOutcome> rate(
    String trackId,
    TrackRatingValue value,
  ) async {
    calls.add('rate:$trackId:${value.wireName}');
    final error = rateError;
    if (error != null) throw error;
    return TrackRatingOutcome(
      rating: value,
      stats: const TrackRatingStats(likes: 5, dislikes: 1, total: 6),
    );
  }

  @override
  Future<TrackRatingOutcome> remove(String trackId) async {
    calls.add('remove:$trackId');
    final error = removeError;
    if (error != null) throw error;
    return const TrackRatingOutcome(
      rating: null,
      stats: TrackRatingStats(likes: 4, dislikes: 1, total: 5),
    );
  }
}

ProviderContainer _containerWith(TrackRatingsApi api) {
  final container = ProviderContainer(overrides: [
    trackRatingsApiProvider.overrideWithValue(api),
  ]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('build merges GET /ratings/mine into the local map', () async {
    final api = _FakeRatingsApi(mineResult: const {
      't1': TrackRatingValue.like,
      't2': TrackRatingValue.dislike,
    });
    final container = _containerWith(api);

    final ratings = await container.read(myTrackRatingsProvider.future);

    expect(ratings, {
      't1': TrackRatingValue.like,
      't2': TrackRatingValue.dislike,
    });
    expect(api.calls, ['mine']);
    expect(container.read(trackRatingProvider('t1')), TrackRatingValue.like);
    expect(container.read(trackRatingProvider('t3')), isNull);
  });

  test('a failed initial load degrades to an empty map, not a crash', () async {
    final container = _containerWith(_BrokenMineApi());

    final ratings = await container.read(myTrackRatingsProvider.future);
    expect(ratings, isEmpty);
  });

  test('tapping a fresh rating PUTs it and updates the map optimistically',
      () async {
    final api = _FakeRatingsApi(mineResult: const {'t1': TrackRatingValue.like});
    final container = _containerWith(api);
    await container.read(myTrackRatingsProvider.future);

    await container
        .read(myTrackRatingsProvider.notifier)
        .toggleRating('t2', TrackRatingValue.dislike);

    expect(api.calls, ['mine', 'rate:t2:dislike']);
    expect(container.read(myTrackRatingsProvider).asData?.value, {
      't1': TrackRatingValue.like,
      't2': TrackRatingValue.dislike,
    });
    // The response stats feed the cache.
    expect(
      container.read(trackRatingStatsCacheProvider)['t2']?.likes,
      5,
    );
  });

  test('tapping the other rating switches it (PUT, not DELETE)', () async {
    final api = _FakeRatingsApi(mineResult: const {'t1': TrackRatingValue.like});
    final container = _containerWith(api);
    await container.read(myTrackRatingsProvider.future);

    await container
        .read(myTrackRatingsProvider.notifier)
        .toggleRating('t1', TrackRatingValue.dislike);

    expect(api.calls, ['mine', 'rate:t1:dislike']);
    expect(container.read(trackRatingProvider('t1')), TrackRatingValue.dislike);
  });

  test('tapping the active rating removes it (DELETE)', () async {
    final api = _FakeRatingsApi(mineResult: const {'t1': TrackRatingValue.like});
    final container = _containerWith(api);
    await container.read(myTrackRatingsProvider.future);

    await container
        .read(myTrackRatingsProvider.notifier)
        .toggleRating('t1', TrackRatingValue.like);

    expect(api.calls, ['mine', 'remove:t1']);
    expect(container.read(trackRatingProvider('t1')), isNull);
  });

  test('a failed toggle rolls the map back and rethrows', () async {
    final api = _FakeRatingsApi(mineResult: const {'t1': TrackRatingValue.like})
      ..rateError = const WalletApiException('offline', isConnectivity: true);
    final container = _containerWith(api);
    await container.read(myTrackRatingsProvider.future);

    await expectLater(
      container
          .read(myTrackRatingsProvider.notifier)
          .toggleRating('t2', TrackRatingValue.like),
      throwsA(isA<WalletApiException>()),
    );

    expect(container.read(myTrackRatingsProvider).asData?.value, {
      't1': TrackRatingValue.like,
    });
    expect(container.read(trackRatingStatsCacheProvider), isEmpty);
  });

  test('a failed remove restores the previous rating', () async {
    final api = _FakeRatingsApi(mineResult: const {'t1': TrackRatingValue.dislike})
      ..removeError = const WalletApiException('boom');
    final container = _containerWith(api);
    await container.read(myTrackRatingsProvider.future);

    await expectLater(
      container
          .read(myTrackRatingsProvider.notifier)
          .toggleRating('t1', TrackRatingValue.dislike),
      throwsA(isA<WalletApiException>()),
    );

    expect(container.read(trackRatingProvider('t1')), TrackRatingValue.dislike);
  });

  test('trending falls back to the top feed when the window is empty',
      () async {
    final api = _FallbackRatingsApi();
    final container = _containerWith(api);

    final items = await container.read(trendingTracksProvider.future);

    expect(api.calls, ['trending', 'topTracks']);
    expect(items.single.id, 'top-1');
    // Trending stats land in the cache for the badges.
    expect(
      container.read(trackRatingStatsCacheProvider)['top-1']?.likePercent,
      87,
    );
  });

  test('trending feed errors surface through the AsyncValue', () async {
    final container = _containerWith(_FailingTrendingApi());

    await expectLater(
      container.read(trendingTracksProvider.future),
      throwsA(isA<WalletApiException>()),
    );
    expect(container.read(trendingTracksProvider).hasError, isTrue);
  });

  test('no backend configured leaves both providers inert', () async {
    // Default TrackRatingsApi(): no DEEMUSIQ_BACKEND_URL in tests.
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(await container.read(myTrackRatingsProvider.future), isEmpty);
    expect(await container.read(trendingTracksProvider.future), isEmpty);
  });
}

class _BrokenMineApi extends TrackRatingsApi {
  @override
  bool get isConfigured => true;

  @override
  Future<Map<String, TrackRatingValue>> mine() async {
    throw const WalletApiException('logged_out', code: 'logged_out');
  }
}

class _FallbackRatingsApi extends TrackRatingsApi {
  final calls = <String>[];

  @override
  bool get isConfigured => true;

  @override
  Future<List<RatedTrack>> trending({int limit = 30}) async {
    calls.add('trending');
    return const [];
  }

  @override
  Future<List<RatedTrack>> topTracks({int limit = 30}) async {
    calls.add('topTracks');
    return const [
      RatedTrack(
        id: 'top-1',
        title: 'Top Song',
        artistId: 'a1',
        artistName: 'Top Artist',
        rating: TrackRatingStats(
          likes: 87,
          dislikes: 13,
          total: 100,
          likeRatio: 0.87,
        ),
      ),
    ];
  }
}

class _FailingTrendingApi extends TrackRatingsApi {
  @override
  bool get isConfigured => true;

  @override
  Future<List<RatedTrack>> trending({int limit = 30}) async {
    throw const WalletApiException('server_error', statusCode: 500);
  }

  @override
  Future<List<RatedTrack>> topTracks({int limit = 30}) async {
    throw const WalletApiException('server_error', statusCode: 500);
  }
}
