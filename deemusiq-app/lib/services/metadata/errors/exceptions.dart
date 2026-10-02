enum MetadataPluginErrorCode {
  pluginApiVersionMismatch,
  invalidPluginConfiguration,
  failedToGetReleaseInfo,
  noReleasesFound,
  assetUrlNotFound,
  pluginConfigJsonNotFound,
  unsupportedPluginDownloadWebsite,
  pluginDownloadFailed,
  duplicatePlugin,
  pluginByteCodeFileNotFound,
  noDefaultMetadataPlugin,
  noDefaultAudiSourcePlugin,
  pluginNotFound,
  pluginPermissionDenied,
  pluginUnavailable,
}

/// Thrown when the DeeMusiq backend cannot be reached at the network level
/// (connection refused, connection timeout, DNS/SocketException), as opposed
/// to the backend answering with an HTTP error. Playback code surfaces this
/// as a distinct "couldn't reach DeeMusiq servers" state instead of retrying.
class CatalogOfflineException implements Exception {
  final String message;
  final Object? cause;

  const CatalogOfflineException([
    this.message = "Couldn't reach DeeMusiq servers",
    this.cause,
  ]);

  @override
  String toString() => 'CatalogOfflineException: $message';
}

class MetadataPluginException implements Exception {
  final String message;
  final MetadataPluginErrorCode errorCode;
  final String? pluginId;
  final Map<String, dynamic> details;

  MetadataPluginException._(
    this.message, {
    required this.errorCode,
    this.pluginId,
    this.details = const {},
  });
  MetadataPluginException.pluginApiVersionMismatch({
    String? pluginId,
    String? requestedVersion,
    String? supportedVersion,
  }) : this._(
          'Plugin API version mismatch',
          errorCode: MetadataPluginErrorCode.pluginApiVersionMismatch,
          pluginId: pluginId,
          details: {
            if (pluginId != null) 'pluginId': pluginId,
            if (requestedVersion != null) 'requestedVersion': requestedVersion,
            if (supportedVersion != null) 'supportedVersion': supportedVersion,
          },
        );
  MetadataPluginException.invalidPluginConfiguration({
    String? pluginId,
    String reason = 'invalid_configuration',
    Map<String, dynamic> context = const {},
  }) : this._(
          'Invalid plugin configuration',
          errorCode: MetadataPluginErrorCode.invalidPluginConfiguration,
          pluginId: pluginId,
          details: {
            'reason': reason,
            if (pluginId != null) 'pluginId': pluginId,
            ...context,
          },
        );
  MetadataPluginException.failedToGetRelease({String? pluginId})
      : this._(
          'Failed to get release information',
          errorCode: MetadataPluginErrorCode.failedToGetReleaseInfo,
          pluginId: pluginId,
        );
  MetadataPluginException.noReleasesFound({String? pluginId})
      : this._(
          'No releases found for the plugin',
          errorCode: MetadataPluginErrorCode.noReleasesFound,
          pluginId: pluginId,
        );

  MetadataPluginException.assetUrlNotFound({String? pluginId})
      : this._(
          'No asset URL found for the plugin release',
          errorCode: MetadataPluginErrorCode.assetUrlNotFound,
          pluginId: pluginId,
        );
  MetadataPluginException.pluginConfigJsonNotFound()
      : this._(
          'Plugin configuration JSON, plugin.json file not found',
          errorCode: MetadataPluginErrorCode.pluginConfigJsonNotFound,
        );
  MetadataPluginException.unsupportedPluginDownloadWebsite({String? pluginId})
      : this._(
          'Unsupported plugin download website. Please use GitHub or Codeberg.',
          errorCode: MetadataPluginErrorCode.unsupportedPluginDownloadWebsite,
          pluginId: pluginId,
        );
  MetadataPluginException.pluginDownloadFailed({
    String? pluginId,
    String reason = 'download_failed',
  }) : this._(
          'Failed to download the plugin. Please check your internet connection or try again later.',
          errorCode: MetadataPluginErrorCode.pluginDownloadFailed,
          pluginId: pluginId,
          details: {
            'reason': reason,
            if (pluginId != null) 'pluginId': pluginId,
          },
        );
  MetadataPluginException.duplicatePlugin({String? pluginId})
      : this._(
          'Same plugin already exists with the same name and version.',
          errorCode: MetadataPluginErrorCode.duplicatePlugin,
          pluginId: pluginId,
        );
  MetadataPluginException.pluginByteCodeFileNotFound({String? pluginId})
      : this._(
          'Plugin byte code file, plugin.out not found. Please ensure the plugin is correctly packaged.',
          errorCode: MetadataPluginErrorCode.pluginByteCodeFileNotFound,
          pluginId: pluginId,
        );
  MetadataPluginException.pluginNotFound({
    required String pluginId,
    String? repository,
  }) : this._(
          'Plugin is not registered for compatibility',
          errorCode: MetadataPluginErrorCode.pluginNotFound,
          pluginId: pluginId,
          details: {
            'pluginId': pluginId,
            if (repository != null) 'repository': repository,
          },
        );
  MetadataPluginException.pluginPermissionDenied({
    required String pluginId,
    required String permission,
    String? kind,
  }) : this._(
          'Plugin does not have the required permission',
          errorCode: MetadataPluginErrorCode.pluginPermissionDenied,
          pluginId: pluginId,
          details: {
            'pluginId': pluginId,
            'permission': permission,
            if (kind != null) 'kind': kind,
          },
        );
  MetadataPluginException.pluginUnavailable({
    required String pluginId,
    required String reason,
    Map<String, dynamic> context = const {},
  }) : this._(
          'Plugin is unavailable',
          errorCode: MetadataPluginErrorCode.pluginUnavailable,
          pluginId: pluginId,
          details: {
            'pluginId': pluginId,
            'reason': reason,
            ...context,
          },
        );
  MetadataPluginException.noDefaultMetadataPlugin()
      : this._(
          'No default metadata plugin is set. Please set a default plugin in the settings.',
          errorCode: MetadataPluginErrorCode.noDefaultMetadataPlugin,
        );
  MetadataPluginException.noDefaultAudioSourcePlugin()
      : this._(
          'No default audio source plugin is set. Please set a default plugin in the settings.',
          errorCode: MetadataPluginErrorCode.noDefaultAudiSourcePlugin,
        );

  @override
  String toString() {
    final plugin = pluginId == null ? '' : ' [$pluginId]';
    return 'MetadataPluginException(${errorCode.name})$plugin: $message';
  }
}
