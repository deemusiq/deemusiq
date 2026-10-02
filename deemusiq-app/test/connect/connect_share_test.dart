import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:deemusiq/models/connect/connect.dart';
import 'package:deemusiq/models/metadata/metadata.dart';

DeeMusiqFullTrackObject _track(String id, [String name = 'Song']) {
  return DeeMusiqFullTrackObject(
    id: id,
    name: name,
    externalUri: 'https://music.example/track/$id',
    artists: [
      DeeMusiqSimpleArtistObject(
        id: 'artist-1',
        name: 'Artist $id',
        externalUri: '',
      ),
    ],
    album: DeeMusiqSimpleAlbumObject(
      albumType: DeeMusiqAlbumType.album,
      id: 'album-1',
      name: 'Album',
      externalUri: '',
      artists: const [],
      images: [DeeMusiqImageObject(url: 'https://img/$id.jpg', width: 300, height: 300)],
      releaseDate: '2024-01-01',
    ),
    durationMs: 180000,
    isrc: '',
    explicit: false,
  );
}

void main() {
  group('WsEvent.share protocol', () {
    test('share type parses; unknown types fall back to error (back-compat)',
        () {
      expect(WsEvent.fromString('share'), WsEvent.share);
      // An older build receiving "share" maps it to error — it logs/toasts
      // instead of crashing (see WebSocketErrorEvent handling).
      expect(WsEvent.fromString('shareV99'), WsEvent.error);
    });

    test('track share round-trips through the WebSocketEvent envelope', () async {
      final payload = ConnectSharePayload.track(_track('t-1', 'Hello'));
      final encoded = WebSocketShareEvent(payload).toJson();

      final decoded = WebSocketEvent.fromJson(jsonDecode(encoded), (d) => d);
      expect(decoded.type, WsEvent.share);

      ConnectSharePayload? received;
      await decoded.onShare((event) async {
        received = event.data;
      });
      expect(received, isNotNull);
      expect(received!.kind, ConnectSharePayload.kindTrack);
      expect(received!.id, 't-1');
      expect(received!.title, 'Hello');
      expect(received!.artist, 'Artist t-1');
      expect(received!.coverUrl, 'https://img/t-1.jpg');
      expect(received!.externalUri, 'https://music.example/track/t-1');
      expect(received!.version, ConnectSharePayload.currentVersion);
    });

    test('non-share callbacks do not fire for share events', () async {
      final event = WebSocketEvent.fromJson(
        jsonDecode(
          WebSocketShareEvent(ConnectSharePayload.track(_track('t-2')))
              .toJson(),
        ),
        (d) => d,
      );
      var fired = false;
      await event.onPause((_) async => fired = true);
      await event.onQueue((_) async => fired = true);
      await event.onAddTrack((_) async => fired = true);
      expect(fired, isFalse);
    });

    test('playlist payload carries capped, metadata-only track entries', () {
      final playlist = DeeMusiqSimplePlaylistObject(
        id: 'pl-1',
        name: 'Mega Mix',
        description: '',
        externalUri: 'https://music.example/playlist/pl-1',
        owner: DeeMusiqUserObject(id: 'u-1', name: 'Someone', externalUri: ''),
        images: const [],
      );
      final tracks = List.generate(250, (i) => _track('t-$i'));

      final payload =
          ConnectSharePayload.playlist(playlist: playlist, tracks: tracks);
      expect(payload.kind, ConnectSharePayload.kindPlaylist);
      expect(payload.tracks, hasLength(ConnectSharePayload.maxPlaylistTracks));
      expect(payload.truncated, isTrue);

      // Metadata only: no audio/url fields beyond the catalog id + display data.
      final json = payload.toJson();
      final entry = (json['tracks'] as List).first as Map<String, dynamic>;
      expect(entry.keys, containsAll(['id', 'title', 'artist']));
      expect(entry.keys, isNot(contains('audioUrl')));
      expect(entry.keys, isNot(contains('bytes')));
    });

    test('encodeChecked enforces the size guard', () {
      final payload = ConnectSharePayload.track(_track('t-1'));
      expect(payload.encodeChecked(), isNotEmpty);
      expect(
        () => payload.encodeChecked(maxBytes: 10),
        throwsStateError,
      );
    });

    test('fromJson rejects unsupported versions and kinds', () {
      Map<String, dynamic> base() =>
          ConnectSharePayload.track(_track('t-1')).toJson();

      expect(
        () => ConnectSharePayload.fromJson({...base(), 'v': 0}),
        throwsFormatException,
      );
      expect(
        () => ConnectSharePayload.fromJson({
          ...base(),
          'v': ConnectSharePayload.currentVersion + 1,
        }),
        throwsFormatException,
      );
      expect(
        () => ConnectSharePayload.fromJson({...base(), 'kind': 'album'}),
        throwsFormatException,
      );
      expect(
        () => ConnectSharePayload.fromJson({...base(), 'id': ''}),
        throwsFormatException,
      );
    });

    test('fromJson bounds overlong fields and ignores junk track entries', () {
      final json = ConnectSharePayload.track(_track('t-1')).toJson();
      json['title'] = 'x' * 1000;
      json['tracks'] = [
        {'id': 'ok', 'title': 'T', 'artist': 'A'},
        'junk',
        {'noId': true},
      ];

      final payload = ConnectSharePayload.fromJson(json);
      expect(payload.title.length, ConnectSharePayload.maxFieldLength);
      // Junk rows are skipped — one malformed entry must not kill the share.
      expect(payload.tracks, hasLength(1));
      expect(payload.tracks.single.id, 'ok');
    });
  });

  group('WsEvent.paired protocol (H1 pairing tokens)', () {
    test('paired type parses; unknown types still fall back to error', () {
      expect(WsEvent.fromString('paired'), WsEvent.paired);
      expect(WsEvent.fromString('pairedV99'), WsEvent.error);
    });

    test('pairing token round-trips through the WebSocketEvent envelope',
        () async {
      const token = 'abcd1234-pairing-token';
      final encoded = WebSocketPairedEvent(token).toJson();

      final decoded = WebSocketEvent.fromJson(jsonDecode(encoded), (d) => d);
      expect(decoded.type, WsEvent.paired);

      String? received;
      await decoded.onPaired((event) async {
        received = event.data;
      });
      expect(received, token);

      // Other callbacks must not fire for a paired event.
      var fired = false;
      await decoded.onPause((_) async => fired = true);
      await decoded.onShare((_) async => fired = true);
      expect(fired, isFalse);
    });
  });
}
