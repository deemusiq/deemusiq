import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:deemusiq/provider/server/access_control.dart';
import 'package:deemusiq/provider/server/routes/connect.dart';
import 'package:deemusiq/provider/server/routes/playback.dart';

final serverRouterProvider = Provider((ref) {
  final playbackRoutes = ref.watch(serverPlaybackRoutesProvider);
  final connectRoutes = ref.watch(serverConnectRoutesProvider);
  final accessGuard = ref.watch(connectAccessGuardProvider);

  // H1: streaming/playback-control endpoints require either loopback in-app
  // traffic (no browser markers) or a per-pairing token minted at WS pairing
  // approval — see ConnectAccessGuard.
  FutureOr<Response> gated(Request request, FutureOr<Response> Function() handler) {
    final denied = accessGuard.denyResponse(request);
    if (denied != null) return denied;
    return handler();
  }

  final router = Router();

  // Unauthenticated on purpose: Connect discovery needs a presence probe, and
  // this leaks nothing beyond "a DeeMusiq instance answers here".
  router.get("/ping", (Request request) => Response.ok("pong"));

  router.head(
    "/stream/<trackId>",
    (Request request, String trackId) =>
        gated(request, () => playbackRoutes.headStreamTrackId(request, trackId)),
  );
  router.get(
    "/stream/<trackId>",
    (Request request, String trackId) =>
        gated(request, () => playbackRoutes.getStreamTrackId(request, trackId)),
  );
  // Adaptive manifests with segment URLs rewritten through the loopback
  // proxy, and the segment proxy itself (see StreamProxy in upstream Spotube).
  router.get(
    "/stream/<trackId>/manifest",
    (Request request, String trackId) =>
        gated(request, () => playbackRoutes.getStreamManifest(request, trackId)),
  );
  router.get(
    "/stream/<trackId>/segment",
    (Request request, String trackId) =>
        gated(request, () => playbackRoutes.getStreamSegment(request, trackId)),
  );

  // DRM-protected offline downloads, decrypted in memory (license-gated).
  router.get(
    "/offline/<name>",
    (Request request, String name) =>
        gated(request, () => playbackRoutes.getOfflineTrack(request, name)),
  );

  router.get(
    "/playback/toggle-playback",
    (Request request) => gated(request, () => playbackRoutes.togglePlayback(request)),
  );
  router.get(
    "/playback/previous",
    (Request request) => gated(request, () => playbackRoutes.previousTrack(request)),
  );
  router.get(
    "/playback/next",
    (Request request) => gated(request, () => playbackRoutes.nextTrack(request)),
  );

  router.all("/ws", connectRoutes.websocket);

  return router;
});
