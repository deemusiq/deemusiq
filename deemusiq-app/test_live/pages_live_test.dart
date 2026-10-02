/// LIVE repro for the broken home timeline ("building your timeline" spinner)
/// and the artist page. Run: flutter test test_live/pages_live_test.dart
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/services/metadata/deemusiq_native_plugin.dart';
import 'package:deemusiq/services/youtube_engine/youtube_explode_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
    await KVStoreService.initialize();
  });

  test('browse sections resolve (offline build → YouTube fallback), timed',
      () async {
    final engine = YouTubeExplodeEngine();
    final endpoints = DeeMusiqNativeEndpoints(engine, [engine]);

    final sw = Stopwatch()..start();
    final page = await endpoints.browse.sections();
    sw.stop();

    // The home page spins "building your timeline" until this completes —
    // record the wall time so regressions are visible.
    // ignore: avoid_print
    print('sections() took ${sw.elapsed.inSeconds}s, ${page.items.length} sections');
    expect(page.items, isNotEmpty,
        reason: 'timeline must not come back empty on an offline build');
    for (final section in page.items) {
      expect(section.items, isNotEmpty,
          reason: 'section "${section.title}" is empty');
    }
  }, timeout: const Timeout(Duration(minutes: 5)));

  test('artist endpoint resolves YouTube channels when backend is offline',
      () async {
    final engine = YouTubeExplodeEngine();
    final endpoints = DeeMusiqNativeEndpoints(engine, [engine]);

    // jawed's channel (uploader of "Me at the zoo") by channel id — the shape
    // browse/search cards now carry.
    final byId = await endpoints.artist
        .getArtist('UC4QobU6STFB0P71PMvOGN5A')
        .timeout(const Duration(minutes: 1));
    // ignore: avoid_print
    print('artist by id: ${byId.id} / ${byId.name}');
    expect(byId.name, isNot('Unknown Artist'),
        reason: 'channel id must resolve to a real artist page');
    expect(byId.images, isNotEmpty, reason: 'channel avatar expected');

    // ...and by display name (legacy cards carried raw channel names).
    final byName = await endpoints.artist
        .getArtist('jawed')
        .timeout(const Duration(minutes: 1));
    // ignore: avoid_print
    print('artist by name: ${byName.id} / ${byName.name}');
    expect(byName.name, isNot('Unknown Artist'));

    // Top tracks must be playable YouTube tracks, not an empty page.
    final tracks = await endpoints.artist
        .topTracks('UC4QobU6STFB0P71PMvOGN5A')
        .timeout(const Duration(minutes: 1));
    // ignore: avoid_print
    print('artist top tracks: ${tracks.items.length}');
    expect(tracks.items, isNotEmpty);
    expect(tracks.items.first.externalUri, startsWith('ytsource:'));
  }, timeout: const Timeout(Duration(minutes: 3)));
}
