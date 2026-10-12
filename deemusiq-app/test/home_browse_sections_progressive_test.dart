// Coverage for progressive Home browse loading.
//
// The browse feed fans out over independent sources, so the slowest one used to
// hold the page on "building your timeline" with nothing to show. The endpoint
// now reports each section to `onSection` as it lands and the notifier republishes
// `state` per batch. These tests pin both halves: that partial batches actually
// reach listeners while the load is still running, and that the final page is
// still authoritative.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/metadata_plugin/browse/sections.dart';
import 'package:deemusiq/provider/metadata_plugin/core/auth.dart';
import 'package:deemusiq/provider/metadata_plugin/metadata_plugin_provider.dart';
import 'package:deemusiq/services/metadata/endpoints/browse.dart';
import 'package:deemusiq/services/metadata/metadata.dart';

DeeMusiqBrowseSectionObject<Object> _section(String id, {int itemCount = 1}) {
  return DeeMusiqBrowseSectionObject<Object>(
    id: id,
    title: id,
    externalUri: 'deemusiq:section:$id',
    browseMore: false,
    items: [
      for (var i = 0; i < itemCount; i++)
        DeeMusiqSimpleAlbumObject(
          id: '$id-$i',
          name: '$id $i',
          externalUri: 'deemusiq:album:$id-$i',
          artists: const [],
          images: const [],
          albumType: DeeMusiqAlbumType.album,
          releaseDate: '2026-01-01',
        ),
    ],
  );
}

/// Emits [batches] to `onSection` one at a time, each gated by its own
/// completer, then returns the accumulated page.
class _ProgressiveBrowse extends MetadataPluginBrowseEndpoint {
  final List<List<DeeMusiqBrowseSectionObject<Object>>> batches;
  _ProgressiveBrowse(this.batches);

  /// One gate per batch, so a test can hold the feed open after the first
  /// section and observe the intermediate state.
  late final List<Completer<void>> gates = [
    for (var i = 0; i < batches.length; i++) Completer<void>()
  ];

  /// Completes once `sections()` has been entered and the gates are live.
  final Completer<void> started = Completer<void>();

  @override
  Future<DeeMusiqPaginationResponseObject<DeeMusiqBrowseSectionObject<Object>>>
      sections({
    int? offset,
    int? limit,
    void Function(List<DeeMusiqBrowseSectionObject<Object>> sections)?
        onSection,
  }) async {
    if (!started.isCompleted) started.complete();
    var accumulated = <DeeMusiqBrowseSectionObject<Object>>[];
    for (var i = 0; i < batches.length; i++) {
      await gates[i].future;
      accumulated = [...accumulated, ...batches[i]];
      onSection?.call(accumulated);
    }
    return DeeMusiqPaginationResponseObject<
        DeeMusiqBrowseSectionObject<Object>>(
      limit: accumulated.length,
      nextOffset: null,
      total: accumulated.length,
      hasMore: false,
      items: accumulated,
    );
  }

  @override
  Future<DeeMusiqPaginationResponseObject<Object>> sectionItems(
    String id, {
    int? offset,
    int? limit,
  }) async {
    return DeeMusiqPaginationResponseObject<Object>(
      limit: 0,
      nextOffset: null,
      total: 0,
      hasMore: false,
      items: const [],
    );
  }
}

MetadataPlugin _pluginWith(MetadataPluginBrowseEndpoint browse) {
  final plugin = MetadataPlugin.forTesting();
  plugin.browse = browse;
  return plugin;
}

void main() {
  test('partial sections reach listeners while the load is still running',
      () async {
    final browse = _ProgressiveBrowse([
      [_section('first')],
      [_section('second')],
    ]);
    final container = ProviderContainer(
      overrides: [
        metadataPluginAuthenticatedProvider.overrideWith(() => _TrueAuth()),
        metadataPluginProvider.overrideWith((ref) async => _pluginWith(browse)),
      ],
    );
    addTearDown(container.dispose);

    final seen = <List<String>>[];
    final sub = container.listen(
      metadataPluginBrowseSectionsProvider,
      (_, next) {
        final ids = next.asData?.value.items.map((s) => s.id).toList();
        if (ids != null) seen.add(ids);
      },
      fireImmediately: true,
    );
    addTearDown(sub.close);

    // Let the notifier reach the awaiting `sections()` call.
    await browse.started.future;

    // Release one batch: this must surface *before* the load completes.
    browse.gates[0].complete();
    await _settle();

    final partial = container.read(metadataPluginBrowseSectionsProvider);
    expect(
      partial.asData!.value.items.map((s) => s.id),
      ['first'],
    );
    expect(
      partial.asData!.value.hasMore,
      isTrue,
      reason: 'a partial batch still owes the feed more sections',
    );
    expect(seen, contains(equals(['first'])));

    // Release the rest; the awaited page stays authoritative.
    browse.gates[1].complete();
    await _settle();

    final done = container.read(metadataPluginBrowseSectionsProvider);
    expect(done.asData!.value.items.map((s) => s.id), ['first', 'second']);
    expect(
      done.asData!.value.hasMore,
      isFalse,
      reason: 'the final page closes the feed',
    );
    expect(done.isLoading, isFalse);
  });

  test('an empty partial batch is not published as an empty feed', () async {
    final browse = _ProgressiveBrowse([
      const [],
      [_section('only')],
    ]);
    final container = ProviderContainer(
      overrides: [
        metadataPluginAuthenticatedProvider.overrideWith(() => _TrueAuth()),
        metadataPluginProvider.overrideWith((ref) async => _pluginWith(browse)),
      ],
    );
    addTearDown(container.dispose);

    final sub = container.listen(
      metadataPluginBrowseSectionsProvider,
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(sub.close);

    await browse.started.future;

    browse.gates[0].complete();
    await _settle();

    // Still nothing has arrived — the feed must not read as "zero results".
    expect(
      container.read(metadataPluginBrowseSectionsProvider).asData,
      isNull,
      reason: 'an empty batch must not publish an empty page',
    );
    expect(
      container.read(metadataPluginBrowseSectionsProvider).isLoading,
      isTrue,
    );
  });
}

/// Drains the microtask/event queue so notifier state settles.
Future<void> _settle() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

class _TrueAuth extends MetadataPluginAuthenticatedNotifier {
  @override
  FutureOr<bool> build() async => true;
}
