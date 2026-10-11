import 'package:deemusiq/models/metadata/metadata.dart';

abstract class MetadataPluginAlbumEndpoint {
  MetadataPluginAlbumEndpoint();

  Future<DeeMusiqFullAlbumObject> getAlbum(String id);

  Future<DeeMusiqPaginationResponseObject<DeeMusiqFullTrackObject>> tracks(
    String id, {
    int? offset,
    int? limit,
  });

  Future<DeeMusiqPaginationResponseObject<DeeMusiqSimpleAlbumObject>> releases({
    int? offset,
    int? limit,
  });

  Future<void> save(List<String> ids);

  Future<void> unsave(List<String> ids);
}
