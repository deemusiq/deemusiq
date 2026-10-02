import 'package:auto_route/auto_route.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';

import 'package:deemusiq/collections/routes.gr.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/image/universal_image.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/pages/artist/section/header.dart';

import 'package:deemusiq/provider/blacklist_provider.dart';

class ArtistCard extends HookConsumerWidget {
  final DeeMusiqFullArtistObject artist;
  const ArtistCard(this.artist, {super.key});

  @override
  Widget build(BuildContext context, ref) {
    final theme = Theme.of(context);
    final scale = context.theme.scaling;
    final backgroundImage = UniversalImage.imageProvider(
      artist.images.asUrlString(
        placeholder: ImagePlaceholder.artist,
      ),
    );
    // Empty/whitespace artist names (bad upstream data) must not crash the
    // card grid with a RangeError — fall back to a neutral initial.
    final trimmedName = artist.name.trim();
    final initial = trimmedName.isEmpty ? "?" : trimmedName[0].toUpperCase();
    final isBlackListed = ref.watch(
      blacklistProvider.select(
        (blacklist) => blacklist.asData?.value.any(
          (element) => element.elementId == artist.id,
        ),
      ),
    );

    return SizedBox(
      width: 180 * scale,
      child: Button.card(
        onPressed: () {
          context.navigateTo(ArtistRoute(artistId: artist.id));
        },
        child: Column(
          children: [
            Avatar(
              initials: initial,
              provider: backgroundImage,
              size: 130 * scale,
            ),
            const Gap(10),
            AutoSizeText(
              artist.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.bold,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (ref.watch(artistVerifiedProvider(artist.id))
                        .asData
                        ?.value ==
                    true) ...[
                  const PrimaryBadge(
                    leading: Icon(
                      DeeMusiqIcons.verified,
                      size: 12,
                      color: deeMusiqOrange,
                    ),
                    child: Text("Verified"),
                  ),
                  const Gap(5),
                ],
                if (isBlackListed == true) ...[
                  DestructiveBadge(
                    child: Text(context.l10n.blacklisted.toUpperCase()),
                  ),
                  const Gap(5),
                ],
                SecondaryBadge(
                  child: Text(context.l10n.artist.toUpperCase()),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
