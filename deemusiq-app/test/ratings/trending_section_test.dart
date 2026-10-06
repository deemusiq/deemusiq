import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/components/home/trending_section.dart';
import 'package:deemusiq/l10n/l10n.dart';
import 'package:deemusiq/provider/ratings/track_ratings_provider.dart';
import 'package:deemusiq/services/ratings/track_ratings_api.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// Cards resolve cover art through AssetImage; serve a 1x1 transparent PNG
/// for every asset so tests don't need the real asset bundle.
final _transparentPng = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

class _FakeAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin' || key == 'AssetManifest.smcbin') {
      return const StandardMessageCodec()
          .encodeMessage(<Object?, Object?>{})!;
    }
    return ByteData.view(_transparentPng.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async => '[]';
}

class _FakeRatingsApi extends TrackRatingsApi {
  _FakeRatingsApi({this.trendingItems = const [], this.topItems = const []});

  final List<RatedTrack> trendingItems;
  final List<RatedTrack> topItems;
  final calls = <String>[];

  @override
  bool get isConfigured => true;

  @override
  Future<List<RatedTrack>> trending({int limit = 30}) async {
    calls.add('trending');
    return trendingItems;
  }

  @override
  Future<List<RatedTrack>> topTracks({int limit = 30}) async {
    calls.add('topTracks');
    return topItems;
  }
}

const _hotTrack = RatedTrack(
  id: 't1',
  title: 'Hot Song',
  artistId: 'a1',
  artistName: 'Hot Artist',
  rating: TrackRatingStats(likes: 87, dislikes: 13, total: 100, likeRatio: 0.87),
);

const _unratedTrack = RatedTrack(
  id: 't2',
  title: 'Fresh Drop',
  artistId: 'a2',
  artistName: 'New Artist',
  rating: TrackRatingStats(),
);

Widget _app(TrackRatingsApi api) {
  return ProviderScope(
    overrides: [
      trackRatingsApiProvider.overrideWithValue(api),
    ],
    child: DefaultAssetBundle(
      bundle: _FakeAssetBundle(),
      child: ShadcnApp(
        supportedLocales: L10n.all,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Scaffold(
          child: SingleChildScrollView(child: TrendingSection()),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders cards with the like-ratio badge', (tester) async {
    await tester.pumpWidget(
      _app(_FakeRatingsApi(trendingItems: const [_hotTrack, _unratedTrack])),
    );
    await tester.pump();

    expect(find.text('Trending'), findsOneWidget);
    expect(find.text('Hot Song'), findsOneWidget);
    expect(find.text('Hot Artist'), findsOneWidget);
    expect(find.text('87%'), findsOneWidget);
    // No ratings yet → no "0%" badge on the second card.
    expect(find.text('0%'), findsNothing);
    expect(find.text('Fresh Drop'), findsOneWidget);
  });

  testWidgets('falls back to the top feed when trending is empty',
      (tester) async {
    final api = _FakeRatingsApi(topItems: const [_hotTrack]);
    await tester.pumpWidget(_app(api));
    await tester.pump();

    expect(api.calls, ['trending', 'topTracks']);
    expect(find.text('Hot Song'), findsOneWidget);
    expect(find.text('87%'), findsOneWidget);
  });

  testWidgets('hides entirely when both feeds are empty', (tester) async {
    await tester.pumpWidget(_app(_FakeRatingsApi()));
    await tester.pump();

    expect(find.text('Trending'), findsNothing);
  });

  testWidgets('a fetch failure surfaces an error box with retry',
      (tester) async {
    await tester.pumpWidget(_app(_FailingRatingsApi()));
    await tester.pump();

    expect(find.byType(TrendingSection), findsOneWidget);
    expect(find.text('Trending'), findsNothing);
  });
}

class _FailingRatingsApi extends TrackRatingsApi {
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
