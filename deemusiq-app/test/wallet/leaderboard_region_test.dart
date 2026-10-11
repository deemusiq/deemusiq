import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/provider/wallet/leaderboard_provider.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

class FakeLeaderboardGateway implements LeaderboardGateway {
  final List<String?> requestedRegions = [];

  @override
  bool get isAvailable => true;

  @override
  Future<List<LeaderboardEntry>> fetch({String? region}) async {
    requestedRegions.add(region);
    return [
      LeaderboardEntry(
        rank: 1,
        songId: "song-${region ?? 'global'}",
        title: "Track",
        artist: "Artist",
        totalTokens: 10,
        pushCount: 2,
      ),
    ];
  }
}

class FakeRegionPreferencesGateway implements RegionPreferencesGateway {
  String? stored;
  Object? writeError;
  int writes = 0;

  FakeRegionPreferencesGateway([this.stored]);

  @override
  bool get isAvailable => true;

  @override
  Future<String?> fetchRegion() async => stored;

  @override
  Future<void> saveRegion(String? region) async {
    writes++;
    final error = writeError;
    if (error != null) throw error;
    stored = region;
  }
}

void main() {
  test("leaderboard is empty when no backend is configured", () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(await container.read(leaderboardProvider(null).future), isEmpty);
    expect(await container.read(leaderboardProvider("ZA").future), isEmpty);
  });

  test("the region filter reaches the backend per board", () async {
    final gateway = FakeLeaderboardGateway();
    final container = ProviderContainer(overrides: [
      leaderboardGatewayProvider.overrideWithValue(gateway),
    ]);
    addTearDown(container.dispose);

    final global = await container.read(leaderboardProvider(null).future);
    final za = await container.read(leaderboardProvider("ZA").future);
    final bw = await container.read(leaderboardProvider("BW").future);

    expect(gateway.requestedRegions, [null, "ZA", "BW"]);
    expect(global.single.songId, "song-global");
    expect(za.single.songId, "song-ZA");
    expect(bw.single.songId, "song-BW");
  });

  test("user region loads from the stored preferences", () async {
    final gateway = FakeRegionPreferencesGateway("ZA");
    final container = ProviderContainer(overrides: [
      regionPreferencesGatewayProvider.overrideWithValue(gateway),
    ]);
    addTearDown(container.dispose);

    expect(await container.read(userRegionProvider.future), "ZA");
  });

  test("user region is null when no backend is configured", () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(await container.read(userRegionProvider.future), isNull);
  });

  test("a failed region read folds to null (chip hides)", () async {
    final gateway = _FailingRegionGateway();
    final container = ProviderContainer(overrides: [
      regionPreferencesGatewayProvider.overrideWithValue(gateway),
    ]);
    addTearDown(container.dispose);

    expect(await container.read(userRegionProvider.future), isNull);
  });

  test("setRegion is optimistic and persists through the gateway", () async {
    final gateway = FakeRegionPreferencesGateway("ZA");
    final container = ProviderContainer(overrides: [
      regionPreferencesGatewayProvider.overrideWithValue(gateway),
    ]);
    addTearDown(container.dispose);
    await container.read(userRegionProvider.future);

    await container.read(userRegionProvider.notifier).setRegion("BW");

    expect(gateway.writes, 1);
    expect(gateway.stored, "BW");
    expect(container.read(userRegionProvider).valueOrNull, "BW");
  });

  test("a failed setRegion rolls back the optimistic state and rethrows",
      () async {
    final gateway = FakeRegionPreferencesGateway("ZA")
      ..writeError = const WalletApiException("offline", isConnectivity: true);
    final container = ProviderContainer(overrides: [
      regionPreferencesGatewayProvider.overrideWithValue(gateway),
    ]);
    addTearDown(container.dispose);
    await container.read(userRegionProvider.future);

    await expectLater(
      container.read(userRegionProvider.notifier).setRegion(null),
      throwsA(isA<WalletApiException>()),
    );
    expect(container.read(userRegionProvider).valueOrNull, "ZA");
  });
}

class _FailingRegionGateway implements RegionPreferencesGateway {
  @override
  bool get isAvailable => true;

  @override
  Future<String?> fetchRegion() =>
      throw const WalletApiException("signed out", code: "logged_out");

  @override
  Future<void> saveRegion(String? region) async {}
}
