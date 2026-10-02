import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_undraw/flutter_undraw.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:deemusiq/components/fallbacks/error_box.dart';
import 'package:deemusiq/components/inter_scrollbar/inter_scrollbar.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/modules/search/loading.dart';
import 'package:deemusiq/pages/search/search.dart';
import 'package:deemusiq/modules/search/sections/albums.dart';
import 'package:deemusiq/modules/search/sections/artists.dart';
import 'package:deemusiq/modules/search/sections/playlists.dart';
import 'package:deemusiq/modules/search/sections/tracks.dart';
import 'package:deemusiq/provider/metadata_plugin/search/all.dart';

class SearchPageAllTab extends HookConsumerWidget {
  const SearchPageAllTab({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final scrollController = useScrollController();
    final searchTerm = ref.watch(searchTermStateProvider);
    final searchSnapshot =
        ref.watch(metadataPluginSearchAllProvider(searchTerm));

    if (searchSnapshot.hasError) {
      return ErrorBox(
        error: searchSnapshot.error!,
        onRetry: () {
          ref.invalidate(metadataPluginSearchAllProvider(searchTerm));
        },
      );
    }

    // Dead-end fix: a completed search where every section is empty used to
    // render a blank page — each section self-hides on no hits. Mirror the
    // empty state the per-type tabs already show.
    final result = searchSnapshot.asData?.value;
    final noHits = result != null &&
        result.tracks.isEmpty &&
        result.albums.isEmpty &&
        result.artists.isEmpty &&
        result.playlists.isEmpty;
    if (noHits) {
      return SearchPlaceholder(
        snapshot: searchSnapshot,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              Undraw(
                height: 200 * context.theme.scaling,
                illustration: UndrawIllustration.taken,
                color: Theme.of(context).colorScheme.primary,
              ),
              Text(
                context.l10n.nothing_found,
                textAlign: TextAlign.center,
              ).muted().small()
            ],
          ),
        ),
      );
    }

    return SearchPlaceholder(
      snapshot: searchSnapshot,
      child: InterScrollbar(
        controller: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchTracksSection(),
                  SearchPlaylistsSection(),
                  Gap(20),
                  SearchArtistsSection(),
                  Gap(20),
                  SearchAlbumsSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
