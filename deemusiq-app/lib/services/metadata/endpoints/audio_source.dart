import 'package:deemusiq/models/metadata/metadata.dart';

abstract class MetadataPluginAudioSourceEndpoint {
  MetadataPluginAudioSourceEndpoint();

  List<DeeMusiqAudioSourceContainerPreset> get supportedPresets;

  Future<List<DeeMusiqAudioSourceMatchObject>> matches(
    DeeMusiqFullTrackObject track,
  );

  Future<List<DeeMusiqAudioSourceStreamObject>> streams(
    DeeMusiqAudioSourceMatchObject match,
  );
}
