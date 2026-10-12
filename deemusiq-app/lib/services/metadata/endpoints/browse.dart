import 'package:deemusiq/models/metadata/metadata.dart';

abstract class MetadataPluginBrowseEndpoint {
  MetadataPluginBrowseEndpoint();

  /// Home sections for the browse feed.
  ///
  /// [onSection], when given, is invoked each time another section becomes
  /// available — in feed order, and always with the full accumulated list —
  /// before the returned future completes. The home feed fans out over several
  /// independent sources, so the slowest one can hold the page blank for tens of
  /// seconds; callers that can render partial data subscribe and paint as
  /// sections land. Implementations that resolve in a single shot may emit once.
  Future<DeeMusiqPaginationResponseObject<DeeMusiqBrowseSectionObject<Object>>>
      sections({
    int? offset,
    int? limit,
    void Function(List<DeeMusiqBrowseSectionObject<Object>> sections)?
        onSection,
  });

  Future<DeeMusiqPaginationResponseObject<Object>> sectionItems(
    String id, {
    int? offset,
    int? limit,
  });
}
