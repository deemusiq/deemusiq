// Regression coverage for HomePageBrowseSection: a successful fetch that
// returns zero sections used to leave Home silently blank. It now shows an
// empty state (illustration + "Nothing found") instead of an empty sliver
// list.

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';
import 'package:deemusiq/l10n/l10n.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/modules/home/sections/sections.dart';
import 'package:deemusiq/provider/metadata_plugin/browse/sections.dart';

const _tinySvg =
    '<svg xmlns="http://www.w3.org/2000/svg" width="1" height="1"/>';

class _FakeAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin' || key == 'AssetManifest.smcbin') {
      return const StandardMessageCodec()
          .encodeMessage(<Object?, Object?>{})!;
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

class _EmptyBrowseSectionsNotifier
    extends MetadataPluginBrowseSectionsNotifier {
  @override
  Future<DeeMusiqPaginationResponseObject<DeeMusiqBrowseSectionObject<Object>>>
      build() async {
    return DeeMusiqPaginationResponseObject<
        DeeMusiqBrowseSectionObject<Object>>(
      limit: 20,
      nextOffset: null,
      total: 0,
      hasMore: false,
      items: const [],
    );
  }
}

void main() {
  testWidgets('zero sections render an empty state instead of a blank page',
      (tester) async {
    // Never disposed: ProviderScope's teardown disposes providers mid-finalize
    // and trips a riverpod subscription close race. Leaking is fine in tests.
    final container = ProviderContainer(
      overrides: [
        metadataPluginBrowseSectionsProvider
            .overrideWith(() => _EmptyBrowseSectionsNotifier()),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
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
    final exc = tester.takeException();
    if (exc != null) {
      // ignore: avoid_print
      print('CAUGHT: $exc');
    }
    await tester.pump();

    expect(find.text('Nothing found'), findsOneWidget);
    expect(find.byType(SliverInfiniteList), findsNothing);
  });
}
