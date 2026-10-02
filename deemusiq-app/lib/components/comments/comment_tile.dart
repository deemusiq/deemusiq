import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/comments/comments_section.dart';
import 'package:deemusiq/components/fallbacks/error_box.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/provider/wallet/comments_provider.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// One top-level comment with an expandable inline replies thread and a
/// reply composer (auth-gated the same way as the top-level composer).
class CommentTile extends HookConsumerWidget {
  final TrackComment comment;
  final CommentTarget target;

  const CommentTile({
    super.key,
    required this.comment,
    required this.target,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repliesExpanded = useState(false);
    final replyComposerOpen = useState(false);

    return Card(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(DeeMusiqIcons.user, size: 14),
              const Gap(6),
              Expanded(
                child: Text(
                  comment.authorLabel != null
                      ? "Listener ${comment.authorLabel}"
                      : "Listener",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).semiBold().small(),
              ),
              if (comment.createdAt != null)
                Text(relativeTime(comment.createdAt!.toLocal()))
                    .muted()
                    .xSmall(),
            ],
          ),
          const Gap(8),
          Text(comment.body),
          const Gap(8),
          Row(
            children: [
              if (WalletApiClient.instance.hasToken())
                Button.ghost(
                  leading: const Icon(FeatherIcons.cornerUpLeft, size: 14),
                  onPressed: () =>
                      replyComposerOpen.value = !replyComposerOpen.value,
                  child: const Text("Reply"),
                ),
              if (comment.replyCount > 0)
                Button.ghost(
                  leading: Icon(
                    repliesExpanded.value
                        ? FeatherIcons.chevronUp
                        : FeatherIcons.chevronDown,
                    size: 14,
                  ),
                  onPressed: () =>
                      repliesExpanded.value = !repliesExpanded.value,
                  child: Text(
                    "${comment.replyCount} "
                    "repl${comment.replyCount == 1 ? "y" : "ies"}",
                  ),
                ),
            ],
          ),
          if (replyComposerOpen.value) ...[
            const Gap(8),
            CommentComposer(
              target: target,
              parentId: comment.id,
              onPosted: () {
                replyComposerOpen.value = false;
                repliesExpanded.value = true;
              },
            ),
          ],
          if (repliesExpanded.value) ...[
            const Gap(8),
            _RepliesList(parentId: comment.id),
          ],
        ],
      ),
    );
  }
}

class _RepliesList extends ConsumerWidget {
  final String parentId;

  const _RepliesList({required this.parentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final replies = ref.watch(commentRepliesProvider(parentId));

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.mutedForeground,
            width: 2,
          ),
        ),
      ),
      padding: const EdgeInsets.only(left: 12),
      child: replies.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => ErrorBox(
          error: error,
          userMessage: error is WalletApiException
              ? error.friendlyMessage
              : null,
          onRetry: () => ref.invalidate(commentRepliesProvider(parentId)),
        ),
        data: (items) => items.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("No replies yet."),
              ).muted().small()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final reply in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Icon(DeeMusiqIcons.user, size: 12),
                              const Gap(6),
                              Expanded(
                                child: Text(
                                  reply.authorLabel != null
                                      ? "Listener ${reply.authorLabel}"
                                      : "Listener",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ).semiBold().xSmall(),
                              ),
                              if (reply.createdAt != null)
                                Text(
                                  relativeTime(reply.createdAt!.toLocal()),
                                ).muted().xSmall(),
                            ],
                          ),
                          const Gap(4),
                          Text(reply.body).small(),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
