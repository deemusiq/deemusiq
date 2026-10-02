import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:deemusiq/collections/routes.dart';
import 'package:deemusiq/collections/routes.gr.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/models/connect/connect.dart';
import 'package:deemusiq/models/metadata/metadata.dart';

import 'package:deemusiq/provider/history/history.dart';
import 'package:deemusiq/provider/audio_player/audio_player.dart';
import 'package:deemusiq/provider/metadata_plugin/metadata_plugin_provider.dart';
import 'package:deemusiq/provider/volume_provider.dart';
import 'package:deemusiq/services/audio_player/audio_player.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/utils/primitive_utils.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

extension _WebsocketSinkExts on WebSocketSink {
  void addEvent(WebSocketEvent event) {
    add(event.toJson());
  }
}

class ServerConnectRoutes {
  final Ref ref;
  final StreamController<String> _connectClientStreamController;

  /// Every connection registers its teardown closers (stream subscriptions +
  /// the ref.listen queue listener) here, keyed per connection (M4): closing
  /// one connection cancels only its own closers — previously a single shared
  /// list meant one disconnect silently killed every other client's handlers.
  final Set<List<void Function()>> _connectionClosers;
  ServerConnectRoutes(this.ref)
      : _connectClientStreamController = StreamController<String>.broadcast(),
        _connectionClosers = {} {
    ref.onDispose(() {
      _connectClientStreamController.close();
      for (final closers in _connectionClosers) {
        for (final close in closers) {
          close();
        }
      }
      _connectionClosers.clear();
    });
  }

  AudioPlayerNotifier get audioPlayerNotifier =>
      ref.read(audioPlayerProvider.notifier);
  PlaybackHistoryActions get historyNotifier =>
      ref.read(playbackHistoryActionsProvider);
  Stream<String> get connectClientStream =>
      _connectClientStreamController.stream;

  // Inbound guards, mirroring ConnectNotifier's client-side limits — the
  // nearby-share feature opened this endpoint to larger incoming messages.
  static const _wsMaxMsgSize = 1000000; // 1 MB
  static const _wsMaxMsgPerSec = 10;

  /// M3: cap concurrent WS connections so a LAN flood can't exhaust fds/memory.
  static const _maxConcurrentConnections = 8;
  int _activeConnections = 0;

  /// M3: pairing-prompt throttling — one dialog at a time, and an origin that
  /// was just prompted (approved or declined) can't trigger another prompt
  /// for [_pairingPromptCooldown], so a reconnect loop can't spam dialogs.
  bool _pairingDialogOpen = false;
  final Map<String, DateTime> _pairingPromptedAt = {};
  static const _pairingPromptCooldown = Duration(seconds: 30);

  final List<String> _allowedConnections = [];
  static const _maxAllowedConnections = 50;
  final Map<String, DateTime> _connectionTimestamps = {};

  /// Per-pairing tokens (H1): minted when the user approves the pairing
  /// dialog and handed to the client over the freshly-paired socket
  /// ([WebSocketPairedEvent]); required on the LAN HTTP endpoints
  /// (`/stream/*`, `/playback/*`, `/offline/*`) for off-device callers.
  /// token → (origin, issuedAt). In-memory only — a server restart revokes
  /// every pairing silently, which is acceptable for a LAN session feature.
  final Map<String, ({String origin, DateTime issuedAt})> _pairingTokens = {};
  static const _maxPairingTokens = 50;

  void _pruneStaleConnections() {
    final now = DateTime.now();
    const maxAge = Duration(hours: 24);
    _connectionTimestamps.removeWhere((_, ts) => now.difference(ts) > maxAge);
    _allowedConnections.removeWhere((o) => !_connectionTimestamps.containsKey(o));
    _pairingTokens.removeWhere((_, t) => now.difference(t.issuedAt) > maxAge);
    _pairingPromptedAt.removeWhere(
      (_, ts) => now.difference(ts) > _pairingPromptCooldown,
    );
  }

  void _addAllowedConnection(String origin) {
    _pruneStaleConnections();
    if (_allowedConnections.length >= _maxAllowedConnections) {
      final oldest = _connectionTimestamps.entries.reduce(
        (a, b) => a.value.isBefore(b.value) ? a : b,
      );
      _connectionTimestamps.remove(oldest.key);
      _allowedConnections.remove(oldest.key);
    }
    _allowedConnections.add(origin);
    _connectionTimestamps[origin] = DateTime.now();
    _bumpPairingRevision();
  }

  String _issuePairingToken(String origin) {
    _pruneStaleConnections();
    if (_pairingTokens.length >= _maxPairingTokens) {
      final oldest = _pairingTokens.entries.reduce(
        (a, b) => a.value.issuedAt.isBefore(b.value.issuedAt) ? a : b,
      );
      _pairingTokens.remove(oldest.key);
    }
    final token = PrimitiveUtils.uuid.v4() + PrimitiveUtils.uuid.v4();
    _pairingTokens[token] = (origin: origin, issuedAt: DateTime.now());
    return token;
  }

  /// True when [token] was minted by a pairing approval and hasn't expired.
  bool isPairingTokenValid(String token) {
    _pruneStaleConnections();
    return _pairingTokens.containsKey(token);
  }

  /// Paired origins as shown in Settings → Connect ("Paired devices", M5).
  List<String> get pairedOrigins => List.unmodifiable(_allowedConnections);

  /// Revokes one paired origin: its WS allowlist entry AND its HTTP tokens.
  void revokePairing(String origin) {
    _allowedConnections.remove(origin);
    _connectionTimestamps.remove(origin);
    _pairingTokens.removeWhere((_, t) => t.origin == origin);
    _bumpPairingRevision();
  }

  void revokeAllPairings() {
    _allowedConnections.clear();
    _connectionTimestamps.clear();
    _pairingTokens.clear();
    _bumpPairingRevision();
  }

  void _bumpPairingRevision() {
    try {
      ref.read(pairedDevicesRevisionProvider.notifier).state++;
    } catch (_) {
      // Provider not initialized yet (e.g. early pairing before the UI
      // watches it) — the next read sees the current list regardless.
    }
  }

  FutureOr<Response> websocket(Request req) {
    // Browser drive-by blunting (H1): browsers attach Origin to WebSocket
    // handshakes; the app's dart:io WebSocket client never does. A web page
    // open on this machine must not even reach the pairing dialog.
    if (req.headers['origin'] != null || req.headers['sec-fetch-site'] != null) {
      return Response.forbidden(
        jsonEncode({'message': 'Browser-originated requests are not accepted'}),
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    }
    return webSocketHandler(
      (
        WebSocketChannel channel,
        String? protocol,
      ) async {
        final context =
            (req.context["shelf.io.connection_info"] as HttpConnectionInfo?);
        final origin = "${context?.remoteAddress.host}:${context?.remotePort}";
        _connectClientStreamController.add(origin);

        // M3: refuse the flood before any dialog/state work.
        if (_activeConnections >= _maxConcurrentConnections) {
          AppLogger.log.w(
            'Connect: denying $origin — connection cap reached',
          );
          channel.sink.addEvent(WebSocketErrorEvent("Too many connections"));
          await channel.sink.close(status.policyViolation);
          return;
        }
        _activeConnections++;

        // Confirm whether user allows to connect.
        // Security: an unknown origin is DENIED unless the UI can show the
        // approval dialog. Previously, a missing/unmounted navigator context
        // skipped the prompt entirely and the socket was admitted unauthenticated.
        final alreadyAllowed = _allowedConnections.contains(origin);
        if (!alreadyAllowed) {
          final navContext = rootNavigatorKey.currentContext;
          final canPrompt = navContext?.mounted == true;
          // M3: serialize pairing dialogs (one at a time) and debounce
          // prompts per origin — a LAN attacker reconnecting in a loop must
          // not spam modal approvals.
          final lastPrompt = _pairingPromptedAt[origin];
          final debounced = lastPrompt != null &&
              DateTime.now().difference(lastPrompt) < _pairingPromptCooldown;
          bool confirmed = false;
          if (canPrompt && !_pairingDialogOpen && !debounced) {
            _pairingDialogOpen = true;
            _pairingPromptedAt[origin] = DateTime.now();
            try {
              confirmed = await showDialog<bool>(
                    context: navContext!,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(context.l10n.connect),
                        content: Text(
                          context.l10n.connect_request(origin),
                        ),
                        actions: [
                          Button.secondary(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text(context.l10n.decline),
                          ),
                          Button.primary(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Text(context.l10n.accept),
                          ),
                        ],
                      );
                    },
                  ) ??
                  false;
            } finally {
              _pairingDialogOpen = false;
            }
          } else {
            AppLogger.log.w(
              'Connect: denying $origin — ${!canPrompt ? 'UI not ready to approve pairing' : (_pairingDialogOpen ? 'another pairing prompt is open' : 'prompt debounced')}',
            );
          }

          if (confirmed) {
            _addAllowedConnection(origin);
          } else {
            channel.sink.addEvent(
              WebSocketErrorEvent("Connection denied"),
            );
            await channel.sink.close();
            _activeConnections--;
            return;
          }
        }

        // Teardown for THIS connection only (M4): stream subscriptions plus
        // the ref.listen queue listener (captured so it can't accumulate).
        final connectionClosers = <void Function()>[];
        _connectionClosers.add(connectionClosers);
        var closed = false;
        void closeConnection() {
          if (closed) return;
          closed = true;
          for (final close in connectionClosers) {
            close();
          }
          _connectionClosers.remove(connectionClosers);
          _activeConnections--;
        }

        final queueListener = ref.listen(
          audioPlayerProvider,
          (previous, next) {
            channel.sink.addEvent(WebSocketQueueEvent(next));
          },
          fireImmediately: true,
        );
        connectionClosers.add(queueListener.close);

        // H1: hand the freshly-paired client its per-pairing token for the
        // LAN HTTP endpoints. Unknown event type to older builds — they map
        // it to an error log line, harmless.
        if (_pairingTokens.values.any((t) => t.origin == origin)) {
          _pairingTokens.removeWhere((_, t) => t.origin == origin);
        }
        channel.sink.addEvent(WebSocketPairedEvent(_issuePairingToken(origin)));

        // because audioPlayer events doesn't fireImmediately
        channel.sink.addEvent(WebSocketPlayingEvent(audioPlayer.isPlaying));
        channel.sink.addEvent(
          WebSocketPositionEvent(audioPlayer.position),
        );
        channel.sink.addEvent(
          WebSocketDurationEvent(audioPlayer.duration),
        );
        channel.sink.addEvent(WebSocketShuffleEvent(audioPlayer.isShuffled));
        channel.sink.addEvent(WebSocketLoopEvent(audioPlayer.loopMode));
        channel.sink.addEvent(WebSocketVolumeEvent(audioPlayer.volume));

        // Per-connection inbound guard state (see _wsMaxMsgSize/_wsMaxMsgPerSec).
        var wsMsgCount = 0;
        var wsLastResetMs = 0;

        connectionClosers.addAll([
          audioPlayer.positionStream.listen(
            (position) {
              channel.sink.addEvent(WebSocketPositionEvent(position));
            },
          ).cancel,
          audioPlayer.playingStream.listen(
            (playing) {
              channel.sink.addEvent(WebSocketPlayingEvent(playing));
            },
          ).cancel,
          audioPlayer.durationStream.listen(
            (duration) {
              channel.sink.addEvent(WebSocketDurationEvent(duration));
            },
          ).cancel,
          audioPlayer.shuffledStream.listen(
            (shuffled) {
              channel.sink.addEvent(WebSocketShuffleEvent(shuffled));
            },
          ).cancel,
          audioPlayer.loopModeStream.listen(
            (loopMode) {
              channel.sink.addEvent(WebSocketLoopEvent(loopMode));
            },
          ).cancel,
          audioPlayer.volumeStream.listen(
            (volume) {
              channel.sink.addEvent(WebSocketVolumeEvent(volume));
            },
          ).cancel,
          channel.stream.listen(
            (message) async {
              try {
                if (message is! String || message.length > _wsMaxMsgSize) {
                  AppLogger.log.w(
                    'WebSocket message exceeds max size, closing connection',
                  );
                  await channel.sink.close(status.protocolError);
                  return;
                }

                final nowMs = DateTime.now().millisecondsSinceEpoch;
                if (nowMs - wsLastResetMs > 1000) {
                  wsMsgCount = 0;
                  wsLastResetMs = nowMs;
                }
                wsMsgCount++;
                if (wsMsgCount > _wsMaxMsgPerSec) {
                  AppLogger.log.w(
                    'WebSocket rate limit exceeded, closing connection',
                  );
                  await channel.sink.close(status.protocolError);
                  return;
                }

                final event = WebSocketEvent.fromJson(
                  jsonDecode(message),
                  (data) => data,
                );

                event.onLoad((event) async {
                  await audioPlayerNotifier.load(
                    event.data.tracks.cast<DeeMusiqFullTrackObject>().toList(),
                    autoPlay: true,
                    initialIndex: event.data.initialIndex ?? 0,
                  );

                  if (event.data.collectionId == null) return;
                  audioPlayerNotifier.addCollection(event.data.collectionId!);
                  if (event.data.collection is DeeMusiqSimpleAlbumObject) {
                    historyNotifier.addAlbums(
                        [event.data.collection as DeeMusiqSimpleAlbumObject]);
                  } else {
                    historyNotifier.addPlaylists(
                        [event.data.collection as DeeMusiqSimplePlaylistObject]);
                  }
                });

                event.onPause((event) async {
                  await audioPlayer.pause();
                });

                event.onResume((event) async {
                  await audioPlayer.resume();
                });

                event.onStop((event) async {
                  await ref.read(audioPlayerProvider.notifier).stop();
                });

                event.onNext((event) async {
                  await audioPlayer.skipToNext();
                });

                event.onPrevious((event) async {
                  await audioPlayer.skipToPrevious();
                });

                event.onJump((event) async {
                  await audioPlayer.jumpTo(event.data);
                });

                event.onSeek((event) async {
                  await audioPlayer.seek(event.data);
                });

                event.onShuffle((event) async {
                  await audioPlayer.setShuffle(event.data);
                });

                event.onLoop((event) async {
                  await audioPlayer.setLoopMode(event.data);
                });

                event.onAddTrack((event) async {
                  await audioPlayerNotifier.addTrack(event.data);
                });

                event.onRemoveTrack((event) async {
                  await audioPlayerNotifier.removeTrack(event.data);
                });

                event.onReorder((event) async {
                  await audioPlayerNotifier.moveTrack(
                    event.data.oldIndex,
                    event.data.newIndex,
                  );
                });

                event.onVolume((event) async {
                  ref.read(volumeProvider.notifier).setVolume(event.data);
                });

                event.onShare((event) async {
                  await _handleIncomingShare(event.data, channel);
                });
              } catch (e, stackTrace) {
                AppLogger.reportError(e, stackTrace);
                channel.sink.addEvent(WebSocketErrorEvent(e.toString()));
              }
            },
            onDone: () {
              // Tear down THIS connection's subscriptions only — other paired
              // clients keep their handlers (M4).
              closeConnection();
              AppLogger.log.i('Connection closed');
            },
            onError: (error) {
              AppLogger.log.w('WebSocket error: $error');
              closeConnection();
            },
          ).cancel,
        ]);
      },
    )(req);
  }

  /// Incoming "Send to nearby device" payload: confirm with the user, then
  /// resolve the shared id against the local catalog/backend and open (playlist)
  /// or enqueue (track) it. Ids that don't resolve (different catalog region,
  /// removed content) get a plain toast instead of an error.
  Future<void> _handleIncomingShare(
    ConnectSharePayload payload,
    WebSocketChannel channel,
  ) async {
    final navContext = rootNavigatorKey.currentContext;
    if (navContext?.mounted != true) {
      AppLogger.log.w('Connect share: dropping incoming share — UI not ready');
      return;
    }

    final isPlaylist = payload.kind == ConnectSharePayload.kindPlaylist;
    final label = isPlaylist
        ? 'playlist "${payload.title}"'
        : '"${payload.title}"${payload.artist != null ? ' by ${payload.artist}' : ''}';

    final confirmed = await showDialog<bool>(
          context: navContext!,
          builder: (context) {
            return AlertDialog(
              title: const Text('Incoming share'),
              content: Text(
                'A nearby device wants to share $label with you.'
                '${payload.truncated ? ' (only the first ${ConnectSharePayload.maxPlaylistTracks} tracks are included)' : ''}',
              ),
              actions: [
                Button.secondary(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(context.l10n.decline),
                ),
                Button.primary(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(context.l10n.accept),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!confirmed) return;

    try {
      final plugin = await ref.read(metadataPluginProvider.future);
      if (plugin == null) {
        throw StateError('No metadata plugin available');
      }

      if (isPlaylist) {
        final playlist = await plugin.playlist.getPlaylist(payload.id);
        final simple = DeeMusiqSimplePlaylistObject(
          id: playlist.id,
          name: playlist.name,
          description: playlist.description,
          externalUri: playlist.externalUri,
          owner: playlist.owner,
          images: playlist.images,
        );
        if (navContext.mounted) {
          await navContext.navigateTo(
            PlaylistRoute(id: playlist.id, playlist: simple),
          );
        }
      } else {
        final track = await plugin.track.getTrack(payload.id);
        await audioPlayerNotifier.addTrack(track);
        if (navContext.mounted) {
          showWalletToast(
            navContext,
            'Added "${track.name}" to the queue',
            icon: DeeMusiqIcons.queueAdd,
          );
        }
      }
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'ConnectShareReceiver');
      if (navContext.mounted) {
        showWalletToast(
          navContext,
          "Couldn't find the shared ${isPlaylist ? 'playlist' : 'track'} "
          'in the catalog on this device.',
          icon: DeeMusiqIcons.error,
        );
      }
    }
  }
}

final serverConnectRoutesProvider = Provider((ref) => ServerConnectRoutes(ref));

/// Bumped whenever the pairing allowlist/token set changes (pair, revoke) so
/// the Settings "Paired devices" list (M5) re-reads [ServerConnectRoutes].
final pairedDevicesRevisionProvider = StateProvider<int>((ref) => 0);
