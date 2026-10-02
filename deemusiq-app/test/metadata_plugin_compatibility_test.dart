import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/metadata_plugin/metadata_plugin_provider.dart';
import 'package:deemusiq/services/metadata/deemusiq_native_plugin.dart';
import 'package:deemusiq/services/metadata/errors/exceptions.dart';
import 'package:deemusiq/services/metadata/metadata.dart';
import 'package:deemusiq/services/youtube_engine/youtube_engine.dart';
import 'package:path/path.dart';

class _UnusedEngine extends Fake implements YouTubeEngine {}

final _youtubeAudioPlugin = PluginConfiguration(
  name: 'YouTube Audio',
  author: 'Kingkor Roy Tirtho',
  description: 'YouTube audio source plugin for Spotube',
  version: '1.0.0',
  entryPoint: 'YouTubeAudioSourcePlugin',
  pluginApiVersion: '2.0.0',
  apis: [PluginApis.localstorage],
  abilities: [PluginAbilities.audioSource],
  repository: 'https://github.com/KRTirtho/spotube-plugin-youtube-audio',
);

Uint8List _pluginArchive(
  PluginConfiguration config, {
  String unsafeEntry = 'logo.png',
}) {
  final archive = Archive()
    ..addFile(ArchiveFile.string(
      'plugin.json',
      jsonEncode(config.toJson()),
    ))
    ..addFile(ArchiveFile.bytes('plugin.out', [0, 1, 2, 3]))
    ..addFile(ArchiveFile.string(unsafeEntry, 'inert'));
  return ZipEncoder().encodeBytes(archive);
}

Matcher _pluginError(MetadataPluginErrorCode code) =>
    isA<MetadataPluginException>()
        .having((error) => error.errorCode, 'errorCode', code);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory supportDirectory;

  setUp(() async {
    supportDirectory = await Directory.systemTemp.createTemp(
      'deemusiq-plugin-test-',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
      if (call.method == 'getApplicationSupportDirectory') {
        return supportDirectory.path;
      }
      return null;
    });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (await supportDirectory.exists()) {
      await supportDirectory.delete(recursive: true);
    }
  });

  test('extracts only inert legacy compatibility assets', () async {
    final notifier = MetadataPluginNotifier();
    final config = await notifier.extractPluginArchive(
      _pluginArchive(_youtubeAudioPlugin),
    );

    expect(config, _youtubeAudioPlugin);
    final directory = Directory(
      join(
        supportDirectory.path,
        'metadata-plugins',
        'Kingkor Roy Tirtho-YouTube Audio-1.0.0',
      ),
    );
    expect(await File(join(directory.path, 'plugin.json')).exists(), isTrue);
    expect(
      await File(join(directory.path, 'plugin.out')).readAsBytes(),
      [0, 1, 2, 3],
    );
    expect(await notifier.getPluginByteCode(config), [0, 1, 2, 3]);
  });

  test('rejects archive paths outside the compatibility root', () async {
    final notifier = MetadataPluginNotifier();
    await expectLater(
      notifier.extractPluginArchive(
        _pluginArchive(
          _youtubeAudioPlugin,
          unsafeEntry: '../outside.txt',
        ),
      ),
      throwsA(
        _pluginError(MetadataPluginErrorCode.invalidPluginConfiguration),
      ),
    );
    expect(
      await File(join(supportDirectory.path, 'outside.txt')).exists(),
      isFalse,
    );
  });

  test(
      'legacy create delegates to native endpoints without evaluating bytecode',
      () async {
    final plugin = await MetadataPlugin.create(
      _UnusedEngine(),
      _youtubeAudioPlugin,
      Uint8List.fromList([0xff, 0xfe, 0xfd]),
    );

    expect(plugin.audioSource.supportedPresets, isNotEmpty);
    expect(plugin.auth.isAuthenticated(), isTrue);
    expect(await plugin.core.support, 'https://deemusiq.co.za/');
  });

  test('native configuration keeps native behavior', () {
    final plugin = MetadataPluginCompatibilityRegistry.resolve(
      kDeeMusiqNativePluginConfig,
      _UnusedEngine(),
      [_UnusedEngine()],
      requiredAbility: PluginAbilities.metadata,
    );

    expect(plugin.audioSource.supportedPresets, isNotEmpty);
    expect(plugin.auth.isAuthenticated(), isTrue);
  });

  test('rejects unregistered remote plugin URLs before downloading', () async {
    final notifier = MetadataPluginNotifier();
    await expectLater(
      notifier.downloadAndCachePlugin(
        'https://example.com/unknown-plugin.smplug',
      ),
      throwsA(_pluginError(MetadataPluginErrorCode.pluginNotFound)),
    );
  });

  test('unknown compatibility IDs return pluginNotFound', () async {
    final config = _youtubeAudioPlugin.copyWith(
      repository: 'https://github.com/KRTirtho/unknown-plugin',
    );

    await expectLater(
      MetadataPlugin.create(_UnusedEngine(), config, Uint8List(0)),
      throwsA(_pluginError(MetadataPluginErrorCode.pluginNotFound)),
    );
  });

  test('identity mismatches return invalidPluginConfiguration', () {
    final config = _youtubeAudioPlugin.copyWith(
      entryPoint: 'UnregisteredPlugin',
    );

    expect(
      () => MetadataPluginCompatibilityRegistry.validate(config),
      throwsA(
        _pluginError(MetadataPluginErrorCode.invalidPluginConfiguration),
      ),
    );
  });

  test('incompatible API versions return pluginApiVersionMismatch', () {
    final config = _youtubeAudioPlugin.copyWith(pluginApiVersion: '1.0.0');

    expect(
      () => MetadataPluginCompatibilityRegistry.validate(config),
      throwsA(
        _pluginError(MetadataPluginErrorCode.pluginApiVersionMismatch),
      ),
    );
  });

  test('unsupported package versions return pluginUnavailable', () {
    final config = _youtubeAudioPlugin.copyWith(version: '2.0.0');

    expect(
      () => MetadataPluginCompatibilityRegistry.validate(config),
      throwsA(_pluginError(MetadataPluginErrorCode.pluginUnavailable)),
    );
  });

  test('unrequested abilities return pluginPermissionDenied', () {
    final config = _youtubeAudioPlugin.copyWith(
      abilities: const [
        PluginAbilities.audioSource,
        PluginAbilities.metadata,
      ],
    );

    expect(
      () => MetadataPluginCompatibilityRegistry.validate(config),
      throwsA(_pluginError(MetadataPluginErrorCode.pluginPermissionDenied)),
    );
  });
}
