import 'package:flutter_test/flutter_test.dart';
import 'package:deemusiq/models/wallet/payment_method.dart';
import 'package:deemusiq/models/wallet/region_pricing.dart';
import 'package:deemusiq/models/wallet/token_pack.dart';
import 'package:deemusiq/services/wallet/payment_service.dart';

void main() {
  const service = DeeMusiqPaymentService();
  final pack = TokenPack.all.first;

  test("test runs are offline builds (no backend URL baked in)", () {
    expect(PaymentGatewayConfig.backendBaseUrl, isEmpty);
  });

  test("without a backend every real rail requires the backend", () async {
    for (final method in PaymentMethodKind.topUpMethods) {
      final res = await service.purchase(
        pack: pack,
        region: RegionTier.za,
        method: method,
      );
      expect(res.status, PaymentStatus.requiresBackend,
          reason: "method ${method.name} must route to the backend");
      expect(res.creditedTokens, 0,
          reason: "offline purchases must never credit tokens");
      expect(res.allowSimulate, isFalse,
          reason: "no fake-credit affordance for real rails");
      expect(res.actionUrl, isNull);
      expect(res.deposit, isNull);
      expect(res.reference, startsWith("DM-"));
    }
  });

  test("demo credit cannot mint tokens offline", () async {
    final res = await service.purchase(
      pack: pack,
      region: RegionTier.za,
      method: PaymentMethodKind.demoCredit,
    );
    // The offline gate fires before the demo-credit branch: tokens are bought
    // online only, so even the demo method routes to the backend message.
    expect(res.status, PaymentStatus.requiresBackend);
    expect(res.creditedTokens, 0);
    expect(res.allowSimulate, isFalse);
  });

  group("normalizePayerPhone matches the backend's normalizeE164", () {
    // Mirrors backend/src/util/phone.ts: ZA country code 27, formatting
    // stripped, trunk 0 dropped, loose E.164 (7–15 digits) enforced.
    test("national and international forms normalise identically", () {
      expect(
        DeeMusiqPaymentService.normalizePayerPhone("073 725 3454"),
        "+27737253454",
      );
      expect(
        DeeMusiqPaymentService.normalizePayerPhone("+27 73 725 3454"),
        "+27737253454",
      );
      expect(
        DeeMusiqPaymentService.normalizePayerPhone("27737253454"),
        "+27737253454",
      );
      expect(
        DeeMusiqPaymentService.normalizePayerPhone("+27 (73) 725-3454"),
        "+27737253454",
      );
    });

    test("rejects implausible numbers instead of round-tripping a 400", () {
      expect(DeeMusiqPaymentService.normalizePayerPhone(""), isNull);
      expect(DeeMusiqPaymentService.normalizePayerPhone("   "), isNull);
      expect(DeeMusiqPaymentService.normalizePayerPhone("abc"), isNull);
      expect(DeeMusiqPaymentService.normalizePayerPhone("0123"), isNull);
      expect(
        DeeMusiqPaymentService.normalizePayerPhone("+2700737253454000000"),
        isNull,
      );
      expect(
        DeeMusiqPaymentService.normalizePayerPhone("+27 82 123 4567 ext 9"),
        isNull,
      );
    });

    test("honours a non-ZA default country code", () {
      expect(
        DeeMusiqPaymentService.normalizePayerPhone(
          "07123 456789",
          defaultCountryCode: "254",
        ),
        "+2547123456789",
      );
    });
  });

  test("unavailable-method cache is observable by the method picker", () {
    DeeMusiqPaymentService.unavailableMethods.clear();
    addTearDown(DeeMusiqPaymentService.unavailableMethods.clear);

    expect(
      DeeMusiqPaymentService.isMethodUnavailable(PaymentMethodKind.monero),
      isFalse,
    );
    DeeMusiqPaymentService.unavailableMethods.add(PaymentMethodKind.monero);
    expect(
      DeeMusiqPaymentService.isMethodUnavailable(PaymentMethodKind.monero),
      isTrue,
    );
  });
}
