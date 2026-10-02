import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:deemusiq/services/kv_store/encrypted_kv_store.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/wallet/payment_service.dart'
    show PaymentGatewayConfig;
import 'package:deemusiq/services/integrity/integrity_service.dart';
import 'package:deemusiq/services/wallet/device_identity.dart';
import 'package:deemusiq/services/wallet/secure_channel.dart';
import 'package:uuid/uuid.dart';

class WalletApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  /// True when the failure came from the network itself (connection error /
  /// timeout / TLS handshake) rather than a server response. Offline-capable
  /// callers use this to enqueue the action for replay instead of erroring.
  final bool isConnectivity;

  const WalletApiException(
    this.message, {
    this.statusCode,
    this.code,
    this.isConnectivity = false,
  });

  /// User-readable rendering for toasts/banners. The server sends machine
  /// codes (`too_many_checkouts`, `insufficient_balance`, …) — never show those
  /// raw. Falls back to [message] for anything unmapped (server-supplied
  /// sentences like the checkout "temporarily unavailable" messages).
  String get friendlyMessage {
    if (isConnectivity) {
      return "Couldn't reach DeeMusiq — check your connection and try again.";
    }
    switch (code) {
      case "insufficient_balance":
        return "Not enough tokens — top up your wallet first.";
      case "bad_phone":
        return "Enter a valid phone number (e.g. +27 82 123 4567).";
      case "unknown_pack":
        return "That token pack isn't available anymore — reopen the token store.";
      case "track_not_found":
        return "That track isn't available on DeeMusiq anymore.";
      case "idempotency_key_reused":
        return "That request was already sent — refresh your wallet before trying again.";
      case "request_pending":
        return "You already have a request waiting for review.";
      case "no_change":
        return "That's already your current setting.";
      case "artist_not_approved":
        return "Your artist profile needs approval before this is available.";
      case "no_artist_profile":
        return "Create your artist profile first.";
      case "too_many_checkouts":
      case "too_many_pushes":
      case "too_many_supports":
      case "too_many_requests":
      case "too_many_attempts":
        return "Too many attempts — give it a moment and try again.";
      case "security_state_unavailable":
        return "DeeMusiq is temporarily unavailable — try again shortly.";
      case "under_min_age":
        return "You're below the minimum age for a DeeMusiq account.";
      case "stale_timestamp":
        return "Your device's clock is out of sync — set the date & time automatically and try again.";
      case "missing_payment_signature":
      case "bad_signature":
        return "This build can't start payments — please update the app.";
      case "logged_out":
        return message;
    }
    switch (statusCode) {
      case 402:
        return "Payment didn't complete — you haven't been charged.";
      case 409:
        return "That conflicts with an earlier request — refresh and try again.";
      case 429:
        return "Too many attempts — give it a moment and try again.";
      case 503:
        return "DeeMusiq is temporarily unavailable — try again shortly.";
    }
    return message;
  }

  @override
  String toString() => "WalletApiException: $message";
}

/// HTTP client for the DeeMusiq backend (see `/backend`). It is INERT until
/// [PaymentGatewayConfig.backendBaseUrl] is set: with no backend the app stays
/// fully local. Auth is device-based — a generated UUID is exchanged for a JWT.
class WalletApiClient {
  WalletApiClient._();
  static final WalletApiClient instance = WalletApiClient._();

  static const _deviceKey = "deemusiq_device_id";

  /// H2 tombstone: set by "log out on all devices" / account sign-out. While
  /// present, [_authToken] refuses to silently re-authenticate this device —
  /// only an explicit user login clears it. Lives in the platform keystore.
  static const _loggedOutKey = "deemusiq_logged_out";

  static const _validProviders = {'spotify', 'google'};

  /// HMAC secret for payment-request signing. NEVER defaults to the secure
  /// channel key (H4): an empty value means checkouts go out unsigned and the
  /// backend rejects them — fail closed beats sharing one compile-time secret
  /// across two different security domains.
  static const _paymentHmacSecret = String.fromEnvironment(
    "DEEMUSIQ_PAYMENT_HMAC_SECRET",
    defaultValue: "",
  );
  static const _walletPageSize = 50;
  static const _checkoutKeyPrefix = "deemusiq_checkout_key_";

  static String get paymentHmacSecret => _paymentHmacSecret;

  static const _uuid = Uuid();
  final Map<String, String> _checkoutKeys = {};

  bool get isConfigured => PaymentGatewayConfig.backendBaseUrl.isNotEmpty;

  /// Reused across calls — [PaymentGatewayConfig.backendBaseUrl] is a compile
  /// time const, so one client (and one interceptor chain) is enough.
  Dio? _dio;

  Dio _client() {
    final cached = _dio;
    if (cached != null) return cached;
    _assertBackendUrlScheme();
    final dio = Dio(
      BaseOptions(
        baseUrl: PaymentGatewayConfig.backendBaseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 20),
        headers: {"Content-Type": "application/json"},
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (SecureChannel.enabled &&
              !SecureChannel.isExemptPath(options.path)) {
            try {
              final deviceId = await _resolvedDeviceId();
              options.headers[SecureChannel.headerName] = "1";
              options.headers[SecureChannel.deviceHeaderName] = deviceId;
              options.headers[SecureChannel.deviceIdHeaderName] = deviceId;
              if (options.data != null) {
                final envelope = await SecureChannel.sealForDevice(
                  jsonEncode(options.data),
                  deviceId,
                );
                options.data = SecureChannel.zwEnabled
                    ? {
                        "v": 3,
                        "zw": SecureChannel.zwEncode(jsonEncode(envelope)),
                      }
                    : envelope;
              }
            } catch (error, stack) {
              AppLogger.reportError(
                  error, stack, "WalletApiClient.secureRequest");
              handler.reject(
                DioException(
                  requestOptions: options,
                  error: error,
                  message: error.toString(),
                ),
              );
              return;
            }
          }
          // The v2 payment signature binds the EXACT wire body
          // (`${ts}.${body}`), so it must be (re)computed here, AFTER the
          // secure channel rewrote the body into its sealed envelope — the
          // signature set by paymentRequestHeaders covers the plain body and
          // stays valid only when nothing transformed it.
          final payTs = options.headers["X-DM-Pay-Ts"];
          final payTsMs = payTs is String ? int.tryParse(payTs) : null;
          if (payTsMs != null &&
              _paymentHmacSecret.isNotEmpty &&
              options.data != null) {
            options.headers["X-DM-Pay-Sig"] = paymentRequestSignature(
              timestamp: payTsMs,
              body: jsonEncode(options.data),
            );
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          var data = response.data;
          // Zero-width carrier first: unwrap to the sealed envelope.
          if (response.headers.value(SecureChannel.zwHeaderName) == "1" &&
              SecureChannel.isZwEnvelope(data)) {
            try {
              data = jsonDecode(
                SecureChannel.zwDecode((data as Map)["zw"] as String)!,
              );
              response.data = data;
            } catch (e) {
              handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  response: response,
                  message: "Could not decode the zero-width response.",
                ),
              );
              return;
            }
          }
          final encrypted =
              response.headers.value(SecureChannel.headerName) == "1";
          if (encrypted && SecureChannel.isEnvelope(data)) {
            try {
              final plain = SecureChannel.open(
                Map<String, dynamic>.from(data as Map),
              );
              response.data = jsonDecode(plain);
            } catch (e) {
              // Corrupt/tampered ciphertext or a wrong channel key — surface a
              // clean error instead of throwing into Dio and breaking the app.
              handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  response: response,
                  message: "Could not decrypt the secure response.",
                ),
              );
              return;
            }
          }
          handler.next(response);
        },
        onError: (e, handler) {
          // Error bodies are sealed too when the secure channel is on —
          // unseal so _message() can read the server's error code.
          final resp = e.response;
          if (resp != null) {
            var data = resp.data;
            if (resp.headers.value(SecureChannel.zwHeaderName) == "1" &&
                SecureChannel.isZwEnvelope(data)) {
              try {
                data = jsonDecode(
                  SecureChannel.zwDecode((data as Map)["zw"] as String)!,
                );
                resp.data = data;
              } catch (err) {
                AppLogger.log.w('Failed to decode zero-width error envelope');
              }
            }
            if (resp.headers.value(SecureChannel.headerName) == "1" &&
                SecureChannel.isEnvelope(resp.data)) {
              try {
                resp.data = jsonDecode(
                  SecureChannel.open(
                      Map<String, dynamic>.from(resp.data as Map)),
                );
              } catch (e) {
                AppLogger.log.w(
                    'Failed to decrypt secure error envelope — using generic message');
              }
            }
          }
          // A cached JWT that expired/was revoked → 401. Drop it so the next
          // call re-authenticates (Ed25519 challenge-response) instead of
          // cascading 401s forever.
          if (e.response?.statusCode == 401) _token = null;
          handler.next(e);
        },
      ),
    );
    _dio = dio;
    return dio;
  }

  /// H3: the secure channel seals request/response BODIES only — the
  /// `Authorization: Bearer` header and URL query strings still travel in
  /// cleartext, so plain HTTP is only acceptable for local development.
  /// Release/profile builds fail closed on `http://` backend URLs.
  static void _assertBackendUrlScheme() {
    const url = PaymentGatewayConfig.backendBaseUrl;
    if (url.isEmpty) return;
    if (!kDebugMode && Uri.parse(url).scheme == 'http') {
      throw const WalletApiException(
        "insecure_backend_url: the DeeMusiq backend URL must use https:// "
        "in release builds (http:// is allowed in debug builds only)",
        code: "insecure_backend_url",
      );
    }
  }

  /// True after "log out on all devices" / account sign-out (H2): blocks the
  /// silent device re-auth in [_authToken] until an explicit user login
  /// ([deviceLogin], [loginEmail], [totpRecover], [authWithGoogle]) clears it.
  Future<bool> isLoggedOut() async {
    final cached = _loggedOutCache;
    if (cached != null) return cached;
    try {
      final value =
          await EncryptedKvStoreService.storage.read(key: _loggedOutKey);
      final loggedOut = value == 'true';
      _loggedOutCache = loggedOut;
      return loggedOut;
    } catch (e) {
      AppLogger.log.w('loggedOut flag read failed: ${e.toString()}');
      return false;
    }
  }

  bool? _loggedOutCache;

  /// Sets the H2 tombstone and drops the in-memory session token. Called by
  /// [logoutAll] and by account sign-outs (Google) — any path after which a
  /// silent re-login would make the user's "sign out" action meaningless.
  Future<void> markLoggedOut() async {
    _token = null;
    _loggedOutCache = true;
    try {
      await EncryptedKvStoreService.storage
          .write(key: _loggedOutKey, value: 'true');
    } catch (e) {
      AppLogger.log.w('loggedOut flag write failed: ${e.toString()}');
    }
  }

  Future<void> _clearLoggedOut() async {
    _loggedOutCache = false;
    try {
      await EncryptedKvStoreService.storage.delete(key: _loggedOutKey);
    } catch (e) {
      AppLogger.log.w('loggedOut flag clear failed: ${e.toString()}');
    }
  }

  /// Test seam: production clears happen only inside the explicit login
  /// flows ([deviceLogin], [loginEmail], [totpRecover], [authWithGoogle]).
  @visibleForTesting
  Future<void> debugClearLoggedOutTombstone() => _clearLoggedOut();

  /// Signs in as this device (Ed25519 challenge–response) and returns the
  /// backend JWT. Used as the Google-less sign-in fallback — an explicit user
  /// action, so it bypasses (and on success clears) the logged-out tombstone.
  Future<String> deviceLogin() async {
    final token = await _authToken(explicitLogin: true);
    await _clearLoggedOut();
    return token;
  }

  bool hasToken() => _token != null;

  /// Cheap reachability probe. Returns true only when a backend is configured
  /// AND answers `/health` — the single gate for online-only features
  /// (downloads, payments, token balance, account linking).
  Future<bool> ping() async {
    if (!isConfigured) return false;
    try {
      final res = await _client().get(
        "/health",
        options: Options(
          sendTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 6),
        ),
      );
      return res.statusCode == 200;
    } catch (e, stack) {
      // Unreachable is a normal state (offline / no backend configured yet),
      // but the cause still gets logged and reported — never swallowed.
      AppLogger.log.w('Backend ping failed: ${e.toString()}');
      AppLogger.reportError(e, stack, 'WalletApiClient.ping');
      return false;
    }
  }

  String? _deviceIdCache;
  Future<void>? _deviceIdHydration;

  String _deviceId() {
    final cached = _deviceIdCache;
    if (cached != null && cached.isNotEmpty) return cached;

    _deviceIdHydration ??= _hydrateDeviceIdFromSecureStorage();
    final prefs = KVStoreService.sharedPreferences;
    final plain = prefs.getString(_deviceKey);
    if (plain != null && plain.isNotEmpty) {
      _deviceIdCache = plain;
      unawaited(_migrateDeviceIdToSecureStorage(plain));
      return plain;
    }

    final id = _uuid.v4();
    _deviceIdCache = id;
    try {
      prefs.setString(_deviceKey, id);
    } catch (_) {}
    unawaited(_persistDeviceId(id));
    return id;
  }

  Future<String> _resolvedDeviceId() async {
    _deviceIdHydration ??= _hydrateDeviceIdFromSecureStorage();
    await _deviceIdHydration;
    return _deviceId();
  }

  Future<void> _hydrateDeviceIdFromSecureStorage() async {
    try {
      final secure =
          await EncryptedKvStoreService.storage.read(key: _deviceKey);
      if (secure != null && secure.isNotEmpty) {
        _deviceIdCache = secure;
        try {
          await KVStoreService.sharedPreferences.remove(_deviceKey);
        } catch (_) {}
      }
    } catch (e) {
      AppLogger.log.w('deviceId keystore hydrate skipped: ${e.toString()}');
    }
  }

  Future<void> _persistDeviceId(String id) async {
    try {
      final existing =
          await EncryptedKvStoreService.storage.read(key: _deviceKey);
      if (existing != null && existing.isNotEmpty) {
        _deviceIdCache = existing;
      } else if (_deviceIdCache == null || _deviceIdCache == id) {
        await EncryptedKvStoreService.storage.write(key: _deviceKey, value: id);
      }
      try {
        await KVStoreService.sharedPreferences.remove(_deviceKey);
      } catch (_) {}
    } catch (e) {
      AppLogger.log.w('deviceId secure store write failed: ${e.toString()}');
    }
  }

  Future<void> _migrateDeviceIdToSecureStorage(String id) async {
    try {
      final existing =
          await EncryptedKvStoreService.storage.read(key: _deviceKey);
      if (existing == null || existing.isEmpty) {
        await EncryptedKvStoreService.storage.write(key: _deviceKey, value: id);
      } else {
        _deviceIdCache = existing;
      }
      await KVStoreService.sharedPreferences.remove(_deviceKey);
    } catch (e) {
      AppLogger.log.w('deviceId migration skipped: ${e.toString()}');
    }
  }

  /// The resolved device id, awaiting secure-storage hydration (L4). All
  /// callers must use this — the old synchronous getter could mint a phantom
  /// UUID into plain prefs when hit before hydration completed, briefly
  /// splitting the device identity seen by the backend.
  Future<String> resolvedDeviceId() => _resolvedDeviceId();

  String? _token;

  /// The cached backend JWT, or null when this device hasn't authenticated
  /// yet. This NEVER triggers a login — it exists for fire-and-forget calls
  /// (e.g. the play-count scrobble) that attach auth when it happens to be in
  /// memory and stay anonymous otherwise.
  String? get sessionToken => _token;

  /// Device login via Ed25519 challenge–response. The backend issues a signed
  /// challenge; we sign it with the device's secure-enclave key (never sent) and
  /// present the signature + public key. No secret ever travels the wire.
  ///
  /// H2: after a "log out on all devices" / sign-out tombstone this refuses to
  /// silently re-authenticate — explicit login flows pass [explicitLogin].
  Future<String> _authToken({bool explicitLogin = false}) async {
    if (_token != null) return _token!;
    if (!explicitLogin && await isLoggedOut()) {
      throw const WalletApiException(
        "This device was signed out. Sign in again to reconnect.",
        code: "logged_out",
      );
    }
    try {
      final deviceId = await _resolvedDeviceId();
      final dio = _client();
      final challengeRes = await dio.post(
        "/auth/device/challenge",
        data: {"deviceId": deviceId},
      );
      final challenge = (challengeRes.data as Map)["challenge"] as String;

      // Client attestation: when this build can report its cert + APK hashes,
      // sign them INTO the challenge so the backend can verify the binding and
      // refuse repackaged builds. Otherwise fall back to signing the bare
      // challenge (the backend treats that as "no attestation").
      final att = await IntegrityService.instance.attestation();
      final hasAttestation = att.cert != null || att.apk != null;
      final message = hasAttestation
          ? "$challenge|${att.cert ?? ''}|${att.apk ?? ''}"
          : challenge;

      final loginRes = await dio.post(
        "/auth/device/login",
        data: {
          "deviceId": deviceId,
          "publicKey": await DeviceIdentity.instance.publicKeyBase64(),
          "challenge": challenge,
          "signature": await DeviceIdentity.instance.sign(message),
          if (att.cert != null) "certSha256": att.cert,
          if (att.apk != null) "apkSha256": att.apk,
        },
      );
      final token = (loginRes.data as Map)["token"] as String;
      _token = token;
      return token;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Attach an email + password to this wallet (works on any device after).
  Future<void> registerEmail({
    required String email,
    required String password,
    required bool acceptTerms,
  }) async {
    if (!acceptTerms) {
      throw const WalletApiException("terms_acceptance_required");
    }
    await _guardCredentialAttempts(() async {
      try {
        await _client().post(
          "/auth/register",
          data: {
            "email": email,
            "password": password,
            "acceptTerms": true,
          },
          options: await _authed(),
        );
      } on DioException catch (e) {
        throw _walletApiException(e);
      }
    });
  }

  /// Log in with email + password (e.g. on a new device); caches the token.
  Future<void> loginEmail({
    required String email,
    required String password,
  }) async {
    await _guardCredentialAttempts(() async {
      try {
        final res = await _client().post(
          "/auth/login",
          data: {"email": email, "password": password},
        );
        _token = (res.data as Map)["token"] as String;
        await _clearLoggedOut();
      } on DioException catch (e) {
        throw _walletApiException(e);
      }
    });
  }

  // ── Client-side brute-force guard (credential endpoints) ─────────────────
  // In-memory only — a UX/anti-hammer guard, not a security boundary (the
  // backend enforces the real rate limits). After [_authLockoutThreshold]
  // consecutive credential rejections the next attempt is blocked for
  // [_authLockoutDuration].
  int _authFailures = 0;
  DateTime? _authLockedUntil;

  static const _authLockoutThreshold = 3;
  static const _authLockoutDuration = Duration(seconds: 10);

  Future<T> _guardCredentialAttempts<T>(Future<T> Function() fn) async {
    final lockedUntil = _authLockedUntil;
    if (lockedUntil != null) {
      final remaining = lockedUntil.difference(DateTime.now());
      if (remaining > Duration.zero) {
        throw WalletApiException(
          "Too many failed attempts — try again in ${remaining.inSeconds + 1}s.",
        );
      }
    }
    try {
      final result = await fn();
      _authFailures = 0;
      _authLockedUntil = null;
      return result;
    } on WalletApiException catch (e) {
      // Only credential rejections (4xx) count — a flaky network must not
      // lock the user out.
      final status = e.statusCode;
      if (status != null && status >= 400 && status < 500) {
        _authFailures++;
        if (_authFailures >= _authLockoutThreshold) {
          _authFailures = 0;
          _authLockedUntil = DateTime.now().add(_authLockoutDuration);
        }
      }
      rethrow;
    }
  }

  /// Begin TOTP enrollment. Returns `{secret, otpauthUri}` to render a QR.
  /// The backend requires step-up proof when the account already has a
  /// factor: [password] when an email+password is attached,
  /// [code] (from the CURRENT authenticator) when re-enrolling while 2FA
  /// is active. Missing proof answers 401 with `step_up_password_required`
  /// / `step_up_code_required` so the UI can prompt for exactly that.
  Future<Map<String, dynamic>> totpSetup({String? password, String? code}) async {
    try {
      final res = await _client().post(
        "/auth/totp/setup",
        data: {
          if (password != null && password.isNotEmpty) "password": password,
          if (code != null && code.isNotEmpty) "code": code,
        },
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Confirm TOTP enrollment with a code from the authenticator app.
  Future<void> totpEnable(String code) async {
    try {
      await _client().post(
        "/auth/totp/enable",
        data: {"code": code},
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Recover wallet access on a new device via email + a TOTP code.
  Future<void> totpRecover(
      {required String email, required String code}) async {
    await _guardCredentialAttempts(() async {
      try {
        final res = await _client().post(
          "/auth/totp/recover",
          data: {"email": email, "code": code},
        );
        _token = (res.data as Map)["token"] as String;
        await _clearLoggedOut();
      } on DioException catch (e) {
        throw _walletApiException(e);
      }
    });
  }

  /// Send (or re-send) the email-verification link to the account's email.
  Future<void> requestVerify() async {
    try {
      await _client().post("/auth/request-verify", options: await _authed());
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Start a password reset — the backend emails a reset link. Always succeeds
  /// (never reveals whether the email exists).
  Future<void> forgotPassword(String email) async {
    try {
      await _client().post("/auth/forgot-password", data: {"email": email});
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Revoke every session for this account (server-side), drop the local
  /// token, and set the logged-out tombstone (H2): without it the very next
  /// authed call would silently mint a fresh JWT for the same wallet via
  /// device login, making "log out on all devices" a lie on this device.
  Future<void> logoutAll() async {
    try {
      await _client().post("/auth/logout-all", options: await _authed());
      await markLoggedOut();
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Permanently delete the account + all its data (POPIA/GDPR). The
  /// server anonymizes the row (status='deleted', email/password/keys
  /// cleared) and bumps tokenVersion so the current JWT is invalid.
  Future<void> deleteAccount() async {
    try {
      await _client().delete("/me/delete-account", options: await _authed());
      _token = null;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Authoritative list of linked accounts from the backend.
  Future<List<dynamic>> fetchLinkedAccounts() async {
    try {
      final res =
          await _client().get("/link/accounts", options: await _authed());
      return (res.data as Map)["accounts"] as List<dynamic>;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Disconnects a linked provider on the backend
  /// (`DELETE /link/accounts/:provider`).
  Future<void> unlinkAccount(String provider) async {
    if (!_validProviders.contains(provider)) {
      throw const WalletApiException('Invalid provider');
    }
    final encoded = Uri.encodeComponent(provider);
    try {
      await _client().delete(
        "/link/accounts/$encoded",
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  Future<Options> _authed() async =>
      Options(headers: {"Authorization": "Bearer ${await _authToken()}"});

  String _fileName(String path) => path.split(RegExp(r'[/\\]')).last;

  Map<String, dynamic> _uploadResult(Response<dynamic> response) {
    if (response.data is! Map) {
      throw const WalletApiException("creator_upload_invalid_response");
    }
    final data = Map<String, dynamic>.from(response.data as Map);
    if (data["mediaUploadId"] is! String ||
        (data["mediaUploadId"] as String).isEmpty) {
      throw const WalletApiException("creator_upload_incomplete");
    }
    return data;
  }

  String _message(DioException e) {
    final data = e.response?.data;
    if (data is Map && data["message"] is String) return data["message"];
    if (data is Map && data["error"] is String) return data["error"];
    if (e.error is SecureChannelException) {
      return (e.error as SecureChannelException).message;
    }
    return e.message ?? "Network error";
  }

  String? _errorCode(DioException e) {
    final data = e.response?.data;
    if (data is Map && data["error"] is String) return data["error"] as String;
    if (e.error is SecureChannelException) {
      return (e.error as SecureChannelException).message;
    }
    return null;
  }

  WalletApiException _walletApiException(DioException e) {
    return WalletApiException(
      _message(e),
      statusCode: e.response?.statusCode,
      code: _errorCode(e),
      isConnectivity: _isConnectivityError(e),
    );
  }

  /// Network-level failures (no response received): connection refused/reset,
  /// DNS failure, timeouts, TLS handshake problems. A 4xx/5xx answer means the
  /// backend WAS reached, so those are deliberately not connectivity errors.
  static bool _isConnectivityError(DioException e) {
    if (e.response != null) return false;
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      case DioExceptionType.unknown:
        final error = e.error;
        return error is SocketException ||
            error is HandshakeException ||
            error is TimeoutException;
      case DioExceptionType.badResponse:
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
        return false;
    }
  }

  /// v2 payment-request signature: HMAC-SHA256 over `"$timestamp.$body"`,
  /// where [timestamp] is unix MILLISECONDS (the `X-DM-Pay-Ts` value) and
  /// [body] is the exact JSON request body being sent. Binding the timestamp
  /// INTO the digest makes a captured signature worthless outside the
  /// backend's freshness window (5 min), closing the replay gap the v1
  /// field-joined scheme had.
  static String paymentRequestSignature({
    required int timestamp,
    required String body,
    String? secret,
  }) {
    final key = secret ?? _paymentHmacSecret;
    if (key.isEmpty) {
      throw const WalletApiException("payment_hmac_secret_missing");
    }
    return crypto.Hmac(
      crypto.sha256,
      utf8.encode(key),
    ).convert(utf8.encode("$timestamp.$body")).toString();
  }

  static Map<String, String> paymentRequestHeaders({
    required int timestamp,
    required String body,
    required String idempotencyKey,
    String? secret,
  }) {
    if (!RegExp(r'^[A-Za-z0-9_-]{8,64}$').hasMatch(idempotencyKey)) {
      throw const WalletApiException("invalid_idempotency_key");
    }
    final headers = <String, String>{"Idempotency-Key": idempotencyKey};
    final key = secret ?? _paymentHmacSecret;
    if (key.isNotEmpty) {
      headers.addAll({
        "X-DM-Pay-Ts": "$timestamp",
        "X-DM-Pay-Sig": paymentRequestSignature(
          timestamp: timestamp,
          body: body,
          secret: key,
        ),
      });
    }
    return headers;
  }

  String _checkoutSignature({
    required String packId,
    required String method,
    required String region,
    String? payerPhone,
  }) {
    return "$packId|$method|${region.toLowerCase()}|${payerPhone ?? ""}";
  }

  String _checkoutStorageKey(String signature) {
    final digest = crypto.sha256.convert(utf8.encode(signature)).toString();
    return "$_checkoutKeyPrefix${digest.substring(0, 32)}";
  }

  Future<String> _checkoutAttemptKey({
    required String packId,
    required String method,
    required String region,
    String? payerPhone,
  }) async {
    final signature = _checkoutSignature(
      packId: packId,
      method: method,
      region: region,
      payerPhone: payerPhone,
    );
    final cached = _checkoutKeys[signature];
    if (cached != null) return cached;
    final storageKey = _checkoutStorageKey(signature);
    try {
      final stored = KVStoreService.sharedPreferences.getString(storageKey);
      if (stored != null && RegExp(r'^[A-Za-z0-9_-]{8,64}$').hasMatch(stored)) {
        _checkoutKeys[signature] = stored;
        return stored;
      }
      final generated = _uuid.v4();
      final saved = await KVStoreService.sharedPreferences.setString(
        storageKey,
        generated,
      );
      if (!saved) {
        throw const WalletApiException("checkout_idempotency_persist_failed");
      }
      _checkoutKeys[signature] = generated;
      return generated;
    } catch (error) {
      if (error is WalletApiException) rethrow;
      throw WalletApiException(
        "checkout_idempotency_persist_failed: ${error.toString()}",
      );
    }
  }

  Future<void> _clearCheckoutAttempt(String signature) async {
    _checkoutKeys.remove(signature);
    try {
      await KVStoreService.sharedPreferences.remove(
        _checkoutStorageKey(signature),
      );
    } catch (e) {
      AppLogger.log.w('checkout idempotency cleanup failed: ${e.toString()}');
    }
  }

  /// Creates a payment intent on the backend. Returns the raw response, e.g.
  /// `{status: "redirect", payUrl}` (cards) or `{status: "crypto", deposit}`.
  Future<Map<String, dynamic>> createCheckout({
    required String packId,
    required String method,
    required String region,
    String? payerPhone,
    String? idempotencyKey,
  }) async {
    final attemptSignature = _checkoutSignature(
      packId: packId,
      method: method,
      region: region,
      payerPhone: payerPhone,
    );
    final managedKey = idempotencyKey == null;
    final key = idempotencyKey ??
        await _checkoutAttemptKey(
          packId: packId,
          method: method,
          region: region,
          payerPhone: payerPhone,
        );
    try {
      final authed = await _authed();
      // v2 payment signature: the timestamp is unix MILLISECONDS and the
      // HMAC binds `${ts}.${body}` — the exact JSON body below — so a
      // captured header set can't be replayed outside the backend's
      // freshness window or against a different body.
      final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
      final body = <String, dynamic>{
        "packId": packId,
        "method": method,
        "region": region,
        if (payerPhone != null) "payerPhone": payerPhone,
      };
      final headers = <String, dynamic>{
        ...?authed.headers,
        ...paymentRequestHeaders(
          timestamp: timestamp,
          body: jsonEncode(body),
          idempotencyKey: key,
        ),
      };
      final res = await _client().post(
        "/payments/checkout",
        data: body,
        options: Options(headers: headers),
      );
      if (res.data is! Map) {
        throw const WalletApiException("checkout_invalid_response");
      }
      final result = Map<String, dynamic>.from(res.data as Map);
      final intentId = result["intentId"];
      if (result["recoveryUrl"] == null &&
          result["recoveryPath"] == null &&
          result["statusUrl"] == null &&
          intentId is String &&
          intentId.isNotEmpty) {
        result["recoveryUrl"] = "/payments/${Uri.encodeComponent(intentId)}";
      }
      final hasAction = result["payUrl"] != null || result["deposit"] != null;
      if (managedKey &&
          (const {"completed", "failed", "expired", "refunded"}
                  .contains(result["status"]) ||
              hasAction)) {
        await _clearCheckoutAttempt(attemptSignature);
      }
      if (result["status"] == "pending" &&
          result["payUrl"] == null &&
          result["deposit"] == null &&
          result["recoveryUrl"] == null &&
          result["recoveryPath"] == null &&
          result["statusUrl"] == null &&
          (intentId is! String || intentId.isEmpty)) {
        throw const WalletApiException("checkout_pending_without_action");
      }
      return result;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (managedKey &&
          status != null &&
          status >= 400 &&
          status < 500 &&
          status != 408 &&
          status != 429) {
        await _clearCheckoutAttempt(attemptSignature);
      }
      throw _walletApiException(e);
    }
  }

  Future<Map<String, dynamic>> fetchPaymentStatus(String intentId) async {
    if (intentId.isEmpty) {
      throw const WalletApiException("payment_intent_required");
    }
    try {
      final res = await _client().get(
        "/payments/${Uri.encodeComponent(intentId)}",
        options: await _authed(),
      );
      if (res.data is! Map) {
        throw const WalletApiException("payment_status_invalid_response");
      }
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  List<Map<String, dynamic>> _walletTransactions(Map<String, dynamic> data) {
    Object? raw = data["transactions"];
    Map<String, dynamic>? page;
    if (raw is Map) {
      page = Map<String, dynamic>.from(raw);
      raw = page["items"] ?? page["transactions"];
    }
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  String? _walletCursor(Map<String, dynamic> data) {
    final sources = <Map<String, dynamic>>[data];
    final pagination = data["pagination"];
    if (pagination is Map) {
      sources.add(Map<String, dynamic>.from(pagination));
    }
    final rawTransactions = data["transactions"];
    if (rawTransactions is Map) {
      final page = Map<String, dynamic>.from(rawTransactions);
      sources.add(page);
      final nested = page["pagination"];
      if (nested is Map) sources.add(Map<String, dynamic>.from(nested));
    }
    for (final source in sources) {
      for (final key in const [
        "nextCursor",
        "transactionCursor",
        "transactionsNextCursor",
      ]) {
        final value = source[key];
        if (value is String && value.isNotEmpty) return value;
        if (value is num) return value.toString();
      }
    }
    return null;
  }

  bool? _walletHasMore(Map<String, dynamic> data) {
    final sources = <Map<String, dynamic>>[data];
    final pagination = data["pagination"];
    if (pagination is Map) {
      sources.add(Map<String, dynamic>.from(pagination));
    }
    final rawTransactions = data["transactions"];
    if (rawTransactions is Map) {
      final page = Map<String, dynamic>.from(rawTransactions);
      sources.add(page);
      final nested = page["pagination"];
      if (nested is Map) sources.add(Map<String, dynamic>.from(nested));
    }
    for (final source in sources) {
      final value = source["hasMore"];
      if (value is bool) return value;
      if (value is num) return value != 0;
    }
    return null;
  }

  bool? _walletHistoryComplete(Map<String, dynamic> data) {
    final sources = <Map<String, dynamic>>[data];
    final pagination = data["pagination"];
    if (pagination is Map) {
      sources.add(Map<String, dynamic>.from(pagination));
    }
    final rawTransactions = data["transactions"];
    if (rawTransactions is Map) {
      final page = Map<String, dynamic>.from(rawTransactions);
      sources.add(page);
      final nested = page["pagination"];
      if (nested is Map) sources.add(Map<String, dynamic>.from(nested));
    }
    for (final source in sources) {
      final value = source["historyComplete"];
      if (value is bool) return value;
    }
    return null;
  }

  int? _walletTotal(Map<String, dynamic> data) {
    for (final key in const [
      "transactionCount",
      "totalTransactions",
      "total"
    ]) {
      final value = data[key];
      if (value is num) return value.toInt();
    }
    final raw = data["transactions"];
    if (raw is Map) {
      final value = raw["total"] ?? raw["count"];
      if (value is num) return value.toInt();
    }
    return null;
  }

  Future<Map<String, dynamic>> _walletPage({
    String? cursor,
  }) async {
    final res = await _client().get(
      "/wallet",
      queryParameters: {
        "limit": _walletPageSize,
        if (cursor != null) "cursor": cursor,
      },
      options: await _authed(),
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// Authoritative wallet state from the server (balance, transactions,
  /// supported creators).
  Future<Map<String, dynamic>> fetchWallet() async {
    Map<String, dynamic>? firstPage;
    final transactions = <Map<String, dynamic>>[];
    final ids = <String>{};
    final cursors = <String>{};
    String? cursor;
    int? total;

    Map<String, dynamic> incomplete(String error) => {
          ...firstPage!,
          "transactions": transactions,
          "nextCursor": cursor,
          "historyComplete": false,
          "historyError": error,
        };

    try {
      var page = await _walletPage();
      firstPage = page;
      while (true) {
        final pageTransactions = _walletTransactions(page);
        final before = transactions.length;
        for (final transaction in pageTransactions) {
          final id = transaction["id"];
          if (id is String && id.isNotEmpty) {
            if (ids.add(id)) transactions.add(transaction);
          } else {
            transactions.add(transaction);
          }
        }

        final pageComplete = _walletHistoryComplete(page);
        final hasMore = _walletHasMore(page);
        cursor = _walletCursor(page);
        total ??= _walletTotal(page);
        final reachedTotal = total != null && transactions.length >= total;
        final shortLegacyPage = pageComplete == null &&
            hasMore == null &&
            cursor == null &&
            total == null &&
            pageTransactions.length < _walletPageSize;

        if (pageComplete == true || reachedTotal || shortLegacyPage) {
          return {
            ...firstPage,
            "transactions": transactions,
            "nextCursor": null,
            "historyComplete": true,
            "historyError": null,
          };
        }
        if (cursor == null) {
          return incomplete(
            hasMore == true
                ? "wallet_pagination_cursor_missing"
                : "wallet_history_pagination_unsupported",
          );
        }
        if (!cursors.add(cursor) || transactions.length == before) {
          return incomplete("wallet_pagination_stalled");
        }
        try {
          page = await _walletPage(cursor: cursor);
        } on DioException catch (e) {
          return incomplete(_walletApiException(e).message);
        }
      }
    } on DioException catch (e) {
      if (firstPage == null) throw _walletApiException(e);
      return incomplete(_walletApiException(e).message);
    } on WalletApiException catch (e) {
      if (firstPage == null) rethrow;
      return incomplete(e.message);
    }
  }

  Future<int> pushSong({
    required String songId,
    required String title,
    required String artist,
    String? artistId,
    String? imageUrl,
    required int tokens,
    String? idempotencyKey,
  }) async {
    try {
      final authed = await _authed();
      final res = await _client().post(
        "/wallet/push",
        data: {
          "songId": songId,
          "title": title,
          "artist": artist,
          // Omit absent optionals entirely: the backend's zod schema accepts
          // missing fields but rejects explicit JSON nulls with a 400.
          if (artistId != null) "artistId": artistId,
          if (imageUrl != null) "imageUrl": imageUrl,
          "tokens": tokens,
        },
        options: Options(headers: {
          ...?authed.headers,
          if (idempotencyKey != null) "Idempotency-Key": idempotencyKey,
        }),
      );
      return ((res.data as Map)["balance"] as num).toInt();
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  Future<int> supportCreator({
    required String creatorId,
    required String name,
    required int tokens,
    String? idempotencyKey,
  }) async {
    try {
      final authed = await _authed();
      final res = await _client().post(
        "/wallet/support",
        data: {"creatorId": creatorId, "name": name, "tokens": tokens},
        options: Options(headers: {
          ...?authed.headers,
          if (idempotencyKey != null) "Idempotency-Key": idempotencyKey,
        }),
      );
      return ((res.data as Map)["balance"] as num).toInt();
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Artist boosts & the yearly leaderboard ────────────────────────────────

  /// Boost an artist with tokens. Returns the new wallet balance.
  ///
  /// Pass a fresh [idempotencyKey] per user-confirmed boost (the backend
  /// dedupes on it): a retry after a flaky network then replays the original
  /// result instead of double-debiting. Each NEW boost needs a NEW key.
  Future<int> boostArtist({
    required String artistId,
    required int tokens,
    String? idempotencyKey,
  }) async {
    try {
      final encoded = Uri.encodeComponent(artistId);
      final authed = await _authed();
      final res = await _client().post(
        "/artists/$encoded/boost",
        data: {"tokens": tokens},
        options: Options(headers: {
          ...?authed.headers,
          if (idempotencyKey != null) "Idempotency-Key": idempotencyKey,
        }),
      );
      return ((res.data as Map)["balance"] as num).toInt();
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// The artist leaderboard for a calendar [year] (defaults to the current year).
  /// Returns `{year, isCurrentYear, entries:[...]}`.
  Future<Map<String, dynamic>> fetchArtistLeaderboard({int? year}) async {
    try {
      final res = await _client().get(
        "/leaderboard/artists",
        queryParameters: year != null ? {"year": year} : null,
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Past years' "Best Artist" winners. Returns the `winners` list.
  Future<List<dynamic>> fetchHallOfFame() async {
    try {
      final res = await _client().get("/leaderboard/artists/hall-of-fame");
      return (res.data as Map)["winners"] as List<dynamic>;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Creator mode ──────────────────────────────────────────────────────────

  /// Create/update the caller's artist profile (requires a linked Google account).
  Future<Map<String, dynamic>> createArtist({
    required String name,
    String? bio,
    String? imageUrl,
  }) async {
    try {
      final res = await _client().post(
        "/creator/artist",
        data: {
          "name": name,
          if (bio != null) "bio": bio,
          if (imageUrl != null) "imageUrl": imageUrl,
        },
        options: await _authed(),
      );
      return Map<String, dynamic>.from((res.data as Map)["artist"] as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// The caller's artist profile + stats, or `{artist: null}` if not a creator yet.
  Future<Map<String, dynamic>> fetchMyArtist() async {
    try {
      final res =
          await _client().get("/creator/artist", options: await _authed());
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// The caller's songs, each with a `stats` object.
  Future<List<dynamic>> fetchMySongs() async {
    try {
      final res =
          await _client().get("/creator/songs", options: await _authed());
      return (res.data as Map)["songs"] as List<dynamic>;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  Future<void> updateSong({
    required String songId,
    String? title,
    String? coverUrl,
    String? description,
    String? status,
  }) async {
    try {
      await _client().patch(
        "/creator/songs/${Uri.encodeComponent(songId)}",
        data: {
          if (title != null) "title": title,
          if (coverUrl != null) "coverUrl": coverUrl,
          if (description != null) "description": description,
          if (status != null) "status": status,
        },
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  Future<void> deleteSong(String songId) async {
    try {
      await _client().delete(
        "/creator/songs/${Uri.encodeComponent(songId)}",
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Full account-carried favorites (`[{trackId,title,artist}]`), used to rebuild
  /// local likes after signing in on a new device.
  Future<List<dynamic>> fetchFavorites() async {
    try {
      final res =
          await _client().get("/sync/favorites", options: await _authed());
      return (res.data as Map)["favorites"] as List<dynamic>;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Returns the provider OAuth URL the app should open in a browser.
  Future<String> startLinking(String provider) async {
    if (!_validProviders.contains(provider)) {
      throw const WalletApiException('Invalid provider');
    }
    final encoded = Uri.encodeComponent(provider);
    try {
      final res = await _client().get(
        "/link/$encoded/start",
        options: await _authed(),
      );
      return (res.data as Map)["url"] as String;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────

  /// Authenticate with a Google ID token. Returns a backend JWT.
  ///
  /// When this device already holds a session token, it is sent so the backend
  /// merges the Google identity into THIS device's wallet (an authenticated
  /// link). Without it the backend resolves to a standalone Google-owned wallet
  /// — the deviceId in the body is never trusted to graft onto an existing
  /// account (that would be an account-takeover vector).
  Future<String> authWithGoogle({
    required String idToken,
    required String deviceId,
  }) async {
    try {
      final res = await _client().post(
        "/auth/google",
        data: {"idToken": idToken, "deviceId": deviceId},
        options: _token != null
            ? Options(headers: {"Authorization": "Bearer $_token"})
            : null,
      );
      final token = (res.data as Map)["token"] as String;
      _token = token;
      await _clearLoggedOut();
      return token;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Ad roll ───────────────────────────────────────────────────────────────

  /// Next eligible ad for this user, or null when the backend has no
  /// inventory. Sends already-heard ad ids so the backend rotates ads.
  Future<Map<String, dynamic>?> fetchNextAd({
    List<String> excludeIds = const [],
  }) async {
    try {
      final res = await _client().get(
        "/ads/next",
        queryParameters: {
          if (excludeIds.isNotEmpty) "exclude": excludeIds.join(","),
        },
        options: await _authed(),
      );
      final ad = (res.data as Map)["ad"];
      return ad is Map ? Map<String, dynamic>.from(ad) : null;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Report that the user skipped an ad (impression accounting).
  Future<void> reportAdSkip(String adId) async {
    try {
      await _client().post(
        "/ads/skip",
        data: {"adId": adId},
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Report that an ad played to completion (campaign spend accounting).
  Future<void> reportAdComplete(String adId) async {
    try {
      await _client().post(
        "/ads/complete",
        data: {"adId": adId},
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Anonymous Data Sync ───────────────────────────────────────────────────

  /// Like a song (sends only SHA-256 hash). Idempotent.
  Future<void> syncLikeSong(String songHash) async {
    try {
      await _client().post(
        "/sync/liked",
        data: {"songHash": songHash},
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Unlike a song.
  Future<void> syncUnlikeSong(String songHash) async {
    try {
      await _client().delete(
        "/sync/liked",
        queryParameters: {"songHash": songHash},
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Fetch all liked song hashes.
  Future<List<String>> syncFetchLikedSongs() async {
    try {
      final res = await _client().get(
        "/sync/liked",
        options: await _authed(),
      );
      final songs = (res.data as Map)["songs"] as List<dynamic>;
      return songs.map((s) => (s as Map)["songHash"] as String).toList();
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Create a playlist (name + hashed song IDs).
  Future<Map<String, dynamic>> syncCreatePlaylist({
    required String name,
    required List<String> songHashes,
  }) async {
    try {
      final res = await _client().post(
        "/sync/playlists",
        data: {"name": name, "songHashes": songHashes},
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Update a playlist.
  Future<void> syncUpdatePlaylist({
    required String id,
    String? name,
    List<String>? songHashes,
  }) async {
    try {
      await _client().patch(
        "/sync/playlists/$id",
        data: {
          if (name != null) "name": name,
          if (songHashes != null) "songHashes": songHashes,
        },
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Delete a playlist.
  Future<void> syncDeletePlaylist(String id) async {
    try {
      await _client().delete(
        "/sync/playlists/$id",
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Fetch all user playlists.
  Future<List<Map<String, dynamic>>> syncFetchPlaylists() async {
    try {
      final res = await _client().get(
        "/sync/playlists",
        options: await _authed(),
      );
      final playlists = (res.data as Map)["playlists"] as List<dynamic>;
      return playlists.map((p) => Map<String, dynamic>.from(p as Map)).toList();
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  Future<List<dynamic>> fetchLeaderboard() async {
    try {
      final res = await _client().get("/leaderboard");
      return (res.data as Map)["entries"] as List<dynamic>;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// The DeeMusiq catalog (published songs). Returns `{items, nextCursor}`.
  Future<Map<String, dynamic>> fetchCatalog({
    String? cursor,
    String? query,
    int limit = 30,
  }) async {
    try {
      final res = await _client().get("/catalog", queryParameters: {
        if (cursor != null) "cursor": cursor,
        if (query != null && query.isNotEmpty) "q": query,
        "limit": limit,
      });
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Region-adjusted pricing from the server (authoritative).
  Future<Map<String, dynamic>> fetchPricing(String region) async {
    try {
      final res = await _client().get(
        "/pricing",
        queryParameters: {"region": region},
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Personalised track recommendations based on the user's liked songs.
  Future<Map<String, dynamic>> fetchRecommendations() async {
    try {
      final res = await _client().get(
        "/recommendations/for-you",
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Force-refresh the recommendations cache.
  Future<Map<String, dynamic>> refreshRecommendations() async {
    try {
      final res = await _client().post(
        "/recommendations/refresh",
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Like a track (for recommendations + account-carried favorites). Passing
  /// [title]/[artist] makes the like reversible so it can be pulled back and
  /// rebuilt as a local favorite on another device.
  Future<void> likeTrack(String trackId,
      {String? title, String? artist}) async {
    try {
      await _client().post(
        "/recommendations/like",
        data: {
          "trackId": trackId,
          if (title != null) "title": title,
          if (artist != null) "artist": artist,
        },
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Unlike a track.
  Future<void> unlikeTrack(String trackId) async {
    try {
      await _client().post(
        "/recommendations/unlike",
        data: {"trackId": trackId},
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Get the user's liked track IDs.
  Future<List<String>> fetchLikedTrackIds() async {
    try {
      final res = await _client().get(
        "/recommendations/liked",
        options: await _authed(),
      );
      final list = (res.data as Map)["likedIds"] as List<dynamic>;
      return list.cast<String>();
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Artist self-serve: uploads, scheduling, verification ────────────────

  /// Submit a draft song (audio+cover not yet uploaded). The backend keeps
  /// the row in "draft" status until the audio and cover are attached and
  /// the artist hits `/creator/songs/:id/submit`.
  Future<Map<String, dynamic>> submitSong({
    required String title,
    String? youtubeId,
    String? coverUrl,
    String? description,
  }) async {
    try {
      final res = await _client().post(
        "/creator/songs",
        data: {
          "title": title,
          if (youtubeId != null) "youtubeId": youtubeId,
          if (coverUrl != null) "coverUrl": coverUrl,
          if (description != null) "description": description,
        },
        options: await _authed(),
      );
      if (res.data is! Map || (res.data as Map)["song"] is! Map) {
        throw const WalletApiException("creator_draft_invalid_response");
      }
      return Map<String, dynamic>.from((res.data as Map)["song"] as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Move a draft song to "pending" so the admin queue picks it up.
  Future<Map<String, dynamic>> submitSongForReview(String songId) async {
    try {
      final res = await _client().post(
        "/creator/songs/${Uri.encodeComponent(songId)}/submit",
        options: await _authed(),
      );
      if (res.data is! Map || (res.data as Map)["song"] is! Map) {
        throw const WalletApiException("creator_submit_invalid_response");
      }
      final song = Map<String, dynamic>.from((res.data as Map)["song"] as Map);
      if (song["status"] != "pending") {
        throw const WalletApiException("creator_submit_not_pending");
      }
      return song;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Multipart upload of an audio file for a CreatorSong. The file lives on
  /// the local filesystem (file_picker) and is streamed to the backend, which
  /// fans it out to R2 (primary) + Bunny (mirror) + Cloudflare cache.
  Future<Map<String, dynamic>> uploadAudio({
    required String creatorSongId,
    required String filePath,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final form = FormData.fromMap({
        "creatorSongId": creatorSongId,
        "audio": await MultipartFile.fromFile(
          filePath,
          filename: _fileName(filePath),
        ),
      });
      final authed = await _authed();
      final res = await _client().post(
        "/creator/uploads/audio",
        data: form,
        options: Options(
          headers: authed.headers,
          contentType: Headers.multipartFormDataContentType,
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 2),
        ),
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) onProgress(sent / total);
        },
      );
      return _uploadResult(res);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Multipart upload of cover art.
  Future<Map<String, dynamic>> uploadCover({
    required String creatorSongId,
    required String filePath,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final form = FormData.fromMap({
        "creatorSongId": creatorSongId,
        "cover": await MultipartFile.fromFile(
          filePath,
          filename: _fileName(filePath),
        ),
      });
      final authed = await _authed();
      final res = await _client().post(
        "/creator/uploads/cover",
        data: form,
        options: Options(
          headers: authed.headers,
          contentType: Headers.multipartFormDataContentType,
        ),
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) onProgress(sent / total);
        },
      );
      return _uploadResult(res);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Multipart upload of the artist's identity-proof photo (selfie holding a
  /// sign that says "deemusiq"). After this, the artist calls
  /// `submitVerification` to attach legal name + country.
  Future<Map<String, dynamic>> uploadVerificationProof(String filePath) async {
    try {
      final form = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          filePath,
          filename: _fileName(filePath),
        ),
      });
      final authed = await _authed();
      final res = await _client().post(
        "/creator/uploads/verification",
        data: form,
        options: Options(
          headers: authed.headers,
          contentType: Headers.multipartFormDataContentType,
        ),
      );
      return _uploadResult(res);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Submit the verification form: legal name, country, optional socials.
  /// Requires that `uploadVerificationProof` has been called first.
  Future<Map<String, dynamic>> submitVerification({
    required String legalName,
    required String country,
    List<({String provider, String url})> socials = const [],
  }) async {
    try {
      final res = await _client().post(
        "/creator/verification/submit",
        data: {
          "legalName": legalName,
          "country": country,
          "socials": socials
              .map((s) => {"provider": s.provider, "url": s.url})
              .toList(),
        },
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Schedule a song for a future publish moment. Requires the operator to
  /// have approved the submission first (status="approved").
  Future<Map<String, dynamic>> scheduleSong({
    required String songId,
    required DateTime publishAt,
  }) async {
    try {
      final res = await _client().post(
        "/creator/songs/${Uri.encodeComponent(songId)}/schedule",
        data: {"publishAt": publishAt.toUtc().toIso8601String()},
        options: await _authed(),
      );
      return Map<String, dynamic>.from((res.data as Map)["song"] as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Trigger an immediate publish for an approved song. Removes any
  /// previously-queued scheduled job and enqueues a zero-delay one.
  Future<Map<String, dynamic>> publishSongNow(String songId) async {
    try {
      final res = await _client().post(
        "/creator/songs/${Uri.encodeComponent(songId)}/publish-now",
        options: await _authed(),
      );
      return Map<String, dynamic>.from((res.data as Map)["song"] as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Cancel a scheduled (or in-flight) publish. Idempotent.
  Future<Map<String, dynamic>> cancelSongRelease(String songId) async {
    try {
      final res = await _client().post(
        "/creator/songs/${Uri.encodeComponent(songId)}/cancel-release",
        options: await _authed(),
      );
      return Map<String, dynamic>.from((res.data as Map)["song"] as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Scrobble / play telemetry ────────────────────────────────────────────

  /// POST /metadata/play/:id with the listened/duration fields so the
  /// backend can distinguish a real listen (counts toward playCount) from
  /// a skip. The backend records both in `ListenHistory`; the response
  /// includes `{counted: true|false}` for UI feedback ("scrobbled!").
  Future<bool> scrobble({
    required String trackId,
    required int listenedMs,
    int? durationMs,
    String source = "app",
  }) async {
    try {
      final res = await _client().post(
        "/metadata/play/${Uri.encodeComponent(trackId)}",
        data: {
          "listenedMs": listenedMs,
          if (durationMs != null) "durationMs": durationMs,
          "source": source,
        },
        options: await _authed(),
      );
      return (res.data as Map)["counted"] == true;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Offline license ──────────────────────────────────────────────────────

  /// Asks the backend to confirm this device's offline-playback license.
  /// The endpoint may not exist on older backends — callers treat 404 as
  /// "no license enforcement deployed" and keep the local grace policy.
  Future<void> confirmOfflineLicense() async {
    try {
      await _client().post(
        "/offline/license/confirm",
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Comments ─────────────────────────────────────────────────────────────

  /// Public read. Exactly one of trackId / albumId / artistId must be set.
  Future<Map<String, dynamic>> listComments({
    String? trackId,
    String? albumId,
    String? artistId,
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final res = await _client().get("/comments", queryParameters: {
        if (trackId != null) "trackId": trackId,
        if (albumId != null) "albumId": albumId,
        if (artistId != null) "artistId": artistId,
        if (cursor != null) "cursor": cursor,
        "limit": limit,
      });
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Post a comment. Body is required; pass exactly one target FK.
  Future<Map<String, dynamic>> postComment({
    required String body,
    String? trackId,
    String? albumId,
    String? artistId,
    String? parentId,
  }) async {
    try {
      final res = await _client().post(
        "/comments",
        data: {
          "body": body,
          if (trackId != null) "trackId": trackId,
          if (albumId != null) "albumId": albumId,
          if (artistId != null) "artistId": artistId,
          if (parentId != null) "parentId": parentId,
        },
        options: await _authed(),
      );
      return Map<String, dynamic>.from((res.data as Map)["comment"] as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  Future<List<dynamic>> listCommentReplies(String parentId) async {
    try {
      final res = await _client().get(
        "/comments/${Uri.encodeComponent(parentId)}/replies",
      );
      return (res.data as Map)["replies"] as List<dynamic>;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Reports (public create) ─────────────────────────────────────────────

  /// File a Trust & Safety report. Anonymous unless the user is logged in.
  /// For DMCA-style copyright claims, include `evidenceUrl`.
  Future<String> reportContent({
    required String targetKind,
    required String targetId,
    required String reason,
    String? description,
    String? evidenceUrl,
  }) async {
    try {
      final res = await _client().post(
        "/reports",
        data: {
          "targetKind": targetKind,
          "targetId": targetId,
          "reason": reason,
          if (description != null && description.isNotEmpty)
            "description": description,
          if (evidenceUrl != null && evidenceUrl.isNotEmpty)
            "evidenceUrl": evidenceUrl,
        },
        options: await _authed(),
      );
      return (res.data as Map)["id"] as String;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Follows ──────────────────────────────────────────────────────────────

  Future<void> followArtist(String artistId) async {
    try {
      await _client().post(
        "/follows",
        data: {"targetKind": "artist", "targetId": artistId},
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  Future<void> unfollowArtist(String artistId) async {
    try {
      await _client().delete(
        "/follows",
        data: {"targetKind": "artist", "targetId": artistId},
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  Future<int> artistFollowerCount(String artistId) async {
    try {
      final res = await _client().get(
        "/artists/${Uri.encodeComponent(artistId)}/followers-count",
      );
      return ((res.data as Map)["count"] as num).toInt();
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  Future<List<dynamic>> myFollowing() async {
    try {
      final res = await _client().get(
        "/me/follows",
        options: await _authed(),
      );
      return (res.data as Map)["follows"] as List<dynamic>;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Precise follow-state check (O(1)) — prefer over list-scan.
  /// GET /me/follows/check?targetKind=artist&targetId=xxx → {following: bool}
  Future<bool> isFollowing({
    required String targetKind,
    required String targetId,
  }) async {
    try {
      final res = await _client().get(
        "/me/follows/check",
        queryParameters: {"targetKind": targetKind, "targetId": targetId},
        options: await _authed(),
      );
      return (res.data as Map)["following"] == true;
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── In-app notifications inbox ──────────────────────────────────────────

  Future<Map<String, dynamic>> fetchNotifications(
      {bool unreadOnly = false}) async {
    try {
      final res = await _client().get(
        "/me/notifications",
        queryParameters: {if (unreadOnly) "unreadOnly": "true"},
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  Future<int> markNotificationsRead({List<String> ids = const []}) async {
    try {
      final res = await _client().post(
        "/me/notifications/mark-read",
        data: {"ids": ids},
        options: await _authed(),
      );
      return ((res.data as Map)["marked"] as num).toInt();
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── GDPR / POPIA ───────────────────────────────────────────────────────

  /// Server-side birth-year check. Returns true on success. Throws
  /// WalletApiException with code "under_min_age" if the user is too young.
  Future<void> submitBirthYear(int birthYear) async {
    try {
      await _client().post(
        "/me/birth-year",
        data: {"birthYear": birthYear},
        options: await _authed(),
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// GDPR data export. Returns the full server-side dump as a Map; the
  /// caller can serialize to JSON and pass to a file-save dialog.
  Future<Map<String, dynamic>> exportMyData() async {
    try {
      final res = await _client().get("/me/export", options: await _authed());
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// POPIA consent records. GET /me/consent → {policyVersions, consents[]}
  Future<Map<String, dynamic>> fetchConsent() async {
    try {
      final res = await _client().get("/me/consent", options: await _authed());
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Grant/withdraw a consent purpose (terms|privacy|marketing).
  /// Withdrawing terms/privacy restricts processing (see backend note).
  Future<Map<String, dynamic>> updateConsent({
    required String purpose,
    required String action,
  }) async {
    try {
      final res = await _client().post(
        "/me/consent",
        data: {"purpose": purpose, "action": action},
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Email-code login hardening: request a one-time code to the account email.
  Future<void> requestEmailCode() async {
    try {
      await _client().post("/auth/email-code/request", options: await _authed());
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Confirm a one-time email code (geo-lock / new-device verification).
  Future<Map<String, dynamic>> confirmEmailCode(String code) async {
    try {
      final res = await _client().post(
        "/auth/email-code/confirm",
        data: {"code": code},
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Complete a password reset with a reset token (emailed via forgotPassword).
  /// POST /auth/reset-password {token, password}
  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      await _client().post(
        "/auth/reset-password",
        data: {"token": token, "password": password},
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Verify an email address with an emailed token.
  /// GET /auth/verify?token=xxx → {ok: true}
  Future<void> verifyEmail(String token) async {
    try {
      await _client().get(
        "/auth/verify",
        queryParameters: {"token": token},
      );
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  // ── Creator monetization panel (post-approval) ─────────────────────────
  // Multi-format uploads are advertised by the backend so the picker never
  // hardcodes extensions; payout method + revenue-split cut + analytics live
  // here so Creator Studio is one import away from the whole panel.

  /// Supported upload containers (mp3/wav/flac/m4a/ogg/opus/webm/aiff…).
  Future<Map<String, dynamic>> fetchUploadFormats() async {
    try {
      final res = await _client().get(
        "/creator/uploads/formats",
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Artist analytics overview (gross vs platform fee vs net, daily, tracks).
  Future<Map<String, dynamic>> fetchCreatorAnalytics({
    String? artistId,
    String range = "30d",
  }) async {
    try {
      final res = await _client().get(
        "/creator/analytics/overview",
        queryParameters: {
          if (artistId != null) "artistId": artistId,
          "range": range,
        },
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Saved payout destination (masked) or null when never set.
  Future<Map<String, dynamic>?> fetchPayoutMethod({String? artistId}) async {
    try {
      final res = await _client().get(
        "/creator/payouts/method",
        queryParameters: {if (artistId != null) "artistId": artistId},
        options: await _authed(),
      );
      final method = (res.data as Map)["method"];
      if (method == null) return null;
      return Map<String, dynamic>.from(method as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Save the artist's payout destination (encrypted server-side).
  Future<Map<String, dynamic>> savePayoutMethod({
    required String artistId,
    required String method,
    required String details,
  }) async {
    try {
      final res = await _client().put(
        "/creator/payouts/method",
        data: {"artistId": artistId, "method": method, "details": details},
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Creator cash-out: payable balances per verified owned artist.
  /// GET /creator/payouts/balance → {rateZarPerTokenMinor, minTokens,
  /// manualThresholdZarMinor, balances[]}
  Future<Map<String, dynamic>> fetchPayoutBalance() async {
    try {
      final res = await _client().get(
        "/creator/payouts/balance",
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Request a cash-out. Uses saved payout method when details omitted.
  /// POST /creator/payouts/request {artistId, tokens, method, details?}
  Future<Map<String, dynamic>> requestPayout({
    required String artistId,
    required int tokens,
    required String method,
    String? details,
  }) async {
    try {
      final res = await _client().post(
        "/creator/payouts/request",
        data: {
          "artistId": artistId,
          "tokens": tokens,
          "method": method,
          if (details != null && details.isNotEmpty) "details": details,
        },
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Creator's own payout requests (same shape as /history, newest first).
  /// GET /creator/payouts → {payouts[]}
  Future<Map<String, dynamic>> fetchMyPayouts() async {
    try {
      final res = await _client().get(
        "/creator/payouts",
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Payout statement for export. GET /creator/payouts/history → {payouts[]}
  /// (amount = ZAR minor units agreed at request time; no settlement details).
  Future<Map<String, dynamic>> fetchPayoutHistory() async {
    try {
      final res = await _client().get(
        "/creator/payouts/history",
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Current platform cut (default 30%) + pending/history.
  Future<Map<String, dynamic>> fetchRevenueSplit({String? artistId}) async {
    try {
      final res = await _client().get(
        "/creator/revenue-split",
        queryParameters: {if (artistId != null) "artistId": artistId},
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Request the 30% default or a custom cut (0–50%). Needs approval.
  Future<Map<String, dynamic>> requestRevenueSplit({
    required String artistId,
    required int requestedPct,
    String? note,
  }) async {
    try {
      final res = await _client().post(
        "/creator/revenue-split/request",
        data: {
          "artistId": artistId,
          "requestedPct": requestedPct,
          if (note != null && note.isNotEmpty) "note": note,
        },
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }

  /// Gmail-link personalization profile for recommendations.
  Future<Map<String, dynamic>> fetchRecommendationProfile() async {
    try {
      final res = await _client().get(
        "/recommendations/profile",
        options: await _authed(),
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw _walletApiException(e);
    }
  }
}
