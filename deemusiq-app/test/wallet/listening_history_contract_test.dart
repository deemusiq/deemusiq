import 'package:deemusiq/services/wallet/wallet_api.dart';
import 'package:flutter_test/flutter_test.dart';

/// Parsing contract for the server-side reading surfaces (listening history,
/// stats, playback state, collaboration, taste profile).
///
/// These are the shapes the app must survive without crashing on an edge case:
/// an empty list before any state exists, a null where the type is nullable,
/// and a null where it is NOT (which must fall back to a safe default rather
/// than throw mid-render).
void main() {
  group('ServerListenEntry', () {
    test('parses a full entry', () {
      final e = ServerListenEntry.fromJson({
        'day': '2026-10-08',
        'listenedMs': 210000,
        'durationMs': 240000,
        'skipped': false,
        'source': 'app',
        'track': {'id': 't1', 'title': 'Song'},
      });
      expect(e.day, '2026-10-08');
      expect(e.listenedMs, 210000);
      expect(e.durationMs, 240000);
      expect(e.skipped, isFalse);
      expect(e.track['id'], 't1');
    });

    test('tolerates a null duration and a missing source', () {
      final e = ServerListenEntry.fromJson({
        'day': '2026-10-08',
        'listenedMs': 5000,
        'durationMs': null,
        'skipped': true,
        'track': {'id': 't2'},
      });
      // A skipped row legitimately has no duration — it must be null, not 0,
      // so the UI can tell "unknown length" from "played for no time".
      expect(e.durationMs, isNull);
      expect(e.source, 'app', reason: 'source defaults server-side');
      expect(e.skipped, isTrue);
    });
  });

  group('ServerListenStats', () {
    test('parses totals, chart and rankings', () {
      final s = ServerListenStats.fromJson({
        'days': 30,
        'listens': 12,
        'listensIncludingSkips': 15,
        'listenedMs': 5400000,
        'byDay': [
          {'day': '2026-10-07', 'listenedMs': 1800000},
        ],
        'topTracks': [
          {
            'listenedMs': 600000,
            'days': 4,
            'track': {'id': 't3'},
          },
        ],
        'topArtists': [
          {'id': 'a1', 'name': 'Artist', 'listenedMs': 900000, 'tracks': 5},
        ],
      });
      expect(s.days, 30);
      expect(s.listens, 12);
      // Skips are counted separately so a caller can show "12 tracks, 15 plays"
      // instead of conflating track-days with raw plays.
      expect(s.listensIncludingSkips, 15);
      expect(s.totalTime, const Duration(minutes: 90));
      expect(s.byDay.single.day, '2026-10-07');
      expect(s.topTracks.single.days, 4);
      expect(s.topArtists.single.name, 'Artist');
    });

    test('an empty payload yields empty lists, not a crash', () {
      final s = ServerListenStats.fromJson({
        'days': 7,
        'listens': 0,
        'listensIncludingSkips': 0,
        'listenedMs': 0,
        'byDay': [],
        'topTracks': [],
        'topArtists': [],
      });
      expect(s.byDay, isEmpty);
      expect(s.topTracks, isEmpty);
      expect(s.topArtists, isEmpty);
      expect(s.totalTime, Duration.zero);
    });

    test('missing optional collections default to empty', () {
      // Defensive: a backend that omits the arrays must not produce null.
      final s = ServerListenStats.fromJson({
        'days': 30,
        'listens': 0,
        'listenedMs': 0,
      });
      expect(s.byDay, isEmpty);
      expect(s.topTracks, isEmpty);
      expect(s.topArtists, isEmpty);
      expect(s.listensIncludingSkips, 0);
    });
  });

  group('RemotePlaybackState', () {
    test('parses a resumable state', () {
      final p = RemotePlaybackState.fromJson({
        'queue': [
          {'id': 't1'},
          {'id': 't2'},
        ],
        'currentTrackId': 't2',
        'positionMs': 95000,
        'playing': true,
        'droppedTrackIds': ['t9'],
        'updatedAt': '2026-10-08T10:00:00.000Z',
        'stale': false,
      });
      expect(p.queue.length, 2);
      expect(p.currentTrackId, 't2');
      expect(p.resumeAt, const Duration(seconds: 95));
      expect(p.playing, isTrue);
      // Ids the server filtered must reach the caller so it can prune.
      expect(p.droppedTrackIds, ['t9']);
      expect(p.stale, isFalse);
      expect(p.isEmpty, isFalse);
    });

    test('the no-state shape is empty, not null-crashing', () {
      final p = RemotePlaybackState.fromJson({
        'queue': [],
        'currentTrackId': null,
        'positionMs': 0,
        'playing': false,
        'updatedAt': null,
        'stale': false,
      });
      expect(p.isEmpty, isTrue);
      expect(p.currentTrackId, isNull);
      expect(p.updatedAt, isNull);
      expect(p.droppedTrackIds, isEmpty);
    });

    test('honours the stale flag', () {
      final p = RemotePlaybackState.fromJson({
        'queue': [
          {'id': 't1'},
        ],
        'positionMs': 0,
        'playing': false,
        'stale': true,
      });
      expect(p.stale, isTrue,
          reason: 'old state must still be resumable, just flagged');
    });
  });

  group('SharedPlaylist', () {
    test('distinguishes owner from editor', () {
      final owner = SharedPlaylist.fromJson({
        'id': 'p1',
        'title': 'Mine',
        'myRole': 'owner',
      });
      final editor = SharedPlaylist.fromJson({
        'id': 'p2',
        'title': 'Shared',
        'myRole': 'editor',
      });
      expect(owner.isOwner, isTrue);
      // Both may edit tracks; only the owner may reshare or rename.
      expect(owner.canEdit, isTrue);
      expect(editor.canEdit, isTrue);
      expect(editor.isOwner, isFalse);
    });
  });

  group('TasteProfile', () {
    test('round-trips a filled profile', () {
      final p = TasteProfile.fromJson({
        'genres': ['amapiano', 'gqom'],
        'artistIds': ['a1', 'a2'],
        'era': '2010s',
        'personalizationEnabled': true,
      });
      expect(p.genres, ['amapiano', 'gqom']);
      expect(p.artistIds, ['a1', 'a2']);
      expect(p.era, '2010s');
      expect(p.isEmpty, isFalse);
    });

    test('an un-profiled user is empty, not an error', () {
      final p = TasteProfile.fromJson({
        'genres': [],
        'artistIds': [],
        'era': null,
        'personalizationEnabled': true,
        'updatedAt': null,
      });
      expect(p.isEmpty, isTrue);
    });

    test('a declined profile still parses and stays reversible', () {
      // personalizationEnabled=false means the ENGINE ignores it, but the
      // profile is stored so the choice can be flipped back later.
      final p = TasteProfile.fromJson({
        'genres': ['jazz'],
        'artistIds': [],
        'era': null,
        'personalizationEnabled': false,
      });
      expect(p.personalizationEnabled, isFalse);
      expect(p.genres, ['jazz']);
    });
  });

  group('TrackRatingStats', () {
    test('null likeRatio distinguishes unrated from 0%', () {
      final none = TrackRatingStats.fromJson({
        'likes': 0,
        'dislikes': 0,
        'total': 0,
        'likeRatio': null,
      });
      expect(none.isRated, isFalse);
      expect(none.likeRatio, isNull);

      final mixed = TrackRatingStats.fromJson({
        'likes': 3,
        'dislikes': 1,
        'total': 4,
        'likeRatio': 0.75,
      });
      expect(mixed.isRated, isTrue);
      expect(mixed.likeRatio, 0.75);
    });
  });

  group('TrendingTrack', () {
    test('reads the merged rating block off the flat track DTO', () {
      final t = TrendingTrack.fromJson({
        'id': 't1',
        'title': 'Hot',
        'rating': {'likes': 9, 'dislikes': 1, 'total': 10, 'likeRatio': 0.9},
      });
      expect(t.track['id'], 't1');
      expect(t.rating.likes, 9);
      expect(t.rating.likeRatio, 0.9);
    });
  });
}