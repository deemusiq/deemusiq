import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/fallbacks/error_box.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/provider/wallet/track_rating_provider.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// Like/dislike quality rating for one track (backend `/ratings`). Renders
/// nothing when no backend is configured. Tapping the active thumb again
/// clears the rating; aggregates (likes/dislikes/total) come from the
/// backend and refresh with every mutation.
class TrackRatingSection extends ConsumerWidget {
  final String trackId;

  const TrackRatingSection({super.key, required this.trackId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trackRatingProvider(trackId));

    if (!state.available) return const SizedBox.shrink();

    Future<void> run(Future<void> Function(TrackRatingNotifier) op) async {
      final notifier = ref.read(trackRatingProvider(trackId).notifier);
      try {
        await op(notifier);
      } on WalletApiException catch (e) {
        if (context.mounted) {
          showWalletToast(context, e.friendlyMessage,
              icon: DeeMusiqIcons.error);
        }
      } catch (e) {
        if (context.mounted) {
          showWalletToast(context, context.l10n.rating_save_failed,
              icon: DeeMusiqIcons.error);
        }
      }
    }

    final rating = state.rating;
    final error = state.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(FeatherIcons.thumbsUp, size: 18),
            const Gap(8),
            Text(context.l10n.rate_this_track).semiBold(),
          ],
        ),
        const Gap(12),
        if (state.loading && rating == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (error != null && rating == null)
          _RatingsError(trackId: trackId, error: error)
        else if (rating != null) ...[
          Row(
            children: [
              _RatingThumbButton(
                trackId: trackId,
                value: TrackRatingValue.like,
                active: rating.myRating == TrackRatingValue.like,
                count: rating.likes,
                mutating: state.mutating,
                run: run,
              ),
              const Gap(8),
              _RatingThumbButton(
                trackId: trackId,
                value: TrackRatingValue.dislike,
                active: rating.myRating == TrackRatingValue.dislike,
                count: rating.dislikes,
                mutating: state.mutating,
                run: run,
              ),
            ],
          ),
          const Gap(8),
          Text(
            context.l10n.rating_summary(
              ((rating.likeRatio ?? 0) * 100).round(),
              rating.total,
            ),
          ).muted().small(),
        ],
      ],
    );
  }
}

/// Error state for the initial load. Ratings only exist for DeeMusiq-catalog
/// tracks: the backend answers `track_not_found` for anything else, which is
/// an expected absence (not a failure), so the section hides. Every other
/// failure gets a visible retry box.
class _RatingsError extends ConsumerWidget {
  final String trackId;
  final Object error;

  const _RatingsError({required this.trackId, required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final err = error;
    if (err is WalletApiException && err.code == "track_not_found") {
      return const SizedBox.shrink();
    }
    return ErrorBox(
      error: err,
      userMessage: err is WalletApiException ? err.friendlyMessage : null,
      onRetry: () => ref.read(trackRatingProvider(trackId).notifier).load(),
    );
  }
}

class _RatingThumbButton extends StatelessWidget {
  final String trackId;
  final TrackRatingValue value;
  final bool active;
  final int count;
  final bool mutating;
  final Future<void> Function(Future<void> Function(TrackRatingNotifier)) run;

  const _RatingThumbButton({
    required this.trackId,
    required this.value,
    required this.active,
    required this.count,
    required this.mutating,
    required this.run,
  });

  @override
  Widget build(BuildContext context) {
    final isLike = value == TrackRatingValue.like;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(isLike ? FeatherIcons.thumbsUp : FeatherIcons.thumbsDown,
            size: 14),
        const Gap(6),
        Text(
            "${isLike ? context.l10n.rating_like : context.l10n.rating_dislike} · $count"),
      ],
    );

    void onPressed() {
      run((notifier) => active ? notifier.clear() : notifier.setRating(value));
    }

    return active
        ? Button.primary(
            enabled: !mutating,
            onPressed: onPressed,
            child: child,
          )
        : Button.outline(
            enabled: !mutating,
            onPressed: onPressed,
            child: child,
          );
  }
}
