import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:deemusiq/collections/routes.gr.dart';
import 'package:deemusiq/components/fallbacks/error_box.dart';
import 'package:deemusiq/components/fallbacks/no_default_metadata_plugin.dart';
import 'package:deemusiq/components/horizontal_playbutton_card_view/horizontal_playbutton_card_view.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/provider/metadata_plugin/browse/sections.dart';
import 'package:deemusiq/provider/metadata_plugin/utils/common.dart';
import 'package:deemusiq/services/metadata/errors/exceptions.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';
import 'package:flutter_undraw/flutter_undraw.dart';

class HomePageBrowseSection extends HookConsumerWidget {
  const HomePageBrowseSection({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final browseSections = ref.watch(metadataPluginBrowseSectionsProvider);
    final sections = browseSections.asData?.value.items;
    final ThemeData(:colorScheme) = Theme.of(context);
    final scale = context.theme.scaling;

    // Nothing has landed yet — the feed is still resolving its first section.
    // The skeleton is the component's own [HorizontalPlaybuttonCardView.skeleton],
    // so it shares the real header and rail geometry rather than approximating
    // it. Sections then replace it as they arrive.
    if (sections == null && !browseSections.hasError) {
      return SliverToBoxAdapter(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < 2; i++)
              HorizontalPlaybuttonCardView.skeleton(
                title: Text(context.l10n.loading),
              ),
            const Gap(8),
            Text(
              context.l10n.building_your_timeline,
              textAlign: TextAlign.center,
            ).muted().small(),
          ],
        ),
      );
    }

    if (browseSections.error
        case MetadataPluginException(
          errorCode: MetadataPluginErrorCode.noDefaultMetadataPlugin,
          message: _,
        )) {
      return SliverFillRemaining(
        child: Center(
          child: NoDefaultMetadataPlugin(
            onRetry: () => ref.invalidate(metadataPluginBrowseSectionsProvider),
          ),
        ),
      );
    }

    if (browseSections.hasError) {
      return SliverFillRemaining(
        child: Center(
          child: ErrorBox(
            error: browseSections.error!,
            onRetry: () {
              ref.invalidate(metadataPluginBrowseSectionsProvider);
            },
          ),
        ),
      );
    }

    // A successful fetch with zero sections used to leave Home silently
    // blank — mirror the illustration + muted label empty states elsewhere.
    if (sections != null && sections.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              Undraw(
                height: 200 * scale,
                illustration: UndrawIllustration.taken,
                color: colorScheme.primary,
              ),
              Text(
                context.l10n.nothing_found,
                textAlign: TextAlign.center,
              ).muted().small(),
            ],
          ),
        ),
      );
    }

    final page = browseSections.asData?.value;
    // Sections paint as they arrive, so this list can be non-empty while the load
    // is still in flight. `hasMore` is the provider's "more sections still
    // coming" signal — `isLoading` flips false as soon as the first batch lands.
    final stillArriving = page?.hasMore ?? false;
    final canPaginate = (page?.hasMore ?? false) && page?.nextOffset != null;

    return SliverMainAxisGroup(
      slivers: [
        SliverInfiniteList(
          hasReachedMax: !canPaginate,
          isLoading:
              !browseSections.isLoading && browseSections.isLoadingNextPage,
          onFetchData: () {
            ref.read(metadataPluginBrowseSectionsProvider.notifier).fetchMore();
          },
          itemCount: sections?.length ?? 0,
          itemBuilder: (context, index) {
            final section = sections![index];
            if (section.items.isEmpty) return const SizedBox.shrink();

            return HorizontalPlaybuttonCardView(
              items: section.items,
              title: Text(section.title),
              hasNextPage: false,
              isLoadingNextPage: false,
              onFetchMore: () {},
              titleTrailing: section.browseMore
                  ? Button.text(
                      child: Text(context.l10n.browse_all),
                      onPressed: () {
                        context.navigateTo(
                          HomeBrowseSectionItemsRoute(
                            sectionId: section.id,
                            section: section,
                          ),
                        );
                      },
                    )
                  : null,
            );
          },
        ),
        if (stillArriving) const SliverToBoxAdapter(child: _TimelinePending()),
      ],
    );
  }
}

/// Spinner + label shown while the browse feed still owes the user sections.
///
/// Appended under the already-rendered sections while the rest are still
/// resolving.
class _TimelinePending extends StatelessWidget {
  const _TimelinePending();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          const Center(child: CircularProgressIndicator()),
          Text(
            context.l10n.building_your_timeline,
            textAlign: TextAlign.center,
          ).muted().small(),
        ],
      ),
    );
  }
}
