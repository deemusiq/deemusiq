import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/database/database.dart';
import 'package:deemusiq/provider/youtube_engine/youtube_engine.dart';
import 'package:deemusiq/services/dio/dio.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/metadata/errors/exceptions.dart';
import 'package:deemusiq/services/metadata/metadata.dart';
import 'package:deemusiq/services/metadata/deemusiq_native_plugin.dart';
import 'package:deemusiq/utils/service_utils.dart';
import 'package:archive/archive.dart';
import 'package:pub_semver/pub_semver.dart';

final allowedDomainsRegex = RegExp(
  r"^(https?:\/\/)?(www\.)?(github\.com|codeberg\.org)\/.+",
);

class MetadataPluginState {
  final List<PluginConfiguration> plugins;
  final int defaultMetadataPlugin;
  final int defaultAudioSourcePlugin;

  const MetadataPluginState({
    this.plugins = const [],
    this.defaultMetadataPlugin = -1,
    this.defaultAudioSourcePlugin = -1,
  });

  // DeeMusiq's built-in native provider is always the active metadata + audio
  // source, so these never return null (the quality-presets/config code relies
  // on a non-null config).
  PluginConfiguration? get defaultMetadataPluginConfig =>
      kDeeMusiqNativePluginConfig;

  PluginConfiguration? get defaultAudioSourcePluginConfig =>
      kDeeMusiqNativePluginConfig;

  factory MetadataPluginState.fromJson(Map<String, dynamic> json) {
    return MetadataPluginState(
      plugins: (json["plugins"] as List<dynamic>)
          .map((e) => PluginConfiguration.fromJson(e))
          .toList(),
      defaultMetadataPlugin: json["default_metadata_plugin"] ?? -1,
      defaultAudioSourcePlugin: json['default_audio_source_plugin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "plugins": plugins.map((e) => e.toJson()).toList(),
      "default_metadata_plugin": defaultMetadataPlugin,
      "default_audio_source_plugin": defaultAudioSourcePlugin
    };
  }

  MetadataPluginState copyWith({
    List<PluginConfiguration>? plugins,
    int? defaultMetadataPlugin,
    int? defaultAudioSourcePlugin,
  }) {
    return MetadataPluginState(
      plugins: plugins ?? this.plugins,
      defaultMetadataPlugin:
          defaultMetadataPlugin ?? this.defaultMetadataPlugin,
      defaultAudioSourcePlugin:
          defaultAudioSourcePlugin ?? this.defaultAudioSourcePlugin,
    );
  }
}

class MetadataPluginNotifier extends AsyncNotifier<MetadataPluginState> {
  AppDatabase get database => ref.read(databaseProvider);

  @override
  build() async {
    final database = ref.watch(databaseProvider);

    final subscription = database.pluginsTable.select().watch().listen(
      (event) async {
        state = AsyncValue.data(await toStatePlugins(event));
      },
    );

    ref.onDispose(() {
      subscription.cancel();
    });

    final plugins = await database.pluginsTable.select().get();

    final pluginState = await toStatePlugins(plugins);

    await _loadDefaultPlugins(pluginState);

    return pluginState;
  }

  Future<MetadataPluginState> toStatePlugins(
    List<PluginsTableData> plugins,
  ) async {
    int defaultMetadataPlugin = -1;
    int defaultAudioSourcePlugin = -1;
    final pluginConfigs = <PluginConfiguration>[];

    for (int i = 0; i < plugins.length; i++) {
      final plugin = plugins[i];

      final pluginConfig = PluginConfiguration(
        name: plugin.name,
        author: plugin.author,
        description: plugin.description,
        version: plugin.version,
        entryPoint: plugin.entryPoint,
        pluginApiVersion: plugin.pluginApiVersion,
        repository: plugin.repository,
        apis: plugin.apis
            .map(
              (e) => PluginApis.values.firstWhereOrNull(
                (api) => api.name == e,
              ),
            )
            .nonNulls
            .toList(),
        abilities: plugin.abilities
            .map(
              (e) => PluginAbilities.values.firstWhereOrNull(
                (ability) => ability.name == e,
              ),
            )
            .nonNulls
            .toList(),
      );

      final pluginExtractionDir = await _getPluginExtractionDir(pluginConfig);
      final pluginJsonFile =
          File(join(pluginExtractionDir.path, "plugin.json"));
      final pluginBinaryFile =
          File(join(pluginExtractionDir.path, "plugin.out"));

      if (!await pluginExtractionDir.exists() ||
          !await pluginJsonFile.exists() ||
          !await pluginBinaryFile.exists()) {
        // Delete the plugin entry from DB if the plugin files are not there.
        await database.pluginsTable.deleteOne(plugin);
        continue;
      }

      pluginConfigs.add(pluginConfig);

      if (plugin.selectedForMetadata) {
        defaultMetadataPlugin = pluginConfigs.length - 1;
      }
      if (plugin.selectedForAudioSource) {
        defaultAudioSourcePlugin = pluginConfigs.length - 1;
      }
    }

    return MetadataPluginState(
      plugins: pluginConfigs,
      defaultMetadataPlugin: defaultMetadataPlugin,
      defaultAudioSourcePlugin: defaultAudioSourcePlugin,
    );
  }

  Future<void> _loadDefaultPlugins(MetadataPluginState pluginState) async {
    // External .smplug plugins removed — DeeMusiq uses only the native
    // backend provider (kDeeMusiqNativePluginConfig). No assets to load.
  }

  // External .smplug plugin system removed — the following methods are dead.
  // They remain as stubs to avoid breaking imports/compile.

  Uri _getGithubReleasesUrl(String repoUrl) {
    throw UnimplementedError('External plugin system removed');
  }

  Uri _getCodebergeReleasesUrl(String repoUrl) {
    throw UnimplementedError('External plugin system removed');
  }

  Future<String> _getPluginDownloadUrl(Uri uri) async {
    throw UnimplementedError('External plugin system removed');
  }

  Future<PluginConfiguration> extractPluginArchive(List<int> bytes) async {
    throw UnimplementedError('External plugin system removed');
  }

  Future<PluginConfiguration> downloadAndCachePlugin(String url) async {
    throw UnimplementedError('External plugin system removed');
  }

  /// Root directory where all metadata plugins are stored.
  Future<Directory> _getPluginRootDir() async => Directory(
        join(
          (await getApplicationSupportDirectory()).path,
          "metadata-plugins",
        ),
      );

  /// Directory where the plugin will be extracted.
  /// This is a unique directory for each plugin version.
  /// It is used to avoid conflicts when multiple versions of the same plugin are installed
  Future<Directory> _getPluginExtractionDir(PluginConfiguration plugin) async {
    final pluginDir = await _getPluginRootDir();
    final pluginExtractionDirPath = join(
      pluginDir.path,
      "${ServiceUtils.sanitizeFilename(plugin.author)}-${ServiceUtils.sanitizeFilename(plugin.name)}-${plugin.version}",
    );
    return Directory(pluginExtractionDirPath);
  }

  bool validatePluginApiCompatibility(PluginConfiguration plugin) {
    final configPluginApiVersion = Version.parse(plugin.pluginApiVersion);
    final appPluginApiVersion = MetadataPlugin.pluginApiVersion;

    // Plugin API's major version must match the app's major version
    if (configPluginApiVersion.major != appPluginApiVersion.major) {
      return false;
    }
    return configPluginApiVersion >= appPluginApiVersion;
  }

  void _assertPluginApiCompatibility(PluginConfiguration plugin) {
    if (!validatePluginApiCompatibility(plugin)) {
      throw MetadataPluginException.pluginApiVersionMismatch();
    }
  }

  Future<void> addPlugin(PluginConfiguration plugin) async {
    throw UnimplementedError('External plugin system removed');
  }

  Future<void> removePlugin(PluginConfiguration plugin) async {
    throw UnimplementedError('External plugin system removed');
  }

  Future<bool> isPluginUpdate(PluginConfiguration newPlugin) async {
    final pluginRes = await (database.pluginsTable.select()
          ..where(
            (tbl) =>
                tbl.name.equals(newPlugin.name) &
                tbl.author.equals(newPlugin.author),
          )
          ..limit(1))
        .get();

    if (pluginRes.isEmpty) {
      return false;
    }

    final oldPlugin = pluginRes.first;
    final oldPluginApiVersion = Version.parse(oldPlugin.pluginApiVersion);
    final newPluginApiVersion = Version.parse(newPlugin.pluginApiVersion);

    return newPluginApiVersion > oldPluginApiVersion;
  }

  Future<void> updatePlugin(
    PluginConfiguration plugin,
    PluginUpdateAvailable update,
  ) async {
    throw UnimplementedError('External plugin system removed');
  }

  Future<void> setDefaultMetadataPlugin(PluginConfiguration plugin) async {
    assert(
      plugin.abilities.contains(PluginAbilities.metadata),
      "Must be a metadata plugin",
    );

    await database.pluginsTable
        .update()
        .write(const PluginsTableCompanion(selectedForMetadata: Value(false)));

    await (database.pluginsTable.update()
          ..where((tbl) =>
              tbl.name.equals(plugin.name) & tbl.author.equals(plugin.author)))
        .write(
      const PluginsTableCompanion(selectedForMetadata: Value(true)),
    );
  }

  Future<void> setDefaultAudioSourcePlugin(PluginConfiguration plugin) async {
    assert(
      plugin.abilities.contains(PluginAbilities.audioSource),
      "Must be an audio-source plugin",
    );

    await database.pluginsTable.update().write(
        const PluginsTableCompanion(selectedForAudioSource: Value(false)));

    await (database.pluginsTable.update()
          ..where((tbl) =>
              tbl.name.equals(plugin.name) & tbl.author.equals(plugin.author)))
        .write(
      const PluginsTableCompanion(selectedForAudioSource: Value(true)),
    );
  }

  Future<Uint8List> getPluginByteCode(PluginConfiguration plugin) async {
    final pluginExtractionDirPath = await _getPluginExtractionDir(plugin);

    final libraryFile = File(join(pluginExtractionDirPath.path, "plugin.out"));

    if (!libraryFile.existsSync()) {
      throw MetadataPluginException.pluginByteCodeFileNotFound();
    }

    return await libraryFile.readAsBytes();
  }

  Future<File?> getLogoPath(PluginConfiguration plugin) async {
    final pluginExtractionDirPath = await _getPluginExtractionDir(plugin);

    final logoFile = File(join(pluginExtractionDirPath.path, "logo.png"));

    if (!logoFile.existsSync()) {
      return null;
    }

    return logoFile;
  }
}

final metadataPluginsProvider =
    AsyncNotifierProvider<MetadataPluginNotifier, MetadataPluginState>(
  MetadataPluginNotifier.new,
);

// DeeMusiq uses its own built-in, native metadata + audio-source provider that
// talks to the DeeMusiq backend `/metadata` API — no Spotify, no external
// plugin bytecode. Both providers return the native plugin directly.
final metadataPluginProvider = FutureProvider<MetadataPlugin?>(
  (ref) async {
    final youtubeEngine = ref.read(youtubeEngineProvider);
    final allEngines = ref.read(allYouTubeEnginesProvider);
    return MetadataPlugin.native(youtubeEngine, allEngines);
  },
);

final audioSourcePluginProvider = FutureProvider<MetadataPlugin?>(
  (ref) async {
    final youtubeEngine = ref.watch(youtubeEngineProvider);
    final allEngines = ref.read(allYouTubeEnginesProvider);
    return MetadataPlugin.native(youtubeEngine, allEngines);
  },
);
