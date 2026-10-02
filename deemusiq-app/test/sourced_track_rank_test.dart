import 'package:flutter_test/flutter_test.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/services/sourced_track/sourced_track.dart';

DeeMusiqFullTrackObject _track() => DeeMusiqFullTrackObject(
      id: 'track-1',
      name: 'Song',
      externalUri: 'catalog:track-1',
      artists: [
        DeeMusiqSimpleArtistObject(
          id: 'artist-1',
          name: 'Artist',
          externalUri: '',
        ),
      ],
      album: DeeMusiqSimpleAlbumObject(
        id: 'album-1',
        name: 'Album',
        externalUri: '',
        artists: const [],
        albumType: DeeMusiqAlbumType.album,
      ),
      durationMs: const Duration(minutes: 3).inMilliseconds,
      isrc: '',
      explicit: false,
    );

DeeMusiqAudioSourceMatchObject _match(
  String id, {
  required String title,
  List<String> artists = const [],
  Duration duration = Duration.zero,
}) {
  return DeeMusiqAudioSourceMatchObject(
    id: id,
    title: title,
    artists: artists,
    duration: duration,
    externalUri: 'yt:$id',
  );
}

void main() {
  test('channel/uploader match outranks an identical title from a stranger', () {
    final ranked = SourcedTrack.rankResults(
      [
        _match(
          'stranger',
          title: 'Song',
          duration: const Duration(minutes: 3),
        ),
        _match(
          'artist-channel',
          title: 'Song',
          artists: ['Artist - Topic'],
          duration: const Duration(minutes: 3),
        ),
      ],
      _track(),
    );
    expect(ranked.first.id, 'artist-channel');
  });

  test('duration within ±30s outranks an off-length upload', () {
    final ranked = SourcedTrack.rankResults(
      [
        _match('live', title: 'Song (Live)', duration: const Duration(minutes: 6)),
        _match('studio', title: 'Song', duration: const Duration(minutes: 3)),
      ],
      _track(),
    );
    expect(ranked.first.id, 'studio');
  });

  test('artist and album names in the title add confidence', () {
    final ranked = SourcedTrack.rankResults(
      [
        _match('plain', title: 'Song', duration: const Duration(minutes: 3)),
        _match(
          'titled',
          title: 'Artist - Song (Album)',
          duration: const Duration(minutes: 3),
        ),
      ],
      _track(),
    );
    expect(ranked.first.id, 'titled');
  });

  test('empty result set stays empty', () {
    expect(SourcedTrack.rankResults(const [], _track()), isEmpty);
  });
}
