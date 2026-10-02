import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local recently-played history (user improvement: quick resume + streak).
/// Stored on-device only — no backend round trip. The audio player calls
/// [push] on every counted scrobble; the home screen reads [history].
class RecentPlay {
  final String trackId;
  final String title;
  final String artist;
  final DateTime playedAt;

  const RecentPlay({
    required this.trackId,
    required this.title,
    required this.artist,
    required this.playedAt,
  });

  Map<String, dynamic> toJson() => {
        'trackId': trackId,
        'title': title,
        'artist': artist,
        'playedAt': playedAt.toIso8601String(),
      };

  factory RecentPlay.fromJson(Map<String, dynamic> json) => RecentPlay(
        trackId: (json['trackId'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        artist: (json['artist'] ?? '').toString(),
        playedAt: DateTime.tryParse(json['playedAt']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
}

class RecentlyPlayedNotifier extends StateNotifier<List<RecentPlay>> {
  static const _key = 'deemusiq_recently_played';
  static const _max = 50;

  RecentlyPlayedNotifier() : super(const []) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return;
      final list = (jsonDecode(raw) as List)
          .map((e) => RecentPlay.fromJson(Map<String, dynamic>.from(e as Map)))
          .where((e) => e.trackId.isNotEmpty)
          .take(_max)
          .toList();
      state = list;
    } catch (_) {}
  }

  Future<void> push(RecentPlay play) async {
    final next = [
      play,
      ...state.where((e) => e.trackId != play.trackId),
    ].take(_max).toList();
    state = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(next.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  Future<void> clear() async {
    state = const [];
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }

  /// Days in a row with at least one play (local streak).
  int get streakDays {
    if (state.isEmpty) return 0;
    final days = state
        .map((e) => DateTime(e.playedAt.year, e.playedAt.month, e.playedAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    var streak = 1;
    for (var i = 1; i < days.length; i++) {
      if (days[i - 1].difference(days[i]).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}

final recentlyPlayedProvider =
    StateNotifierProvider<RecentlyPlayedNotifier, List<RecentPlay>>(
  (ref) => RecentlyPlayedNotifier(),
);
