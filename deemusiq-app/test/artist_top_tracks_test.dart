// Widget coverage for the artist top-tracks fixes:
//  - with zero top tracks the play and add-to-queue buttons are disabled
//    (they used to stay enabled and crash on tracks.first)
//  - a failed top-tracks load renders an ErrorBox with retry instead of a
//    raw error.toString() text

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart' hide Track;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/fallbacks/error_box.dart';
import 'package:deemusiq/l10n/l10n.dart';
import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/pages/artist/section/top_tracks.dart';
import 'package:deemusiq/provider/audio_player/audio_player.dart';
import 'package:deemusiq/provider/audio_player/state.dart';
import 'package:deemusiq/provider/blacklist_provider.dart';
import 'package:deemusiq/provider/metadata_plugin/artist/top_tracks.dart';

class _FakeAudioPlayerNotifier extends AudioPlayerNotifier {
  @override
  AudioPlayerState build() => AudioPlayerState(
        playing: false,
        loopMode: PlaylistMode.none,
        shuffled: false,
        collections: const [],
      );
}

class _EmptyTopTracksNotifier extends MetadataPluginArtistTopTracksNotifier {
  @override
  build(arg) async {
    return DeeMusiqPaginationResponseObject<DeeMusiqFullTrackObject>(
      limit: 20,
      nextOffset: null,
      total: 0,
      hasMore: false,
      items: const [],
    );
  }
}

class _ErrorTopTracksNotifier extends MetadataPluginArtistTopTracksNotifier {
  @override
  build(arg) async {
    throw Exception('failed to load top tracks');
  }
}

class _FakeBlacklistNotifier extends BlackListNotifier {
  @override
  build() async => <BlacklistTableData>[];
}

Widget _app(Override topTracksOverride) {
  return ProviderScope(
    overrides: [
      audioPlayerProvider.overrideWith(() => _FakeAudioPlayerNotifier()),
      blacklistProvider.overrideWith(() => _FakeBlacklistNotifier()),
      topTracksOverride,
    ],
    child: ShadcnApp(
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MediaQuery(
        // The Ahem test font is much wider than real fonts and overflows
        // ErrorBox's action row; shrink text so the harness renders it.
        data: MediaQueryData(textScaler: TextScaler.linear(0.7)),
        child: Scaffold(
          child: CustomScrollView(
            slivers: [
              ArtistPageTopTracks(artistId: 'artist-1'),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('play and queue buttons are disabled with zero top tracks',
      (tester) async {
    await tester.pumpWidget(
      _app(metadataPluginArtistTopTracksProvider
          .overrideWith(() => _EmptyTopTracksNotifier())),
    );
    await tester.pump();

    final queueButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, DeeMusiqIcons.queueAdd),
    );
    expect(queueButton.onPressed, isNull);

    final playButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, DeeMusiqIcons.play),
    );
    expect(playButton.enabled, isFalse);
  });

  testWidgets('failed top-tracks load renders an ErrorBox with retry',
      (tester) async {
    await tester.pumpWidget(
      _app(metadataPluginArtistTopTracksProvider
          .overrideWith(() => _ErrorTopTracksNotifier())),
    );
    await tester.pump();

    expect(find.byType(ErrorBox), findsOneWidget);

    // Tapping retry re-triggers the provider without throwing in the UI.
    await tester.tap(find.widgetWithIcon(Button, DeeMusiqIcons.refresh));
    await tester.pump();

    expect(find.byType(ErrorBox), findsOneWidget);
  });
}
