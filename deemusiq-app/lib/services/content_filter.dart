import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:deemusiq/models/metadata/metadata.dart';

class ContentFilter {
  static const _blockedKeywords = [
    'podcast',
    'interview',
    'talk show',
    'lecture',
    'webinar',
    'asmr',
    'audiobook',
    'speech',
    'press conference',
    'meditation',
    'sleep music',
    'sleep sound',
    'sleep meditation',
    'white noise',
    'nature sounds',
    'ambience',
    'news',
    'trailer',
    'reaction',
    'unboxing',
    'review',
    'guided',
    'hypnosis',
    'compilation',
    'full album',
    'mix',
    'mixtape',
  ];

  static final _blockedPatterns = [
    RegExp(r'episode\s+\d+', caseSensitive: false),
    RegExp(r'ep\.\s*\d+', caseSensitive: false),
    RegExp(r'#shorts', caseSensitive: false),
  ];

  static bool isPlayableSong(Video video) {
    if (video.isLive) return false;
    if (video.duration == null || video.duration == Duration.zero) return false;
    final secs = video.duration!.inSeconds;
    if (secs < 30 || secs > 900) return false;
    if (_hasBlockedTitle(video.title)) return false;
    return true;
  }

  static bool isPlayableMatch(DeeMusiqAudioSourceMatchObject match) {
    if (match.duration == Duration.zero) return false;
    final secs = match.duration.inSeconds;
    if (secs < 30 || secs > 900) return false;
    if (_hasBlockedTitle(match.title)) return false;
    return true;
  }

  static bool _hasBlockedTitle(String title) {
    final lower = title.toLowerCase();
    for (final keyword in _blockedKeywords) {
      if (lower.contains(keyword)) return true;
    }
    for (final pattern in _blockedPatterns) {
      if (pattern.hasMatch(lower)) return true;
    }
    return false;
  }
}
