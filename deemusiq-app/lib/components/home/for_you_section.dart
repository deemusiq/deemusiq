import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/components/fallbacks/error_box.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/provider/recommendations/for_you.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';

/// For You — Gmail-linked recommendations (user improvement).
/// Shows the backend's `gmailLinked` badge so users know their Gmail identity
/// carries taste across devices, with pull-to-refresh and like toggles.

/// Like/unlike calls for the For You tiles, behind a provider so tests can
/// substitute a failing/succeeding fake without a backend or keystore.
typedef TrackLikeAction = Future<void> Function(String trackId);

final forYouLikeActionsProvider =
    Provider<({TrackLikeAction like, TrackLikeAction unlike})>((ref) {
  final api = WalletApiClient.instance;
  return (like: api.likeTrack, unlike: api.unlikeTrack);
});

class ForYouSection extends HookConsumerWidget {
  const ForYouSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recommendationsProvider);
    final notifier = ref.read(recommendationsProvider.notifier);
    final ThemeData(:colorScheme) = Theme.of(context);

    // Tracks liked from this section, keyed by track id so the tile button
    // reflects the toggle (the backend response carries no liked flag).
    final likedTracks = useState<Set<String>>({});

    useEffect(() {
      if (state.tracks.isEmpty && !state.isLoading && state.error == null) {
        Future.microtask(() => notifier.load());
      }
      return null;
    }, const []);

    Future<void> toggleLike(String trackId, bool liked) async {
      final actions = ref.read(forYouLikeActionsProvider);
      try {
        if (liked) {
          await actions.unlike(trackId);
          if (context.mounted) {
            likedTracks.value = {...likedTracks.value}..remove(trackId);
          }
        } else {
          await actions.like(trackId);
          if (context.mounted) {
            likedTracks.value = {...likedTracks.value, trackId};
          }
        }
        await notifier.refresh();
      } catch (_) {
        if (context.mounted) {
          showWalletToast(
            context,
            liked
                ? "Couldn't remove the like — try again"
                : "Couldn't save the like — try again",
            icon: DeeMusiqIcons.heart,
          );
        }
      }
    }

    return Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: const Text("For You").semiBold()),
              if (state.gmailLinked)
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text("Gmail linked",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(fontSize: 11, color: colorScheme.primary)),
                  ),
                )
              else
                Flexible(
                  child: const Text(
                    "Sign in with Gmail for smarter picks",
                    style: TextStyle(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).muted(),
                ),
              const Gap(8),
              Button.ghost(
                onPressed: state.isRefreshing ? null : () => notifier.refresh(),
                leading: state.isRefreshing
                    ? const CircularProgressIndicator(size: 14)
                    : null,
                child: const Text("Refresh"),
              ),
            ],
          ),
          const Gap(8),
          if (state.isLoading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator())),
          if (state.error != null && state.error != 'backend_not_configured')
            ErrorBox(
              error: state.error!,
              onRetry: () => notifier.load(force: true),
            ),
          if (!state.isLoading && state.error == null && state.tracks.isEmpty)
            const Text("Like songs to train For You — picks appear here.")
                .muted()
                .small(),
          for (final t in state.tracks.take(8))
            _ForYouTile(
              title: t.title,
              artist: t.artistName,
              reasons: t.reasons,
              liked: likedTracks.value.contains(t.id),
              onLike: () => toggleLike(t.id, likedTracks.value.contains(t.id)),
            ),
        ],
      ),
    );
  }
}

class _ForYouTile extends StatelessWidget {
  final String title;
  final String artist;
  final List<String> reasons;
  final bool liked;
  final VoidCallback onLike;
  const _ForYouTile({
    required this.title,
    required this.artist,
    required this.reasons,
    required this.liked,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(DeeMusiqIcons.music, size: 16),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.isEmpty ? "Unknown title" : title,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                if (reasons.isNotEmpty)
                  Text(reasons.first,
                          maxLines: 1, overflow: TextOverflow.ellipsis)
                      .muted()
                      .xSmall()
                else if (artist.isNotEmpty)
                  Text(artist, maxLines: 1, overflow: TextOverflow.ellipsis)
                      .muted()
                      .xSmall(),
              ],
            ),
          ),
          Button.ghost(
            onPressed: onLike,
            leading: Icon(
              liked ? DeeMusiqIcons.heartFilled : DeeMusiqIcons.heart,
              size: 14,
            ),
            child: Text(liked ? "Liked" : "Like"),
          ),
        ],
      ),
    );
  }
}
