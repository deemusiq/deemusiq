import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/ratings/track_ratings_provider.dart';
import 'package:deemusiq/services/ratings/track_ratings_api.dart';

/// Like / dislike pair for the backend track-rating system. Sits next to the
/// favorites heart (which is a separate, local system): thumb-up/thumb-down
/// reflect `GET /ratings/mine` via [myTrackRatingsProvider]. Tapping the
/// active rating removes it; tapping the other switches. Hidden entirely when
/// no backend is configured.
class TrackRatingControls extends HookConsumerWidget {
  final DeeMusiqTrackObject track;

  const TrackRatingControls({super.key, required this.track});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(trackRatingsApiProvider);
    if (!api.isConfigured) return const SizedBox.shrink();

    final myRating = ref.watch(trackRatingProvider(track.id));
    final ThemeData(:colorScheme) = Theme.of(context);

    Future<void> tap(TrackRatingValue value) async {
      try {
        await ref
            .read(myTrackRatingsProvider.notifier)
            .toggleRating(track.id, value);
      } catch (_) {
        // The notifier already rolled back and reported the error — the
        // toast is the user-facing surface for it.
        if (context.mounted) {
          showWalletToast(
            context,
            "Couldn't save your rating — try again",
            icon: DeeMusiqIcons.warning,
          );
        }
      }
    }

    Widget button({
      required TrackRatingValue value,
      required String tooltip,
    }) {
      final active = myRating == value;
      final icon = switch (value) {
        TrackRatingValue.like =>
          active ? DeeMusiqIcons.thumbUpFilled : DeeMusiqIcons.thumbUp,
        TrackRatingValue.dislike =>
          active ? DeeMusiqIcons.thumbDownFilled : DeeMusiqIcons.thumbDown,
      };
      return Tooltip(
        tooltip: TooltipContainer(child: Text(tooltip)).call,
        child: IconButton.ghost(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              icon,
              key: ValueKey(active),
              size: 18,
              color: active ? colorScheme.primary : null,
            ),
          ),
          onPressed: () => tap(value),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(value: TrackRatingValue.like, tooltip: "Like this track"),
        button(value: TrackRatingValue.dislike, tooltip: "Dislike this track"),
      ],
    );
  }
}
