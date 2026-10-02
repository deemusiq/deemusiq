import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:deemusiq/components/track_presentation/presentation_props.dart';
import 'package:deemusiq/components/track_presentation/track_presentation.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/catalog/catalog_provider.dart';
import 'package:deemusiq/provider/metadata_plugin/utils/common.dart';

/// The DeeMusiq catalog page — exclusive DeeMusiq songs (unlisted-YouTube backed)
/// rendered through the standard [TrackPresentation], so play / queue / download
/// / "Push this song" all work via the existing track widgets.
@RoutePage()
class CatalogPage extends HookConsumerWidget {
  static const name = "catalog";
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final catalog = ref.watch(catalogProvider);
    final catalogNotifier = ref.read(catalogProvider.notifier);
    final tracks = catalog.asData?.value ?? const <DeeMusiqFullTrackObject>[];

    final collection = DeeMusiqSimplePlaylistObject(
      id: "deemusiq-catalog",
      name: "DeeMusiq",
      description: "Exclusive DeeMusiq drops",
      externalUri: "",
      owner: DeeMusiqUserObject(
        id: "deemusiq",
        name: "DeeMusiq",
        externalUri: "",
      ),
    );

    Future<void> refreshCatalog() async {
      final refreshed = ref.refresh(catalogProvider.future);
      await refreshed;
    }

    Future<List<DeeMusiqFullTrackObject>> fetchAllTracks() async {
      await catalogNotifier.fetchAll();
      return ref.read(catalogProvider).value ?? tracks;
    }

    return material.RefreshIndicator.adaptive(
      onRefresh: refreshCatalog,
      child: TrackPresentation(
        options: TrackPresentationOptions(
          collection: collection,
          title: "DeeMusiq",
          description: "Exclusive DeeMusiq drops",
          owner: "DeeMusiq",
          image: "assets/branding/deemusiq-logo.png",
          tracks: tracks,
          error: catalog.error,
          routePath: "/catalog",
          isLiked: false,
          shareUrl: null,
          onHeart: null,
          pagination: PaginationProps(
            hasNextPage: catalogNotifier.hasMore,
            isLoading: catalog.isLoading || catalog.isLoadingNextPage,
            onFetchMore: () => catalogNotifier.fetchMore(),
            onFetchAll: fetchAllTracks,
            onRefresh: refreshCatalog,
          ),
        ),
      ),
    );
  }
}
