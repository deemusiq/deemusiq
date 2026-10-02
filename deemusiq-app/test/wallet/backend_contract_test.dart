import 'package:flutter_test/flutter_test.dart';
import 'package:deemusiq/models/wallet/token_transaction.dart';
import 'package:deemusiq/models/wallet/wallet_state.dart';
import 'package:deemusiq/provider/creator/creator_provider.dart';
import 'package:deemusiq/services/wallet/secure_channel.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

void main() {
  test('payment request signing matches backend v2 (ts.body) rules', () {
    const secret = 'test-hmac-secret-1234567890abcdef';
    const timestamp = 1700000000123; // unix ms
    const body =
        '{"packId":"starter","method":"payshap","region":"ZA","payerPhone":"+27821234567"}';

    expect(
      WalletApiClient.paymentRequestSignature(
        timestamp: timestamp,
        body: body,
        secret: secret,
      ),
      '7f3b29e0a9b2648412bbf70f3c93d47adb4cf105594453f921b71bb88bc622cb',
    );

    final headers = WalletApiClient.paymentRequestHeaders(
      timestamp: timestamp,
      body: body,
      idempotencyKey: 'checkout-attempt-1',
      secret: secret,
    );
    expect(headers['Idempotency-Key'], 'checkout-attempt-1');
    expect(headers['X-DM-Pay-Ts'], '$timestamp');
    expect(headers['X-DM-Pay-Sig'], isNotEmpty);
  });

  test('wallet state keeps the server balance and sync failure explicit', () {
    final transaction = TokenTransaction(
      id: 'tx-1',
      type: TokenTransactionType.topUp,
      tokens: 10,
      timestamp: DateTime.utc(2026),
      description: 'Top up',
    );
    final state = WalletState(
      transactions: [transaction],
      authoritativeBalance: 73,
      syncError: 'wallet_history_pagination_unsupported',
    );

    expect(state.balance, 73);
    final restored = WalletState.fromJson(state.toJson());
    expect(restored.balance, 73);
    expect(restored.syncError, 'wallet_history_pagination_unsupported');
    expect(
      state.copyWith(clearAuthoritativeBalance: true).balance,
      10,
    );
  });

  test('authoritative balance survives incomplete history replacement', () {
    final local = WalletState(
      transactions: [
        TokenTransaction(
          id: 'local-tx',
          type: TokenTransactionType.bonus,
          tokens: 9,
          timestamp: DateTime.utc(2026),
          description: 'Local',
        ),
      ],
      authoritativeBalance: 73,
      syncError: 'wallet_history_pagination_unsupported',
    );

    final synced = local.copyWith(transactions: const []);
    expect(synced.balance, 73);
    expect(synced.transactions, isEmpty);
  });

  test('creator parser exposes the draft review gate', () {
    final draft = CreatorSong.fromJson({
      'id': 'song-1',
      'title': 'Draft',
      'status': 'draft',
      'hasAudio': true,
      'hasCover': true,
      'stats': <String, dynamic>{},
    });
    final incomplete = CreatorSong.fromJson({
      'id': 'song-2',
      'title': 'Incomplete',
      'status': 'draft',
      'hasAudio': true,
      'hasCover': false,
      'stats': <String, dynamic>{},
    });

    expect(draft.canSubmitForReview, isTrue);
    expect(incomplete.canSubmitForReview, isFalse);
  });

  test('secure channel exposes device routing and zero-width round trips', () {
    const value = '{"device":"test","value":"支付"}';
    expect(SecureChannel.zwDecode(SecureChannel.zwEncode(value)), value);
    expect(SecureChannel.deviceHeaderName, 'X-DM-Device');
    expect(SecureChannel.deviceIdHeaderName, 'X-DM-Device-ID');
    expect(SecureChannel.isExemptPath('/integrity/report'), isTrue);
    expect(SecureChannel.isExemptPath('/creator/uploads/audio'), isTrue);
  });

  group('WalletApiException.friendlyMessage never leaks raw server codes', () {
    test('maps wallet/payment status codes to readable sentences', () {
      expect(
        const WalletApiException('insufficient_balance',
                statusCode: 400, code: 'insufficient_balance')
            .friendlyMessage,
        contains('Not enough tokens'),
      );
      expect(
        const WalletApiException('bad_phone',
                statusCode: 400, code: 'bad_phone')
            .friendlyMessage,
        contains('+27'),
      );
      expect(
        const WalletApiException('idempotency_key_reused',
                statusCode: 409, code: 'idempotency_key_reused')
            .friendlyMessage,
        isNot('idempotency_key_reused'),
      );
      expect(
        const WalletApiException('too_many_checkouts',
                statusCode: 429, code: 'too_many_checkouts')
            .friendlyMessage,
        contains('Too many attempts'),
      );
      expect(
        const WalletApiException('too_many_supports',
                statusCode: 429, code: 'too_many_supports')
            .friendlyMessage,
        contains('Too many attempts'),
      );
      expect(
        const WalletApiException('security_state_unavailable',
                statusCode: 503, code: 'security_state_unavailable')
            .friendlyMessage,
        contains('temporarily unavailable'),
      );
    });

    test('falls back on status code when the body has no known code', () {
      expect(
        const WalletApiException('Payment Required', statusCode: 402)
            .friendlyMessage,
        contains("haven't been charged"),
      );
      expect(
        const WalletApiException('conflict', statusCode: 409).friendlyMessage,
        isNot('conflict'),
      );
      expect(
        const WalletApiException('too_many_requests', statusCode: 429)
            .friendlyMessage,
        contains('Too many attempts'),
      );
      expect(
        const WalletApiException('oops', statusCode: 503).friendlyMessage,
        contains('temporarily unavailable'),
      );
    });

    test('connectivity failures get an offline-flavoured message', () {
      expect(
        const WalletApiException('SocketException', isConnectivity: true)
            .friendlyMessage,
        contains('check your connection'),
      );
    });

    test('unmapped server sentences pass through untouched', () {
      const sentence =
          'Card checkout is temporarily unavailable. Please try again.';
      expect(
        const WalletApiException(sentence, statusCode: 502).friendlyMessage,
        sentence,
      );
    });
  });
}
