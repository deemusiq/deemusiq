import 'package:flutter_test/flutter_test.dart';
import 'package:deemusiq/provider/server/routes/playback.dart';

void main() {
  group('manifestContentType', () {
    test('detects HLS spellings', () {
      expect(
        manifestContentType('application/vnd.apple.mpegurl'),
        'application/vnd.apple.mpegurl',
      );
      expect(
        manifestContentType('application/x-mpegURL'),
        'application/vnd.apple.mpegurl',
      );
      expect(
        manifestContentType('audio/mpegurl'),
        'application/vnd.apple.mpegurl',
      );
    });

    test('detects DASH', () {
      expect(
        manifestContentType('application/dash+xml'),
        'application/dash+xml',
      );
    });

    test('passes progressive media through', () {
      expect(manifestContentType('audio/webm'), isNull);
      expect(manifestContentType('video/mp4'), isNull);
      expect(manifestContentType(null), isNull);
    });
  });

  group('manifestContentTypeFromUrl', () {
    test('detects by extension', () {
      expect(
        manifestContentTypeFromUrl('https://x.googlevideo.com/a.m3u8?sig=1'),
        'application/vnd.apple.mpegurl',
      );
      expect(
        manifestContentTypeFromUrl('https://x.googlevideo.com/a.mpd'),
        'application/dash+xml',
      );
      expect(manifestContentTypeFromUrl('https://x.googlevideo.com/videoplayback'), isNull);
    });
  });

  group('resolveSegmentUrl', () {
    final origin = Uri.parse('https://rr1---sn-x.googlevideo.com/hls/playlist.m3u8');
    const base = 'https://rr1---sn-x.googlevideo.com/hls';

    test('absolute URL passes through', () {
      expect(
        resolveSegmentUrl('https://other.com/seg.ts', base, origin),
        'https://other.com/seg.ts',
      );
    });

    test('root-relative resolves against origin', () {
      expect(
        resolveSegmentUrl('/videoplayback/seg1.ts', base, origin),
        'https://rr1---sn-x.googlevideo.com/videoplayback/seg1.ts',
      );
    });

    test('relative resolves against the manifest directory', () {
      expect(
        resolveSegmentUrl('seg1.ts', base, origin),
        '$base/seg1.ts',
      );
    });
  });

  group('rewriteHlsManifest', () {
    test('rewrites segment lines and key URIs through the segment endpoint', () {
      const manifest = '''
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-TARGETDURATION:5
#EXT-X-KEY:METHOD=AES-128,URI="https://googlevideo.com/key?p=1"
#EXT-X-MAP:URI="/init.mp4"
#EXTINF:5.000,
seg1.ts
#EXTINF:5.000,
/videoplayback/seg2.ts
#EXTINF:4.500,
https://cdn.example.com/seg3.ts
#EXT-X-ENDLIST
''';
      final out = rewriteHlsManifest(
        manifest,
        'https://rr1---sn-x.googlevideo.com/hls/playlist.m3u8',
        'track 9',
      );
      final lines = out.split('\n');

      expect(lines[0], '#EXTM3U');
      expect(lines[1], '#EXT-X-VERSION:3');
      expect(lines[2], '#EXT-X-TARGETDURATION:5');

      // Key URI proxied, method preserved.
      expect(lines[3], startsWith('#EXT-X-KEY:METHOD=AES-128,URI="'));
      expect(
        lines[3],
        contains(
          '/stream/track%209/segment?url=${Uri.encodeComponent('https://googlevideo.com/key?p=1')}',
        ),
      );

      // EXT-X-MAP root-relative URI proxied and absolutized.
      expect(
        lines[4],
        startsWith('#EXT-X-MAP:URI="/stream/track%209/segment?url='
            '${Uri.encodeComponent('https://rr1---sn-x.googlevideo.com/init.mp4')}'),
      );
      // Segment URLs carry a per-process HMAC against open-SSRF replay.
      expect(lines[4], contains('&sig='));
      expect(lines[4], endsWith('"'));

      expect(lines[5], '#EXTINF:5.000,');
      expect(
        lines[6],
        startsWith('/stream/track%209/segment?url='
            '${Uri.encodeComponent('https://rr1---sn-x.googlevideo.com/hls/seg1.ts')}'),
      );
      expect(lines[6], contains('&sig='));
      expect(
        lines[8],
        startsWith('/stream/track%209/segment?url='
            '${Uri.encodeComponent('https://rr1---sn-x.googlevideo.com/videoplayback/seg2.ts')}'),
      );
      expect(lines[8], contains('&sig='));
      expect(
        lines[10],
        startsWith('/stream/track%209/segment?url='
            '${Uri.encodeComponent('https://cdn.example.com/seg3.ts')}'),
      );
      expect(lines[10], contains('&sig='));
      expect(lines[11], '#EXT-X-ENDLIST');
    });

    test('leaves master-playlist variant lines tagged but proxied', () {
      const manifest = '''
#EXTM3U
#EXT-X-STREAM-INF:BANDWIDTH=128000
variant/index.m3u8
''';
      final out = rewriteHlsManifest(
        manifest,
        'https://example.com/master.m3u8',
        't1',
      );
      final lines = out.split('\n');
      expect(lines[1], '#EXT-X-STREAM-INF:BANDWIDTH=128000');
      expect(
        lines[2],
        startsWith(
            '/stream/t1/segment?url=${Uri.encodeComponent('https://example.com/variant/index.m3u8')}'),
      );
      expect(lines[2], contains('&sig='));
    });
  });
}
