import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// One row of the global most-pushed leaderboard (`GET /leaderboard`).
/// Mirrors the backend's entry JSON: rank, songId, title, artist, artistId,
/// imageUrl, totalTokens, pushCount.
class LeaderboardEntry {
  final int rank;
  final String songId;
  final String title;
  final String artist;
  final String? artistId;
  final String? imageUrl;
  final int totalTokens;
  final int pushCount;

  const LeaderboardEntry({
    required this.rank,
    required this.songId,
    required this.title,
    required this.artist,
    required this.totalTokens,
    required this.pushCount,
    this.artistId,
    this.imageUrl,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: (json["rank"] as num?)?.toInt() ?? 0,
      songId: json["songId"] as String? ?? "",
      title: json["title"] as String? ?? "Unknown track",
      artist: json["artist"] as String? ?? "Unknown artist",
      artistId: json["artistId"] as String?,
      imageUrl: json["imageUrl"] as String?,
      totalTokens: (json["totalTokens"] as num?)?.toInt() ?? 0,
      pushCount: (json["pushCount"] as num?)?.toInt() ?? 0,
    );
  }
}

/// Network seam for the track leaderboard (same pattern as
/// `TrackRatingsGateway`): tests substitute a fake and assert the region
/// passed through.
abstract class LeaderboardGateway {
  /// False when no backend is configured — the page falls back to the
  /// device-local board.
  bool get isAvailable;

  /// [region] is an ISO alpha-2 code; null = the global board.
  Future<List<LeaderboardEntry>> fetch({String? region});
}

class WalletLeaderboardGateway implements LeaderboardGateway {
  @override
  bool get isAvailable => WalletApiClient.instance.isConfigured;

  @override
  Future<List<LeaderboardEntry>> fetch({String? region}) async {
    final raw = await WalletApiClient.instance.fetchLeaderboard(region: region);
    return raw
        .map((e) =>
            LeaderboardEntry.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}

final leaderboardGatewayProvider = Provider<LeaderboardGateway>(
  (ref) => WalletLeaderboardGateway(),
);

/// Global most-pushed songs across ALL users, from the backend, optionally
/// scoped to a region (`?region=ZA`; the response echoes it as `"region"`).
/// Only meaningful when a backend is configured — offline the leaderboard
/// page falls back to this device's own pushes.
final leaderboardProvider =
    FutureProvider.autoDispose.family<List<LeaderboardEntry>, String?>(
        (ref, region) async {
  final gateway = ref.watch(leaderboardGatewayProvider);
  if (!gateway.isAvailable) return const [];
  return gateway.fetch(region: region);
});

/// Network seam for the caller's stored leaderboard region
/// (`GET/PUT /recommendations/preferences`). Tests substitute a fake.
abstract class RegionPreferencesGateway {
  bool get isAvailable;

  /// The stored ISO alpha-2 region, or null when unset.
  Future<String?> fetchRegion();

  Future<void> saveRegion(String? region);
}

class WalletRegionPreferencesGateway implements RegionPreferencesGateway {
  @override
  bool get isAvailable => WalletApiClient.instance.isConfigured;

  @override
  Future<String?> fetchRegion() async {
    return (await WalletApiClient.instance.fetchTasteProfile()).region;
  }

  @override
  Future<void> saveRegion(String? region) {
    return WalletApiClient.instance.saveRegion(region);
  }
}

final regionPreferencesGatewayProvider = Provider<RegionPreferencesGateway>(
  (ref) => WalletRegionPreferencesGateway(),
);

/// The caller's leaderboard region as stored in the server-side preferences
/// (null = global / unset). Drives the "My region" chip on the leaderboard
/// pages and is written by the onboarding region section and the
/// language & region settings tile.
class UserRegionNotifier extends AsyncNotifier<String?> {
  RegionPreferencesGateway get _gateway =>
      ref.read(regionPreferencesGatewayProvider);

  @override
  Future<String?> build() async {
    final gateway = _gateway;
    if (!gateway.isAvailable) return null;
    try {
      return await gateway.fetchRegion();
    } on WalletApiException catch (e, stack) {
      // A signed-out/offline device has no stored region — the "My region"
      // chip hides; the failure is still logged, never swallowed.
      AppLogger.log.w('UserRegion load failed: ${e.message}');
      AppLogger.reportError(e, stack, 'UserRegionNotifier.build');
      return null;
    }
  }

  /// Persist a new region (ISO alpha-2, or null for global). Optimistic: the
  /// state flips immediately, the PUT follows; a failed write rethrows so the
  /// caller can toast and the state rolls back to the last known value.
  Future<void> setRegion(String? region) async {
    final previous = state.valueOrNull;
    state = AsyncData(region);
    try {
      await _gateway.saveRegion(region);
    } catch (e) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}

final userRegionProvider =
    AsyncNotifierProvider<UserRegionNotifier, String?>(
  UserRegionNotifier.new,
);
