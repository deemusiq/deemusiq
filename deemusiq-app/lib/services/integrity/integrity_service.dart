import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:deemusiq/collections/http-override.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/wallet/payment_service.dart'
    show PaymentGatewayConfig;
import 'package:deemusiq/services/wallet/wallet_api.dart';
import 'package:deemusiq/utils/platform.dart';

/// Result of the most recent integrity evaluation.
///
/// - [ok]: nothing wrong detected (or checks not applicable on this platform).
/// - [walletLocked]: the installed APK does not match the hash GitHub published
///   for this release. Money features are disabled; playback keeps working.
/// - [bricked]: the build is signed with a certificate other than the pinned
///   release certificate — a repackaged app. The app refuses to run.
enum IntegrityVerdict { ok, walletLocked, bricked }

/// Anti-tamper / integrity verification.
///
/// Two independent signals, by design:
///  1. **Signing certificate** (local, offline, strong): a modified APK must be
///     re-signed with a different key, which changes this hash. When the
///     expected hash is pinned via [expectedCertSha256], a mismatch bricks the
///     app at boot. This is the primary protection and needs no network.
///  2. **Published APK hash** (online, supplementary): the app compares its own
///     on-disk APK against the SHA-256 GitHub Actions published for the release.
///     A confirmed mismatch locks the wallet and is reported to the backend; an
///     unreachable hash endpoint is treated as "unknown" and never locks anyone.
///     When [integritySigningPublicKey] is configured, the payload must also
///     carry a valid `X-Body-Signature` (hex Ed25519 over the raw body) — an
///     unsigned/invalid payload is itself treated as tamper evidence.
///
/// A third signal gates money features without a verdict: the ACTIVE backend
/// TLS pin probe ([BackendCertPinProbe]) — see [walletLocked].
///
/// Honest limits: client-side checks raise the bar against casual repackaging
/// and give the operator telemetry, but they are not unbreakable DRM. The money
/// guarantee comes from the backend owning the crypto deposit address and
/// confirming funds on-chain — a fake app can never redirect a real top-up.
class IntegrityService {
  IntegrityService._() {
    // A failed ACTIVE TLS pin probe (backend reachable but its certificate
    // matches no build-time pin — compromised CA / MITM) locks money features
    // through the same wallet-lock path as a tampered build.
    BackendCertPinProbe.state.addListener(_onBackendPinProbe);
  }
  static final IntegrityService instance = IntegrityService._();

  static const MethodChannel _channel = MethodChannel("deemusiq/integrity");

  /// Expected SHA-256 of the signing certificate (lowercase hex, no colons).
  /// Set via `--dart-define=DEEMUSIQ_CERT_SHA256=...` once a PERMANENT keystore
  /// is in use. Empty => the cert check is informational only, because the
  /// temporary CI keystore produces a different certificate on every build and
  /// cannot be pinned.
  static final String expectedCertSha256 = _normalizeHash(
    const String.fromEnvironment("DEEMUSIQ_CERT_SHA256", defaultValue: ""),
  );

  /// URL of the published SHA-256 of the release APK. Defaults to the
  /// project site's Cloudflare-proxied copy so the app never references the
  /// build host directly; override with `--dart-define` if self-hosting.
  static const String apkHashUrl = String.fromEnvironment(
    "DEEMUSIQ_INTEGRITY_HASH_URL",
    defaultValue: "https://deemusiq.co.za/downloads/android.sha256",
  );

  /// Base64 Ed25519 public key verifying the download worker's
  /// `X-Body-Signature` header (hex Ed25519 over the raw response body) on the
  /// published-hash payload. When set, an unsigned or invalid payload is
  /// treated as tamper evidence (fail closed — it never unlocks the wallet);
  /// when empty, the legacy unsigned payload is accepted as-is.
  static const String integritySigningPublicKey = String.fromEnvironment(
    "DEEMUSIQ_INTEGRITY_ED25519_PUBLIC_KEY",
    defaultValue: "",
  );

  final ValueNotifier<IntegrityVerdict> verdict =
      ValueNotifier<IntegrityVerdict>(IntegrityVerdict.ok);

  /// Set by the active backend TLS pin probe (see [BackendCertPinProbe]).
  /// Only a definitive FAILED probe (pin configured + host reachable + cert
  /// mismatch) sets this; offline/unknown states never do, so a phone without
  /// connectivity degrades to normal offline behavior instead of bricking.
  bool _backendPinFailed =
      BackendCertPinProbe.state.value == BackendPinProbeState.failed;

  void _onBackendPinProbe() {
    final failed =
        BackendCertPinProbe.state.value == BackendPinProbeState.failed;
    if (failed == _backendPinFailed) return;
    _backendPinFailed = failed;
    if (failed) {
      AppLogger.log.e(
        'IntegrityService: backend TLS pin probe FAILED — locking wallet '
        '(possible MITM / compromised CA)',
      );
    } else {
      AppLogger.log.i('IntegrityService: backend TLS pin probe verified');
    }
  }

  /// True when money features must be disabled: the integrity check flagged a
  /// tampered/repackaged build, or the backend's TLS certificate does not
  /// match the build-time pin (active probe, MITM/compromised-CA defence).
  bool get walletLocked =>
      verdict.value != IntegrityVerdict.ok || _backendPinFailed;

  Timer? _timer;
  final Random _rng = Random.secure();

  /// Shared HTTP client for hash fetch / tamper reports (timeouts applied).
  Dio? _dio;
  Dio get _client {
    final cached = _dio;
    if (cached != null) return cached;
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
      ),
    );
    _dio = dio;
    return dio;
  }

  /// Published-hash cache: GitHub/site content for a given release is fixed
  /// for the life of the install, so we only re-fetch periodically instead of
  /// on every monitor tick (fleet-wide IO/CPU + network churn at 1–10 min).
  String? _publishedHashCache;
  DateTime? _publishedHashFetchedAt;
  static const _publishedHashTtl = Duration(hours: 6);

  /// Last successfully computed APK hash — only re-invoke the platform
  /// channel when the TTL expires (the on-disk APK cannot change under a
  /// running process except by replacement, which the cert check also sees).
  String? _apkHashCache;
  DateTime? _apkHashFetchedAt;
  static const _apkHashTtl = Duration(minutes: 15);

  static String _normalizeHash(String raw) =>
      raw.toLowerCase().replaceAll(RegExp(r'[^0-9a-f]'), '');

  Future<String?> _certHash() async {
    if (!kIsAndroid) return null;
    try {
      final v = await _channel.invokeMethod<String>("certSha256");
      return v == null ? null : _normalizeHash(v);
    } catch (e, stack) {
      AppLogger.log.e('IntegrityService: failed to read cert hash: $e');
      AppLogger.reportError(e, stack, 'IntegrityService certHash');
      rethrow;
    }
  }

  Future<String?> _apkHash() async {
    if (!kIsAndroid) return null;
    final cached = _apkHashCache;
    final fetchedAt = _apkHashFetchedAt;
    if (cached != null &&
        fetchedAt != null &&
        DateTime.now().difference(fetchedAt) < _apkHashTtl) {
      return cached;
    }
    try {
      final v = await _channel.invokeMethod<String>("apkSha256");
      final norm = v == null ? null : _normalizeHash(v);
      if (norm != null && norm.isNotEmpty) {
        _apkHashCache = norm;
        _apkHashFetchedAt = DateTime.now();
      }
      return norm;
    } catch (e, stack) {
      AppLogger.log.e('IntegrityService: failed to read APK hash: $e');
      AppLogger.reportError(e, stack, 'IntegrityService apkHash');
      rethrow;
    }
  }

  /// Current device-build hashes for login attestation, or null off Android /
  /// when unreadable. The backend binds these into the signed challenge.
  Future<({String? cert, String? apk})> attestation() async {
    return (cert: await _certHash(), apk: await _apkHash());
  }

  /// LOCAL, offline boot gate. When the certificate is pinned
  /// ([expectedCertSha256] set) this FAILS CLOSED: a build whose signing
  /// certificate can't be read or doesn't match the pin refuses to boot — a
  /// repackaged app must never slip through on a transient read failure. When
  /// no pin is configured (dev builds / temporary CI keystore) the check stays
  /// permissive so legitimate builds always start.
  Future<bool> bootCheckPassed() async {
    if (!kIsAndroid || expectedCertSha256.isEmpty) return true;

    const maxRetries = 3;
    const retryDelay = Duration(seconds: 1);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final cert = await _certHash();
        if (cert == null) {
          AppLogger.log.w(
            'IntegrityService: cert hash unavailable '
            '(attempt $attempt/$maxRetries)',
          );
          if (attempt < maxRetries) {
            await Future.delayed(retryDelay);
            continue;
          }
          AppLogger.log.e(
            'IntegrityService: cert hash unreadable after $maxRetries '
            'attempts with a pin configured — failing closed',
          );
          verdict.value = IntegrityVerdict.bricked;
          return false;
        }
        if (cert == expectedCertSha256) return true;

        AppLogger.log.e(
          'IntegrityService: cert hash mismatch — '
          'expected $expectedCertSha256, got $cert',
        );
        verdict.value = IntegrityVerdict.bricked;
        return false;
      } catch (e, stack) {
        AppLogger.log.w(
          'IntegrityService: cert hash check error '
          '(attempt $attempt/$maxRetries): $e',
        );
        if (attempt == maxRetries) {
          AppLogger.log.e(
            'IntegrityService: cert hash check failed after '
            '$maxRetries attempts — bricking app',
          );
          AppLogger.reportError(
            e,
            stack,
            'IntegrityService bootCheckPassed exhausted retries',
          );
          verdict.value = IntegrityVerdict.bricked;
          return false;
        }
        await Future.delayed(retryDelay);
      }
    }

    verdict.value = IntegrityVerdict.bricked;
    return false;
  }

  /// Runtime check (after boot and on the random interval). Re-confirms the
  /// certificate and compares the on-disk APK against the published hash.
  Future<void> runCheck() async {
    if (!kIsAndroid) return;

    String? cert;
    try {
      cert = await _retryHash(() => _certHash(), 'certHash');
    } catch (e, stack) {
      AppLogger.log.w('IntegrityService: runtime cert check failed: $e');
      AppLogger.reportError(e, stack, 'IntegrityService runCheck cert');
      return;
    }

    if (expectedCertSha256.isNotEmpty &&
        cert != null &&
        cert != expectedCertSha256) {
      verdict.value = IntegrityVerdict.bricked;
      await _report(certSha: cert, apkSha: null, reason: "cert_mismatch");
      return;
    }

    String? published;
    try {
      published = await _retryHash(() => _fetchPublishedHash(), 'publishedHash');
    } catch (e, stack) {
      AppLogger.log.w(
        'IntegrityService: runtime published hash fetch failed: $e',
      );
      AppLogger.reportError(
        e,
        stack,
        'IntegrityService runCheck publishedHash',
      );
      return;
    }
    if (published == null) return;

    String? apk;
    try {
      apk = await _retryHash(() => _apkHash(), 'apkHash');
    } catch (e, stack) {
      AppLogger.log.w('IntegrityService: runtime APK hash check failed: $e');
      AppLogger.reportError(e, stack, 'IntegrityService runCheck apk');
      return;
    }
    if (apk == null) return;

    if (apk != published) {
      verdict.value = IntegrityVerdict.walletLocked;
      await _report(certSha: cert, apkSha: apk, reason: "apk_mismatch");
    } else if (verdict.value == IntegrityVerdict.walletLocked) {
      verdict.value = IntegrityVerdict.ok;
    }
  }

  Future<T?> _retryHash<T>(
    Future<T?> Function() fn,
    String label,
  ) async {
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 1);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await fn();
      } catch (e, stack) {
        AppLogger.log.w(
          'IntegrityService: $label failed '
          '(attempt $attempt/$maxRetries): $e',
        );
        if (attempt == maxRetries) {
          AppLogger.reportError(
            e,
            stack,
            'IntegrityService _retryHash $label exhausted',
          );
          rethrow;
        }
        await Future.delayed(retryDelay);
      }
    }
    return null; // unreachable — the last attempt rethrows
  }

  /// Start the runtime monitor: one check now, then again at a random interval
  /// between 5 and 15 minutes, repeating for the life of the process.
  void startMonitor() {
    if (!kIsAndroid) return;
    unawaited(runCheck());
    _schedule();
  }

  void stopMonitor() {
    _timer?.cancel();
    _timer = null;
  }

  void _schedule() {
    _timer?.cancel();
    // 5–15 min: still frequent enough to catch a repackaged APK quickly,
    // but ~3× less fleet-wide work than the old 1–10 min full re-hash cycle.
    final minutes = 5 + _rng.nextInt(11);
    _timer = Timer(Duration(minutes: minutes), () async {
      await runCheck();
      _schedule();
    });
  }

  Future<String?> _fetchPublishedHash() async {
    final cached = _publishedHashCache;
    final fetchedAt = _publishedHashFetchedAt;
    if (cached != null &&
        fetchedAt != null &&
        DateTime.now().difference(fetchedAt) < _publishedHashTtl) {
      return cached;
    }
    try {
      final res = await _client.get<List<int>>(
        apkHashUrl,
        options: Options(
          responseType: ResponseType.bytes,
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      ).timeout(const Duration(seconds: 12));
      final data = res.data;
      if (data == null || data.isEmpty) return null;
      final bodyBytes = data is Uint8List ? data : Uint8List.fromList(data);
      if (!await _verifyBodySignature(bodyBytes, res.headers)) {
        // Fail closed: an unsigned/invalid payload is tamper evidence and must
        // NEVER unlock (or keep unlocked) the wallet. The lock itself was
        // applied inside _verifyBodySignature.
        return null;
      }
      final body = utf8.decode(bodyBytes);
      if (body.isEmpty) return null;
      final first = body.trim().split(RegExp(r'\s+')).first;
      final norm = _normalizeHash(first);
      if (norm.length == 64) {
        _publishedHashCache = norm;
        _publishedHashFetchedAt = DateTime.now();
        return norm;
      }
      return null;
    } catch (e, stack) {
      AppLogger.log.w(
        'IntegrityService: failed to fetch published hash: $e',
      );
      AppLogger.reportError(
        e,
        stack,
        'IntegrityService fetchPublishedHash',
      );
      return null;
    }
  }

  /// Verifies the worker's `X-Body-Signature` header — hex-encoded Ed25519
  /// over the raw response body bytes — against
  /// [integritySigningPublicKey]. Returns true when no key is configured
  /// (legacy unsigned mode) or the signature is valid. When a key IS
  /// configured and the signature is missing/invalid, the wallet is locked as
  /// tamper evidence and false is returned.
  Future<bool> _verifyBodySignature(Uint8List body, Headers headers) async {
    final keyBase64 = integritySigningPublicKey.trim();
    if (keyBase64.isEmpty) return true; // signature scheme not armed

    var valid = false;
    try {
      final publicKeyBytes = base64Decode(keyBase64);
      final sigHex = headers.value("x-body-signature")?.trim() ?? "";
      if (publicKeyBytes.length == 32 &&
          RegExp(r'^[0-9a-fA-F]{128}$').hasMatch(sigHex)) {
        final sigBytes = Uint8List(64);
        for (var i = 0; i < sigBytes.length; i++) {
          sigBytes[i] = int.parse(sigHex.substring(i * 2, i * 2 + 2), radix: 16);
        }
        valid = await Ed25519().verify(
          body,
          signature: Signature(
            sigBytes,
            publicKey: SimplePublicKey(
              publicKeyBytes,
              type: KeyPairType.ed25519,
            ),
          ),
        );
      }
    } catch (e, stack) {
      AppLogger.reportError(
        e,
        stack,
        'IntegrityService body-signature verification',
      );
      valid = false;
    }

    if (!valid) {
      AppLogger.log.e(
        'IntegrityService: published-hash payload signature missing/invalid '
        '— treating as tamper evidence, wallet stays locked',
      );
      verdict.value = IntegrityVerdict.walletLocked;
      await _report(
        certSha: null,
        apkSha: null,
        reason: "hash_signature_invalid",
      );
    }
    return valid;
  }

  Future<void> _report({
    required String? certSha,
    required String? apkSha,
    required String reason,
  }) async {
    const base = PaymentGatewayConfig.backendBaseUrl;
    if (base.isEmpty) return;
    try {
      await _client.post(
        "$base/integrity/report",
        data: {
          "deviceId": await WalletApiClient.instance.resolvedDeviceId(),
          "reason": reason,
          if (certSha != null) "certSha256": certSha,
          if (apkSha != null) "apkSha256": apkSha,
          "expectedCert": expectedCertSha256,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
    } catch (e, stack) {
      // Best-effort: a failed report never blocks the caller, but a tamper
      // signal that didn't reach the backend MUST be visible in local logs.
      AppLogger.log.w(
        'IntegrityService: failed to report "$reason" to backend: ${e.toString()}',
      );
      AppLogger.reportError(e, stack, 'IntegrityService._report $reason');
    }
  }
}
