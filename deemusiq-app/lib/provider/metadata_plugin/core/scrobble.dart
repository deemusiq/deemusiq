import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/metadata_plugin/metadata_plugin_provider.dart';
import 'package:deemusiq/services/logger/logger.dart';

typedef ScrobbleEvent = ({DeeMusiqTrackObject track, int listenedMs, int durationMs});

class MetadataPluginScrobbleNotifier
    extends Notifier<StreamController<ScrobbleEvent>?> {
  @override
  build() {
    final metadataPlugin = ref.watch(metadataPluginProvider);
    final pluginConfig = ref
        .watch(metadataPluginsProvider)
        .valueOrNull
        ?.defaultMetadataPluginConfig;

    if (metadataPlugin.valueOrNull == null ||
        pluginConfig == null ||
        !pluginConfig.abilities.contains(PluginAbilities.scrobbling)) {
      return null;
    }

    final controller = StreamController<ScrobbleEvent>.broadcast();

    final subscription = controller.stream.listen((event) async {
      try {
        final listenedMs = event.listenedMs;
        final durationMs = event.durationMs;
        final track = event.track;
        await metadataPlugin.valueOrNull?.core.scrobble({
          "id": track.id,
          "title": track.name,
          "artists": track.artists
              .map((artist) => {
                    "id": artist.id,
                    "name": artist.name,
                  })
              .toList(),
          "album": {
            "id": track.album.id,
            "name": track.album.name,
          },
          "timestamp": DateTime.now().millisecondsSinceEpoch ~/ 1000,
          "duration_ms": durationMs,
          "listened_ms": listenedMs,
          "isrc": track is DeeMusiqFullTrackObject ? track.isrc : null,
        });
      } catch (e, stack) {
        AppLogger.reportError(e, stack);
      }
    });

    ref.onDispose(() {
      subscription.cancel();
      controller.close();
    });

    return controller;
  }

  /// Backwards-compat: pass a bare track and we'll use its full duration.
  void scrobble(DeeMusiqTrackObject track) {
    scrobbleWith(track: track, listenedMs: track.durationMs, durationMs: track.durationMs);
  }

  /// Preferred: pass the track with the actual listened time so the backend
  /// can distinguish a real listen from a skip.
  void scrobbleWith({
    required DeeMusiqTrackObject track,
    required int listenedMs,
    required int durationMs,
  }) {
    state?.add((track: track, listenedMs: listenedMs, durationMs: durationMs));
  }
}

final metadataPluginScrobbleProvider = NotifierProvider<
    MetadataPluginScrobbleNotifier, StreamController<ScrobbleEvent>?>(
  MetadataPluginScrobbleNotifier.new,
);
