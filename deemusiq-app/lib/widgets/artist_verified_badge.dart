import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/pages/artist/section/header.dart';

/// Compact verified mark shown next to an artist's name in dense contexts
/// (track tiles, search results) where the artist page header's full
/// PrimaryBadge wouldn't fit. Renders nothing for unverified artists or
/// non-catalog ids (the provider answers false for both).
class ArtistVerifiedBadge extends ConsumerWidget {
  final String artistId;

  const ArtistVerifiedBadge({super.key, required this.artistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVerified =
        ref.watch(artistVerifiedProvider(artistId)).asData?.value == true;
    if (!isVerified) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Tooltip(
        tooltip: const TooltipContainer(
          child: Text("Verified artist"),
        ).call,
        child: const Icon(
          DeeMusiqIcons.verified,
          size: 12,
          color: deeMusiqOrange,
        ),
      ),
    );
  }
}
