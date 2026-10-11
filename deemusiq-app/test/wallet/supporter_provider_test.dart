import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/provider/wallet/supporter_provider.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

SupporterBoard _board({
  List<SupporterEntry>? entries,
  int gold = 1,
  int silver = 2,
  int bronze = 3,
}) =>
    SupporterBoard(
      artistId: "artist-1",
      tiers: SupporterTierCounts(gold: gold, silver: silver, bronze: bronze),
      entries: entries ??
          const [
            SupporterEntry(
              rank: 1,
              name: "a1b2c3d4…",
              totalTokens: 120,
              tier: SupporterTier.gold,
              badge: "top_supporter",
            ),
            SupporterEntry(
              rank: 2,
              name: "e5f6a7b8…",
              totalTokens: 40,
              tier: SupporterTier.silver,
            ),
          ],
    );

class FakeSupportersGateway implements SupportersGateway {
  SupporterBoard board;
  MySupport mine;
  Object? boardError;
  Object? mineError;
  int boardCalls = 0;
  int mineCalls = 0;

  FakeSupportersGateway({SupporterBoard? board, MySupport? mine})
      : board = board ?? _board(),
        mine = mine ??
            const MySupport(
              rank: 2,
              totalTokens: 40,
              tier: SupporterTier.silver,
            );

  @override
  bool get isAvailable => true;

  @override
  Future<SupporterBoard> fetchBoard(String artistId, {int limit = 10}) async {
    boardCalls++;
    final error = boardError;
    if (error != null) throw error;
    return board;
  }

  @override
  Future<MySupport> fetchMine(String artistId) async {
    mineCalls++;
    final error = mineError;
    if (error != null) throw error;
    return mine;
  }
}

ProviderContainer _containerWith(FakeSupportersGateway gateway) {
  final container = ProviderContainer(overrides: [
    supportersGatewayProvider.overrideWithValue(gateway),
  ]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  const artistId = "artist-1";

  test("board is null (section hides) when no backend is configured", () async {
    // No override: the default WalletSupportersGateway reads
    // DEEMUSIQ_BACKEND_URL, which is empty in tests.
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final board = await container.read(supporterBoardProvider(artistId).future);
    expect(board, isNull);

    final mine = await container.read(mySupportProvider(artistId).future);
    expect(mine, isNull);
  });

  test("board loads entries and tier counts", () async {
    final gateway = FakeSupportersGateway();
    final container = _containerWith(gateway);

    final board = await container.read(supporterBoardProvider(artistId).future);

    expect(gateway.boardCalls, 1);
    expect(board?.tiers.gold, 1);
    expect(board?.entries, hasLength(2));
    expect(board?.entries.first.isTopSupporter, isTrue);
    expect(board?.entries.first.tier, SupporterTier.gold);
    expect(board?.entries.last.badge, isNull);
  });

  test("board errors surface as AsyncError", () async {
    final gateway = FakeSupportersGateway()
      ..boardError = const WalletApiException("nope", code: "server_error");
    final container = _containerWith(gateway);

    await expectLater(
      container.read(supporterBoardProvider(artistId).future),
      throwsA(isA<WalletApiException>()),
    );
  });

  test("my support loads rank and tier", () async {
    final gateway = FakeSupportersGateway();
    final container = _containerWith(gateway);

    final mine = await container.read(mySupportProvider(artistId).future);

    expect(mine?.rank, 2);
    expect(mine?.tier, SupporterTier.silver);
    expect(mine?.isSupporter, isTrue);
  });

  test("a signed-out my-support read folds to null, not an error", () async {
    final gateway = FakeSupportersGateway()
      ..mineError = const WalletApiException("signed out", code: "logged_out");
    final container = _containerWith(gateway);

    final state = await container.read(mySupportProvider(artistId).future);
    expect(state, isNull);
    // Non-wallet failures (bugs) must still surface.
    gateway.mineError = StateError("boom");
    await expectLater(
      container.read(mySupportProvider("artist-2").future),
      throwsA(isA<StateError>()),
    );
  });

  test("SupporterBoard parses the GET /artists/:id/supporters shape", () {
    final board = SupporterBoard.fromJson({
      "artistId": "artist-1",
      "tiers": {"gold": 2, "silver": 5, "bronze": 9},
      "entries": [
        {
          "rank": 1,
          "name": "a1b2c3d4…",
          "totalTokens": 300,
          "tier": "gold",
          "badge": "top_supporter",
        },
        {
          "rank": 2,
          "name": "z9y8x7w6…",
          "totalTokens": 12,
          "tier": "none",
          "badge": null,
        },
      ],
    });

    expect(board.artistId, "artist-1");
    expect(board.tiers.gold, 2);
    expect(board.tiers.silver, 5);
    expect(board.tiers.bronze, 9);
    expect(board.entries.first.isTopSupporter, isTrue);
    expect(board.entries.last.tier, SupporterTier.none);
  });

  test("MySupport parses the supporters/me shape with a null rank", () {
    final mine = MySupport.fromJson({
      "artistId": "artist-1",
      "tiers": {"gold": 0, "silver": 1, "bronze": 2},
      "rank": null,
      "totalTokens": 0,
      "tier": "none",
      "badge": null,
    });

    expect(mine.rank, isNull);
    expect(mine.isSupporter, isFalse);
  });
}
