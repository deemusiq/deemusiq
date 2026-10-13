import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// One row of the yearly artist leaderboard (`GET /leaderboard/artists`).
class ArtistLeaderEntry {
  final int rank;
  final String artistId;
  final String name;
  final String? imageUrl;
  final bool verified;
  final int totalTokens;
  final int supporters;

  const ArtistLeaderEntry({
    required this.rank,
    required this.artistId,
    required this.name,
    required this.totalTokens,
    required this.supporters,
    this.imageUrl,
    this.verified = false,
  });

  factory ArtistLeaderEntry.fromJson(Map<String, dynamic> json) {
    return ArtistLeaderEntry(
      rank: (json["rank"] as num?)?.toInt() ?? 0,
      artistId: json["artistId"] as String? ?? "",
      name: json["name"] as String? ?? "Unknown artist",
      imageUrl: json["imageUrl"] as String?,
      verified: json["verified"] == true,
      totalTokens: (json["totalTokens"] as num?)?.toInt() ?? 0,
      supporters: (json["supporters"] as num?)?.toInt() ?? 0,
    );
  }
}

class ArtistLeaderboard {
  final int year;
  final bool isCurrentYear;

  /// Echoed `region` filter ("ZA") or null for the global board.
  final String? region;
  final List<ArtistLeaderEntry> entries;

  const ArtistLeaderboard({
    required this.year,
    required this.isCurrentYear,
    required this.entries,
    this.region,
  });
}

/// The artist leaderboard for a given calendar year + region (both null =
/// current year, global). The board "resets" each year because the backend
/// windows by calendar year.
final artistLeaderboardProvider = FutureProvider.autoDispose
    .family<ArtistLeaderboard, ({int? year, String? region})>(
        (ref, query) async {
  if (!WalletApiClient.instance.isConfigured) {
    return ArtistLeaderboard(
      year: query.year ?? DateTime.now().toUtc().year,
      isCurrentYear: query.year == null,
      entries: const [],
      region: query.region,
    );
  }
  final data = await WalletApiClient.instance
      .fetchArtistLeaderboard(year: query.year, region: query.region);
  final entries = (data["entries"] as List? ?? const [])
      .map((e) =>
          ArtistLeaderEntry.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
  return ArtistLeaderboard(
    year: (data["year"] as num?)?.toInt() ??
        (query.year ?? DateTime.now().toUtc().year),
    isCurrentYear: data["isCurrentYear"] == true,
    region: data["region"] as String? ?? query.region,
    entries: entries,
  );
});

/// Past years' "Best Artist of the year" winners.
class HallOfFameEntry {
  final int year;
  final String artistId;
  final String name;
  final String? imageUrl;
  final int totalTokens;

  const HallOfFameEntry({
    required this.year,
    required this.artistId,
    required this.name,
    required this.totalTokens,
    this.imageUrl,
  });

  factory HallOfFameEntry.fromJson(Map<String, dynamic> json) =>
      HallOfFameEntry(
        year: (json["year"] as num?)?.toInt() ?? 0,
        artistId: json["artistId"] as String? ?? "",
        name: json["name"] as String? ?? "Unknown artist",
        imageUrl: json["imageUrl"] as String?,
        totalTokens: (json["totalTokens"] as num?)?.toInt() ?? 0,
      );
}

final hallOfFameProvider =
    FutureProvider.autoDispose<List<HallOfFameEntry>>((ref) async {
  if (!WalletApiClient.instance.isConfigured) return const [];
  final winners = await WalletApiClient.instance.fetchHallOfFame();
  return winners
      .map((e) => HallOfFameEntry.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
});

/// A creator-submitted song with its stats.
class CreatorSong {
  final String id;
  final String title;
  final String? youtubeId;
  final String? coverUrl;
  final String? description;
  final String status;
  final int pushes;
  final int tokens;
  final int likes;
  // New pipeline fields.
  final bool hasAudio;
  final bool hasCover;
  final int? audioSizeBytes;
  final int? audioDurationSec;
  final int? audioBitrateKbps;
  final DateTime? scheduledPublishAt;
  final bool cancelRequested;
  final DateTime? cancelledAt;
  final String? reviewNote;
  final DateTime? reviewedAt;
  final String? publishedTrackId;

  bool get canSubmitForReview => status == "draft" && hasAudio && hasCover;
  bool get isLegacyYoutubeSubmission => youtubeId != null && !hasAudio;

  const CreatorSong({
    required this.id,
    required this.title,
    required this.status,
    required this.pushes,
    required this.tokens,
    required this.likes,
    this.youtubeId,
    this.coverUrl,
    this.description,
    this.hasAudio = false,
    this.hasCover = false,
    this.audioSizeBytes,
    this.audioDurationSec,
    this.audioBitrateKbps,
    this.scheduledPublishAt,
    this.cancelRequested = false,
    this.cancelledAt,
    this.reviewNote,
    this.reviewedAt,
    this.publishedTrackId,
  });

  factory CreatorSong.fromJson(Map<String, dynamic> json) {
    final stats = json["stats"] as Map? ?? const {};
    DateTime? parseDt(Object? v) {
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
      return null;
    }

    return CreatorSong(
      id: json["id"] as String? ?? "",
      title: json["title"] as String? ?? "",
      youtubeId: json["youtubeId"] as String?,
      coverUrl: json["coverUrl"] as String?,
      description: json["description"] as String?,
      status: json["status"] as String? ?? "draft",
      pushes: (stats["pushes"] as num?)?.toInt() ?? 0,
      tokens: (stats["tokens"] as num?)?.toInt() ?? 0,
      likes: (stats["likes"] as num?)?.toInt() ?? 0,
      hasAudio: json["hasAudio"] as bool? ?? false,
      hasCover: json["hasCover"] as bool? ?? false,
      audioSizeBytes: (json["audioSizeBytes"] as num?)?.toInt(),
      audioDurationSec: (json["audioDurationSec"] as num?)?.toInt(),
      audioBitrateKbps: (json["audioBitrateKbps"] as num?)?.toInt(),
      scheduledPublishAt: parseDt(json["scheduledPublishAt"]),
      cancelRequested: json["cancelRequested"] as bool? ?? false,
      cancelledAt: parseDt(json["cancelledAt"]),
      reviewNote: json["reviewNote"] as String?,
      reviewedAt: parseDt(json["reviewedAt"]),
      publishedTrackId: json["publishedTrackId"] as String?,
    );
  }
}

/// The caller's artist profile + summary stats, or null artist if not yet a
/// creator. `{artist, stats}`.
final myArtistProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  if (!WalletApiClient.instance.isConfigured) return const {"artist": null};
  return WalletApiClient.instance.fetchMyArtist();
});

/// The caller's songs (with stats).
final mySongsProvider =
    FutureProvider.autoDispose<List<CreatorSong>>((ref) async {
  if (!WalletApiClient.instance.isConfigured) return const [];
  final raw = await WalletApiClient.instance.fetchMySongs();
  return raw
      .map((e) => CreatorSong.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
});

/// The signed-in account's email state (GET /auth/me): `email`,
/// `emailVerified`, `hasPassword`, plus a derived `signedIn` flag. The Creator
/// Studio gate picks its card from this — sign-in form (no session), emailed-
/// code form (session but unconfirmed address), or the dashboard. Errors
/// propagate so the studio can show its failure card instead of guessing.
final accountStatusProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = WalletApiClient.instance;
  if (!api.isConfigured || !api.hasToken()) {
    return const {
      "signedIn": false,
      "email": null,
      "emailVerified": false,
      "hasPassword": false,
    };
  }
  final data = await api.fetchAccountStatus();
  return {...data, "signedIn": true};
});
