import 'package:flutter_test/flutter_test.dart';
import 'package:deemusiq/services/artist_info/artist_info_service.dart';

void main() {
  group('ArtistInfoService.secureImageUrl', () {
    test('accepts allowlisted HTTPS hosts', () {
      for (final url in const [
        'https://cdn-images.dzcdn.net/images/artist/abc/1000x1000.jpg',
        'https://is1-ssl.mzstatic.com/image/thumb/Features/600x600bb.jpg',
        'https://yt3.ggpht.com/ytc/abc=s900-c-k-c0x00ffffff-no-rj',
        'https://yt3.googleusercontent.com/abc=s900',
        'https://i.ytimg.com/vi/abc/hqdefault.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/a/ab/photo.jpg',
        'https://lastfm.freetls.fastly.net/i/u/770x0/abc.webp',
      ]) {
        expect(
          ArtistInfoService.secureImageUrl(url),
          isNotNull,
          reason: '$url should be accepted',
        );
      }
    });

    test('rejects insecure or unknown hosts', () {
      for (final url in const [
        'http://cdn-images.dzcdn.net/images/artist/abc.jpg', // plain http
        'https://evil.example.com/photo.jpg', // unknown host
        'https://dzcdn.net.evil.example.com/x.jpg', // lookalike suffix
        'https://user:pass@cdn-images.dzcdn.net/x.jpg', // embedded credentials
        'https://cdn-images.dzcdn.net:8443/x.jpg', // non-default port
        'ftp://upload.wikimedia.org/x.jpg', // non-https scheme
        '',
        '   ',
        'not a url',
      ]) {
        expect(
          ArtistInfoService.secureImageUrl(url),
          isNull,
          reason: '$url should be rejected',
        );
      }
    });

    test('returns null for null input', () {
      expect(ArtistInfoService.secureImageUrl(null), isNull);
    });
  });
}
