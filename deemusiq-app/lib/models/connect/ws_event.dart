part of 'connect.dart';

enum WsEvent {
  error,
  volume,
  removeTrack,
  addTrack,
  reorder,
  shuffle,
  loop,
  seek,
  duration,
  queue,
  position,
  playing,
  resume,
  pause,
  load,
  next,
  previous,
  jump,
  stop,

  /// Nearby-share (protocol v1): catalog ids + metadata only, never audio
  /// bytes. Unknown to older builds — [fromString] maps it to [WsEvent.error]
  /// there, so a legacy peer just logs an error instead of crashing.
  share,

  /// Pairing token grant (H1): sent once right after the user approves the
  /// pairing dialog; the token authenticates the LAN HTTP endpoints
  /// (`/stream/*`, `/playback/*`). Unknown to older builds — maps to
  /// [WsEvent.error] there, harmless since they never call those endpoints.
  paired;

  static WsEvent fromString(String value) {
    return WsEvent.values.firstWhere((e) => e.name == value, orElse: () => WsEvent.error);
  }
}

typedef EventCallback<T> = FutureOr<void> Function(T event);

class WebSocketEvent<T> {
  final WsEvent type;
  final T data;

  WebSocketEvent(this.type, this.data);

  factory WebSocketEvent.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson,
  ) {
    return WebSocketEvent(
      WsEvent.fromString(json["type"]),
      fromJson(json["data"]),
    );
  }

  String toJson() {
    return jsonEncode({
      "type": type.name,
      "data": data,
    });
  }

  Future<void> onPosition(
    EventCallback<WebSocketPositionEvent> callback,
  ) async {
    if (type == WsEvent.position) {
      await callback(WebSocketPositionEvent.fromJson({"data": data}));
    }
  }

  Future<void> onPlaying(
    EventCallback<WebSocketPlayingEvent> callback,
  ) async {
    if (type == WsEvent.playing) {
      await callback(WebSocketPlayingEvent(data as bool));
    }
  }

  Future<void> onResume(
    EventCallback<WebSocketResumeEvent> callback,
  ) async {
    if (type == WsEvent.resume) {
      await callback(WebSocketResumeEvent());
    }
  }

  Future<void> onPause(
    EventCallback<WebSocketPauseEvent> callback,
  ) async {
    if (type == WsEvent.pause) {
      await callback(WebSocketPauseEvent());
    }
  }

  Future<void> onStop(
    EventCallback<WebSocketStopEvent> callback,
  ) async {
    if (type == WsEvent.stop) {
      await callback(WebSocketStopEvent());
    }
  }

  Future<void> onLoad(
    EventCallback<WebSocketLoadEvent> callback,
  ) async {
    if (type == WsEvent.load) {
      await callback(
        WebSocketLoadEvent(
          WebSocketLoadEventData.fromJson(data as Map<String, dynamic>),
        ),
      );
    }
  }

  Future<void> onNext(
    EventCallback<WebSocketNextEvent> callback,
  ) async {
    if (type == WsEvent.next) {
      await callback(WebSocketNextEvent());
    }
  }

  Future<void> onPrevious(
    EventCallback<WebSocketPreviousEvent> callback,
  ) async {
    if (type == WsEvent.previous) {
      await callback(WebSocketPreviousEvent());
    }
  }

  Future<void> onJump(
    EventCallback<WebSocketJumpEvent> callback,
  ) async {
    if (type == WsEvent.jump) {
      await callback(WebSocketJumpEvent(data as int));
    }
  }

  Future<void> onError(
    EventCallback<WebSocketErrorEvent> callback,
  ) async {
    if (type == WsEvent.error) {
      await callback(WebSocketErrorEvent(data as String));
    }
  }

  Future<void> onQueue(
    EventCallback<WebSocketQueueEvent> callback,
  ) async {
    if (type == WsEvent.queue) {
      await callback(
        WebSocketQueueEvent.fromJson(data as Map<String, dynamic>),
      );
    }
  }

  Future<void> onDuration(
    EventCallback<WebSocketDurationEvent> callback,
  ) async {
    if (type == WsEvent.duration) {
      await callback(
        WebSocketDurationEvent(
          Duration(seconds: data as int),
        ),
      );
    }
  }

  Future<void> onSeek(
    EventCallback<WebSocketSeekEvent> callback,
  ) async {
    if (type == WsEvent.seek) {
      await callback(
        WebSocketSeekEvent(
          Duration(seconds: data as int),
        ),
      );
    }
  }

  Future<void> onShuffle(
    EventCallback<WebSocketShuffleEvent> callback,
  ) async {
    if (type == WsEvent.shuffle) {
      await callback(WebSocketShuffleEvent(data as bool));
    }
  }

  Future<void> onLoop(
    EventCallback<WebSocketLoopEvent> callback,
  ) async {
    if (type == WsEvent.loop) {
      await callback(
        WebSocketLoopEvent(
          PlaylistMode.values.firstWhere((e) => e.name == data as String),
        ),
      );
    }
  }

  Future<void> onRemoveTrack(
    EventCallback<WebSocketRemoveTrackEvent> callback,
  ) async {
    if (type == WsEvent.removeTrack) {
      await callback(WebSocketRemoveTrackEvent(data as String));
    }
  }

  Future<void> onAddTrack(
    EventCallback<WebSocketAddTrackEvent> callback,
  ) async {
    if (type == WsEvent.addTrack) {
      await callback(
          WebSocketAddTrackEvent.fromJson(data as Map<String, dynamic>));
    }
  }

  Future<void> onReorder(
    EventCallback<WebSocketReorderEvent> callback,
  ) async {
    if (type == WsEvent.reorder) {
      await callback(
          WebSocketReorderEvent.fromJson(data as Map<String, dynamic>));
    }
  }

  Future<void> onVolume(
    EventCallback<WebSocketVolumeEvent> callback,
  ) async {
    if (type == WsEvent.volume) {
      await callback(WebSocketVolumeEvent(data as double));
    }
  }

  Future<void> onShare(
    EventCallback<WebSocketShareEvent> callback,
  ) async {
    if (type == WsEvent.share) {
      await callback(
        WebSocketShareEvent(
          ConnectSharePayload.fromJson(data as Map<String, dynamic>),
        ),
      );
    }
  }

  Future<void> onPaired(
    EventCallback<WebSocketPairedEvent> callback,
  ) async {
    if (type == WsEvent.paired) {
      await callback(WebSocketPairedEvent(data as String));
    }
  }
}

class WebSocketLoopEvent extends WebSocketEvent<PlaylistMode> {
  WebSocketLoopEvent(PlaylistMode data) : super(WsEvent.loop, data);

  WebSocketLoopEvent.fromJson(Map<String, dynamic> json)
      : super(
          WsEvent.loop,
          PlaylistMode.values.firstWhere(
            (e) => e.name == json["data"] as String,
          ),
        );

  @override
  String toJson() {
    return jsonEncode({
      "type": type.name,
      "data": data.name,
    });
  }
}

class WebSocketPositionEvent extends WebSocketEvent<Duration> {
  WebSocketPositionEvent(Duration data) : super(WsEvent.position, data);

  WebSocketPositionEvent.fromJson(Map<String, dynamic> json)
      : super(WsEvent.position, Duration(seconds: json["data"] as int));

  @override
  String toJson() {
    return jsonEncode({
      "type": type.name,
      "data": data.inSeconds,
    });
  }
}

class WebSocketDurationEvent extends WebSocketEvent<Duration> {
  WebSocketDurationEvent(Duration data) : super(WsEvent.duration, data);

  WebSocketDurationEvent.fromJson(Map<String, dynamic> json)
      : super(WsEvent.duration, Duration(seconds: json["data"] as int));

  @override
  String toJson() {
    return jsonEncode({
      "type": type.name,
      "data": data.inSeconds,
    });
  }
}

class WebSocketSeekEvent extends WebSocketEvent<Duration> {
  WebSocketSeekEvent(Duration data) : super(WsEvent.seek, data);

  WebSocketSeekEvent.fromJson(Map<String, dynamic> json)
      : super(WsEvent.seek, Duration(seconds: json["data"] as int));

  @override
  String toJson() {
    return jsonEncode({
      "type": type.name,
      "data": data.inSeconds,
    });
  }
}

class WebSocketShuffleEvent extends WebSocketEvent<bool> {
  WebSocketShuffleEvent(bool data) : super(WsEvent.shuffle, data);
}

class WebSocketPlayingEvent extends WebSocketEvent<bool> {
  WebSocketPlayingEvent(bool data) : super(WsEvent.playing, data);
}

class WebSocketResumeEvent extends WebSocketEvent<void> {
  WebSocketResumeEvent() : super(WsEvent.resume, null);
}

class WebSocketPauseEvent extends WebSocketEvent<void> {
  WebSocketPauseEvent() : super(WsEvent.pause, null);
}

class WebSocketStopEvent extends WebSocketEvent<void> {
  WebSocketStopEvent() : super(WsEvent.stop, null);
}

class WebSocketNextEvent extends WebSocketEvent<void> {
  WebSocketNextEvent() : super(WsEvent.next, null);
}

class WebSocketPreviousEvent extends WebSocketEvent<void> {
  WebSocketPreviousEvent() : super(WsEvent.previous, null);
}

class WebSocketJumpEvent extends WebSocketEvent<int> {
  WebSocketJumpEvent(int data) : super(WsEvent.jump, data);
}

class WebSocketErrorEvent extends WebSocketEvent<String> {
  WebSocketErrorEvent(String data) : super(WsEvent.error, data);
}

/// Carries the per-pairing token minted at pairing approval (H1). A paired
/// client presents it as `X-DM-Connect-Token` (or `?token=`) on the LAN HTTP
/// endpoints; it lives only in memory on both sides and dies with the host's
/// server (24 h allowlist TTL bounds the server-side copy).
class WebSocketPairedEvent extends WebSocketEvent<String> {
  WebSocketPairedEvent(String data) : super(WsEvent.paired, data);
}

class WebSocketQueueEvent extends WebSocketEvent<AudioPlayerState> {
  WebSocketQueueEvent(AudioPlayerState data) : super(WsEvent.queue, data);

  factory WebSocketQueueEvent.fromJson(Map<String, dynamic> json) =>
      WebSocketQueueEvent(
        AudioPlayerState.fromJson(json),
      );
}

class WebSocketRemoveTrackEvent extends WebSocketEvent<String> {
  WebSocketRemoveTrackEvent(String data) : super(WsEvent.removeTrack, data);
}

class WebSocketAddTrackEvent extends WebSocketEvent<DeeMusiqFullTrackObject> {
  WebSocketAddTrackEvent(DeeMusiqFullTrackObject data)
      : super(WsEvent.addTrack, data);

  WebSocketAddTrackEvent.fromJson(Map<String, dynamic> json)
      : super(
          WsEvent.addTrack,
          DeeMusiqFullTrackObject.fromJson(
            json["data"] as Map<String, dynamic>,
          ),
        );
}

typedef ReorderData = ({int oldIndex, int newIndex});

class WebSocketReorderEvent extends WebSocketEvent<ReorderData> {
  WebSocketReorderEvent(ReorderData data) : super(WsEvent.reorder, data);

  factory WebSocketReorderEvent.fromJson(Map<String, dynamic> json) =>
      WebSocketReorderEvent(
        (
          oldIndex: json["oldIndex"] as int,
          newIndex: json["newIndex"] as int,
        ),
      );

  @override
  String toJson() {
    return jsonEncode({
      "type": type.name,
      "data": {
        "oldIndex": data.oldIndex,
        "newIndex": data.newIndex,
      },
    });
  }
}

class WebSocketVolumeEvent extends WebSocketEvent<double> {
  WebSocketVolumeEvent(double data) : super(WsEvent.volume, data);
}

/// ── Nearby share (WsEvent.share) ──────────────────────────────────────────
/// "Send to nearby device" payload: catalog ids + display metadata only —
/// never audio bytes (the project's byte-path rule forbids proxying audio).
/// The receiver resolves [id] against its own catalog/backend.

/// One track entry inside a shared playlist.
class ConnectShareTrack {
  final String id;
  final String title;
  final String artist;
  final String? coverUrl;

  const ConnectShareTrack({
    required this.id,
    required this.title,
    required this.artist,
    this.coverUrl,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "artist": artist,
        if (coverUrl != null) "coverUrl": coverUrl,
      };

  factory ConnectShareTrack.fromJson(Map<String, dynamic> json) {
    final id = json["id"];
    final title = json["title"];
    final artist = json["artist"];
    if (id is! String || id.isEmpty) {
      throw const FormatException("share track: missing id");
    }
    return ConnectShareTrack(
      id: ConnectSharePayload._bounded(id),
      title: ConnectSharePayload._bounded(title is String ? title : ""),
      artist: ConnectSharePayload._bounded(artist is String ? artist : ""),
      coverUrl: json["coverUrl"] is String
          ? ConnectSharePayload._bounded(json["coverUrl"] as String)
          : null,
    );
  }
}

/// Versioned share envelope (`{"v":1,"kind":"track|playlist",...}`).
class ConnectSharePayload {
  /// Bump when the wire shape changes; receivers reject newer versions with a
  /// [FormatException] so the UI can tell the user to update.
  static const int currentVersion = 1;

  /// Playlist entries are capped so the encoded message stays far below the
  /// WebSocket limits (ConnectNotifier._wsMaxMsgSize = 1 MB).
  static const int maxPlaylistTracks = 200;

  /// Hard encoded-size guard enforced by the sender ([encodeChecked]).
  static const int maxPayloadBytes = 500 * 1024;

  /// Per-field length cap — a malicious/buggy peer can't send huge strings.
  static const int maxFieldLength = 300;

  static const kindTrack = "track";
  static const kindPlaylist = "playlist";

  final int version;
  final String kind;
  final String id;
  final String title;
  final String? artist;
  final String? coverUrl;
  final String? externalUri;

  /// Playlist entries (empty for single tracks).
  final List<ConnectShareTrack> tracks;

  /// True when the sender cut the playlist down to [maxPlaylistTracks].
  final bool truncated;

  const ConnectSharePayload({
    required this.kind,
    required this.id,
    required this.title,
    this.version = currentVersion,
    this.artist,
    this.coverUrl,
    this.externalUri,
    this.tracks = const [],
    this.truncated = false,
  });

  factory ConnectSharePayload.track(DeeMusiqTrackObject track) {
    return ConnectSharePayload(
      kind: kindTrack,
      id: track.id,
      title: track.name,
      artist: track.artists.map((a) => a.name).join(", "),
      coverUrl:
          track.album.images.isNotEmpty ? track.album.images.first.url : null,
      externalUri: track.externalUri.isNotEmpty ? track.externalUri : null,
    );
  }

  factory ConnectSharePayload.playlist({
    required DeeMusiqSimplePlaylistObject playlist,
    required List<DeeMusiqTrackObject> tracks,
  }) {
    final capped = tracks.length > maxPlaylistTracks;
    return ConnectSharePayload(
      kind: kindPlaylist,
      id: playlist.id,
      title: playlist.name,
      artist: playlist.owner.name,
      coverUrl: playlist.images.isNotEmpty ? playlist.images.first.url : null,
      externalUri:
          playlist.externalUri.isNotEmpty ? playlist.externalUri : null,
      truncated: capped,
      tracks: tracks
          .take(maxPlaylistTracks)
          .map(
            (t) => ConnectShareTrack(
              id: t.id,
              title: t.name,
              artist: t.artists.map((a) => a.name).join(", "),
              coverUrl:
                  t.album.images.isNotEmpty ? t.album.images.first.url : null,
            ),
          )
          .toList(),
    );
  }

  static String _bounded(String value) => value.length > maxFieldLength
      ? value.substring(0, maxFieldLength)
      : value;

  static ConnectShareTrack? _tryParseTrack(dynamic raw) {
    if (raw is! Map) return null;
    try {
      return ConnectShareTrack.fromJson(Map<String, dynamic>.from(raw));
    } on FormatException {
      // Skip malformed entries — one bad row must not kill the whole share.
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
        "v": version,
        "kind": kind,
        "id": id,
        "title": title,
        if (artist != null) "artist": artist,
        if (coverUrl != null) "coverUrl": coverUrl,
        if (externalUri != null) "externalUri": externalUri,
        if (tracks.isNotEmpty)
          "tracks": tracks.map((t) => t.toJson()).toList(),
        if (truncated) "truncated": true,
      };

  factory ConnectSharePayload.fromJson(Map<String, dynamic> json) {
    final version = json["v"];
    if (version is! int || version < 1 || version > currentVersion) {
      throw FormatException("Unsupported share version: $version");
    }
    final kind = json["kind"];
    if (kind != kindTrack && kind != kindPlaylist) {
      throw FormatException("Unknown share kind: $kind");
    }
    final id = json["id"];
    if (id is! String || id.isEmpty) {
      throw const FormatException("Share payload is missing an id");
    }
    final rawTracks = json["tracks"];
    return ConnectSharePayload(
      version: version,
      kind: kind,
      id: _bounded(id),
      title: _bounded(json["title"] is String ? json["title"] as String : ""),
      artist: json["artist"] is String
          ? _bounded(json["artist"] as String)
          : null,
      coverUrl: json["coverUrl"] is String
          ? _bounded(json["coverUrl"] as String)
          : null,
      externalUri: json["externalUri"] is String
          ? _bounded(json["externalUri"] as String)
          : null,
      truncated: json["truncated"] == true,
      tracks: rawTracks is List
          ? rawTracks
              .take(maxPlaylistTracks)
              .map(_tryParseTrack)
              .nonNulls
              .toList()
          : const [],
    );
  }

  /// Encodes and enforces the size guard — throws [StateError] when the
  /// message would exceed [maxBytes] (default [maxPayloadBytes]).
  String encodeChecked({int maxBytes = maxPayloadBytes}) {
    final encoded = jsonEncode(toJson());
    if (encoded.length > maxBytes) {
      throw StateError(
        "Share payload too large (${encoded.length} bytes > $maxBytes)",
      );
    }
    return encoded;
  }
}

class WebSocketShareEvent extends WebSocketEvent<ConnectSharePayload> {
  WebSocketShareEvent(ConnectSharePayload data) : super(WsEvent.share, data);

  @override
  String toJson() {
    return jsonEncode({
      "type": type.name,
      // Raw toJson here — the size guard lives on the sender path
      // ([ConnectSharePayload.encodeChecked]), not on every encode.
      "data": data.toJson(),
    });
  }
}
