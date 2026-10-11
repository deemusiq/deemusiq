import 'package:deemusiq/models/metadata/metadata.dart';

abstract class MetadataPluginSearchEndpoint {
  MetadataPluginSearchEndpoint();

  List<String> get chips;

  Future<DeeMusiqSearchResponseObject> all(String query);

  Future<DeeMusiqPaginationResponseObject<DeeMusiqSimpleAlbumObject>> albums(
    String query, {
    int? limit,
    int? offset,
  });

  Future<DeeMusiqPaginationResponseObject<DeeMusiqFullArtistObject>> artists(
    String query, {
    int? limit,
    int? offset,
  });

  Future<DeeMusiqPaginationResponseObject<DeeMusiqSimplePlaylistObject>>
      playlists(
    String query, {
    int? limit,
    int? offset,
  });

  Future<DeeMusiqPaginationResponseObject<DeeMusiqFullTrackObject>> tracks(
    String query, {
    int? limit,
    int? offset,
  });
}
