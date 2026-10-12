import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deemusiq/services/audio_player/audio_player.dart'
    show loudnessGainLinear;
import 'package:deemusiq/services/audio_player/data_saver.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("DataSaverService.isActiveFor", () {
    test("off is never active", () {
      expect(
        DataSaverService.isActiveFor(DataSaverMode.off, metered: false),
        isFalse,
      );
      expect(
        DataSaverService.isActiveFor(DataSaverMode.off, metered: true),
        isFalse,
      );
    });

    test("on is always active", () {
      expect(
        DataSaverService.isActiveFor(DataSaverMode.on, metered: false),
        isTrue,
      );
    });

    test("auto-on-metered follows the connection", () {
      expect(
        DataSaverService.isActiveFor(DataSaverMode.autoOnMetered,
            metered: true),
        isTrue,
      );
      expect(
        DataSaverService.isActiveFor(DataSaverMode.autoOnMetered,
            metered: false),
        isFalse,
      );
    });
  });

  group("DataSaverService persistence", () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await KVStoreService.initialize();
    });

    test("mode defaults to off and round-trips through the KV store",
        () async {
      expect(DataSaverService.mode, DataSaverMode.off);

      await DataSaverService.setMode(DataSaverMode.autoOnMetered);
      expect(DataSaverService.mode, DataSaverMode.autoOnMetered);

      await DataSaverService.setMode(DataSaverMode.on);
      expect(DataSaverService.mode, DataSaverMode.on);
    });

    test("an unknown stored value falls back to off", () async {
      await KVStoreService.sharedPreferences
          .setString("dataSaverMode", "bogus");
      expect(DataSaverService.mode, DataSaverMode.off);
    });
  });

  group("lowestBitrateOf", () {
    test("picks the lowest bitrate", () {
      final picked = lowestBitrateOf(
        [128000.0, 48000.0, 256000.0],
        (v) => v,
      );
      expect(picked, 48000.0);
    });

    test("missing bitrates lose to known ones", () {
      final picked = lowestBitrateOf(
        <({String name, double? bitrate})>[
          (name: "unknown", bitrate: null),
          (name: "low", bitrate: 64000.0),
        ],
        (item) => item.bitrate,
      );
      expect(picked?.name, "low");
    });

    test("empty list yields null", () {
      expect(lowestBitrateOf(const <double>[], (v) => v), isNull);
    });
  });

  group("loudnessGainLinear", () {
    test("0 dB is unity gain", () {
      expect(loudnessGainLinear(0), closeTo(1.0, 1e-9));
    });

    test("-6 dB roughly halves the amplitude", () {
      expect(loudnessGainLinear(-6), closeTo(0.501, 0.001));
    });

    test("+6 dB roughly doubles it", () {
      expect(loudnessGainLinear(6), closeTo(1.995, 0.01));
    });

    test("extreme values are clamped to ±15 dB", () {
      expect(loudnessGainLinear(-60), closeTo(loudnessGainLinear(-15), 1e-9));
      expect(loudnessGainLinear(60), closeTo(loudnessGainLinear(15), 1e-9));
    });
  });
}
