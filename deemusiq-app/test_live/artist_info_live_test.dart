/// LIVE tests — hit the real Deezer/iTunes APIs. Not part of the CI gate;
/// run with `flutter test test_live/`.
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deemusiq/services/artist_info/artist_info_service.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;

  setUp(() async {
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
    await KVStoreService.initialize();
  });

  test('fetches a real, fetchable artist photo (Deezer primary)', () async {
    final url = await ArtistInfoService.instance.fetchArtistImage('Sho Madjozi');
    // ignore: avoid_print
    print('Sho Madjozi image: $url');
    expect(url, isNotNull, reason: 'third-party artist image should resolve');
    expect(ArtistInfoService.secureImageUrl(url), isNotNull);

    // The URL must serve an actual image right now.
    final head = await Dio().head(url!);
    expect(head.statusCode, 200);
    expect(
      head.headers.value('content-type') ?? '',
      startsWith('image/'),
    );
  }, timeout: const Timeout(Duration(seconds: 60)));

  test('iTunes fallback resolves an artist with no Deezer photo', () async {
    // Exercise the allowlist + rewrite logic through a mainstream artist.
    final url = await ArtistInfoService.instance.fetchArtistImage('Black Coffee');
    // ignore: avoid_print
    print('Black Coffee image: $url');
    expect(url, isNotNull);
  }, timeout: const Timeout(Duration(seconds: 60)));

  test('cache serves the same URL on repeat lookup', () async {
    final first = await ArtistInfoService.instance.fetchArtistImage('DBN Gogo');
    final sw = Stopwatch()..start();
    final second = await ArtistInfoService.instance.fetchArtistImage('DBN Gogo');
    sw.stop();
    expect(second, first);
    // ignore: avoid_print
    print('cached lookup: ${sw.elapsedMilliseconds}ms');
    expect(sw.elapsedMilliseconds, lessThan(500));
  }, timeout: const Timeout(Duration(seconds: 60)));
}
