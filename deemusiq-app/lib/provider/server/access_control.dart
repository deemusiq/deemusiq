import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shelf/shelf.dart';
import 'package:deemusiq/provider/server/routes/connect.dart';
import 'package:deemusiq/provider/user_preferences/user_preferences_provider.dart';

/// Access control for the Connect LAN/loopback HTTP endpoints (audit H1).
///
/// `/stream/*`, `/playback/*` and `/offline/*` were previously callable by
/// anyone on the LAN (when Connect is enabled) and by any web page open in a
/// local browser (drive-by GETs against the loopback server). Policy:
///
/// - Loopback callers with no browser markers are in-app traffic
///   (media_kit/ffmpeg/dio) and pass.
/// - Requests carrying browser markers (`Origin` / `Sec-Fetch-Site` — browsers
///   attach them to every fetch/XHR/beacon; the in-app callers never do) are
///   rejected outright, on loopback AND remotely.
/// - Any other off-device caller needs a per-pairing token minted when the
///   user approved the pairing on the WebSocket route
///   ([ServerConnectRoutes.isPairingTokenValid]). When Connect is disabled the
///   server only binds loopback, and off-device requests are rejected here
///   too (defence in depth).
///
/// `/ping` is intentionally NOT covered: discovery needs an unauthenticated
/// presence probe, and it leaks nothing beyond "something answers here".
class ConnectAccessGuard {
  final Ref ref;
  ConnectAccessGuard(this.ref);

  static const tokenHeader = 'x-dm-connect-token';
  static const tokenQueryParam = 'token';

  static const _jsonHeaders = {
    'content-type': 'application/json; charset=utf-8',
  };

  /// Returns the denial [Response] when [request] may not proceed, else null.
  Response? denyResponse(Request request) {
    final connectionInfo =
        request.context['shelf.io.connection_info'] as HttpConnectionInfo?;
    return check(
      isLoopback: connectionInfo?.remoteAddress.isLoopback ?? false,
      connectEnabled: ref
          .read(userPreferencesProvider.select((v) => v.enableConnect)),
      headers: request.headers,
      queryToken: request.url.queryParameters[tokenQueryParam],
      isTokenValid: ref.read(serverConnectRoutesProvider).isPairingTokenValid,
    );
  }

  /// The pure decision, split out so tests don't need a shelf Request or a
  /// dart:io [HttpConnectionInfo].
  @visibleForTesting
  static Response? check({
    required bool isLoopback,
    required bool connectEnabled,
    required Map<String, String> headers,
    required String? queryToken,
    required bool Function(String token) isTokenValid,
  }) {
    String header(String name) => headers[name.toLowerCase()] ?? '';

    // Browser drive-by: any Origin/Sec-Fetch-Site header means a browser
    // fired this — media players and dio never send them.
    if (header('origin').isNotEmpty || header('sec-fetch-site').isNotEmpty) {
      return Response.forbidden(
        jsonEncode({'message': 'Browser-originated requests are not accepted'}),
        headers: _jsonHeaders,
      );
    }

    if (isLoopback) return null; // in-app playback engine traffic

    if (!connectEnabled) {
      // Connect off ⇒ loopback bind; an off-device request should be
      // impossible. Reject anyway (defence in depth).
      return Response.forbidden(
        jsonEncode({'message': 'Connect is disabled'}),
        headers: _jsonHeaders,
      );
    }

    final headerToken = header(tokenHeader);
    final token = headerToken.isNotEmpty ? headerToken : (queryToken ?? '');
    if (token.isNotEmpty && isTokenValid(token)) return null;

    return Response(
      401,
      body: jsonEncode({'message': 'Pairing required'}),
      headers: _jsonHeaders,
    );
  }
}

final connectAccessGuardProvider =
    Provider((ref) => ConnectAccessGuard(ref));
