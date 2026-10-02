import 'package:flutter_test/flutter_test.dart';
import 'package:deemusiq/provider/server/access_control.dart';

void main() {
  group('ConnectAccessGuard (H1)', () {
    bool isValidToken(String token) => token == 'good-token';

    test('loopback in-app traffic passes (no browser markers)', () {
      final denied = ConnectAccessGuard.check(
        isLoopback: true,
        connectEnabled: false,
        headers: const {},
        queryToken: null,
        isTokenValid: isValidToken,
      );
      expect(denied, isNull);
    });

    test('browser drive-by on loopback is rejected (Origin header)', () {
      final denied = ConnectAccessGuard.check(
        isLoopback: true,
        connectEnabled: false,
        headers: const {'origin': 'http://evil.example'},
        queryToken: null,
        isTokenValid: isValidToken,
      );
      expect(denied?.statusCode, 403);
    });

    test('browser drive-by on loopback is rejected (Sec-Fetch-Site header)',
        () {
      final denied = ConnectAccessGuard.check(
        isLoopback: true,
        connectEnabled: true,
        headers: const {'sec-fetch-site': 'cross-site'},
        queryToken: 'good-token', // even a valid token doesn't help a browser
        isTokenValid: isValidToken,
      );
      expect(denied?.statusCode, 403);
    });

    test('LAN caller without a token gets 401 when Connect is enabled', () {
      final denied = ConnectAccessGuard.check(
        isLoopback: false,
        connectEnabled: true,
        headers: const {},
        queryToken: null,
        isTokenValid: isValidToken,
      );
      expect(denied?.statusCode, 401);
    });

    test('LAN caller with a bad token gets 401', () {
      final denied = ConnectAccessGuard.check(
        isLoopback: false,
        connectEnabled: true,
        headers: const {'x-dm-connect-token': 'wrong'},
        queryToken: null,
        isTokenValid: isValidToken,
      );
      expect(denied?.statusCode, 401);
    });

    test('LAN caller with a valid pairing token passes (header and query)', () {
      expect(
        ConnectAccessGuard.check(
          isLoopback: false,
          connectEnabled: true,
          headers: const {'x-dm-connect-token': 'good-token'},
          queryToken: null,
          isTokenValid: isValidToken,
        ),
        isNull,
      );
      expect(
        ConnectAccessGuard.check(
          isLoopback: false,
          connectEnabled: true,
          headers: const {},
          queryToken: 'good-token',
          isTokenValid: isValidToken,
        ),
        isNull,
      );
    });

    test('Connect disabled rejects off-device even with a valid token', () {
      // Connect off ⇒ loopback bind ⇒ off-device should be impossible; the
      // guard is the defence-in-depth layer for that invariant.
      final denied = ConnectAccessGuard.check(
        isLoopback: false,
        connectEnabled: false,
        headers: const {'x-dm-connect-token': 'good-token'},
        queryToken: null,
        isTokenValid: isValidToken,
      );
      expect(denied?.statusCode, 403);
    });
  });
}
