import 'package:deemusiq/models/metadata/metadata.dart';

abstract class MetadataPluginUserEndpoint {
  MetadataPluginUserEndpoint();

  Future<DeeMusiqUserObject> me();

  Future<DeeMusiqPaginationResponseObject<DeeMusiqFullTrackObject>> savedTracks({
    int? offset,
    int? limit,
  });

  Future<DeeMusiqPaginationResponseObject<DeeMusiqSimplePlaylistObject>>
      savedPlaylists({
    int? offset,
    int? limit,
  });

  Future<DeeMusiqPaginationResponseObject<DeeMusiqSimpleAlbumObject>>
      savedAlbums({
    int? offset,
    int? limit,
  });

  Future<DeeMusiqPaginationResponseObject<DeeMusiqFullArtistObject>>
      savedArtists({
    int? offset,
    int? limit,
  });

  Future<bool> isSavedPlaylist(String playlistId);

  Future<List<bool>> isSavedTracks(List<String> ids);

  Future<List<bool>> isSavedAlbums(List<String> ids);

  Future<List<bool>> isSavedArtists(List<String> ids);
}
