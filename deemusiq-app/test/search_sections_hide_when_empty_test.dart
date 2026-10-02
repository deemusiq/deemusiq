// Regression coverage for the search "All" tab: sections with zero hits must
// hide entirely instead of rendering their title plus five interactive fake
// skeleton cards that navigate to nonexistent entities.

import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart' hide Track;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/fake.dart';
import 'package:deemusiq/l10n/l10n.dart';
import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/modules/album/album_card.dart';
import 'package:deemusiq/modules/artist/artist_card.dart';
import 'package:deemusiq/modules/playlist/playlist_card.dart';
import 'package:deemusiq/modules/search/sections/albums.dart';
import 'package:deemusiq/modules/search/sections/artists.dart';
import 'package:deemusiq/modules/search/sections/playlists.dart';
import 'package:deemusiq/provider/audio_player/audio_player.dart';
import 'package:deemusiq/provider/audio_player/state.dart';
import 'package:deemusiq/provider/blacklist_provider.dart';
import 'package:deemusiq/provider/metadata_plugin/search/all.dart';

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

DeeMusiqSearchResponseObject _response({
  List<DeeMusiqSimpleAlbumObject> albums = const [],
  List<DeeMusiqFullArtistObject> artists = const [],
  List<DeeMusiqSimplePlaylistObject> playlists = const [],
}) {
  return DeeMusiqSearchResponseObject(
    albums: albums,
    artists: artists,
    playlists: playlists,
    tracks: const [],
  );
}

Widget _app(Widget home, DeeMusiqSearchResponseObject response) {
  // Never disposed: ProviderScope's teardown disposes providers mid-finalize
  // and trips a riverpod select-subscription close race ("read from a
  // ProviderContainer that was already disposed"). Leaking is fine in tests.
  final container = ProviderContainer(
    overrides: [
      metadataPluginSearchAllProvider
          .overrideWith((ref, query) async => response),
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
        home: Scaffold(child: home),
      ),
    ),
  );
}

void main() {
  MediaKit.ensureInitialized();

  testWidgets('empty results hide the album/artist/playlist sections',
      (tester) async {
    await tester.pumpWidget(
      _app(
        const SingleChildScrollView(
          child: Column(
            children: [
              SearchAlbumsSection(),
              SearchArtistsSection(),
              SearchPlaylistsSection(),
            ],
          ),
        ),
        _response(),
      ),
    );
    await tester.pump();
    await tester.pump();

    // No fake interactive skeleton cards and no section card views.
    expect(find.byType(AlbumCard), findsNothing);
    expect(find.byType(ArtistCard), findsNothing);
    expect(find.byType(PlaylistCard), findsNothing);
  });

  testWidgets('sections with hits render real cards', (tester) async {
    await tester.pumpWidget(
      _app(
        const SingleChildScrollView(
          child: Column(
            children: [
              SearchAlbumsSection(),
              SearchArtistsSection(),
              SearchPlaylistsSection(),
            ],
          ),
        ),
        _response(
          albums: [FakeData.albumSimple],
          artists: [FakeData.artist],
          playlists: [FakeData.playlistSimple],
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(AlbumCard), findsOneWidget);
    expect(find.byType(ArtistCard), findsOneWidget);
    expect(find.byType(PlaylistCard), findsOneWidget);

    // Advance fake time so the zero-duration Timer in CustomPlayer's Linux
    // audio init (created when AlbumCard touches the global player) fires.
    await tester.pump(const Duration(milliseconds: 1));
  });
}
