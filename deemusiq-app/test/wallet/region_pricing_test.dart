import 'package:flutter_test/flutter_test.dart';
import 'package:deemusiq/models/metadata/market.dart';
import 'package:deemusiq/models/wallet/region_pricing.dart';

void main() {
  group("localPrice", () {
    test("ZA base tier is identity (fx 1.0, ppp 1.0)", () {
      expect(RegionTier.za.localPrice(29), 29.0);
      expect(RegionTier.za.localPrice(249), 249.0);
    });

    test("applies ppp factor then fx rate", () {
      // US: 100 ZAR * 2.2 ppp * 0.054 fx
      expect(RegionTier.global.localPrice(100), closeTo(11.88, 1e-9));
      // IN: 100 ZAR * 0.55 ppp * 4.6 fx
      expect(RegionTier.india.localPrice(100), closeTo(253.0, 1e-9));
    });
  });

  group("formatPrice", () {
    test("uses two decimals for standard currencies", () {
      expect(RegionTier.za.formatPrice(29), "R29.00");
      // 29 * 2.2 * 0.054 = 3.4452 -> 3.45
      expect(RegionTier.global.formatPrice(29), "\$3.45");
    });

    test("drops decimals when the server declares a zero-decimal currency", () {
      // The flag comes from the backend (GET /pricing ships
      // `zeroDecimalCurrencies` + a per-pack `zeroDecimal`) instead of a local
      // copy of the currency codes — this offline fallback is only correct when
      // the caller passes the server's answer.
      // 29 * 0.7 * 86 = 1745.8 -> 1746
      expect(RegionTier.nigeria.formatPrice(29, zeroDecimal: true), "₦1746");
      // 29 * 0.55 * 4.6 = 73.37 -> 73
      expect(RegionTier.india.formatPrice(29, zeroDecimal: true), "₹73");
      // 29 * 0.7 * 7 = 142.1 -> 142 (symbol carries its own space)
      expect(RegionTier.kenya.formatPrice(29, zeroDecimal: true), "KSh 142");
    });

    test("defaults to two decimals when the flag is absent", () {
      // A backend too old to send `zeroDecimal` must not crash the UI or
      // silently drop cents — 2dp is the safe default.
      expect(RegionTier.nigeria.formatPrice(29), "₦1745.80");
      expect(RegionTier.kenya.formatPrice(29), "KSh 142.10");
    });
  });

  group("forCode", () {
    test("resolves known tier codes", () {
      expect(RegionTier.forCode("GB"), RegionTier.uk);
      expect(RegionTier.forCode("EU"), RegionTier.euro);
    });

    test("falls back to ZA for null/unknown codes", () {
      expect(RegionTier.forCode(null), RegionTier.za);
      expect(RegionTier.forCode("ZZ"), RegionTier.za);
    });
  });

  group("forMarket", () {
    test("maps direct and Eurozone markets", () {
      expect(RegionTier.forMarket(Market.ZA), RegionTier.za);
      expect(RegionTier.forMarket(Market.NG), RegionTier.nigeria);
      expect(RegionTier.forMarket(Market.DE), RegionTier.euro);
      expect(RegionTier.forMarket(Market.FR), RegionTier.euro);
    });

    test("unmapped markets fall back to the global USD tier", () {
      expect(RegionTier.forMarket(Market.US), RegionTier.global);
      expect(RegionTier.forMarket(Market.JP), RegionTier.global);
    });
  });
}
