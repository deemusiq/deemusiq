import 'package:deemusiq/models/metadata/metadata.dart';

abstract class MetadataPluginPlaylistEndpoint {
  MetadataPluginPlaylistEndpoint();

  Future<DeeMusiqFullPlaylistObject> getPlaylist(String id);

  Future<DeeMusiqPaginationResponseObject<DeeMusiqFullTrackObject>> tracks(
    String id, {
    int? offset,
    int? limit,
  });

  Future<DeeMusiqFullPlaylistObject?> create(
    String userId, {
    required String name,
    String? description,
    bool? public,
    bool? collaborative,
  });

  Future<void> update(
    String playlistId, {
    String? name,
    String? description,
    bool? public,
    bool? collaborative,
  });

  Future<void> addTracks(
    String playlistId, {
    required List<String> trackIds,
    int? position,
  });

  Future<void> removeTracks(
    String playlistId, {
    required List<String> trackIds,
  });

  Future<void> save(String playlistId);

  Future<void> unsave(String playlistId);

  Future<void> deletePlaylist(String playlistId);
}
