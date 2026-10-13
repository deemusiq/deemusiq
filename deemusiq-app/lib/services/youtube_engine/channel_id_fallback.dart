import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Stable placeholder used when an extractor (yt-dlp flat entries, NewPipe
/// handle URLs) yields no canonical channel identifier. The value satisfies
/// youtube_explode_dart's `UC…` 24-char validation, so the video survives
/// parsing instead of being dropped; the author NAME is still real, only
/// channel navigation is unavailable for these entries.
final ChannelId unknownChannelId = ChannelId('UCunknown-channel-000000');

/// Returns a [ChannelId] for the first candidate that parses as a canonical
/// `UC…` id or a `youtube…/channel/UC…` URL. Falls back to
/// [unknownChannelId] when no candidate qualifies — never throws on
/// extractor output that carries a video id, a handle URL, or nothing.
ChannelId resolveChannelId(Iterable<String?> candidates) {
  for (final candidate in candidates) {
    if (candidate == null || candidate.isEmpty) continue;
    final parsed = ChannelId.parseChannelId(candidate);
    if (parsed != null) return ChannelId(parsed);
  }
  return unknownChannelId;
}
