import 'package:flutter_test/flutter_test.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/pages/library/user_local_tracks/user_local_tracks.dart';
import 'package:deemusiq/utils/service_utils.dart';

DeeMusiqTrackObject _track(String name, String? releaseDate) {
  return DeeMusiqTrackObject.full(
    id: 'track-$name',
    name: name,
    externalUri: 'spotify:track:$name',
    artists: [
      DeeMusiqSimpleArtistObject(
        id: 'artist-1',
        name: 'Artist',
        externalUri: 'spotify:artist:artist-1',
      ),
    ],
    album: DeeMusiqSimpleAlbumObject(
      id: 'album-$name',
      name: 'Album $name',
      externalUri: 'spotify:album:$name',
      artists: const [],
      albumType: DeeMusiqAlbumType.album,
      releaseDate: releaseDate,
    ),
    durationMs: 180000,
    isrc: 'ISRC-$name',
    explicit: false,
  );
}

void main() {
  group('ServiceUtils.sortTracks newest/oldest', () {
    test('newest orders by album release date, newest first', () {
      final tracks = [
        _track('mid', '2010-06-15'),
        _track('new', '2020-01-01'),
        _track('old', '2000-12-31'),
      ];

      final sorted = ServiceUtils.sortTracks(tracks, SortBy.newest);

      expect(sorted.map((t) => t.name), ['new', 'mid', 'old']);
    });

    test('oldest orders by album release date, oldest first', () {
      final tracks = [
        _track('mid', '2010-06-15'),
        _track('new', '2020-01-01'),
        _track('old', '2000-12-31'),
      ];

      final sorted = ServiceUtils.sortTracks(tracks, SortBy.oldest);

      expect(sorted.map((t) => t.name), ['old', 'mid', 'new']);
    });

    test('partial release dates (yyyy, yyyy-MM) compare by padded date', () {
      final tracks = [
        _track('yearOnly', '2015'),
        _track('monthPrecision', '2015-03'),
        _track('fullDate', '2015-03-10'),
      ];

      final newest = ServiceUtils.sortTracks(tracks, SortBy.newest);
      expect(
        newest.map((t) => t.name),
        ['fullDate', 'monthPrecision', 'yearOnly'],
      );

      final oldest = ServiceUtils.sortTracks(tracks, SortBy.oldest);
      expect(
        oldest.map((t) => t.name),
        ['yearOnly', 'monthPrecision', 'fullDate'],
      );
    });

    test('missing or unparseable dates fall back to the epoch date', () {
      final tracks = [
        _track('dated', '2001-01-01'),
        _track('noDate', null),
        _track('garbage', 'not-a-date'),
      ];

      final newest = ServiceUtils.sortTracks(tracks, SortBy.newest);
      expect(newest.first.name, 'dated');

      final oldest = ServiceUtils.sortTracks(tracks, SortBy.oldest);
      expect(oldest.last.name, 'dated');
    });

    test('does not mutate the input list', () {
      final tracks = [
        _track('b', '2020-01-01'),
        _track('a', '2010-01-01'),
      ];

      ServiceUtils.sortTracks(tracks, SortBy.oldest);

      expect(tracks.map((t) => t.name), ['b', 'a']);
    });
  });

  group('ServiceUtils.parseSpotifyAlbumDate', () {
    test('parses full and partial dates', () {
      expect(
        ServiceUtils.parseSpotifyAlbumDate(_track('t', '2020-05-17').album),
        DateTime(2020, 5, 17),
      );
      expect(
        ServiceUtils.parseSpotifyAlbumDate(_track('t', '2020-05').album),
        DateTime(2020, 5, 1),
      );
      expect(
        ServiceUtils.parseSpotifyAlbumDate(_track('t', '2020').album),
        DateTime(2020, 1, 1),
      );
    });

    test('null album and null/garbage dates use the fallback', () {
      final fallback = DateTime.parse('1975-01-01');
      expect(ServiceUtils.parseSpotifyAlbumDate(null), fallback);
      expect(
        ServiceUtils.parseSpotifyAlbumDate(_track('t', null).album),
        fallback,
      );
      expect(
        ServiceUtils.parseSpotifyAlbumDate(_track('t', 'nope').album),
        fallback,
      );
    });
  });
}
