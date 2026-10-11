import 'package:deemusiq/models/metadata/metadata.dart';

abstract class MetadataPluginArtistEndpoint {
  MetadataPluginArtistEndpoint();

  Future<DeeMusiqFullArtistObject> getArtist(String id);

  Future<DeeMusiqPaginationResponseObject<DeeMusiqFullTrackObject>> topTracks(
    String id, {
    int? offset,
    int? limit,
  });

  Future<DeeMusiqPaginationResponseObject<DeeMusiqSimpleAlbumObject>> albums(
    String id, {
    int? offset,
    int? limit,
  });

  Future<void> save(List<String> ids);

  Future<void> unsave(List<String> ids);

  Future<DeeMusiqPaginationResponseObject<DeeMusiqFullArtistObject>> related(
    String id, {
    int? offset,
    int? limit,
  });
}
