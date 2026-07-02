import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/provider/user_preferences/user_preferences_provider.dart';
import 'package:deemusiq/services/youtube_engine/newpipe_engine.dart';
import 'package:deemusiq/services/youtube_engine/youtube_explode_engine.dart';
import 'package:deemusiq/services/youtube_engine/yt_dlp_engine.dart';
import 'package:deemusiq/services/youtube_engine/direct_ytdlp_engine.dart';
import 'package:deemusiq/services/youtube_engine/cache_first_engine.dart';
import 'package:deemusiq/services/youtube_engine/youtube_engine.dart';

final youtubeEngineProvider = Provider((ref) {
  final engineMode = ref.watch(
    userPreferencesProvider.select((value) => value.youtubeClientEngine),
  );

  if (engineMode == YoutubeClientEngine.newPipe &&
      NewPipeEngine().isAvailableForPlatform) {
    return NewPipeEngine();
  } else if (engineMode == YoutubeClientEngine.ytDlp &&
      YtDlpEngine().isAvailableForPlatform) {
    return YtDlpEngine();
  } else {
    return YouTubeExplodeEngine();
  }
});

/// All available YouTube engines in priority order for stream extraction:
/// 1. DirectYtDlp (raw Process.start with 25s timeout — most robust)
/// 2. YtDlpEngine (original Spotube — Process.run via yt_dlp_dart)
/// 3. YouTubeExplode (pure Dart isolate)
/// 4. NewPipe (Java FFI extractor)
final allYouTubeEnginesProvider = Provider<List<YouTubeEngine>>((ref) {
  final all = <YouTubeEngine>[];
  final directYtDlp = DirectYtDlpEngine();
  if (directYtDlp.isAvailableForPlatform) {
    all.add(directYtDlp);
  }
  final ytDlp = YtDlpEngine();
  if (ytDlp.isAvailableForPlatform) {
    all.add(ytDlp);
  }
  final youtubeExplode = YouTubeExplodeEngine();
  if (youtubeExplode.isAvailableForPlatform) {
    all.add(youtubeExplode);
  }
  final newPipe = NewPipeEngine();
  if (newPipe.isAvailableForPlatform) {
    all.add(newPipe);
  }
  return all;
});
