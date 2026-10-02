import 'package:auto_route/auto_route.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:deemusiq/collections/routes.gr.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/comments/comment_tile.dart';
import 'package:deemusiq/components/fallbacks/error_box.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/provider/wallet/comments_provider.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// The comments thread for one target (track/album/artist): composer on top,
/// cursor-paginated list below. Renders nothing when no backend is
/// configured — comments are an online-only feature.
class CommentsSection extends ConsumerWidget {
  final CommentTarget target;

  const CommentsSection({super.key, required this.target});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commentsProvider(target));

    if (!state.available) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(FeatherIcons.messageCircle, size: 18),
            const Gap(8),
            const Text("Comments").semiBold(),
          ],
        ),
        const Gap(12),
        if (WalletApiClient.instance.hasToken())
          CommentComposer(target: target)
        else
          const _SignInToCommentCard(),
        const Gap(16),
        if (state.loading && state.comments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (state.error != null && state.comments.isEmpty)
          ErrorBox(
            error: state.error!,
            userMessage: state.error is WalletApiException
                ? (state.error as WalletApiException).friendlyMessage
                : null,
            onRetry: () =>
                ref.read(commentsProvider(target).notifier).loadInitial(),
          )
        else if (state.comments.isEmpty)
          Card(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(FeatherIcons.messageCircle,
                    size: 28, color: deeMusiqOrange),
                const Gap(10),
                const Text("No comments yet").semiBold(),
                const Gap(4),
                const Text(
                  "Be the first to share what you think.",
                  textAlign: TextAlign.center,
                ).muted().small(),
              ],
            ),
          )
        else ...[
          for (final comment in state.comments)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CommentTile(comment: comment, target: target),
            ),
          if (state.loadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.loadMoreError != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    state.loadMoreError is WalletApiException
                        ? (state.loadMoreError as WalletApiException)
                            .friendlyMessage
                        : "Couldn't load more comments.",
                    textAlign: TextAlign.center,
                  ).muted().small(),
                ),
                Button.ghost(
                  leading: const Icon(DeeMusiqIcons.refresh, size: 14),
                  onPressed: () =>
                      ref.read(commentsProvider(target).notifier).loadMore(),
                  child: const Text("Retry"),
                ),
              ],
            )
          else if (state.hasMore)
            Center(
              child: Button.outline(
                onPressed: () =>
                    ref.read(commentsProvider(target).notifier).loadMore(),
                child: const Text("Load more comments"),
              ),
            ),
        ],
      ],
    );
  }
}

/// Shown in place of the composer when there is no backend session. Posting
/// requires auth; reading does not.
class _SignInToCommentCard extends StatelessWidget {
  const _SignInToCommentCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(DeeMusiqIcons.user, size: 18),
          const Gap(10),
          const Expanded(
            child: Text("Sign in to join the conversation."),
          ),
          Button.primary(
            onPressed: () => context.pushRoute(const Auth()),
            child: const Text("Sign in"),
          ),
        ],
      ),
    );
  }
}

/// Comment input + post button. With [parentId] it posts a reply under that
/// top-level comment and calls [onPosted] so the parent can collapse itself.
class CommentComposer extends HookConsumerWidget {
  final CommentTarget target;
  final String? parentId;
  final VoidCallback? onPosted;

  const CommentComposer({
    super.key,
    required this.target,
    this.parentId,
    this.onPosted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final posting = ref.watch(
      commentsProvider(target).select((s) => s.posting),
    );

    Future<void> post() async {
      final body = controller.text.trim();
      if (body.isEmpty || posting) return;
      try {
        await ref
            .read(commentsProvider(target).notifier)
            .post(body, parentId: parentId);
        controller.clear();
        onPosted?.call();
      } on WalletApiException catch (e) {
        if (context.mounted) {
          showWalletToast(context, e.friendlyMessage,
              icon: DeeMusiqIcons.error);
        }
      } catch (e) {
        if (context.mounted) {
          showWalletToast(
            context,
            "Couldn't post your comment — try again.",
            icon: DeeMusiqIcons.error,
          );
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: controller,
          maxLines: parentId == null ? 3 : 2,
          placeholder: Text(
            parentId == null ? "Add a comment…" : "Write a reply…",
          ),
        ),
        const Gap(8),
        Button.primary(
          enabled: !posting,
          leading: posting
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(size: 14),
                )
              : const Icon(DeeMusiqIcons.message, size: 14),
          onPressed: post,
          child: Text(parentId == null ? "Post" : "Reply"),
        ),
      ],
    );
  }
}
