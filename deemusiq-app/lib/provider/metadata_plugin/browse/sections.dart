import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/metadata_plugin/core/auth.dart';
import 'package:deemusiq/provider/metadata_plugin/utils/paginated.dart';

class MetadataPluginBrowseSectionsNotifier
    extends PaginatedAsyncNotifier<DeeMusiqBrowseSectionObject<Object>> {
  @override
  Future<DeeMusiqPaginationResponseObject<DeeMusiqBrowseSectionObject<Object>>>
      fetch(
    int offset,
    int limit,
  ) async {
    return await (await metadataPlugin).browse.sections(
          limit: limit,
          offset: offset,
        );
  }

  @override
  build() async {
    ref.watch(metadataPluginAuthenticatedProvider);
    final plugin = await metadataPlugin;

    // Publish each batch to listeners as it lands so Home paints section by
    // section instead of staying blank for the whole fallback fan-out. The
    // awaited page below stays authoritative and supersedes these partials.
    return plugin.browse.sections(
      limit: 20,
      offset: 0,
      onSection: _publishPartial,
    );
  }

  /// Pushes an intermediate batch of sections into [state] while the initial
  /// load is still running. No-ops on an empty batch so an early callback with
  /// nothing ready yet cannot flip the feed to a spurious "no results" state.
  ///
  /// Publishing `AsyncData` here clears `AsyncValue.isLoading`, so `isLoading`
  /// cannot express "partial results, more still coming" — `hasMore: true` does,
  /// and it differs from the final page's `hasMore: false`, which guarantees the
  /// authoritative result is a distinct state and so still triggers a rebuild.
  void _publishPartial(List<DeeMusiqBrowseSectionObject<Object>> sections) {
    if (sections.isEmpty) return;
    state = AsyncData(
      DeeMusiqPaginationResponseObject<DeeMusiqBrowseSectionObject<Object>>(
        limit: sections.length,
        nextOffset: null,
        total: sections.length,
        hasMore: true,
        items: sections,
      ),
    );
  }
}

final metadataPluginBrowseSectionsProvider = AsyncNotifierProvider<
    MetadataPluginBrowseSectionsNotifier,
    DeeMusiqPaginationResponseObject<DeeMusiqBrowseSectionObject<Object>>>(
  () => MetadataPluginBrowseSectionsNotifier(),
);
