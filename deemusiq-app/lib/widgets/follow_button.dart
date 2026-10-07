import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// A "Follow" / "Following" toggle for an artist, backed by the wallet
/// backend's follow graph (server-authoritative). Only meaningful when the
/// backend is configured — callers gate on `WalletApiClient.instance.isConfigured`.
class FollowArtistButton extends HookConsumerWidget {
  final String artistId;
  final String artistName;

  const FollowArtistButton({
    super.key,
    required this.artistId,
    required this.artistName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFollowing = useState<bool?>(null); // null = loading
    final busy = useState(false);

    Future<void> load() async {
      try {
        // Precise O(1) check — GET /me/follows/check (falls back to list-scan
        // on older backends that 404 the new route).
        try {
          final following = await WalletApiClient.instance.isFollowing(
            targetKind: "artist",
            targetId: artistId,
          );
          if (context.mounted) isFollowing.value = following;
        } catch (_) {
          final list = await WalletApiClient.instance.myFollowing();
          if (context.mounted) {
            isFollowing.value = list
                .cast<Map<String, dynamic>>()
                .any((f) =>
                    f["targetKind"] == "artist" && f["targetId"] == artistId);
          }
        }
      } catch (e, st) {
        AppLogger.reportError(e, st, 'load follow state');
        if (context.mounted) isFollowing.value = false;
      }
    }

    useEffect(() {
      load();
      return null;
    }, [artistId]);

    Future<void> toggle() async {
      if (busy.value) return;
      busy.value = true;
      final wasFollowing = isFollowing.value ?? false;
      isFollowing.value = !wasFollowing; // optimistic
      try {
        if (wasFollowing) {
          await WalletApiClient.instance.unfollowArtist(artistId);
        } else {
          await WalletApiClient.instance.followArtist(artistId);
        }
      } on WalletApiException catch (e) {
        if (context.mounted) {
          isFollowing.value = wasFollowing; // revert
          showWalletToast(context, e.message, icon: DeeMusiqIcons.error);
        }
      } catch (e, st) {
        AppLogger.reportError(e, st, 'toggle follow');
        if (context.mounted) isFollowing.value = wasFollowing;
      } finally {
        if (context.mounted) busy.value = false;
      }
    }

    if (isFollowing.value == null) {
      return const SizedBox(
        width: 72,
        height: 32,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final following = isFollowing.value!;
    return Button.ghost(
      onPressed: busy.value ? null : toggle,
      leading: Icon(
        following ? DeeMusiqIcons.done : DeeMusiqIcons.add,
        size: 14,
      ),
      child: Text(following ? "Following" : "Follow"),
    );
  }
}
