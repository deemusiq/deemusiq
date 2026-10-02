// Widget coverage for the track details dialog width fix:
//  - below the md breakpoint (phones) the details table gets the full dialog
//    width (it used to be fixed at 700px and overflowed the screen)
//  - md screens and up (desktops/tablets) get the fixed 700px table (they
//    used to get double.infinity, stretching the table unconstrained)

import 'dart:async';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/fake.dart';
import 'package:deemusiq/components/dialogs/track_details_dialog.dart';
import 'package:deemusiq/l10n/l10n.dart';
import 'package:deemusiq/provider/server/sourced_track_provider.dart';
import 'package:deemusiq/services/sourced_track/sourced_track.dart';

class _FakeSourcedTrackNotifier extends SourcedTrackNotifier {
  @override
  FutureOr<SourcedTrack> build(query) {
    throw Exception('no audio source plugin in tests');
  }
}

Widget _app(Size screenSize) {
  return ProviderScope(
    overrides: [
      sourcedTrackProvider.overrideWith(() => _FakeSourcedTrackNotifier()),
    ],
    child: ShadcnApp(
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: MediaQuery(
        data: MediaQueryData(size: screenSize),
        child: TrackDetailsDialog(track: FakeData.track),
      ),
    ),
  );
}

SizedBox _contentSizedBox(WidgetTester tester) {
  return tester.widget<SizedBox>(
    find.byWidgetPredicate((widget) => widget is SizedBox && widget.child is Table),
  );
}

void main() {
  testWidgets('details table is full width below the md breakpoint',
      (tester) async {
    await tester.pumpWidget(_app(const Size(500, 800)));
    await tester.pump();

    expect(_contentSizedBox(tester).width, double.infinity);
  });

  testWidgets('details table is fixed at 700px on md screens and up',
      (tester) async {
    await tester.pumpWidget(_app(const Size(1000, 800)));
    await tester.pump();

    expect(_contentSizedBox(tester).width, 700);
  });
}
