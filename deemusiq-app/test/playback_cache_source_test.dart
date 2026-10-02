import 'package:flutter_test/flutter_test.dart';
import 'package:deemusiq/provider/server/routes/playback.dart';

void main() {
  group('cacheMetadataMatchesTrackSource', () {
    test('accepts an entry cached for the current track and source', () {
      expect(
        cacheMetadataMatchesTrackSource(
          metadataTrackId: 'track-1',
          metadataSourceId: 'video-a',
          trackId: 'track-1',
          sourceId: 'video-a',
        ),
        isTrue,
      );
    });

    test('bypasses an entry cached under a different source', () {
      expect(
        cacheMetadataMatchesTrackSource(
          metadataTrackId: 'track-1',
          metadataSourceId: 'video-a',
          trackId: 'track-1',
          sourceId: 'video-b',
        ),
        isFalse,
      );
    });

    test('bypasses entries without a recorded source when the source is known', () {
      expect(
        cacheMetadataMatchesTrackSource(
          metadataTrackId: 'track-1',
          metadataSourceId: null,
          trackId: 'track-1',
          sourceId: 'video-b',
        ),
        isFalse,
      );
    });

    test('rejects entries belonging to a different track', () {
      expect(
        cacheMetadataMatchesTrackSource(
          metadataTrackId: 'track-2',
          metadataSourceId: 'video-a',
          trackId: 'track-1',
          sourceId: 'video-a',
        ),
        isFalse,
      );
    });

    test('accepts same-track entries when the current source is unknown', () {
      expect(
        cacheMetadataMatchesTrackSource(
          metadataTrackId: 'track-1',
          metadataSourceId: null,
          trackId: 'track-1',
          sourceId: '',
        ),
        isTrue,
      );
    });
  });
}
