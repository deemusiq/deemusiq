import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/components/ratings/track_rating_buttons.dart';
import 'package:deemusiq/l10n/l10n.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/ratings/track_ratings_provider.dart';
import 'package:deemusiq/services/ratings/track_ratings_api.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

class _FakeRatingsApi extends TrackRatingsApi {
  _FakeRatingsApi({this.mineResult = const {}});

  final Map<String, TrackRatingValue> mineResult;
  Object? rateError;
  final calls = <String>[];

  @override
  bool get isConfigured => true;

  @override
  Future<Map<String, TrackRatingValue>> mine() async => Map.of(mineResult);

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
      stats: const TrackRatingStats(likes: 1, total: 1, likeRatio: 1),
    );
  }

  @override
  Future<TrackRatingOutcome> remove(String trackId) async {
    calls.add('remove:$trackId');
    return const TrackRatingOutcome(rating: null, stats: TrackRatingStats());
  }
}

final _track = DeeMusiqFullTrackObject(
  id: 't1',
  name: 'Song',
  externalUri: 'ytsource:t1',
  artists: const [],
  album: DeeMusiqSimpleAlbumObject(
    id: 'a1',
    name: 'Album',
    externalUri: '',
    artists: const [],
    albumType: DeeMusiqAlbumType.single,
  ),
  durationMs: 1000,
  isrc: '',
  explicit: false,
);

Widget _app(_FakeRatingsApi api) {
  return ProviderScope(
    overrides: [
      trackRatingsApiProvider.overrideWithValue(api),
    ],
    child: ShadcnApp(
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(child: Center(child: TrackRatingControls(track: _track))),
    ),
  );
}

void main() {
  testWidgets('tapping thumb-up likes, tapping again removes the rating',
      (tester) async {
    final api = _FakeRatingsApi();
    await tester.pumpWidget(_app(api));
    await tester.pump();

    expect(find.byIcon(Icons.thumb_up_off_alt_rounded), findsOneWidget);
    expect(find.byIcon(Icons.thumb_down_off_alt_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.thumb_up_off_alt_rounded));
    await tester.pump();
    expect(api.calls, ['rate:t1:like']);
    expect(find.byIcon(Icons.thumb_up_rounded), findsOneWidget);

    // Tapping the active rating removes it (DELETE).
    await tester.tap(find.byIcon(Icons.thumb_up_rounded));
    await tester.pump();
    expect(api.calls, ['rate:t1:like', 'remove:t1']);
    expect(find.byIcon(Icons.thumb_up_off_alt_rounded), findsOneWidget);
  });

  testWidgets('tapping thumb-down on a liked track switches the rating',
      (tester) async {
    final api = _FakeRatingsApi(
      mineResult: const {'t1': TrackRatingValue.like},
    );
    await tester.pumpWidget(_app(api));
    await tester.pump();
    await tester.pump();

    expect(find.byIcon(Icons.thumb_up_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.thumb_down_off_alt_rounded));
    await tester.pump();
    expect(api.calls, ['rate:t1:dislike']);
    expect(find.byIcon(Icons.thumb_down_rounded), findsOneWidget);
    expect(find.byIcon(Icons.thumb_up_off_alt_rounded), findsOneWidget);
  });

  testWidgets('a failed rating rolls back and shows a toast', (tester) async {
    final api = _FakeRatingsApi()
      ..rateError = const WalletApiException('offline', isConnectivity: true);
    await tester.pumpWidget(_app(api));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.thumb_up_off_alt_rounded));
    await tester.pump();
    await tester.pump();

    expect(find.text("Couldn't save your rating — try again"), findsOneWidget);
    expect(find.byIcon(Icons.thumb_up_off_alt_rounded), findsOneWidget);
    expect(find.byIcon(Icons.thumb_up_rounded), findsNothing);

    // Flush the toast auto-dismiss timer so no timer is left pending.
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('hides entirely when no backend is configured', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: ShadcnApp(
          supportedLocales: L10n.all,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(child: Center(child: TrackRatingControls(track: _track))),
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.thumb_up_off_alt_rounded), findsNothing);
    expect(find.byIcon(Icons.thumb_down_off_alt_rounded), findsNothing);
  });
}
