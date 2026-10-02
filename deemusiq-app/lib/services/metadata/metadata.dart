import 'dart:typed_data';

import 'package:pub_semver/pub_semver.dart';

import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/services/metadata/deemusiq_native_plugin.dart';
import 'package:deemusiq/services/metadata/endpoints/album.dart';
import 'package:deemusiq/services/metadata/endpoints/artist.dart';
import 'package:deemusiq/services/metadata/endpoints/audio_source.dart';
import 'package:deemusiq/services/metadata/endpoints/auth.dart';
import 'package:deemusiq/services/metadata/endpoints/browse.dart';
import 'package:deemusiq/services/metadata/endpoints/playlist.dart';
import 'package:deemusiq/services/metadata/endpoints/search.dart';
import 'package:deemusiq/services/metadata/endpoints/track.dart';
import 'package:deemusiq/services/metadata/endpoints/user.dart';
import 'package:deemusiq/services/metadata/endpoints/core.dart';
import 'package:deemusiq/services/metadata/errors/exceptions.dart';
import 'package:deemusiq/services/youtube_engine/youtube_engine.dart';

const defaultMetadataLimit = "20";

class MetadataPlugin {
  static final pluginApiVersion = Version.parse("2.0.0");

  static Future<MetadataPlugin> create(
    YouTubeEngine youtubeEngine,
    PluginConfiguration config,
    Uint8List byteCode,
  ) async {
    return MetadataPluginCompatibilityRegistry.resolve(
      config,
      youtubeEngine,
      [youtubeEngine],
    );
  }

  late final MetadataAuthEndpoint auth;

  late final MetadataPluginAudioSourceEndpoint audioSource;
  late final MetadataPluginAlbumEndpoint album;
  late final MetadataPluginArtistEndpoint artist;
  late final MetadataPluginBrowseEndpoint browse;
  late final MetadataPluginSearchEndpoint search;
  late final MetadataPluginPlaylistEndpoint playlist;
  late final MetadataPluginTrackEndpoint track;
  late final MetadataPluginUserEndpoint user;
  late final MetadataPluginCore core;

  /// DeeMusiq's built-in metadata provider: every endpoint is native Dart
  /// talking to the DeeMusiq backend `/metadata` API (no Spotify, no Hetu
  /// bytecode). This is what the app uses by default.
  MetadataPlugin.native(
      YouTubeEngine youtubeEngine, List<YouTubeEngine> allEngines) {
    final n = DeeMusiqNativeEndpoints(youtubeEngine, allEngines);
    auth = n.auth;
    audioSource = n.audioSource;
    artist = n.artist;
    album = n.album;
    browse = n.browse;
    search = n.search;
    playlist = n.playlist;
    track = n.track;
    user = n.user;
    core = n.core;
  }
}

class _MetadataPluginCompatibilityRegistration {
  final String name;
  final String author;
  final String entryPoint;
  final String? repository;
  final VersionConstraint versions;
  final Set<PluginApis> apis;
  final Set<PluginAbilities> abilities;

  const _MetadataPluginCompatibilityRegistration({
    required this.name,
    required this.author,
    required this.entryPoint,
    required this.repository,
    required this.versions,
    required this.apis,
    required this.abilities,
  });
}

class MetadataPluginCompatibilityRegistry {
  MetadataPluginCompatibilityRegistry._();

  static const nativePluginId = 'deemusiq-native';
  static const youtubeAudioPluginId = 'spotube-plugin-youtube-audio';
  static const musicBrainzPluginId = 'spotube-plugin-musicbrainz-listenbrainz';
  static const _repositoryOwner = 'krtirtho';
  static final _legacyVersion =
      VersionConstraint.compatibleWith(Version.parse('1.0.0'));
  static final Map<String, _MetadataPluginCompatibilityRegistration>
      _registrations = {
    nativePluginId: _MetadataPluginCompatibilityRegistration(
      name: kDeeMusiqNativePluginConfig.name,
      author: kDeeMusiqNativePluginConfig.author,
      entryPoint: kDeeMusiqNativePluginConfig.entryPoint,
      repository: null,
      versions: _legacyVersion,
      apis: const {},
      abilities: const {
        PluginAbilities.metadata,
        PluginAbilities.audioSource,
      },
    ),
    youtubeAudioPluginId: _MetadataPluginCompatibilityRegistration(
      name: 'YouTube Audio',
      author: 'Kingkor Roy Tirtho',
      entryPoint: 'YouTubeAudioSourcePlugin',
      repository: 'https://github.com/KRTirtho/spotube-plugin-youtube-audio',
      versions: _legacyVersion,
      apis: const {PluginApis.localstorage},
      abilities: const {PluginAbilities.audioSource},
    ),
    musicBrainzPluginId: _MetadataPluginCompatibilityRegistration(
      name: 'Musicbrainz and Listenbrainz',
      author: 'Kingkor Roy Tirtho',
      entryPoint: 'BrainzMetadataProviderPlugin',
      repository:
          'https://github.com/KRTirtho/spotube-plugin-musicbrainz-listenbrainz',
      versions: _legacyVersion,
      apis: const {
        PluginApis.webview,
        PluginApis.localstorage,
        PluginApis.timezone,
      },
      abilities: const {
        PluginAbilities.authentication,
        PluginAbilities.scrobbling,
        PluginAbilities.metadata,
      },
    ),
  };

  static Set<String> get pluginIds => _registrations.keys.toSet();

  static bool contains(String pluginId) =>
      _registrations.containsKey(pluginId.toLowerCase());

  static bool isNative(PluginConfiguration config) {
    final registration = _registrationFor(config);
    return registration != null &&
        _registrations[nativePluginId] == registration &&
        _matchesIdentity(config, registration);
  }

  static bool isApiCompatible(String version) {
    try {
      final pluginVersion = Version.parse(version);
      return pluginVersion.major == MetadataPlugin.pluginApiVersion.major &&
          pluginVersion >= MetadataPlugin.pluginApiVersion;
    } catch (_) {
      return false;
    }
  }

  static String? pluginIdForRepository(Uri repository) {
    if (repository.scheme != 'https' || repository.userInfo.isNotEmpty) {
      return null;
    }
    final host = repository.host.toLowerCase();
    if (host != 'github.com' && host != 'codeberg.org') return null;
    if (repository.pathSegments.length < 2) return null;
    if (repository.pathSegments.first.toLowerCase() != _repositoryOwner) {
      return null;
    }
    return repository.pathSegments[1].toLowerCase();
  }

  static String identify(PluginConfiguration config) {
    final repository = _repositoryUri(config.repository);
    final repositoryId =
        repository == null ? null : pluginIdForRepository(repository);
    if (repositoryId != null && contains(repositoryId)) return repositoryId;
    if (_matchesIdentity(
      config,
      _registrations[nativePluginId]!,
    )) {
      return nativePluginId;
    }
    return repositoryId ?? config.slug;
  }

  static String validate(
    PluginConfiguration config, {
    PluginAbilities? requiredAbility,
  }) {
    final pluginId = identify(config);
    final registration = _registrationFor(config);
    if (registration == null) {
      if (config.repository != null &&
          _repositoryUri(config.repository) == null) {
        throw MetadataPluginException.invalidPluginConfiguration(
          pluginId: pluginId,
          reason: 'invalid_plugin_id',
          context: {'repository': config.repository},
        );
      }
      throw MetadataPluginException.pluginNotFound(
        pluginId: pluginId,
        repository: config.repository,
      );
    }
    if (!_matchesIdentity(config, registration)) {
      throw MetadataPluginException.invalidPluginConfiguration(
        pluginId: pluginId,
        reason: 'plugin_identity_mismatch',
      );
    }

    final Version version;
    try {
      version = Version.parse(config.version);
    } catch (_) {
      throw MetadataPluginException.invalidPluginConfiguration(
        pluginId: pluginId,
        reason: 'invalid_plugin_version',
        context: {'version': config.version},
      );
    }
    if (!registration.versions.allows(version)) {
      throw MetadataPluginException.pluginUnavailable(
        pluginId: pluginId,
        reason: 'unsupported_plugin_version',
        context: {
          'version': config.version,
          'supportedVersions': registration.versions.toString(),
        },
      );
    }
    if (!isApiCompatible(config.pluginApiVersion)) {
      throw MetadataPluginException.pluginApiVersionMismatch(
        pluginId: pluginId,
        requestedVersion: config.pluginApiVersion,
        supportedVersion: MetadataPlugin.pluginApiVersion.toString(),
      );
    }
    for (final api in config.apis) {
      if (!registration.apis.contains(api)) {
        throw MetadataPluginException.pluginPermissionDenied(
          pluginId: pluginId,
          permission: api.name,
          kind: 'api',
        );
      }
    }
    for (final ability in config.abilities) {
      if (!registration.abilities.contains(ability)) {
        throw MetadataPluginException.pluginPermissionDenied(
          pluginId: pluginId,
          permission: ability.name,
          kind: 'ability',
        );
      }
    }
    if (requiredAbility != null &&
        !config.abilities.contains(requiredAbility)) {
      throw MetadataPluginException.pluginPermissionDenied(
        pluginId: pluginId,
        permission: requiredAbility.name,
        kind: 'ability',
      );
    }
    return pluginId;
  }

  static MetadataPlugin resolve(
    PluginConfiguration config,
    YouTubeEngine youtubeEngine,
    List<YouTubeEngine> allEngines, {
    PluginAbilities? requiredAbility,
  }) {
    validate(config, requiredAbility: requiredAbility);
    return MetadataPlugin.native(youtubeEngine, allEngines);
  }

  static _MetadataPluginCompatibilityRegistration? _registrationFor(
    PluginConfiguration config,
  ) {
    final repository = _repositoryUri(config.repository);
    final repositoryId =
        repository == null ? null : pluginIdForRepository(repository);
    if (repositoryId != null) return _registrations[repositoryId];
    if (_matchesIdentity(config, _registrations[nativePluginId]!)) {
      return _registrations[nativePluginId];
    }
    return null;
  }

  static Uri? _repositoryUri(String? repository) {
    if (repository == null) return null;
    final uri = Uri.tryParse(repository);
    if (uri == null ||
        uri.pathSegments.length != 2 ||
        pluginIdForRepository(uri) == null) {
      return null;
    }
    return uri;
  }

  static bool _matchesIdentity(
    PluginConfiguration config,
    _MetadataPluginCompatibilityRegistration registration,
  ) {
    if (config.name != registration.name ||
        config.author != registration.author ||
        config.entryPoint != registration.entryPoint) {
      return false;
    }
    final repository = _repositoryUri(config.repository);
    final configuredRepository = registration.repository;
    if (configuredRepository == null) return repository == null;
    return repository != null &&
        _normalizeRepository(repository) ==
            _normalizeRepository(Uri.parse(configuredRepository));
  }

  static String _normalizeRepository(Uri repository) {
    final host = repository.host.toLowerCase();
    return '$host/${repository.pathSegments[0].toLowerCase()}/'
        '${repository.pathSegments[1].toLowerCase()}';
  }
}
