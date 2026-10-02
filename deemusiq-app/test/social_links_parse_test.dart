import 'package:deemusiq/pages/creator/verification_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("parseSocialLinks", () {
    test("returns empty for blank input", () {
      expect(parseSocialLinks(""), isEmpty);
      expect(parseSocialLinks("   \n , "), isEmpty);
    });

    test("parses 'provider: url' lines", () {
      final result = parseSocialLinks(
        "instagram: https://instagram.com/a\nyoutube: https://youtube.com/@a",
      );
      expect(result, hasLength(2));
      expect(result[0].provider, "instagram");
      expect(result[0].url, "https://instagram.com/a");
      expect(result[1].provider, "youtube");
      expect(result[1].url, "https://youtube.com/@a");
    });

    test("bare URLs are not split on their scheme colon", () {
      final result = parseSocialLinks("https://example.com");
      expect(result, hasLength(1));
      expect(result[0].provider, "website");
      expect(result[0].url, "https://example.com");
    });

    test("comma-separated entries work too", () {
      final result =
          parseSocialLinks("tiktok: https://tiktok.com/@a, https://example.com");
      expect(result, hasLength(2));
      expect(result[0].provider, "tiktok");
      expect(result[1].provider, "website");
      expect(result[1].url, "https://example.com");
    });
  });
}
