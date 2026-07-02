import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/models/playback/track_sources.dart';
import 'package:deemusiq/provider/database/database.dart';
import 'package:deemusiq/provider/metadata_plugin/audio_source/quality_presets.dart';
import 'package:deemusiq/provider/metadata_plugin/metadata_plugin_provider.dart';
import 'package:deemusiq/services/dio/dio.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/metadata/errors/exceptions.dart';

import 'package:deemusiq/services/sourced_track/exceptions.dart';
import 'package:deemusiq/utils/service_utils.dart';

final officialMusicRegex = RegExp(
  r"official\s(video|audio|music\svideo|lyric\svideo|visualizer)",
  caseSensitive: false,
);

class SourcedTrack extends BasicSourcedTrack {
  final Ref ref;

  SourcedTrack({
    required this.ref,
    required super.info,
    required super.query,
    required super.source,
    required super.siblings,
    required super.sources,
  });

  static Future<SourcedTrack> fetchFromTrack({
    required DeeMusiqFullTrackObject query,
    required Ref ref,
    int retryDepth = 0,
  }) async {
    if (retryDepth >= 3) throw TrackNotFoundError(query);

    final audioSource = await ref.read(audioSourcePluginProvider.future)
        .timeout(const Duration(seconds: 10), onTimeout: () => null);
    final audioSourceConfig = await ref.read(metadataPluginsProvider
        .selectAsync((data) => data.defaultAudioSourcePluginConfig))
        .timeout(const Duration(seconds: 10), onTimeout: () => null);
    if (audioSource == null || audioSourceConfig == null) {
      throw MetadataPluginException.noDefaultAudioSourcePlugin();
    }

    final database = ref.read(databaseProvider);
    final cachedSource = await (database.select(database.sourceMatchTable)
          ..where((s) =>
              s.trackId.equals(query.id) &
              s.sourceType.equals(audioSourceConfig.slug))
          ..limit(1)
          ..orderBy([
            (s) =>
                OrderingTerm(expression: s.createdAt, mode: OrderingMode.desc),
          ]))
        .get()
        .then((s) => s.firstOrNull);

    if (cachedSource == null) {
      final siblings = await fetchSiblings(ref: ref, query: query);
      if (siblings.isEmpty) {
        throw TrackNotFoundError(query);
      }

      final manifest = await audioSource.audioSource.streams(siblings.first);

      await database.into(database.sourceMatchTable).insert(
            SourceMatchTableCompanion.insert(
              trackId: query.id,
              sourceInfo: Value(jsonEncode(siblings.first)),
              sourceType: audioSourceConfig.slug,
            ),
          );

      return SourcedTrack(
        ref: ref,
        siblings: siblings.skip(1).toList(),
        info: siblings.first,
        source: audioSourceConfig.slug,
        sources: manifest,
        query: query,
      );
    }
    final item = DeeMusiqAudioSourceMatchObject.fromJson(
      jsonDecode(cachedSource.sourceInfo),
    );
    final manifest = await audioSource.audioSource.streams(item);

    // Try to fetch fresh siblings for fallback if the cached source fails.
    // Runs in background — if it fails, we still have the cached manifest.
    List<DeeMusiqAudioSourceMatchObject> freshSiblings = [];
    try {
      freshSiblings = await fetchSiblings(ref: ref, query: query)
          .timeout(const Duration(seconds: 5));
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'SourcedTrack: fresh siblings fetch failed');
      // siblings fetch failed — keep empty list, fallback won't work but
      // the primary cached source is still valid
    }

    final sourcedTrack = SourcedTrack(
      ref: ref,
      siblings: freshSiblings,
      sources: manifest,
      info: item,
      query: query,
      source: audioSourceConfig.slug,
    );

    // Validate cached source URL hasn't expired (quick HEAD check)
    if (sourcedTrack.url != null && sourcedTrack.url!.isNotEmpty) {
      try {
        final headRes = await globalDio.head(sourcedTrack.url!,
            options: Options(
                validateStatus: (s) => s != null && s < 500,
                sendTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 5)));
        if (headRes.statusCode != null && headRes.statusCode! >= 400) {
          AppLogger.log.w('Cached URL expired for ${query.id}, re-fetching');
          final stmt = database.delete(database.sourceMatchTable)
            ..where((s) => s.trackId.equals(query.id));
          await stmt.go();
          return fetchFromTrack(query: query, ref: ref, retryDepth: retryDepth + 1);
        }
      } catch (e, stack) {
        AppLogger.reportError(e, stack, 'SourcedTrack: cached URL HEAD check failed');
        // HEAD failed quickly — keep cached, engine failover handles streaming
      }
    }

    AppLogger.log.i("${query.name}: ${sourcedTrack.url}");

    return sourcedTrack;
  }

  static List<DeeMusiqAudioSourceMatchObject> rankResults(
    List<DeeMusiqAudioSourceMatchObject> results,
    DeeMusiqFullTrackObject track,
  ) {
    return results
        .map((sibling) {
          int score = 0;

          for (final artist in track.artists) {
            final isSameChannelArtist =
                sibling.artists.any((a) => a.toLowerCase() == artist.name);

            if (isSameChannelArtist) {
              score += 1;
            }

            final titleContainsArtist =
                sibling.title.toLowerCase().contains(artist.name.toLowerCase());

            if (titleContainsArtist) {
              score += 1;
            }
          }

          final titleContainsTrackName =
              sibling.title.toLowerCase().contains(track.name.toLowerCase());

          final hasOfficialFlag =
              officialMusicRegex.hasMatch(sibling.title.toLowerCase());

          if (titleContainsTrackName) {
            score += 3;
          }

          if (hasOfficialFlag) {
            score += 1;
          }

          if (hasOfficialFlag && titleContainsTrackName) {
            score += 2;
          }

          return (sibling: sibling, score: score);
        })
        .sorted((a, b) => b.score.compareTo(a.score))
        .map((e) => e.sibling)
        .toList();
  }

  static Future<List<DeeMusiqAudioSourceMatchObject>> fetchSiblings({
    required DeeMusiqFullTrackObject query,
    required Ref ref,
  }) async {
    final audioSource = await ref.read(audioSourcePluginProvider.future);

    if (audioSource == null) {
      throw MetadataPluginException.noDefaultAudioSourcePlugin();
    }

    final videoResults = <DeeMusiqAudioSourceMatchObject>[];

    final searchResults = await audioSource.audioSource.matches(query);

    if (ServiceUtils.onlyContainsEnglish(query.name)) {
      videoResults.addAll(searchResults);
    } else {
      videoResults.addAll(rankResults(searchResults, query));
    }

    return videoResults.toSet().toList();
  }

  Future<SourcedTrack> copyWithSibling() async {
    if (siblings.isNotEmpty) {
      return this;
    }
    final fetchedSiblings = await fetchSiblings(ref: ref, query: query);

    return SourcedTrack(
      ref: ref,
      siblings: fetchedSiblings.where((s) => s.id != info.id).toList(),
      source: source,
      sources: sources,
      info: info,
      query: query,
    );
  }

  Future<SourcedTrack?> swapWithSibling(
    DeeMusiqAudioSourceMatchObject sibling,
  ) async {
    if (sibling.id == info.id) {
      return null;
    }

    final audioSource = await ref.read(audioSourcePluginProvider.future);
    final audioSourceConfig = await ref.read(metadataPluginsProvider
        .selectAsync((data) => data.defaultAudioSourcePluginConfig));
    if (audioSource == null || audioSourceConfig == null) {
      throw MetadataPluginException.noDefaultAudioSourcePlugin();
    }

    // a sibling source that was fetched from the search results
    final isStepSibling = siblings.none((s) => s.id == sibling.id);

    final newSourceInfo = isStepSibling
        ? sibling
        : siblings.firstWhere((s) => s.id == sibling.id);

    final newSiblings = siblings.where((s) => s.id != sibling.id).toList()
      ..insert(0, info);

    final manifest = await audioSource.audioSource.streams(newSourceInfo);

    final database = ref.read(databaseProvider);

    // Delete the old Entry
    await (database.sourceMatchTable.delete()
          ..where(
            (table) =>
                table.trackId.equals(query.id) &
                table.sourceType.equals(audioSourceConfig.slug),
          ))
        .go();

    await database.into(database.sourceMatchTable).insert(
          SourceMatchTableCompanion.insert(
            trackId: query.id,
            sourceInfo: Value(jsonEncode(sibling)),
            sourceType: audioSourceConfig.slug,
            createdAt: Value(DateTime.now()),
          ),
          mode: InsertMode.replace,
        );

    return SourcedTrack(
      ref: ref,
      source: source,
      siblings: newSiblings,
      sources: manifest,
      info: newSourceInfo,
      query: query,
    );
  }

  Future<SourcedTrack?> swapWithSiblingOfIndex(int index) {
    return swapWithSibling(siblings[index]);
  }

  Future<SourcedTrack> refreshStream() async {
    final audioSource = await ref.read(audioSourcePluginProvider.future);
    final audioSourceConfig = await ref.read(metadataPluginsProvider
        .selectAsync((data) => data.defaultAudioSourcePluginConfig));
    if (audioSource == null || audioSourceConfig == null) {
      throw MetadataPluginException.noDefaultAudioSourcePlugin();
    }

    List<DeeMusiqAudioSourceStreamObject> validStreams = [];

    final stringBuffer = StringBuffer();
    for (final source in sources) {
      try {
        final res = await globalDio.head(
          source.url,
          options: Options(
              validateStatus: (status) => status != null && status < 500),
        );

        final statusCode = res.statusCode;
        stringBuffer.writeln(
          "[${query.id}] ${statusCode ?? 'null'} ${source.container} ${source.codec} ${source.bitrate}",
        );

        if (statusCode != null && statusCode < 400) {
          validStreams.add(source);
        }
      } catch (e, stack) {
        AppLogger.log.w(
          'refreshStream HEAD failed for ${source.url}: $e',
        );
        AppLogger.reportError(e, stack, 'refreshStream HEAD');
        stringBuffer.writeln(
          "[${query.id}] ERROR ${source.container} ${source.codec} ${source.bitrate}: $e",
        );
      }
    }

    AppLogger.log.d(stringBuffer.toString());

    if (validStreams.isEmpty) {
      validStreams = await audioSource.audioSource.streams(info);
    }

    final sourcedTrack = SourcedTrack(
      ref: ref,
      siblings: siblings,
      source: source,
      sources: validStreams,
      info: info,
      query: query,
    );

    AppLogger.log.i("Refreshing ${query.name}: ${sourcedTrack.url}");

    return sourcedTrack;
  }

  String? get url {
    final preferences = ref.read(audioSourcePresetsProvider);
    final presets = preferences.presets;
    if (presets.isEmpty) return null;
    final index = preferences.selectedStreamingContainerIndex;
    if (index < 0 || index >= presets.length) return null;
    return getUrlOfQuality(
      presets[index],
      preferences.selectedStreamingQualityIndex,
    );
  }

  static const _audioContainers = {'mp4', 'm4a', 'webm', 'opus', 'ogg', 'aac', 'mp3'};

  bool _isAudioContainer(String container) {
    return _audioContainers.contains(container.toLowerCase());
  }

  /// Returns the URL of the track based on the codec and quality preferences.
  /// If an exact match is not found, it will return the closest match based on
  /// the user's audio quality preference.
  ///
  /// If no sources match the codec, it will return the first or last source
  /// based on the user's audio quality preference.
  DeeMusiqAudioSourceStreamObject? getStreamOfQuality(
    DeeMusiqAudioSourceContainerPreset preset,
    int qualityIndex,
  ) {
    if (sources.isEmpty) return null;

    final quality = preset.qualities[qualityIndex];

    final exactMatch = sources.firstWhereOrNull(
      (source) {
        if (!_isAudioContainer(source.container)) return false;

        if (quality case DeeMusiqAudioLosslessContainerQuality()) {
          return source.sampleRate == quality.sampleRate &&
              source.bitDepth == quality.bitDepth;
        } else {
          return source.bitrate ==
              (quality as DeeMusiqAudioLossyContainerQuality).bitrate;
        }
      },
    );

    if (exactMatch != null) {
      return exactMatch;
    }

    if (quality case DeeMusiqAudioLossyContainerQuality lossyQuality) {
      final target = lossyQuality.bitrate;
      final tolerance = (target * 0.2).round();
      final toleranceMatch = sources.firstWhereOrNull((source) {
        if (!_isAudioContainer(source.container)) return false;
        final srcBitrate = source.bitrate ?? 0;
        return (srcBitrate - target).abs() <= tolerance;
      });
      if (toleranceMatch != null) {
        return toleranceMatch;
      }
    }

    final matching = sources.where((source) {
      return _isAudioContainer(source.container);
    }).toList();
    if (matching.isEmpty) return null;
    return matching.reduce((prev, curr) {
      if (quality is DeeMusiqAudioLosslessContainerQuality) {
        final prevDiff = ((prev.sampleRate ?? 0) - quality.sampleRate).abs() +
            ((prev.bitDepth ?? 0) - quality.bitDepth).abs();
        final currDiff = ((curr.sampleRate ?? 0) - quality.sampleRate).abs() +
            ((curr.bitDepth ?? 0) - quality.bitDepth).abs();
        return currDiff < prevDiff ? curr : prev;
      } else {
        final prevDiff = ((prev.bitrate ?? 0) -
                (quality as DeeMusiqAudioLossyContainerQuality).bitrate)
            .abs();
        final currDiff = ((curr.bitrate ?? 0) - quality.bitrate).abs();
        return currDiff < prevDiff ? curr : prev;
      }
    });
  }

  String? getUrlOfQuality(
    DeeMusiqAudioSourceContainerPreset preset,
    int qualityIndex,
  ) {
    return getStreamOfQuality(preset, qualityIndex)?.url;
  }

  DeeMusiqAudioSourceContainerPreset? get qualityPreset {
    final presetState = ref.read(audioSourcePresetsProvider);
    return presetState.presets
        .elementAtOrNull(presetState.selectedStreamingContainerIndex);
  }
}
