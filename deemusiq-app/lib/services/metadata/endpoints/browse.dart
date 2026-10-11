import 'package:deemusiq/models/metadata/metadata.dart';

abstract class MetadataPluginBrowseEndpoint {
  MetadataPluginBrowseEndpoint();

  Future<DeeMusiqPaginationResponseObject<DeeMusiqBrowseSectionObject<Object>>>
      sections({
    int? offset,
    int? limit,
  });

  Future<DeeMusiqPaginationResponseObject<Object>> sectionItems(
    String id, {
    int? offset,
    int? limit,
  });
}
