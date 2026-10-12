import 'package:deemusiq/models/metadata/metadata.dart';

abstract class MetadataAuthEndpoint {
  MetadataAuthEndpoint();

  /// User-configurable fields this provider exposes, rendered by the
  /// metadata-provider settings form. Empty when the provider has nothing
  /// to configure — the built-in DeeMusiq provider currently has none.
  List<MetadataFormFieldObject> get configurationFields => const [];

  Stream get authStateStream;

  Future<void> authenticate();

  bool isAuthenticated();

  Future<void> logout();
}
