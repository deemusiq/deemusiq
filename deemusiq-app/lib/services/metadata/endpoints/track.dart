import 'package:deemusiq/models/metadata/metadata.dart';

abstract class MetadataPluginTrackEndpoint {
  MetadataPluginTrackEndpoint();

  Future<DeeMusiqFullTrackObject> getTrack(String id);

  Future<void> save(List<String> ids);

  Future<void> unsave(List<String> ids);

  Future<List<DeeMusiqFullTrackObject>> radio(String id);
}
