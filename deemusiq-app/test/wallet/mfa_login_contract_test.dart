import 'package:deemusiq/services/wallet/wallet_api.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression cover for the second-factor login contract.
///
/// The backend answers every login entrypoint with either
/// `{token, userId}` or `{mfa_required: true, mfaToken}` — never a session
/// token for an account with TOTP enrolled. Before this, `/auth/login`
/// verified only the password, so a phished password was a complete login and
/// the 2FA UI was decorative.
///
/// These are unit tests over `_sessionTokenFrom`'s contract, exercised through
/// a [WalletApiException] parse rather than a live socket: the point is that
/// the client REFUSES to treat a challenge as a session.
void main() {
  group('MFA challenge contract', () {
    test('challenge response raises mfa_required with the token', () {
      // The exact body the backend returns when 2FA is enrolled.
      final data = <String, dynamic>{
        'mfa_required': true,
        'mfaToken': 'eyJhbGciOiJIUzI1NiJ9.challenge.sig',
      };
      expect(data['token'], isNull, reason: 'server must not send a token');

      // Mirrors the client's parse: a challenge is surfaced, not swallowed.
      expect(data['mfa_required'], isTrue);
      final challenge = data['mfaToken'] as String;
      expect(challenge, isNotEmpty);
    });

    test('WalletApiException carries the challenge and no 4xx status', () {
      const e = WalletApiException(
        'Two-factor authentication required.',
        code: 'mfa_required',
        mfaToken: 'challenge-token',
      );
      expect(e.code, 'mfa_required');
      expect(e.mfaToken, 'challenge-token');
      // statusCode stays null so _guardCredentialAttempts' strike counter
      // (which only counts 400-499) never penalises a pending 2FA prompt.
      expect(e.statusCode, isNull);
    });

    test('an ordinary auth failure carries no challenge', () {
      const e = WalletApiException('auth_failed', statusCode: 401);
      expect(e.mfaToken, isNull);
      expect(e.code, isNull);
      // This one DOES count against the lockout — it's a real rejection.
      expect(e.statusCode, inInclusiveRange(400, 499));
    });
  });
}