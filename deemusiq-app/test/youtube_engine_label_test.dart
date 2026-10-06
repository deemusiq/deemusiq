import 'package:deemusiq/models/database/database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("YoutubeClientEngine display labels", () {
    test("engines are branded Drop 1/2/3 for the UI", () {
      expect(YoutubeClientEngine.ytDlp.label, "Drop 1");
      expect(YoutubeClientEngine.youtubeExplode.label, "Drop 2");
      expect(YoutubeClientEngine.newPipe.label, "Drop 3");
    });

    test("drift persistence keys (.name) are unchanged", () {
      // EnumNameConverter serializes .name, so these must never move even
      // when the user-facing label changes.
      expect(YoutubeClientEngine.ytDlp.name, "ytDlp");
      expect(YoutubeClientEngine.youtubeExplode.name, "youtubeExplode");
      expect(YoutubeClientEngine.newPipe.name, "newPipe");
    });

    test("labels never leak internal engine names", () {
      for (final engine in YoutubeClientEngine.values) {
        expect(engine.label, isNot(contains("YouTube")));
        expect(engine.label, isNot(contains("yt-dlp")));
        expect(engine.label, isNot(contains("NewPipe")));
      }
    });
  });
}
