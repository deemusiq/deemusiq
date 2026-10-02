import 'package:flutter_test/flutter_test.dart';
import 'package:deemusiq/pages/auth/birth_year.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

void main() {
  group('parseBirthYearInput', () {
    test('accepts a plausible year', () {
      expect(parseBirthYearInput('1990', currentYear: 2026), 1990);
      expect(parseBirthYearInput(' 1985 ', currentYear: 2026), 1985);
      expect(parseBirthYearInput('2026', currentYear: 2026), 2026);
    });

    test('rejects non-numeric, future and implausible years', () {
      expect(parseBirthYearInput('', currentYear: 2026), isNull);
      expect(parseBirthYearInput('abcd', currentYear: 2026), isNull);
      expect(parseBirthYearInput('19a0', currentYear: 2026), isNull);
      expect(parseBirthYearInput('2027', currentYear: 2026), isNull);
      expect(parseBirthYearInput('1899', currentYear: 2026), isNull);
    });
  });

  group('submitBirthYearToServer', () {
    test('success path submits the parsed birth year', () async {
      int? submitted;
      final result = await submitBirthYearToServer(
        1990,
        submit: (year) async => submitted = year,
      );

      expect(result.status, BirthYearSubmitStatus.success);
      expect(submitted, 1990);
    });

    test('under-18 rejection maps to underMinAge with a readable message',
        () async {
      final result = await submitBirthYearToServer(
        2015,
        submit: (year) async => throw const WalletApiException(
          'under_min_age',
          statusCode: 400,
          code: 'under_min_age',
        ),
      );

      expect(result.status, BirthYearSubmitStatus.underMinAge);
      expect(result.message, isNotNull);
      expect(result.message, isNot(contains('under_min_age')));
      expect(
        result.message,
        const WalletApiException('under_min_age',
                statusCode: 400, code: 'under_min_age')
            .friendlyMessage,
      );
    });

    test('connectivity failure defers to the offline flow', () async {
      final result = await submitBirthYearToServer(
        1990,
        submit: (year) async =>
            throw const WalletApiException('SocketException', isConnectivity: true),
      );

      expect(result.status, BirthYearSubmitStatus.connectivity);
    });

    test('other server rejections map to error with a friendly message',
        () async {
      final result = await submitBirthYearToServer(
        1990,
        submit: (year) async => throw const WalletApiException(
          'boom',
          statusCode: 503,
          code: 'security_state_unavailable',
        ),
      );

      expect(result.status, BirthYearSubmitStatus.error);
      expect(result.message, contains('temporarily unavailable'));
    });

    test('unexpected exceptions never propagate into sign-in', () async {
      final result = await submitBirthYearToServer(
        1990,
        submit: (year) async => throw StateError('secure storage missing'),
      );

      expect(result.status, BirthYearSubmitStatus.connectivity);
    });
  });
}
