import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/database/database.dart';
import 'package:deemusiq/provider/youtube_engine/youtube_engine.dart';
import 'package:deemusiq/services/dio/dio.dart';
import 'package:deemusiq/services/metadata/errors/exceptions.dart';
import 'package:deemusiq/services/metadata/metadata.dart';
import 'package:deemusiq/services/metadata/deemusiq_native_plugin.dart';
import 'package:deemusiq/utils/service_utils.dart';
import 'package:pub_semver/pub_semver.dart';

final allowedDomainsRegex = RegExp(
  r"^(https?:\/\/)?(www\.)?(github\.com|codeberg\.org)\/.+",
);

const _maxPluginArchiveBytes = 5 * 1024 * 1024;
const _maxPluginPayloadBytes = 10 * 1024 * 1024;
const _maxPluginManifestBytes = 64 * 1024;
const _maxPluginByteCodeBytes = 5 * 1024 * 1024;
const _maxPluginLogoBytes = 5 * 1024 * 1024;
const _maxPluginArchiveEntries = 8;
const _allowedPluginFiles = {
  'plugin.json',
  'plugin.out',
  'logo.png',
};

class MetadataPluginState {
  final List<PluginConfiguration> plugins;
  final int defaultMetadataPlugin;
  final int defaultAudioSourcePlugin;

  const MetadataPluginState({
    this.plugins = const [],
    this.defaultMetadataPlugin = -1,
    this.defaultAudioSourcePlugin = -1,
  });

  PluginConfiguration? get defaultMetadataPluginConfig =>
      _pluginAt(defaultMetadataPlugin) ?? kDeeMusiqNativePluginConfig;

  PluginConfiguration? get defaultAudioSourcePluginConfig =>
      _pluginAt(defaultAudioSourcePlugin) ?? kDeeMusiqNativePluginConfig;

  PluginConfiguration? _pluginAt(int index) {
    if (index < 0 || index >= plugins.length) return null;
    return plugins[index];
  }

  factory MetadataPluginState.fromJson(Map<String, dynamic> json) {
    return MetadataPluginState(
      plugins: (json["plugins"] as List<dynamic>)
          .map((e) => PluginConfiguration.fromJson(e))
          .toList(),
      defaultMetadataPlugin: json["default_metadata_plugin"] ?? -1,
      defaultAudioSourcePlugin: json['default_audio_source_plugin'] ?? -1,
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
  Future<MetadataPluginState> build() async {
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

    for (final plugin in plugins) {
      final apis = <PluginApis>[];
      for (final apiName in plugin.apis) {
        final api = PluginApis.values.firstWhereOrNull(
          (value) => value.name == apiName,
        );
        if (api == null) {
          throw MetadataPluginException.invalidPluginConfiguration(
            pluginId: plugin.name,
            reason: 'unknown_plugin_api',
            context: {'api': apiName},
          );
        }
        apis.add(api);
      }
      final abilities = <PluginAbilities>[];
      for (final abilityName in plugin.abilities) {
        final ability = PluginAbilities.values.firstWhereOrNull(
          (value) => value.name == abilityName,
        );
        if (ability == null) {
          throw MetadataPluginException.invalidPluginConfiguration(
            pluginId: plugin.name,
            reason: 'unknown_plugin_ability',
            context: {'ability': abilityName},
          );
        }
        abilities.add(ability);
      }
      final pluginConfig = PluginConfiguration(
        name: plugin.name,
        author: plugin.author,
        description: plugin.description,
        version: plugin.version,
        entryPoint: plugin.entryPoint,
        pluginApiVersion: plugin.pluginApiVersion,
        repository: plugin.repository,
        apis: apis,
        abilities: abilities,
      );

      if (plugin.selectedForMetadata) {
        MetadataPluginCompatibilityRegistry.validate(
          pluginConfig,
          requiredAbility: PluginAbilities.metadata,
        );
      }
      if (plugin.selectedForAudioSource) {
        MetadataPluginCompatibilityRegistry.validate(
          pluginConfig,
          requiredAbility: PluginAbilities.audioSource,
        );
      }
      final pluginId =
          MetadataPluginCompatibilityRegistry.validate(pluginConfig);

      if (!MetadataPluginCompatibilityRegistry.isNative(pluginConfig)) {
        final pluginExtractionDir = await _getPluginExtractionDir(pluginConfig);
        final pluginJsonFile =
            File(join(pluginExtractionDir.path, 'plugin.json'));
        final pluginBinaryFile =
            File(join(pluginExtractionDir.path, 'plugin.out'));

        if (!await pluginExtractionDir.exists() ||
            !await pluginJsonFile.exists() ||
            !await pluginBinaryFile.exists()) {
          throw MetadataPluginException.pluginUnavailable(
            pluginId: pluginId,
            reason: 'cached_plugin_files_missing',
            context: {
              'version': pluginConfig.version,
            },
          );
        }
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

  Future<void> _loadDefaultPlugins(MetadataPluginState pluginState) async {}

  Uri _getGithubReleasesUrl(Uri repository) {
    return Uri(
      scheme: 'https',
      host: 'api.github.com',
      pathSegments: [
        'repos',
        ...repository.pathSegments.take(2),
        'releases',
      ],
      queryParameters: const {
        'per_page': '1',
        'page': '1',
      },
    );
  }

  Uri _getCodebergeReleasesUrl(Uri repository) {
    return Uri(
      scheme: 'https',
      host: repository.host,
      pathSegments: [
        'api',
        'v1',
        'repos',
        ...repository.pathSegments.take(2),
        'releases',
      ],
      queryParameters: const {
        'limit': '1',
        'page': '1',
      },
    );
  }

  Future<String> _getPluginDownloadUrl(Uri uri, String pluginId) async {
    final Response<dynamic> response;
    try {
      response = await globalDio.getUri<dynamic>(
        uri,
        options: Options(responseType: ResponseType.json),
      );
    } on DioException {
      throw MetadataPluginException.failedToGetRelease(pluginId: pluginId);
    }

    if (response.statusCode != 200 || response.data is! List) {
      throw MetadataPluginException.failedToGetRelease(pluginId: pluginId);
    }
    final releases = response.data as List<dynamic>;
    if (releases.isEmpty) {
      throw MetadataPluginException.noReleasesFound(pluginId: pluginId);
    }
    for (final release in releases) {
      if (release is! Map) continue;
      final assets = release['assets'];
      if (assets is! List) continue;
      for (final asset in assets) {
        if (asset is! Map) continue;
        final name = asset['name'];
        final value = asset['browser_download_url'];
        if (name is! String ||
            !name.toLowerCase().endsWith('.smplug') ||
            value is! String) {
          continue;
        }
        final downloadUri = Uri.tryParse(value);
        if (downloadUri != null &&
            downloadUri.scheme == 'https' &&
            (downloadUri.host.toLowerCase() == 'github.com' ||
                downloadUri.host.toLowerCase() == 'codeberg.org')) {
          return value;
        }
      }
    }
    throw MetadataPluginException.assetUrlNotFound(pluginId: pluginId);
  }

  Future<Directory> _getPluginRootDir() async => Directory(
        join(
          (await getApplicationSupportDirectory()).path,
          'metadata-plugins',
        ),
      );

  Future<Directory> _getPluginExtractionDir(PluginConfiguration plugin) async {
    MetadataPluginCompatibilityRegistry.validate(plugin);
    final pluginDir = await _getPluginRootDir();
    final pluginExtractionDirPath = join(
      pluginDir.path,
      '${ServiceUtils.sanitizeFilename(plugin.author)}-${ServiceUtils.sanitizeFilename(plugin.name)}-${plugin.version}',
    );
    return Directory(pluginExtractionDirPath);
  }

  Future<PluginConfiguration> extractPluginArchive(List<int> bytes) async {
    if (bytes.isEmpty || bytes.length > _maxPluginArchiveBytes) {
      throw MetadataPluginException.pluginUnavailable(
        pluginId: 'unknown',
        reason:
            bytes.isEmpty ? 'empty_plugin_archive' : 'plugin_archive_too_large',
        context: {'size': bytes.length},
      );
    }

    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      throw MetadataPluginException.pluginUnavailable(
        pluginId: 'unknown',
        reason: 'invalid_plugin_archive',
      );
    }
    if (archive.length > _maxPluginArchiveEntries) {
      throw MetadataPluginException.pluginUnavailable(
        pluginId: 'unknown',
        reason: 'too_many_plugin_archive_entries',
        context: {'entries': archive.length},
      );
    }

    final contents = <String, List<int>>{};
    var totalSize = 0;
    for (final file in archive) {
      if (!_isSafePluginArchivePath(file.name)) {
        throw MetadataPluginException.invalidPluginConfiguration(
          pluginId: 'unknown',
          reason: 'unsafe_plugin_archive_path',
          context: {'entry': file.name},
        );
      }
      if (!file.isFile) continue;
      if (file.isSymbolicLink ||
          !_allowedPluginFiles.contains(file.name) ||
          contents.containsKey(file.name)) {
        throw MetadataPluginException.invalidPluginConfiguration(
          pluginId: 'unknown',
          reason: 'unsupported_plugin_archive_entry',
          context: {'entry': file.name},
        );
      }
      final maxSize = switch (file.name) {
        'plugin.json' => _maxPluginManifestBytes,
        'plugin.out' => _maxPluginByteCodeBytes,
        'logo.png' => _maxPluginLogoBytes,
        _ => 0,
      };
      if (file.size > maxSize) {
        throw MetadataPluginException.pluginUnavailable(
          pluginId: 'unknown',
          reason: 'plugin_archive_entry_too_large',
          context: {'entry': file.name, 'size': file.size},
        );
      }
      totalSize += file.size;
      if (totalSize > _maxPluginPayloadBytes) {
        throw MetadataPluginException.pluginUnavailable(
          pluginId: 'unknown',
          reason: 'plugin_payload_too_large',
          context: {'size': totalSize},
        );
      }
      contents[file.name] = file.content;
    }

    final pluginJson = contents['plugin.json'];
    final pluginByteCode = contents['plugin.out'];
    if (pluginJson == null) {
      throw MetadataPluginException.pluginConfigJsonNotFound();
    }
    if (pluginByteCode == null) {
      throw MetadataPluginException.pluginUnavailable(
        pluginId: 'unknown',
        reason: 'plugin_bytecode_missing',
      );
    }

    final PluginConfiguration pluginConfig;
    try {
      final decoded = jsonDecode(utf8.decode(pluginJson));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('plugin.json must contain an object');
      }
      pluginConfig = PluginConfiguration.fromJson(decoded);
    } catch (_) {
      throw MetadataPluginException.invalidPluginConfiguration(
        pluginId: 'unknown',
        reason: 'invalid_plugin_manifest',
      );
    }
    MetadataPluginCompatibilityRegistry.validate(pluginConfig);

    final extractionDirectory = await _getPluginExtractionDir(pluginConfig);
    final temporaryDirectory = Directory('${extractionDirectory.path}.tmp');
    try {
      if (await temporaryDirectory.exists()) {
        await temporaryDirectory.delete(recursive: true);
      }
      await temporaryDirectory.create(recursive: true);
      for (final entry in contents.entries) {
        await File(join(temporaryDirectory.path, entry.key))
            .writeAsBytes(entry.value, flush: true);
      }
      if (await extractionDirectory.exists()) {
        await extractionDirectory.delete(recursive: true);
      }
      await temporaryDirectory.rename(extractionDirectory.path);
      return pluginConfig;
    } catch (failure) {
      Object? cleanupFailure;
      try {
        if (await temporaryDirectory.exists()) {
          await temporaryDirectory.delete(recursive: true);
        }
      } catch (error) {
        cleanupFailure = error;
      }
      throw MetadataPluginException.pluginUnavailable(
        pluginId: MetadataPluginCompatibilityRegistry.identify(pluginConfig),
        reason: 'plugin_cache_write_failed',
        context: {
          'cause': failure.runtimeType.toString(),
          if (cleanupFailure != null)
            'cleanupCause': cleanupFailure.runtimeType.toString(),
        },
      );
    }
  }

  Future<PluginConfiguration> downloadAndCachePlugin(String url) async {
    final requestedUri = Uri.tryParse(url);
    if (requestedUri == null || requestedUri.scheme != 'https') {
      throw MetadataPluginException.unsupportedPluginDownloadWebsite();
    }
    final pluginId = MetadataPluginCompatibilityRegistry.pluginIdForRepository(
      requestedUri,
    );
    if (pluginId == null ||
        !MetadataPluginCompatibilityRegistry.contains(pluginId)) {
      throw MetadataPluginException.pluginNotFound(
        pluginId: pluginId ??
            MetadataPluginCompatibilityRegistry.identify(
              PluginConfiguration(
                name: 'unknown',
                description: '',
                version: '0.0.0',
                author: 'unknown',
                entryPoint: '',
                pluginApiVersion: '0.0.0',
                repository: url,
              ),
            ),
        repository: url,
      );
    }

    final segments = requestedUri.pathSegments;
    final isRepositoryPage = segments.length == 2 ||
        (segments.length == 3 && segments[2] == 'releases');
    final isDirectArchive = requestedUri.path.toLowerCase().endsWith('.smplug');
    if (!isRepositoryPage && !isDirectArchive) {
      throw MetadataPluginException.assetUrlNotFound(pluginId: pluginId);
    }

    final downloadUri = isRepositoryPage
        ? Uri.parse(
            await _getPluginDownloadUrl(
              requestedUri.host.toLowerCase() == 'github.com'
                  ? _getGithubReleasesUrl(requestedUri)
                  : _getCodebergeReleasesUrl(requestedUri),
              pluginId,
            ),
          )
        : requestedUri;

    final Response<List<int>> response;
    try {
      response = await globalDio.getUri<List<int>>(
        downloadUri,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
    } on DioException {
      throw MetadataPluginException.pluginDownloadFailed(pluginId: pluginId);
    }

    final data = response.data;
    if ((response.statusCode ?? 500) < 200 ||
        (response.statusCode ?? 500) > 299 ||
        data is! List<int>) {
      throw MetadataPluginException.pluginDownloadFailed(pluginId: pluginId);
    }
    if (data.isEmpty || data.length > _maxPluginArchiveBytes) {
      throw MetadataPluginException.pluginDownloadFailed(
        pluginId: pluginId,
        reason: data.isEmpty ? 'empty_download' : 'download_too_large',
      );
    }
    return extractPluginArchive(data);
  }

  bool validatePluginApiCompatibility(PluginConfiguration plugin) {
    return MetadataPluginCompatibilityRegistry.isApiCompatible(
      plugin.pluginApiVersion,
    );
  }

  String _assertPluginCompatibility(
    PluginConfiguration plugin, {
    PluginAbilities? requiredAbility,
  }) {
    return MetadataPluginCompatibilityRegistry.validate(
      plugin,
      requiredAbility: requiredAbility,
    );
  }

  Future<void> addPlugin(PluginConfiguration plugin) async {
    final pluginId = _assertPluginCompatibility(plugin);
    if (!plugin.abilities.contains(PluginAbilities.metadata) &&
        !plugin.abilities.contains(PluginAbilities.audioSource)) {
      throw MetadataPluginException.pluginPermissionDenied(
        pluginId: pluginId,
        permission: 'metadata|audio-source',
        kind: 'ability',
      );
    }

    if (!MetadataPluginCompatibilityRegistry.isNative(plugin)) {
      final pluginDirectory = await _getPluginExtractionDir(plugin);
      final manifest = File(join(pluginDirectory.path, 'plugin.json'));
      final byteCode = File(join(pluginDirectory.path, 'plugin.out'));
      if (!await manifest.exists() || !await byteCode.exists()) {
        throw MetadataPluginException.pluginUnavailable(
          pluginId: pluginId,
          reason: 'cached_plugin_files_missing',
        );
      }
    }

    final pluginRes = await (database.pluginsTable.select()
          ..where(
            (tbl) =>
                tbl.name.equals(plugin.name) & tbl.author.equals(plugin.author),
          )
          ..limit(1))
        .get();

    if (pluginRes.isNotEmpty) {
      throw MetadataPluginException.duplicatePlugin(pluginId: pluginId);
    }

    await database.pluginsTable.insertOne(
      PluginsTableCompanion.insert(
        name: plugin.name,
        author: plugin.author,
        description: plugin.description,
        version: plugin.version,
        entryPoint: plugin.entryPoint,
        apis: plugin.apis.map((e) => e.name).toList(),
        abilities: plugin.abilities.map((e) => e.name).toList(),
        pluginApiVersion: Value(plugin.pluginApiVersion),
        repository: Value(plugin.repository),
        selectedForMetadata: Value(
          (state.valueOrNull?.plugins
                      .where(
                          (d) => d.abilities.contains(PluginAbilities.metadata))
                      .isEmpty ??
                  true) &&
              plugin.abilities.contains(PluginAbilities.metadata),
        ),
        selectedForAudioSource: Value(
          (state.valueOrNull?.plugins
                      .where((d) =>
                          d.abilities.contains(PluginAbilities.audioSource))
                      .isEmpty ??
                  true) &&
              plugin.abilities.contains(PluginAbilities.audioSource),
        ),
      ),
    );
  }

  Future<void> removePlugin(PluginConfiguration plugin) async {
    final pluginId = _assertPluginCompatibility(plugin);
    if (!MetadataPluginCompatibilityRegistry.isNative(plugin)) {
      final pluginExtractionDir = await _getPluginExtractionDir(plugin);
      try {
        if (await pluginExtractionDir.exists()) {
          await pluginExtractionDir.delete(recursive: true);
        }
      } catch (_) {
        throw MetadataPluginException.pluginUnavailable(
          pluginId: pluginId,
          reason: 'plugin_cache_delete_failed',
        );
      }
    }
    await database.pluginsTable.deleteWhere((tbl) =>
        tbl.name.equals(plugin.name) & tbl.author.equals(plugin.author));

    if (state.valueOrNull?.defaultMetadataPluginConfig == plugin) {
      final remainingPlugins = state.valueOrNull?.plugins.where(
            (p) =>
                p != plugin && p.abilities.contains(PluginAbilities.metadata),
          ) ??
          [];
      if (remainingPlugins.length == 1) {
        await setDefaultMetadataPlugin(remainingPlugins.first);
      }
    }

    if (state.valueOrNull?.defaultAudioSourcePluginConfig == plugin) {
      final remainingPlugins = state.valueOrNull?.plugins.where(
            (p) =>
                p != plugin &&
                p.abilities.contains(PluginAbilities.audioSource),
          ) ??
          [];
      if (remainingPlugins.length == 1) {
        await setDefaultAudioSourcePlugin(remainingPlugins.first);
      }
    }
  }

  Future<bool> isPluginUpdate(PluginConfiguration newPlugin) async {
    _assertPluginCompatibility(newPlugin);
    final pluginRes = await (database.pluginsTable.select()
          ..where(
            (tbl) =>
                tbl.name.equals(newPlugin.name) &
                tbl.author.equals(newPlugin.author),
          )
          ..limit(1))
        .get();

    if (pluginRes.isEmpty) return false;

    final oldPlugin = pluginRes.first;
    final Version oldVersion;
    final Version newVersion;
    try {
      oldVersion = Version.parse(oldPlugin.version);
      newVersion = Version.parse(newPlugin.version);
    } catch (_) {
      throw MetadataPluginException.invalidPluginConfiguration(
        pluginId: MetadataPluginCompatibilityRegistry.identify(newPlugin),
        reason: 'invalid_plugin_version',
      );
    }
    return newVersion > oldVersion;
  }

  Future<void> updatePlugin(
    PluginConfiguration plugin,
    PluginUpdateAvailable update,
  ) async {
    _assertPluginCompatibility(plugin);
    final Version currentVersion;
    final Version updateVersion;
    try {
      currentVersion = Version.parse(plugin.version);
      updateVersion = Version.parse(update.version);
    } catch (_) {
      throw MetadataPluginException.invalidPluginConfiguration(
        pluginId: MetadataPluginCompatibilityRegistry.identify(plugin),
        reason: 'invalid_update_version',
        context: {'version': update.version},
      );
    }
    if (updateVersion <= currentVersion) {
      throw MetadataPluginException.pluginUnavailable(
        pluginId: MetadataPluginCompatibilityRegistry.identify(plugin),
        reason: 'update_not_newer',
        context: {
          'currentVersion': currentVersion.toString(),
          'updateVersion': updateVersion.toString(),
        },
      );
    }

    final isDefaultMetadata =
        plugin == state.valueOrNull?.defaultMetadataPluginConfig;
    final isDefaultAudioSource =
        plugin == state.valueOrNull?.defaultAudioSourcePluginConfig;
    final pluginUpdatedConfig =
        await downloadAndCachePlugin(update.downloadUrl);

    if (pluginUpdatedConfig.name != plugin.name ||
        pluginUpdatedConfig.author != plugin.author ||
        Version.parse(pluginUpdatedConfig.version) != updateVersion) {
      throw MetadataPluginException.invalidPluginConfiguration(
        pluginId: MetadataPluginCompatibilityRegistry.identify(plugin),
        reason: 'update_identity_or_version_mismatch',
      );
    }
    _assertPluginCompatibility(pluginUpdatedConfig);

    await removePlugin(plugin);
    await addPlugin(pluginUpdatedConfig);

    if (isDefaultMetadata) {
      await setDefaultMetadataPlugin(pluginUpdatedConfig);
    }
    if (isDefaultAudioSource) {
      await setDefaultAudioSourcePlugin(pluginUpdatedConfig);
    }
  }

  Future<void> setDefaultMetadataPlugin(PluginConfiguration plugin) async {
    final pluginId = _assertPluginCompatibility(
      plugin,
      requiredAbility: PluginAbilities.metadata,
    );
    final installed = await (database.pluginsTable.select()
          ..where((tbl) =>
              tbl.name.equals(plugin.name) & tbl.author.equals(plugin.author))
          ..limit(1))
        .getSingleOrNull();
    if (installed == null) {
      throw MetadataPluginException.pluginUnavailable(
        pluginId: pluginId,
        reason: 'plugin_not_installed',
      );
    }

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
    final pluginId = _assertPluginCompatibility(
      plugin,
      requiredAbility: PluginAbilities.audioSource,
    );
    final installed = await (database.pluginsTable.select()
          ..where((tbl) =>
              tbl.name.equals(plugin.name) & tbl.author.equals(plugin.author))
          ..limit(1))
        .getSingleOrNull();
    if (installed == null) {
      throw MetadataPluginException.pluginUnavailable(
        pluginId: pluginId,
        reason: 'plugin_not_installed',
      );
    }

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
    final pluginId = _assertPluginCompatibility(plugin);
    final pluginExtractionDirPath = await _getPluginExtractionDir(plugin);

    final libraryFile = File(join(pluginExtractionDirPath.path, 'plugin.out'));

    if (!await libraryFile.exists()) {
      throw MetadataPluginException.pluginByteCodeFileNotFound(
        pluginId: pluginId,
      );
    }

    try {
      return await libraryFile.readAsBytes();
    } catch (_) {
      throw MetadataPluginException.pluginUnavailable(
        pluginId: pluginId,
        reason: 'plugin_bytecode_read_failed',
      );
    }
  }

  Future<File?> getLogoPath(PluginConfiguration plugin) async {
    _assertPluginCompatibility(plugin);
    if (MetadataPluginCompatibilityRegistry.isNative(plugin)) return null;
    final pluginExtractionDirPath = await _getPluginExtractionDir(plugin);
    final logoFile = File(join(pluginExtractionDirPath.path, 'logo.png'));
    return await logoFile.exists() ? logoFile : null;
  }

  static bool _isSafePluginArchivePath(String path) {
    if (path.isEmpty || path.contains('\\') || isAbsolute(path)) return false;
    return path.split('/').every(
          (segment) => segment.isNotEmpty && segment != '.' && segment != '..',
        );
  }
}

final metadataPluginsProvider =
    AsyncNotifierProvider<MetadataPluginNotifier, MetadataPluginState>(
  MetadataPluginNotifier.new,
);

final metadataPluginProvider = FutureProvider<MetadataPlugin?>(
  (ref) async {
    final defaultPlugin = await ref.watch(
      metadataPluginsProvider
          .selectAsync((data) => data.defaultMetadataPluginConfig),
    );
    if (defaultPlugin == null) return null;
    final youtubeEngine = ref.read(youtubeEngineProvider);
    final allEngines = ref.read(allYouTubeEnginesProvider);
    return MetadataPluginCompatibilityRegistry.resolve(
      defaultPlugin,
      youtubeEngine,
      allEngines,
      requiredAbility: PluginAbilities.metadata,
    );
  },
);

final audioSourcePluginProvider = FutureProvider<MetadataPlugin?>(
  (ref) async {
    final defaultPlugin = await ref.watch(
      metadataPluginsProvider
          .selectAsync((data) => data.defaultAudioSourcePluginConfig),
    );
    if (defaultPlugin == null) return null;
    final youtubeEngine = ref.watch(youtubeEngineProvider);
    final allEngines = ref.read(allYouTubeEnginesProvider);
    return MetadataPluginCompatibilityRegistry.resolve(
      defaultPlugin,
      youtubeEngine,
      allEngines,
      requiredAbility: PluginAbilities.audioSource,
    );
  },
);
