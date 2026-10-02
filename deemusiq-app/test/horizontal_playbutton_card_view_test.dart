// Widget coverage for the browse/home fixes:
//  - "tracks" browse sections render as playable track tiles (they used to
//    collapse to SizedBox.shrink)
//  - a failed collection load surfaces the "Couldn't load this list" toast
//    instead of silently doing nothing.


import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart' hide Track;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/components/horizontal_playbutton_card_view/horizontal_playbutton_card_view.dart';
import 'package:deemusiq/components/track_tile/track_tile.dart';
import 'package:deemusiq/l10n/l10n.dart';
import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/modules/album/album_card.dart';
import 'package:deemusiq/modules/artist/artist_card.dart';
import 'package:deemusiq/modules/playlist/playlist_card.dart';
import 'package:deemusiq/provider/audio_player/audio_player.dart';
import 'package:deemusiq/provider/audio_player/state.dart';
import 'package:deemusiq/provider/blacklist_provider.dart';

/// TrackTile resolves the placeholder album art through an [AssetImage];
/// serve a 1x1 transparent PNG for every asset so tests don't need the real
/// asset bundle.
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
    // AssetImage resolves variants through the binary asset manifest first —
    // serve a valid, empty manifest so it falls back to loading the key
    // directly (which gets the transparent PNG below).
    if (key == 'AssetManifest.bin' || key == 'AssetManifest.smcbin') {
      return const StandardMessageCodec()
          .encodeMessage(<Object?, Object?>{})!;
    }
    return ByteData.view(_transparentPng.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async => '[]';
}

class _FakeAudioPlayerNotifier extends AudioPlayerNotifier {
  @override
  AudioPlayerState build() => AudioPlayerState(
        playing: false,
        loopMode: PlaylistMode.none,
        shuffled: false,
        collections: const [],
      );
}

class _FakeBlacklistNotifier extends BlackListNotifier {
  @override
  Future<List<BlacklistTableData>> build() async => [];
}

DeeMusiqFullTrackObject _track(String id, String name) {
  return DeeMusiqFullTrackObject(
    id: id,
    name: name,
    externalUri: 'ytsource:$id',
    artists: [
      DeeMusiqSimpleArtistObject(
        id: 'artist-$id',
        name: 'Artist $id',
        externalUri: '',
      ),
    ],
    album: DeeMusiqSimpleAlbumObject(
      id: 'album-$id',
      name: 'Album $id',
      externalUri: '',
      artists: const [],
      albumType: DeeMusiqAlbumType.single,
    ),
    durationMs: 180000,
    isrc: '',
    explicit: false,
  );
}

Widget _app(Widget home) {
  // Never disposed: ProviderScope's teardown can trip a riverpod
  // select-subscription close race ("read from a ProviderContainer that was
  // already disposed") when cards watch async providers. Leaking is fine in
  // tests.
  final container = ProviderContainer(
    overrides: [
      audioPlayerProvider.overrideWith(() => _FakeAudioPlayerNotifier()),
      blacklistProvider.overrideWith(() => _FakeBlacklistNotifier()),
    ],
  );
  return UncontrolledProviderScope(
    container: container,
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
        home: home,
      ),
    ),
  );
}

void main() {
  // PlaylistCard/TrackTile touch the global media_kit player (playingStream).
  MediaKit.ensureInitialized();
  testWidgets('tracks sections render as playable track tiles', (tester) async {
    await tester.pumpWidget(
      _app(
        HorizontalPlaybuttonCardView<DeeMusiqFullTrackObject>(
          title: const Text('New releases'),
          items: [
            _track('dQw4w9WgXcQ', 'First Song'),
            _track('jNQXAC9IVRw', 'Second Song'),
          ],
          hasNextPage: false,
          isLoadingNextPage: false,
          onFetchMore: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(TrackTile), findsNWidgets(2));
    expect(find.text('First Song'), findsOneWidget);
    expect(find.text('Second Song'), findsOneWidget);
  });

  testWidgets('failed collection load shows the load-failure toast',
      (tester) async {
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Button.primary(
            child: const Text('trigger'),
            onPressed: () => showListLoadFailureToast(context),
          ),
        ),
      ),
    );

    await tester.tap(find.text('trigger'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text("Couldn't load this list"), findsOneWidget);

    // Let the toast auto-dismiss so no timers are left pending.
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('empty track sections render track-tile skeletons, not album cards',
      (tester) async {
    await tester.pumpWidget(
      _app(
        HorizontalPlaybuttonCardView<DeeMusiqFullTrackObject>(
          title: const Text('New releases'),
          items: const [],
          hasNextPage: false,
          isLoadingNextPage: false,
          onFetchMore: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(TrackTile), findsWidgets);
    expect(find.byType(AlbumCard), findsNothing);
  });

  testWidgets('empty artist sections render artist-card skeletons, not album cards',
      (tester) async {
    await tester.pumpWidget(
      _app(
        HorizontalPlaybuttonCardView<DeeMusiqFullArtistObject>(
          title: const Text('Artists'),
          items: const [],
          hasNextPage: false,
          isLoadingNextPage: false,
          onFetchMore: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(ArtistCard), findsWidgets);
    expect(find.byType(AlbumCard), findsNothing);
  });

  testWidgets(
      'empty playlist sections render playlist-card skeletons, not album cards',
      (tester) async {
    await tester.pumpWidget(
      _app(
        HorizontalPlaybuttonCardView<DeeMusiqSimplePlaylistObject>(
          title: const Text('Playlists'),
          items: const [],
          hasNextPage: false,
          isLoadingNextPage: false,
          onFetchMore: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(PlaylistCard), findsWidgets);
    expect(find.byType(AlbumCard), findsNothing);

    // Advance fake time so zero-duration Timers (e.g. CustomPlayer's Linux
    // audio init, created when cards touch the global player) fire.
    await tester.pump(const Duration(milliseconds: 1));
  });
}
