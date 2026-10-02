import 'dart:async';
import 'dart:convert';

import 'package:bonsoir/bonsoir.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/models/connect/connect.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/connect/clients.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Result of a nearby-share send attempt.
enum ConnectShareResult { sent, denied, unreachable, failed }

/// "Send to nearby device" over the existing Connect infrastructure
/// (bonsoir mDNS discovery + the `/ws` WebSocket channel). Carries catalog
/// ids + metadata only — never audio bytes.
///
/// The send path deliberately opens a short-lived, dedicated WebSocket
/// connection instead of reusing [connectProvider]: resolving a peer through
/// the Connect provider would also start a remote-control session and hijack
/// the local playback state.
class ConnectShareSender {
  ConnectShareSender(this.ref);

  final Ref ref;

  static const _bonsoirType = '_spotube._tcp';
  static const _resolveTimeout = Duration(seconds: 5);
  static const _connectTimeout = Duration(seconds: 5);
  static const _denyWindow = Duration(seconds: 2);

  /// Devices currently visible via mDNS.
  List<BonsoirService> get peers =>
      ref.read(connectClientsProvider).asData?.value.services ?? const [];

  bool get hasPeers => peers.isNotEmpty;

  Future<ConnectShareResult> sendTrack(
    BonsoirService peer,
    DeeMusiqTrackObject track,
  ) =>
      send(peer, ConnectSharePayload.track(track));

  Future<ConnectShareResult> sendPlaylist(
    BonsoirService peer, {
    required DeeMusiqSimplePlaylistObject playlist,
    required List<DeeMusiqTrackObject> tracks,
  }) =>
      send(
        peer,
        ConnectSharePayload.playlist(playlist: playlist, tracks: tracks),
      );

  /// Sends a pre-built payload to [peer]. Public so UI layers that already
  /// hold a [ConnectSharePayload] (e.g. the share dialog) don't rebuild one.
  Future<ConnectShareResult> send(
    BonsoirService peer,
    ConnectSharePayload payload,
  ) async {
    final String envelope;
    try {
      // Envelope = {"type":"share","data":{...}}; guard the data size so the
      // message stays well under the WS limits on both ends.
      final data = payload.encodeChecked();
      envelope = jsonEncode({
        "type": WsEvent.share.name,
        "data": jsonDecode(data),
      });
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'ConnectShareSender.encode');
      return ConnectShareResult.failed;
    }

    ResolvedBonsoirService? resolved;
    try {
      resolved = await _resolve(peer);
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'ConnectShareSender.resolve');
      return ConnectShareResult.unreachable;
    }
    final host = resolved?.host;
    final port = resolved?.port;
    if (resolved == null || host == null || host.isEmpty || port == null) {
      AppLogger.log.w('ConnectShareSender: ${peer.name} did not resolve');
      return ConnectShareResult.unreachable;
    }

    WebSocketChannel? channel;
    try {
      channel = WebSocketChannel.connect(Uri.parse('ws://$host:$port/ws'));
      await channel.ready.timeout(_connectTimeout);
      channel.sink.add(envelope);

      // The receiver answers a refused pairing with an error event
      // ("Connection denied"); give that a short window before closing.
      final answer = await channel.stream
          .firstWhere(
            (message) =>
                message is String &&
                message.contains('"${WsEvent.error.name}"'),
            orElse: () => null,
          )
          .timeout(_denyWindow, onTimeout: () => null);
      if (answer != null) {
        AppLogger.log.w('ConnectShareSender: share refused by ${peer.name}');
        return ConnectShareResult.denied;
      }
      return ConnectShareResult.sent;
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'ConnectShareSender.send');
      return ConnectShareResult.unreachable;
    } finally {
      try {
        await channel?.sink.close();
      } catch (_) {}
    }
  }

  /// Resolves [peer] to host/port. Reuses the Connect provider's already
  /// resolved service when it matches; otherwise resolves on a scratch
  /// discovery so the remote-control session isn't disturbed.
  Future<ResolvedBonsoirService?> _resolve(BonsoirService peer) async {
    final connectState = ref.read(connectClientsProvider).asData?.value;
    final existing = connectState?.resolvedService;
    if (existing != null && existing.name == peer.name) {
      return existing;
    }

    final discovery = BonsoirDiscovery(type: _bonsoirType);
    try {
      await discovery.ready;
      await discovery.start();
    } catch (e) {
      AppLogger.log.d('ConnectShareSender: mDNS unavailable: $e');
      return null;
    }

    try {
      final completer = Completer<ResolvedBonsoirService>();
      final sub = discovery.eventStream?.listen((event) {
        if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved &&
            event.service?.name == peer.name &&
            event.service is ResolvedBonsoirService) {
          if (!completer.isCompleted) {
            completer.complete(event.service as ResolvedBonsoirService);
          }
        }
      });
      await peer.resolve(discovery.serviceResolver);
      final resolved = await completer.future.timeout(_resolveTimeout);
      await sub?.cancel();
      return resolved;
    } finally {
      await discovery.stop();
    }
  }
}

final connectShareProvider = Provider<ConnectShareSender>(
  (ref) => ConnectShareSender(ref),
);
