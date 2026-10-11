import 'package:deemusiq/models/metadata/metadata.dart';

abstract class MetadataPluginCore {
  MetadataPluginCore();

  Future<PluginUpdateAvailable?> checkUpdate(
    PluginConfiguration pluginConfig,
  );

  Future<String> get support;

  /// [details] is a map containing the scrobble information, such as:
  /// - [id] -> The unique identifier of the track.
  /// - [title] -> The title of the track.
  /// - [artists] -> List of artists
  ///   - [id] -> The unique identifier of the artist.
  ///   - [name] -> The name of the artist.
  /// - [album] -> The album of the track
  ///   - [id] -> The unique identifier of the album.
  ///   - [name] -> The name of the album.
  /// - [timestamp] -> The timestamp of the scrobble (optional).
  /// - [duration_ms] -> The duration of the track in milliseconds (optional).
  /// - [isrc] -> The ISRC code of the track (optional).
  Future<void> scrobble(Map<String, dynamic> details);
}
