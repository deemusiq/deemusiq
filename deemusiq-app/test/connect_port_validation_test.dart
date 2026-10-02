import 'package:deemusiq/modules/settings/playback/edit_connect_port_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("validateConnectPort", () {
    test("accepts the full bindable port range", () {
      expect(validateConnectPort("1"), isNull);
      expect(validateConnectPort("3000"), isNull);
      expect(validateConnectPort("65535"), isNull);
    });

    test("rejects zero, negatives and ports above 65535", () {
      expect(validateConnectPort("0"), isNotNull);
      expect(validateConnectPort("-1"), isNotNull);
      expect(validateConnectPort("-3000"), isNotNull);
      expect(validateConnectPort("65536"), isNotNull);
      expect(validateConnectPort("100000"), isNotNull);
    });

    test("rejects empty and non-numeric input", () {
      expect(validateConnectPort(null), isNotNull);
      expect(validateConnectPort(""), isNotNull);
      expect(validateConnectPort("abc"), isNotNull);
      expect(validateConnectPort("30a00"), isNotNull);
    });
  });
}
