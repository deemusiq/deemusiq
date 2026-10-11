import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/provider/wallet/rewards_provider.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

class FakeRewardsGateway implements RewardsGateway {
  RewardsStatus? status;
  Object? error;
  int calls = 0;

  FakeRewardsGateway({RewardsStatus? status})
      : status = status ??
            const RewardsStatus(
              enabled: true,
              earnedToday: 12,
              dailyCap: 50,
              perPlay: 2,
              newAccountTaper: false,
              lifetimeEarned: 340,
            );

  /// The backend predates the rewards feature — the gateway answers null.
  FakeRewardsGateway.absent() : status = null;

  @override
  bool get isAvailable => true;

  @override
  Future<RewardsStatus?> fetchStatus() async {
    calls++;
    final e = error;
    if (e != null) throw e;
    return status;
  }
}

ProviderContainer _containerWith(FakeRewardsGateway gateway) {
  final container = ProviderContainer(overrides: [
    rewardsGatewayProvider.overrideWithValue(gateway),
  ]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  test("status is null (card hides) when no backend is configured", () async {
    // No override: the default WalletRewardsGateway reads
    // DEEMUSIQ_BACKEND_URL, which is empty in tests.
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final status = await container.read(rewardsStatusProvider.future);
    expect(status, isNull);
  });

  test("status loads when the feature is enabled", () async {
    final gateway = FakeRewardsGateway();
    final container = _containerWith(gateway);

    final status = await container.read(rewardsStatusProvider.future);

    expect(gateway.calls, 1);
    expect(status?.earnedToday, 12);
    expect(status?.dailyCap, 50);
    expect(status?.perPlay, 2);
    expect(status?.lifetimeEarned, 340);
    expect(status?.newAccountTaper, isFalse);
  });

  test("enabled=false folds to null so all rewards UI hides", () async {
    final gateway = FakeRewardsGateway(
      status: const RewardsStatus(
        enabled: false,
        earnedToday: 0,
        dailyCap: 50,
        perPlay: 2,
        newAccountTaper: false,
        lifetimeEarned: 0,
      ),
    );
    final container = _containerWith(gateway);

    final status = await container.read(rewardsStatusProvider.future);
    expect(status, isNull);
  });

  test("a missing endpoint (gateway null) folds to null, not an error",
      () async {
    final gateway = FakeRewardsGateway.absent();
    final container = _containerWith(gateway);

    final status = await container.read(rewardsStatusProvider.future);
    expect(status, isNull);
  });

  test("a signed-out read (401) folds to null, not an error", () async {
    final gateway = FakeRewardsGateway()
      ..error = const WalletApiException(
        "missing_token",
        statusCode: 401,
        code: "missing_token",
      );
    final container = _containerWith(gateway);

    final status = await container.read(rewardsStatusProvider.future);
    expect(status, isNull);
  });

  test("real failures (429) surface as AsyncError", () async {
    final gateway = FakeRewardsGateway()
      ..error = const WalletApiException(
        "too_many_requests",
        statusCode: 429,
        code: "too_many_requests",
      );
    final container = _containerWith(gateway);

    await expectLater(
      container.read(rewardsStatusProvider.future),
      throwsA(isA<WalletApiException>()),
    );
  });

  test("non-wallet failures (bugs) still surface", () async {
    final gateway = FakeRewardsGateway()..error = StateError("boom");
    final container = _containerWith(gateway);

    await expectLater(
      container.read(rewardsStatusProvider.future),
      throwsA(isA<StateError>()),
    );
  });

  test("RewardsStatus parses the GET /rewards/status shape", () {
    final status = RewardsStatus.fromJson({
      "enabled": true,
      "earnedToday": 7,
      "dailyCap": 50,
      "perPlay": 2,
      "newAccountTaper": true,
      "lifetimeEarned": 1234,
    });

    expect(status.enabled, isTrue);
    expect(status.earnedToday, 7);
    expect(status.dailyCap, 50);
    expect(status.perPlay, 2);
    expect(status.newAccountTaper, isTrue);
    expect(status.lifetimeEarned, 1234);
  });

  test("RewardsStatus parses defensively when fields are missing", () {
    final status = RewardsStatus.fromJson(const {});

    expect(status.enabled, isFalse);
    expect(status.earnedToday, 0);
    expect(status.dailyCap, 0);
    expect(status.perPlay, 0);
    expect(status.newAccountTaper, isFalse);
    expect(status.lifetimeEarned, 0);
  });
}
