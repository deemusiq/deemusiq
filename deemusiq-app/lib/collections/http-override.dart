import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:deemusiq/services/connectivity_adapter.dart';
import 'package:deemusiq/services/logger/logger.dart';

const allowList = [
  "spotify.com",
];

/// SECURITY: Custom HttpOverrides that permits bad certificates ONLY for
/// Spotify API hosts (a legacy workaround for Spotify's cert issues).
///
/// IMPORTANT: This MUST NOT be set as HttpOverrides.global — it should be
/// applied ONLY to the HttpClient used for Spotify metadata API calls. Setting
/// it globally would expose ALL app HTTP traffic (including backend wallet/
/// payment calls) to potential MITM attacks.
///
/// The global assignment in main.dart has been removed; Spotify-specific Dio
/// instances should inject this HttpClient directly instead.
class BadCertificateAllowlistOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return allowList.any((allowedHost) {
          return host.endsWith(allowedHost);
        });
      };
  }
}

/// ---------------------------------------------------------------------------
/// Server TLS certificate pinning for the DeeMusiq backend.
/// ---------------------------------------------------------------------------
///
/// The pinned hash (DEEMUSIQ_SERVER_CERT_SHA256) is the SHA-256 fingerprint of
/// the backend's TLS certificate, set at build time via `--dart-define`.
/// When configured, the Dio client for wallet/payment/account calls will reject
/// any connection where the server's leaf certificate doesn't match — even if
/// a trusted CA signed it. This defeats compromised/intermediate CAs and
/// DNS-poisoning + a valid-but-wrong cert.
///
/// Generate the pin with:
///   openssl s_client -connect api.deemusiq.co.za:443 </dev/null 2>/dev/null \
///     | openssl x509 -noout -fingerprint -sha256 \
///     | tr -d ':' | cut -d= -f2
///
/// Leave empty for dev/test (pinning disabled, standard PKI validation only).

/// SHA-256 of the backend's leaf TLS certificate (lowercase hex, no colons).
/// Multiple pins may be comma-separated to smooth certificate rotation.
const String _serverCertPin = String.fromEnvironment(
  'DEEMUSIQ_SERVER_CERT_SHA256',
  defaultValue: '',
);

/// The normalized, well-formed pins from [_serverCertPin]; malformed entries
/// are dropped so a typo can never widen or narrow the trust set.
List<String> get serverCertPins => _serverCertPin
    .split(',')
    .map((p) => p.toLowerCase().replaceAll(RegExp(r'[^0-9a-f]'), ''))
    .where((p) => p.length == 64)
    .toList(growable: false);

bool get serverCertPinningEnabled =>
    serverCertPins.isNotEmpty && !_serverCertPin.contains('change-me');

/// Timing-safe string comparison — used for every pin/digest equality check
/// so a mismatch leaks nothing through early-exit timing.
bool constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}

/// Validates the server's X.509 certificate against the pinned SHA-256
/// hash(es). Extracts DER bytes from the PEM-encoded certificate, computes
/// SHA-256, and constant-time compares against every configured pin.
bool validateServerCertSha256(X509Certificate cert) {
  final pins = serverCertPins;
  if (!serverCertPinningEnabled || pins.isEmpty) return true;

  // Extract DER bytes from PEM: find base64 content between header and footer.
  final pem = cert.pem;
  final lines = pem.split('\n');
  final b64 = lines
      .where((l) => !l.startsWith('-----'))
      .join();
  final der = base64Decode(b64);
  final digest = sha256.convert(der);
  final actual = digest.toString();
  return pins.any((pin) => constantTimeEquals(pin, actual));
}

const String _backendBaseUrl =
    String.fromEnvironment("DEEMUSIQ_BACKEND_URL", defaultValue: "");

/// The host the TLS pin applies to, resolved from the same build-time define
/// the wallet client uses. Define-local (like [BackendCertPinProbe.start]'s
/// parameter) so this module stays dependency-light.
String? get _backendPinHost {
  if (_backendBaseUrl.isEmpty) return null;
  final host = Uri.tryParse(_backendBaseUrl)?.host;
  return host == null || host.isEmpty ? null : host;
}

/// HttpOverrides that enforces TLS certificate pinning for the backend host
/// AND allows bad certs only for Spotify API hosts.
///
/// NOTE: The `badCertificateCallback` is called on every secure handshake on
/// Android/iOS, but on some desktop platforms it may only fire when standard
/// PKI validation FAILS. Where it fires on every connection, the backend cert
/// pinning (DEEMUSIQ_SERVER_CERT_SHA256) provides full protection against
/// compromised CAs and MITM proxies. Where it only fires on failures, it still
/// protects against invalid/self-signed cert MITM — and the secure channel
/// (AES-256-GCM) provides defense-in-depth for payload confidentiality.
class DeeMusiqHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        if (kDebugMode && allowList.any((h) => host.endsWith(h))) return true;

        // The pin judges ONLY the backend host. Where this callback fires for
        // every handshake (Android/iOS), applying it to unrelated hosts would
        // reject their valid certificates and break playback/metadata calls.
        final pinnedHost = _backendPinHost;
        if (serverCertPinningEnabled &&
            pinnedHost != null &&
            host == pinnedHost) {
          return validateServerCertSha256(cert);
        }

        return false;
      };
  }
}

/// ---------------------------------------------------------------------------
/// ACTIVE backend TLS pin probe.
/// ---------------------------------------------------------------------------

/// Outcome of the most recent [BackendCertPinProbe] run.
enum BackendPinProbeState {
  /// No pin configured (dev builds) or no backend URL — probe not applicable.
  disabled,

  /// No probe has completed yet this session.
  unknown,

  /// The backend presented a certificate matching a configured pin.
  verified,

  /// The backend is REACHABLE but presented a certificate matching NO
  /// configured pin — a valid-but-wrong cert (compromised CA / MITM proxy).
  /// Money features must lock, exactly like a tampered build.
  failed,

  /// The backend could not be reached (offline / DNS / timeout). Verdict
  /// deferred: callers degrade to normal offline behavior and lock NOTHING.
  unreachable,
}

/// Active verification of the backend TLS pin.
///
/// [DeeMusiqHttpOverrides.badCertificateCallback] only fires when PLATFORM
/// validation fails, so a valid-but-wrong certificate (compromised CA,
/// enterprise MITM) is never presented to it. This probe closes that gap: it
/// opens a raw [SecureSocket] to the backend — deliberately accepting any
/// chain at the socket level so the wrong-but-valid cert still reaches the
/// comparison — and checks the peer leaf certificate against the build-time
/// pin itself.
///
/// The verdict is cached in [state], refreshed every [refreshInterval] and on
/// connectivity regain, and consumed by `IntegrityService.walletLocked` so a
/// FAILED probe blocks wallet/payment operations through the existing
/// integrity lock path.
class BackendCertPinProbe {
  BackendCertPinProbe._();

  static final ValueNotifier<BackendPinProbeState> state =
      ValueNotifier(BackendPinProbeState.unknown);

  /// The cached verdict: true/false once a probe has completed, null while
  /// disabled, unknown or unreachable (offline — no judgement either way).
  static bool? get backendPinVerified => switch (state.value) {
        BackendPinProbeState.verified => true,
        BackendPinProbeState.failed => false,
        _ => null,
      };

  static const refreshInterval = Duration(hours: 6);
  static const _connectTimeout = Duration(seconds: 10);

  static Timer? _timer;
  static StreamSubscription<bool>? _connectivitySub;
  static String? _backendBaseUrl;
  static bool _started = false;

  /// Starts the startup probe, the periodic refresh and the
  /// connectivity-regain re-probe. [backendBaseUrl] is passed in (rather than
  /// imported from the wallet services) to keep this module dependency-light.
  static void start(String backendBaseUrl) {
    if (_started) return;
    _started = true;
    _backendBaseUrl = backendBaseUrl;
    if (!serverCertPinningEnabled || backendBaseUrl.isEmpty) {
      state.value = BackendPinProbeState.disabled;
      return;
    }
    unawaited(verify());
    _timer = Timer.periodic(refreshInterval, (_) => unawaited(verify()));
    _connectivitySub =
        ConnectionCheckerService.instance.onConnectivityChanged.listen(
      (connected) {
        // A network change may mean a new (hostile) path — re-prove the pin.
        if (connected) unawaited(verify());
      },
    );
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
    _connectivitySub?.cancel();
    _connectivitySub = null;
    _started = false;
  }

  /// Runs one probe now and updates [state]. Never throws.
  static Future<BackendPinProbeState> verify() async {
    if (!serverCertPinningEnabled) {
      state.value = BackendPinProbeState.disabled;
      return state.value;
    }
    final base = _backendBaseUrl;
    final uri = base == null ? null : Uri.tryParse(base);
    if (uri == null || uri.host.isEmpty) {
      state.value = BackendPinProbeState.disabled;
      return state.value;
    }
    final port = uri.hasPort ? uri.port : 443;
    SecureSocket? socket;
    try {
      socket = await SecureSocket.connect(
        uri.host,
        port,
        // Platform validation is bypassed ON PURPOSE here: the probe's whole
        // job is to judge the peer certificate against the pin itself, so a
        // valid-but-wrong chain must still reach the pin comparison below.
        onBadCertificate: (_) => true,
      ).timeout(_connectTimeout);
      final peer = socket.peerCertificate;
      if (peer == null) {
        state.value = BackendPinProbeState.unreachable;
      } else if (validateServerCertSha256(peer)) {
        state.value = BackendPinProbeState.verified;
      } else {
        state.value = BackendPinProbeState.failed;
        AppLogger.log.e(
          'BackendCertPinProbe: backend presented an UNPINNED certificate '
          '(possible MITM / compromised CA)',
        );
      }
    } catch (_) {
      // Offline, DNS failure, timeout, handshake reset: degrade to the normal
      // offline behavior — an unreachable host is not tamper evidence.
      state.value = BackendPinProbeState.unreachable;
    } finally {
      socket?.destroy();
    }
    return state.value;
  }
}
