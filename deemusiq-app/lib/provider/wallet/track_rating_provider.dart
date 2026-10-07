import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// The backend's rating vocabulary (`PUT /ratings/:trackId`): a like/dislike
/// quality signal, not a favorite — favorites stay with the heart button.
enum TrackRatingValue { like, dislike }

/// One track's rating state: the public aggregates plus the caller's own
/// rating (`myRating`, null when unrated or anonymous).
class TrackRating {
  final int likes;
  final int dislikes;
  final int total;

  /// Null when nobody has rated the track yet.
  final double? likeRatio;
  final TrackRatingValue? myRating;

  const TrackRating({
    required this.likes,
    required this.dislikes,
    required this.total,
    this.likeRatio,
    this.myRating,
  });

  /// Parses the `GET /ratings/:trackId` shape
  /// (`{likes, dislikes, total, likeRatio, myRating}`).
  factory TrackRating.fromJson(Map<String, dynamic> json) {
    return TrackRating(
      likes: (json["likes"] as num?)?.toInt() ?? 0,
      dislikes: (json["dislikes"] as num?)?.toInt() ?? 0,
      total: (json["total"] as num?)?.toInt() ?? 0,
      likeRatio: (json["likeRatio"] as num?)?.toDouble(),
      myRating: switch (json["myRating"]) {
        "like" => TrackRatingValue.like,
        "dislike" => TrackRatingValue.dislike,
        _ => null,
      },
    );
  }

  /// Parses the write-response shape (`{rating, stats: {…}}`) returned by
  /// PUT/DELETE: aggregates live under `stats`, the caller's new rating
  /// under `rating` (null after a DELETE).
  factory TrackRating.fromWriteResponse(Map<String, dynamic> json) {
    final stats = json["stats"];
    return TrackRating.fromJson({
      if (stats is Map) ...Map<String, dynamic>.from(stats),
      "myRating": json["rating"],
    });
  }
}

/// Network seam for the ratings feature. The default implementation talks to
/// [WalletApiClient]; tests substitute a fake — the singleton is `final` and
/// cannot be swapped out directly.
abstract class TrackRatingsGateway {
  /// False when no backend is configured — the UI then hides the section.
  bool get isAvailable;

  Future<TrackRating> fetch(String trackId);

  /// Throws [WalletApiException] on failure (e.g. `logged_out`).
  Future<TrackRating> setRating(String trackId, TrackRatingValue value);

  Future<TrackRating> clear(String trackId);
}

class WalletTrackRatingsGateway implements TrackRatingsGateway {
  @override
  bool get isAvailable => WalletApiClient.instance.isConfigured;

  @override
  Future<TrackRating> fetch(String trackId) async {
    final data = await WalletApiClient.instance.fetchTrackRating(trackId);
    return TrackRating.fromJson(data);
  }

  @override
  Future<TrackRating> setRating(
    String trackId,
    TrackRatingValue value,
  ) async {
    final data = await WalletApiClient.instance.rateTrack(
      trackId,
      value == TrackRatingValue.like ? "like" : "dislike",
    );
    return TrackRating.fromWriteResponse(data);
  }

  @override
  Future<TrackRating> clear(String trackId) async {
    final data = await WalletApiClient.instance.clearTrackRating(trackId);
    return TrackRating.fromWriteResponse(data);
  }
}

final trackRatingsGatewayProvider = Provider<TrackRatingsGateway>(
  (ref) => WalletTrackRatingsGateway(),
);

class TrackRatingState {
  /// False when no backend is configured — the section hides.
  final bool available;
  final bool loading;
  final Object? error;
  final TrackRating? rating;
  final bool mutating;

  const TrackRatingState({
    this.available = true,
    this.loading = false,
    this.error,
    this.rating,
    this.mutating = false,
  });

  TrackRatingState copyWith({
    bool? available,
    bool? loading,
    Object? Function()? error,
    TrackRating? Function()? rating,
    bool? mutating,
  }) {
    return TrackRatingState(
      available: available ?? this.available,
      loading: loading ?? this.loading,
      error: error != null ? error() : this.error,
      rating: rating != null ? rating() : this.rating,
      mutating: mutating ?? this.mutating,
    );
  }
}

/// Rating state for one track (family arg is the track id). Loads on
/// creation when a backend is configured; otherwise stays inert so the UI
/// can hide the whole section.
class TrackRatingNotifier
    extends AutoDisposeFamilyNotifier<TrackRatingState, String> {
  TrackRatingsGateway get _gateway => ref.read(trackRatingsGatewayProvider);

  @override
  TrackRatingState build(String arg) {
    final gateway = _gateway;
    if (!gateway.isAvailable) {
      return const TrackRatingState(available: false);
    }
    state = const TrackRatingState(loading: true);
    Future.microtask(load);
    return state;
  }

  Future<void> load() async {
    if (!_gateway.isAvailable) return;
    state = state.copyWith(loading: true, error: () => null);
    try {
      final rating = await _gateway.fetch(arg);
      state = state.copyWith(loading: false, rating: () => rating);
    } catch (e) {
      state = state.copyWith(loading: false, error: () => e);
    }
  }

  /// Sets (or changes) the caller's rating and folds the returned aggregates
  /// into state. Rethrows so the widget can toast the backend's friendly
  /// message.
  Future<void> setRating(TrackRatingValue value) async {
    if (state.mutating) return;
    state = state.copyWith(mutating: true);
    try {
      final rating = await _gateway.setRating(arg, value);
      state = state.copyWith(
        mutating: false,
        rating: () => rating,
        error: () => null,
      );
    } catch (e) {
      state = state.copyWith(mutating: false);
      rethrow;
    }
  }

  /// Clears the caller's rating. Same rethrow contract as [setRating].
  Future<void> clear() async {
    if (state.mutating) return;
    state = state.copyWith(mutating: true);
    try {
      final rating = await _gateway.clear(arg);
      state = state.copyWith(
        mutating: false,
        rating: () => rating,
        error: () => null,
      );
    } catch (e) {
      state = state.copyWith(mutating: false);
      rethrow;
    }
  }
}

final trackRatingProvider = NotifierProvider.autoDispose
    .family<TrackRatingNotifier, TrackRatingState, String>(
  TrackRatingNotifier.new,
);
