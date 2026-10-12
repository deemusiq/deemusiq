// Dependency-light smoke test: exercises the wallet display helpers inside a
// minimal widget tree (no platform channels, no app bootstrap).

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/l10n/generated/app_localizations_en.dart';

void main() {
  testWidgets("renders a formatted token balance in a plain widget tree",
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Text("Balance: ${formatTokens(1234567)} tokens"),
      ),
    );

    expect(find.text("Balance: 1,234,567 tokens"), findsOneWidget);
  });

  test("formatTokens groups thousands and keeps the sign", () {
    expect(formatTokens(0), "0");
    expect(formatTokens(999), "999");
    expect(formatTokens(1000), "1,000");
    expect(formatTokens(25000), "25,000");
    expect(formatTokens(-1234), "-1,234");
  });

  test("relativeTime buckets recent moments sensibly", () {
    final l10n = AppLocalizationsEn();
    final now = DateTime.now();
    expect(relativeTime(l10n, now), "just now");
    expect(
        relativeTime(l10n, now.subtract(const Duration(minutes: 5))), "5m ago");
    expect(
        relativeTime(l10n, now.subtract(const Duration(hours: 3))), "3h ago");
    expect(relativeTime(l10n, now.subtract(const Duration(days: 3))), "3d ago");
  });
}
