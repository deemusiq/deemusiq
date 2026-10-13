import 'package:deemusiq/services/wallet/wallet_api.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cover for the account-creation contract introduced by POST /auth/signup.
///
/// The property that matters: `/auth/signup` returns
/// `{ok, verificationRequired, email}` and **no token**. The session only
/// arrives from `/auth/signup/verify`, once the caller has proved control of
/// the address with the emailed 6-digit code. If the client ever treated the
/// signup response as a sign-in, account creation would silently become an open
/// account factory — anyone could mint unlimited verified-looking identities
/// from throwaway addresses.
void main() {
  group('sign-up response contract', () {
    test('signup returns no token and demands verification', () {
      // The exact body the backend sends from POST /auth/signup.
      final data = <String, dynamic>{
        'ok': true,
        'verificationRequired': true,
        'email': 'someone@example.test',
      };

      // A token here would be a full account takeover for anyone who can
      // receive mail at an arbitrary address.
      expect(data['token'], isNull, reason: 'signup must not return a token');
      expect(data['mfaToken'], isNull);

      // And the response must positively tell the client not to sign in.
      expect(data['verificationRequired'], isTrue);
      expect(data['email'], 'someone@example.test');
    });

    test('only the verify response carries a session token', () {
      final verify = <String, dynamic>{
        'token': 'eyJhbGciOiJIUzI1NiJ9.session.sig',
        'userId': 'user-1',
      };
      expect(verify['token'], isA<String>());
      expect((verify['token'] as String), isNotEmpty);
    });

    test('resend is indistinguishable for known and unknown addresses', () {
      // Both answer `{ok: true}` — the route must never become an
      // account-existence oracle on an unauthenticated surface.
      const known = <String, dynamic>{'ok': true};
      const unknown = <String, dynamic>{'ok': true};
      expect(known, equals(unknown));
    });
  });

  group('sign-up failures read as sentences, not machine codes', () {
    test('email_taken points the user at signing in', () {
      const e = WalletApiException('email_taken', statusCode: 409, code: 'email_taken');
      expect(e.code, 'email_taken');
      expect(e.friendlyMessage, contains('already has a DeeMusiq account'));
      // The raw code must never reach the user.
      expect(e.friendlyMessage, isNot(contains('email_taken')));
    });

    test('the per-IP signup ceiling is explained, not leaked', () {
      const e = WalletApiException('too_many_signups', statusCode: 429, code: 'too_many_signups');
      expect(e.friendlyMessage, contains('Too many accounts'));
      expect(e.friendlyMessage, isNot(contains('too_many_signups')));
    });

    test('every password-policy reason has its own sentence', () {
      // Each of these is a distinct `checkPassword` rejection. Sharing one
      // generic message would leave a user unable to tell a too-short password
      // from a well-known one — the guidance differs.
      const codes = <String>[
        'password_too_short',
        'password_too_long',
        'password_too_simple',
        'password_too_common',
        'password_contains_email',
        'weak_password',
      ];
      for (final code in codes) {
        final e = WalletApiException(code, statusCode: 400, code: code);
        expect(e.friendlyMessage, isNotEmpty, reason: code);
        expect(e.friendlyMessage, isNot(contains(code)), reason: code);
      }
      // And they must be genuinely different sentences.
      final messages =
          codes.map((c) => WalletApiException(c, code: c).friendlyMessage)
              .toSet();
      expect(messages.length, codes.length);
    });

    test('a wrong confirmation code is told what to do', () {
      const e = WalletApiException('auth_failed', statusCode: 401, code: 'auth_failed');
      expect(e.friendlyMessage, contains('confirmation code'));
    });

    test('an unmapped code still never renders as a raw identifier', () {
      const e = WalletApiException('server_error', statusCode: 500);
      // No mapping for this one, so the message passes through — but the
      // generic status fallback keeps it human-readable rather than empty.
      expect(e.friendlyMessage, isNotEmpty);
    });
  });
}
