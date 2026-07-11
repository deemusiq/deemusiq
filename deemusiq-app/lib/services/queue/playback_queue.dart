import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/audio_player/audio_player.dart';
import 'package:deemusiq/provider/audio_player/state.dart';
import 'package:deemusiq/services/audio_player/audio_player.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:drift/drift.dart' show Value;
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// High-level playback queue manager that wraps [AudioPlayerNotifier].
///
/// Adds concepts beyond the raw playlist:
/// - **Queue-first**: tracks pushed as "play next" go before the current
///   track index so they play immediately after the current track finishes.
/// - **Queue-last**: tracks added to the end of the playlist.
/// - **Queue inspection**: view the upcoming tracks in play order.
///
/// The actual playlist is managed by [AudioPlayerNotifier]; this service
/// provides convenient grouping and ordering on top of it.
class PlaybackQueue {
  final Ref ref;

  PlaybackQueue(this.ref);

  AudioPlayerNotifier get _notifier => ref.read(audioPlayerProvider.notifier);
  AudioPlayerState get _state => ref.read(audioPlayerProvider);

  /// The tracks that will play after the current track (in order).
  List<DeeMusiqTrackObject> get upcomingTracks {
    final currentIndex = _state.currentIndex;
    if (currentIndex < 0 || currentIndex >= _state.tracks.length) {
      return [];
    }
    return _state.tracks.sublist(currentIndex + 1);
  }

  /// The tracks that have already played (before the current track).
  List<DeeMusiqTrackObject> get previousTracks {
    final currentIndex = _state.currentIndex;
    if (currentIndex <= 0) return [];
    return _state.tracks.sublist(0, currentIndex);
  }

  /// Total number of tracks in the play queue.
  int get length => _state.tracks.length;

  /// Whether the queue is empty.
  bool get isEmpty => _state.tracks.isEmpty;

  /// Add a track to play next (right after the current track finishes).
  Future<void> playNext(DeeMusiqTrackObject track) async {
    final currentIndex = _state.currentIndex;
    if (_state.tracks.isEmpty || currentIndex < 0) {
      // No active playlist — just add it
      await _notifier.addTrack(track);
      return;
    }
    // Insert right after the current track
    await _notifier.addTracksAtFirst([track]);
    AppLogger.log.i('PlaybackQueue: track added to play next — ${track.name}');
  }

  /// Add a track to the end of the queue.
  Future<void> addToEnd(DeeMusiqTrackObject track) async {
    await _notifier.addTrack(track);
    AppLogger.log.i('PlaybackQueue: track added to end — ${track.name}');
  }

  /// Add multiple tracks to the end of the queue.
  Future<void> addAllToEnd(Iterable<DeeMusiqTrackObject> tracks) async {
    await _notifier.addTracks(tracks);
    AppLogger.log.i('PlaybackQueue: ${tracks.length} tracks added to end');
  }

  /// Remove a track from the queue by its ID.
  Future<void> remove(String trackId) async {
    await _notifier.removeTrack(trackId);
    AppLogger.log.i('PlaybackQueue: track removed — $trackId');
  }

  /// Clear the entire queue (stop playback).
  Future<void> clear() async {
    await _notifier.stop();
    AppLogger.log.i('PlaybackQueue: queue cleared');
  }

  /// Jump to a specific track in the queue.
  Future<void> jumpTo(DeeMusiqTrackObject track) async {
    await _notifier.jumpToTrack(track);
    AppLogger.log.i('PlaybackQueue: jumped to — ${track.name}');
  }

  /// Move a track from one position to another.
  Future<void> move(int oldIndex, int newIndex) async {
    await _notifier.moveTrack(oldIndex, newIndex);
  }

  /// Check if a track is already in the queue.
  bool contains(DeeMusiqTrackObject track) {
    return _state.containsTrack(track);
  }

  /// Skip to the next track in the queue.
  Future<void> skipNext() async {
    await audioPlayer.skipToNext();
  }

  /// Skip to the previous track in the queue.
  Future<void> skipPrevious() async {
    await audioPlayer.skipToPrevious();
  }

  static Future<void> saveQueue(AppDatabase database, List<DeeMusiqTrackObject> tracks, {int currentIndex = 0}) async {
    await database.transaction(() async {
      final existing =
          await database.select(database.audioPlayerStateTable).getSingleOrNull();
      if (existing != null) {
        await (database.update(database.audioPlayerStateTable)
              ..where((tb) => tb.id.equals(0)))
            .write(AudioPlayerStateTableCompanion(
          tracks: Value(tracks),
          currentIndex: Value(currentIndex),
        ));
      } else {
        await database.into(database.audioPlayerStateTable).insert(
              AudioPlayerStateTableCompanion.insert(
                playing: false,
                loopMode: audioPlayer.loopMode,
                shuffled: audioPlayer.isShuffled,
                collections: const <String>[],
                tracks: Value(tracks),
                currentIndex: Value(currentIndex),
                id: const Value(0),
              ),
            );
      }
    });
  }

  static Future<({List<DeeMusiqTrackObject> tracks, int currentIndex})?> loadQueue(AppDatabase database) async {
    final state = await database
        .select(database.audioPlayerStateTable)
        .getSingleOrNull();
    if (state == null || state.tracks.isEmpty) return null;
    return (tracks: state.tracks, currentIndex: state.currentIndex);
  }

  static Future<void> clearQueue(AppDatabase database) async {
    final existing =
        await database.select(database.audioPlayerStateTable).getSingleOrNull();
    if (existing != null) {
      await (database.update(database.audioPlayerStateTable)
            ..where((tb) => tb.id.equals(0)))
          .write(const AudioPlayerStateTableCompanion(
        tracks: Value([]),
      ));
    }
  }
}

/// Provider for [PlaybackQueue].
final playbackQueueProvider = Provider<PlaybackQueue>((ref) {
  return PlaybackQueue(ref);
});
