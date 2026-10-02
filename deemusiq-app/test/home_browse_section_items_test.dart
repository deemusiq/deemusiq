// Regression coverage for HomeBrowseSectionItemsPage:
//  - a failed initial fetch shows an ErrorBox with retry instead of a blank
//    grid
//  - pagination (fetchMore) keeps the loaded grid visible instead of
//    collapsing the whole page to skeletons (scroll jump)

import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart' hide Track;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:auto_route/auto_route.dart';
import 'package:deemusiq/collections/fake.dart';
import 'package:deemusiq/collections/routes.dart';
import 'package:deemusiq/components/fallbacks/error_box.dart';
import 'package:deemusiq/l10n/l10n.dart';
import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/modules/album/album_card.dart';
import 'package:deemusiq/pages/home/sections/section_items.dart';
import 'package:deemusiq/provider/audio_player/audio_player.dart';
import 'package:deemusiq/provider/audio_player/state.dart';
import 'package:deemusiq/provider/blacklist_provider.dart';
import 'package:deemusiq/provider/metadata_plugin/browse/section_items.dart';

final _transparentPng = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

class _FakeAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin' || key == 'AssetManifest.smcbin') {
      return const StandardMessageCodec()
          .encodeMessage(<Object?, Object?>{})!;
    }
    if (key.endsWith('.svg')) {
      final svg = Uint8List.fromList(utf8.encode(
        '<svg xmlns="http://www.w3.org/2000/svg" width="1" height="1"/>',
      ));
      return ByteData.view(svg.buffer);
    }
    return ByteData.view(_transparentPng.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async => '[]';
}

class _FakeRef extends Fake implements WidgetRef {}

class _FakeAudioPlayerNotifier extends AudioPlayerNotifier {
  @override
  AudioPlayerState build() => AudioPlayerState(
        playing: false,
        loopMode: PlaylistMode.none,
        shuffled: false,
        collections: const [],
      );
}

class _FakeBlacklistNotifier extends BlackListNotifier {
  @override
  Future<List<BlacklistTableData>> build() async => [];
}

class _FailingSectionItemsNotifier
    extends MetadataPluginBrowseSectionItemsNotifier {
  @override
  Future<DeeMusiqPaginationResponseObject<Object>> build(String arg) async {
    throw Exception('boom');
  }
}

/// Serves one album for the first page; the next page never completes so the
/// widget stays in the fetchMore (AsyncLoadingNext) state during the test.
class _PagingSectionItemsNotifier
    extends MetadataPluginBrowseSectionItemsNotifier {
  final Completer<DeeMusiqPaginationResponseObject<Object>> _nextPage =
      Completer();

  @override
  Future<DeeMusiqPaginationResponseObject<Object>> build(String arg) async {
    return DeeMusiqPaginationResponseObject<Object>(
      limit: 20,
      nextOffset: 20,
      total: 40,
      hasMore: true,
      items: [FakeData.albumSimple],
    );
  }

  @override
  Future<DeeMusiqPaginationResponseObject<Object>> fetch(
    int offset,
    int limit,
  ) {
    return _nextPage.future;
  }
}

final _section = DeeMusiqBrowseSectionObject<Object>(
  id: 'test-section',
  title: 'Test section',
  externalUri: '',
  browseMore: true,
  items: const [],
);

Widget _app(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: DefaultAssetBundle(
      bundle: _FakeAssetBundle(),
      child: ShadcnApp(
        supportedLocales: L10n.all,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: StackRouterScope(
          controller: AppRouter(_FakeRef()),
          stateHash: 0,
          child: HomeBrowseSectionItemsPage(
            sectionId: 'test-section',
            section: _section,
          ),
        ),
      ),
    ),
  );
}

ProviderContainer _container(MetadataPluginBrowseSectionItemsNotifier notifier) {
  return ProviderContainer(
    overrides: [
      metadataPluginBrowseSectionItemsProvider.overrideWith(() => notifier),
      audioPlayerProvider.overrideWith(() => _FakeAudioPlayerNotifier()),
      blacklistProvider.overrideWith(() => _FakeBlacklistNotifier()),
    ],
  );
}

void main() {
  MediaKit.ensureInitialized();
  // Waypoint uses VisibilityDetector, whose controller drives updates with a
  // periodic timer — zero the interval so tests don't end with timers pending.
  VisibilityDetectorController.instance.updateInterval = Duration.zero;

  testWidgets('failed initial fetch shows an ErrorBox with retry',
      (tester) async {
    final container = _container(_FailingSectionItemsNotifier());
    addTearDown(container.dispose);

    await tester.pumpWidget(_app(container));
    await tester.pump();
    await tester.pump();

    expect(find.byType(ErrorBox), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.byType(AlbumCard), findsNothing);
  });

  testWidgets('pagination keeps the loaded grid visible', (tester) async {
    final notifier = _PagingSectionItemsNotifier();
    final container = _container(notifier);
    addTearDown(container.dispose);

    await tester.pumpWidget(_app(container));
    await tester.pump();
    await tester.pump();

    expect(find.byType(AlbumCard), findsOneWidget);

    // Kick off the next page fetch (stays pending). Before the fix the whole
    // grid collapsed to skeletons here; the loaded items must stay visible.
    unawaited(notifier.fetchMore());
    await tester.pump();

    expect(find.byType(AlbumCard), findsOneWidget);

    // Let the pending next-page fetch resolve so no timer/future chain is
    // left dangling when the tree is disposed.
    notifier._nextPage.complete(
      DeeMusiqPaginationResponseObject<Object>(
        limit: 20,
        nextOffset: null,
        total: 40,
        hasMore: false,
        items: const [],
      ),
    );
    await tester.pump();

    // Unmount the tree so autoDispose providers (and their cacheFor timers)
    // release before the test-end pending-timer invariant runs.
    await tester.pumpWidget(const SizedBox());
    // Advance fake time so zero-duration Timers (e.g. CustomPlayer's Linux
    // audio init, created when AlbumCard touches the global player) fire.
    await tester.pump(const Duration(milliseconds: 1));
  });
}
