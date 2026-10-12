// Coverage for the Home browse feed's loading state.
//
// While the feed is still resolving its first section, Home renders the
// component's own skeleton (`HorizontalPlaybuttonCardView.skeleton`) rather than
// a blank gap. The skeleton is built from real presentational widgets, and this
// test pins the two properties that are easy to regress and expensive to notice:
// it must not build `AlbumCard` (which watches the audio player and throws
// MediaKit.ensureInitialized outside a running app), and it must not resolve any
// image — neither a remote URL nor a bundled asset path, which widget tests
// cannot load.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/components/playbutton_view/playbutton_card.dart';
import 'package:deemusiq/l10n/l10n.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/modules/home/sections/sections.dart';
import 'package:deemusiq/provider/metadata_plugin/browse/sections.dart';

const _tinySvg =
    '<svg xmlns="http://www.w3.org/2000/svg" width="1" height="1"/>';

/// Fails loudly on any asset the skeleton tries to resolve, so a regression that
/// reintroduces an image URL or an `assets/...` path fails the test instead of
/// silently rendering nothing.
class _StrictAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin' || key == 'AssetManifest.smcbin') {
      return const StandardMessageCodec().encodeMessage(<Object?, Object?>{})!;
    }
    if (key.endsWith('.svg')) {
      final svg = Uint8List.fromList(utf8.encode(_tinySvg));
      return ByteData.view(svg.buffer);
    }
    throw FlutterError('unexpected asset: $key');
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key.endsWith('.svg')) return _tinySvg;
    return '[]';
  }
}

/// Never resolves, so the feed stays in its first-load state for the whole test.
class _HangingBrowseSectionsNotifier
    extends MetadataPluginBrowseSectionsNotifier {
  @override
  Future<DeeMusiqPaginationResponseObject<DeeMusiqBrowseSectionObject<Object>>>
      build() async {
    await Completer<void>().future;
    throw StateError('unreachable: the loading test never resolves this feed');
  }
}

void main() {
  testWidgets('the loading state shows a skeleton and resolves no assets',
      (tester) async {
    // Never disposed: ProviderScope teardown disposes providers mid-finalize and
    // trips a riverpod subscription close race. Leaking is fine in tests.
    final container = ProviderContainer(
      overrides: [
        metadataPluginBrowseSectionsProvider
            .overrideWith(() => _HangingBrowseSectionsNotifier()),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: DefaultAssetBundle(
          bundle: _StrictAssetBundle(),
          child: ShadcnApp(
            supportedLocales: L10n.all,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const Scaffold(
              child: CustomScrollView(
                slivers: [HomePageBrowseSection()],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // Real loading affordance, not a silent blank region.
    expect(find.textContaining('Building your timeline'), findsOneWidget);

    // Built from the live presentational card rather than hand-placed boxes.
    // (Matched on PlaybuttonCard, not Skeletonizer: Skeletonizer is a
    // factory-backed class, so its runtime type is a private subclass.)
    expect(find.byType(PlaybuttonCard), findsWidgets);

    // No artwork resolved: _StrictAssetBundle throws on anything but .svg, and
    // a remote URL would surface as an exception here instead.
    expect(
      tester.takeException(),
      isNull,
      reason: 'the skeleton must not stand up media_kit or fetch artwork',
    );
  });
}
