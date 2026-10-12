import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/ratings/track_ratings_api.dart';

/// Network seam for the ratings feature. Tests substitute a fake — the
/// default builds the real client against `DEEMUSIQ_BACKEND_URL`.
final trackRatingsApiProvider = Provider<TrackRatingsApi>(
  (ref) => TrackRatingsApi(),
);

/// Server-reported aggregate stats, keyed by track id. Populated from
/// rate/remove responses, batch calls and the trending feed so widgets can
/// show counts without an extra round trip.
final trackRatingStatsCacheProvider =
    StateNotifierProvider<TrackRatingStatsCache, Map<String, TrackRatingStats>>(
  (ref) => TrackRatingStatsCache(),
);

class TrackRatingStatsCache extends StateNotifier<Map<String, TrackRatingStats>> {
  TrackRatingStatsCache() : super(const {});

  void merge(String trackId, TrackRatingStats stats) {
    state = {...state, trackId: stats};
  }

  void mergeRatedTracks(Iterable<RatedTrack> tracks) {
    final entries = <String, TrackRatingStats>{};
    for (final track in tracks) {
      final stats = track.rating;
      if (stats != null) entries[track.id] = stats;
    }
    if (entries.isNotEmpty) state = {...state, ...entries};
  }
}

/// The signed-in device's own ratings (`GET /ratings/mine`), merged into one
/// map. Toggles apply optimistically and roll back on failure — the error is
/// rethrown so the widget can toast, and reported via [AppLogger].
class MyTrackRatingsNotifier
    extends AsyncNotifier<Map<String, TrackRatingValue>> {
  TrackRatingsApi get _api => ref.read(trackRatingsApiProvider);

  @override
  Future<Map<String, TrackRatingValue>> build() async {
    if (!_api.isConfigured) return const {};
    try {
      return await _api.mine();
    } catch (e, stack) {
      // Signed-out / unreachable backend must not break the UI — the controls
      // just render as "no rating". Logged and reported, never swallowed.
      AppLogger.log.w('Track ratings load failed: $e');
      AppLogger.reportError(e, stack, 'MyTrackRatingsNotifier.build');
      return const {};
    }
  }

  /// Toggles [value] on [trackId]: tapping the active rating removes it
  /// (DELETE), tapping the other switches (PUT). Optimistic — the map flips
  /// before the request and rolls back on error, which is rethrown for the
  /// caller to surface.
  Future<void> toggleRating(String trackId, TrackRatingValue value) async {
    final before = Map<String, TrackRatingValue>.of(
      state.asData?.value ?? const {},
    );
    final previous = before[trackId];
    final removing = previous == value;

    final optimistic = Map<String, TrackRatingValue>.of(before);
    if (removing) {
      optimistic.remove(trackId);
    } else {
      optimistic[trackId] = value;
    }
    state = AsyncData(optimistic);

    try {
      final outcome =
          removing ? await _api.remove(trackId) : await _api.rate(trackId, value);
      ref.read(trackRatingStatsCacheProvider.notifier).merge(
            trackId,
            outcome.stats,
          );
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'MyTrackRatingsNotifier.toggleRating');
      state = AsyncData(before);
      rethrow;
    }
  }
}

final myTrackRatingsProvider = AsyncNotifierProvider<MyTrackRatingsNotifier,
    Map<String, TrackRatingValue>>(
  MyTrackRatingsNotifier.new,
);

/// The caller's rating on one track, or null. Widgets watch this instead of
/// the whole map so unrelated rating changes don't rebuild them.
final trackRatingProvider =
    Provider.autoDispose.family<TrackRatingValue?, String>(
  (ref, trackId) => ref.watch(myTrackRatingsProvider).asData?.value[trackId],
);

/// The home "Trending" feed: most-liked tracks of the trending window,
/// falling back to the all-time top feed (`/catalog?sort=top`) while the
/// window is still empty. Empty when no backend is configured; fetch errors
/// surface through the AsyncValue so the section can offer a retry.
final trendingTracksProvider =
    FutureProvider.autoDispose<List<RatedTrack>>((ref) async {
  final api = ref.watch(trackRatingsApiProvider);
  if (!api.isConfigured) return const [];
  var items = await api.trending();
  if (items.isEmpty) {
    items = await api.topTracks();
  }
  ref.read(trackRatingStatsCacheProvider.notifier).mergeRatedTracks(items);
  return items;
});
