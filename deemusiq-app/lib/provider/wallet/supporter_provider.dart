import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// The backend's supporter-tier vocabulary (`GET /artists/:id/supporters`):
/// a supporter is gold/silver/bronze by tokens given, "none" below bronze.
enum SupporterTier { gold, silver, bronze, none }

SupporterTier supporterTierFromJson(Object? value) => switch (value) {
      "gold" => SupporterTier.gold,
      "silver" => SupporterTier.silver,
      "bronze" => SupporterTier.bronze,
      _ => SupporterTier.none,
    };

/// Per-tier supporter counts echoed by the supporters endpoints.
class SupporterTierCounts {
  final int gold;
  final int silver;
  final int bronze;

  const SupporterTierCounts({
    this.gold = 0,
    this.silver = 0,
    this.bronze = 0,
  });

  factory SupporterTierCounts.fromJson(Map json) => SupporterTierCounts(
        gold: (json["gold"] as num?)?.toInt() ?? 0,
        silver: (json["silver"] as num?)?.toInt() ?? 0,
        bronze: (json["bronze"] as num?)?.toInt() ?? 0,
      );
}

/// One ranked row of the supporter board. [name] arrives anonymized from the
/// server ("a1b2c3d4…") — never resolve it to a user; [badge] is
/// "top_supporter" for the #1 supporter or null.
class SupporterEntry {
  final int rank;
  final String name;
  final int totalTokens;
  final SupporterTier tier;
  final String? badge;

  const SupporterEntry({
    required this.rank,
    required this.name,
    required this.totalTokens,
    required this.tier,
    this.badge,
  });

  bool get isTopSupporter => badge == "top_supporter";

  factory SupporterEntry.fromJson(Map json) => SupporterEntry(
        rank: (json["rank"] as num?)?.toInt() ?? 0,
        name: (json["name"] as String?) ?? "",
        totalTokens: (json["totalTokens"] as num?)?.toInt() ?? 0,
        tier: supporterTierFromJson(json["tier"]),
        badge: json["badge"] as String?,
      );
}

/// The full supporter board for one artist.
class SupporterBoard {
  final String artistId;
  final SupporterTierCounts tiers;
  final List<SupporterEntry> entries;

  const SupporterBoard({
    required this.artistId,
    required this.tiers,
    required this.entries,
  });

  factory SupporterBoard.fromJson(Map<String, dynamic> json) =>
      SupporterBoard(
        artistId: (json["artistId"] as String?) ?? "",
        tiers: SupporterTierCounts.fromJson(
          (json["tiers"] as Map?) ?? const {},
        ),
        entries: ((json["entries"] as List<dynamic>?) ?? const [])
            .map((raw) => SupporterEntry.fromJson(raw as Map))
            .toList(),
      );
}

/// The caller's own standing with one artist. [rank] is null when the caller
/// has never tipped this artist.
class MySupport {
  final int? rank;
  final int totalTokens;
  final SupporterTier tier;
  final String? badge;

  const MySupport({
    required this.rank,
    required this.totalTokens,
    required this.tier,
    this.badge,
  });

  bool get isSupporter => rank != null || totalTokens > 0;

  factory MySupport.fromJson(Map<String, dynamic> json) => MySupport(
        rank: (json["rank"] as num?)?.toInt(),
        totalTokens: (json["totalTokens"] as num?)?.toInt() ?? 0,
        tier: supporterTierFromJson(json["tier"]),
        badge: json["badge"] as String?,
      );
}

/// Network seam for the supporters feature (same pattern as
/// [TrackRatingsGateway]): the default implementation talks to
/// [WalletApiClient]; tests substitute a fake.
abstract class SupportersGateway {
  /// False when no backend is configured — the UI then hides the section.
  bool get isAvailable;

  Future<SupporterBoard> fetchBoard(String artistId, {int limit});

  /// Throws [WalletApiException] on failure (e.g. `logged_out`).
  Future<MySupport> fetchMine(String artistId);
}

class WalletSupportersGateway implements SupportersGateway {
  @override
  bool get isAvailable => WalletApiClient.instance.isConfigured;

  @override
  Future<SupporterBoard> fetchBoard(String artistId, {int limit = 10}) async {
    final data =
        await WalletApiClient.instance.fetchSupporters(artistId, limit: limit);
    return SupporterBoard.fromJson(data);
  }

  @override
  Future<MySupport> fetchMine(String artistId) async {
    final data = await WalletApiClient.instance.fetchMySupport(artistId);
    return MySupport.fromJson(data);
  }
}

final supportersGatewayProvider = Provider<SupportersGateway>(
  (ref) => WalletSupportersGateway(),
);

/// The supporter board for one artist (family arg is the artist id). Null
/// when no backend is configured — the section hides instead of erroring.
final supporterBoardProvider =
    FutureProvider.autoDispose.family<SupporterBoard?, String>(
  (ref, artistId) async {
    final gateway = ref.watch(supportersGatewayProvider);
    if (!gateway.isAvailable) return null;
    return gateway.fetchBoard(artistId);
  },
);

/// The caller's own supporter standing with one artist. Null when no backend
/// is configured; a signed-out caller folds to null as well (the 401 is
/// logged, not shown — the artist page must not toast for a passive read).
final mySupportProvider =
    FutureProvider.autoDispose.family<MySupport?, String>(
  (ref, artistId) async {
    final gateway = ref.watch(supportersGatewayProvider);
    if (!gateway.isAvailable) return null;
    try {
      return await gateway.fetchMine(artistId);
    } on WalletApiException catch (e, stack) {
      AppLogger.log.w('mySupportProvider($artistId): ${e.message}');
      AppLogger.reportError(e, stack, 'mySupportProvider');
      return null;
    }
  },
);
