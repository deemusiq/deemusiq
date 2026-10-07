// The For You header used to overflow on narrow phones: the sign-in hint
// text competed with the title and Refresh button in an unconstrained Row.
// It is now wrapped in Flexible with an ellipsis, so a 300px-wide layout must
// render without an overflow.

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/components/home/for_you_section.dart';
import 'package:deemusiq/l10n/l10n.dart';
import 'package:deemusiq/provider/recommendations/for_you.dart';

class _FakeRecommendationsNotifier extends RecommendationsNotifier {
  _FakeRecommendationsNotifier(RecommendationsState initial) {
    // ignore: invalid_use_of_protected_member
    state = initial;
  }

  @override
  Future<void> load({bool force = false}) async {}

  @override
  Future<void> refresh() async {}
}

Widget _app(
  Widget home,
  RecommendationsState state, {
  ({TrackLikeAction like, TrackLikeAction unlike})? likeActions,
}) {
  return ProviderScope(
    overrides: [
      recommendationsProvider
          .overrideWith((ref) => _FakeRecommendationsNotifier(state)),
      if (likeActions != null)
        forYouLikeActionsProvider.overrideWithValue(likeActions),
    ],
    child: ShadcnApp(
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(child: Center(child: home)),
    ),
  );
}

void main() {
  testWidgets('header does not overflow on a 300px-wide layout',
      (tester) async {
    await tester.pumpWidget(
      _app(
        const SizedBox(width: 300, child: ForYouSection()),
        const RecommendationsState(isLoading: false),
      ),
    );
    await tester.pump();

    // An overflowing Row would have thrown during the pump above.
    expect(find.text('Sign in with Gmail for smarter picks'), findsOneWidget);
    expect(find.text('Refresh'), findsOneWidget);
  });

  testWidgets('linked badge replaces the sign-in hint', (tester) async {
    await tester.pumpWidget(
      _app(
        const SizedBox(width: 300, child: ForYouSection()),
        const RecommendationsState(isLoading: false, gmailLinked: true),
      ),
    );
    await tester.pump();

    expect(find.text('Gmail linked'), findsOneWidget);
    expect(find.text('Sign in with Gmail for smarter picks'), findsNothing);
  });

  testWidgets('refresh in progress shows a spinner, not an ellipsis',
      (tester) async {
    await tester.pumpWidget(
      _app(
        const ForYouSection(),
        const RecommendationsState(isLoading: false, isRefreshing: true),
      ),
    );
    await tester.pump();

    expect(find.text('…'), findsNothing);
    expect(find.text('Refresh'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  const sampleTrack = RecommendedTrack(
    id: 't1',
    title: 'Song',
    artistName: 'Artist',
    artistId: 'a1',
    sourceType: 'youtube',
    sourceRef: 'x',
    reasons: ['Because you listened to Artist'],
  );

  // A failed like must surface a toast instead of being swallowed silently,
  // and the tile must not flip to "Liked".
  testWidgets('failed like shows a toast and keeps the tile un-liked',
      (tester) async {
    await tester.pumpWidget(
      _app(
        const ForYouSection(),
        const RecommendationsState(isLoading: false, tracks: [sampleTrack]),
        likeActions: (
          like: (_) async => throw Exception('backend down'),
          unlike: (_) async {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Like'), findsOneWidget);

    await tester.tap(find.text('Like'));
    await tester.pump();
    await tester.pump();

    expect(find.text("Couldn't save the like — try again"), findsOneWidget);
    expect(find.text('Liked'), findsNothing);
    expect(find.text('Like'), findsOneWidget);

    // Flush the toast auto-dismiss timer (5s) so no timer is left pending.
    await tester.pump(const Duration(seconds: 6));
  });

  // A successful like flips the tile to "Liked"; tapping again un-likes.
  testWidgets('successful like toggles the tile state', (tester) async {
    var liked = false;
    await tester.pumpWidget(
      _app(
        const ForYouSection(),
        const RecommendationsState(isLoading: false, tracks: [sampleTrack]),
        likeActions: (
          like: (_) async => liked = true,
          unlike: (_) async => liked = false,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Like'));
    await tester.pump();
    expect(liked, isTrue);
    expect(find.text('Liked'), findsOneWidget);

    await tester.tap(find.text('Liked'));
    await tester.pump();
    expect(liked, isFalse);
    expect(find.text('Like'), findsOneWidget);
  });
}
