import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:encrypt/encrypt.dart' as enc;
import 'package:deemusiq/services/kv_store/encrypted_kv_store.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/wallet/payment_service.dart'
    show PaymentGatewayConfig;

class SecureChannelException implements Exception {
  final String message;

  const SecureChannelException(this.message);

  @override
  String toString() => "SecureChannelException: $message";
}

/// In-transit payload encryption for the DeeMusiq backend ("secure channel").
///
/// Sensitive request/response BODIES are sealed in an AES-256-GCM envelope using
/// a PRE-SHARED 256-bit key ([PaymentGatewayConfig.secureChannelKey], shared
/// with the backend's `SECURE_CHANNEL_KEY`). This is quantum-resistant by
/// design — there is no RSA/ECDH key exchange for a quantum computer to break
/// (Shor's), and AES-256 keeps ~128-bit security against Grover's.
///
/// ## What the channel does NOT cover (H3)
/// Only bodies are sealed. The `Authorization: Bearer` JWT and URL query
/// strings travel in cleartext on a plain-HTTP deployment, so the app REJECTS
/// `http://` backend URLs outside debug builds
/// (`WalletApiClient._assertBackendUrlScheme`). Production deployments must
/// use TLS; the channel then stacks under it as defence in depth.
///
/// ## Accepted residual risks (H4)
/// - The channel key is a compile-time pre-shared secret baked into every
///   install (`--dart-define`). One APK decompilation extracts it worldwide.
///   This is ACCEPTED for the current release: the channel is a
///   casual-eavesdropper barrier, not the trust root — auth is the per-device
///   Ed25519 challenge–response, whose seed never leaves the keystore.
/// - The zero-width carrier ([zwEncode]) is OBFUSCATION, not a security
///   layer; do not cite it as one.
///
/// ## Rotation story
/// Every envelope carries `kid` (a short fingerprint of the active channel
/// key), so the backend can serve an overlap window with two keys during
/// rotation. On the client the key is compile-time, so rotation lands via app
/// upgrade: a new key changes the per-(key, device) sequence storage key and
/// the monotonic counter restarts via [resetSeq] (rekey path).
///
/// Replay protection: every sealed envelope includes a monotonic `seq` counter.
/// The backend must reject any message whose `seq` is <= the last seen seq for
/// that device. The counter resets when a new channel key is negotiated.
///
/// Wire format (matches the backend `util/secureChannel.ts`; the `encrypt`
/// package appends the 16-byte GCM tag to the ciphertext):
///   { "v": 1, "iv": base64(12-byte nonce), "ct": base64(ciphertext || tag), "seq": <uint>, "kid": <key fingerprint> }
abstract class SecureChannel {
  static const _header = "X-DM-Enc";
  static const _zwHeader = "X-DM-ZW";
  static const _deviceHeader = "X-DM-Device";
  static const _deviceIdHeader = "X-DM-Device-ID";
  static String get headerName => _header;
  static String get zwHeaderName => _zwHeader;
  static String get deviceHeaderName => _deviceHeader;
  static String get deviceIdHeaderName => _deviceIdHeader;

  /// Zero-width alphabet: 2 bits per invisible character. Mirrors the backend
  /// `util/secureChannel.ts` exactly.
  static const List<String> _zwChars = [
    "\u200B", // 00
    "\u200C", // 01
    "\u200D", // 10
    "\u2060", // 11
  ];
  static final Map<String, int> _zwIndex = {
    for (var i = 0; i < _zwChars.length; i++) _zwChars[i]: i,
  };

  static int _seq = 0;
  static String? _deviceId;
  static String? _sequenceStorageKey;
  static Future<void>? _sequenceHydration;
  static Future<void> _sequenceWrites = Future<void>.value();

  /// Restarts the monotonic counter. Wired into the rekey path: a new channel
  /// key (or a different device id) rekeys the sequence storage and starts a
  /// fresh sequence — see [initializeDevice].
  static void resetSeq() {
    _seq = 0;
  }

  static Future<void> initializeDevice(String deviceId) {
    if (deviceId.isEmpty) {
      return Future<void>.error(
        const SecureChannelException("secure_device_id_missing"),
      );
    }
    final keyDigest = crypto.sha256
        .convert(utf8.encode(PaymentGatewayConfig.secureChannelKey))
        .toString();
    final deviceDigest =
        crypto.sha256.convert(utf8.encode(deviceId)).toString();
    final storageKey =
        "deemusiq_secure_seq_${keyDigest.substring(0, 24)}_${deviceDigest.substring(0, 16)}";
    final current = _deviceId;
    if (current == deviceId &&
        _sequenceStorageKey == storageKey &&
        _sequenceHydration != null) {
      return _sequenceHydration!;
    }
    _deviceId = deviceId;
    // Rekey path: a new channel key (new keyDigest ⇒ new storage key) or a
    // different device restarts the monotonic sequence.
    resetSeq();
    _sequenceStorageKey = storageKey;
    final hydration = _hydrateSequence();
    _sequenceHydration = hydration;
    return hydration;
  }

  static Future<void> _hydrateSequence() async {
    final key = _sequenceStorageKey;
    if (key == null) {
      throw const SecureChannelException("secure_device_id_missing");
    }
    try {
      final stored = await EncryptedKvStoreService.storage.read(key: key);
      final parsed = int.tryParse(stored ?? "");
      _seq = parsed != null && parsed > 0 ? parsed : 0;
    } catch (error, stack) {
      AppLogger.reportError(error, stack, "SecureChannel.sequenceHydrate");
      throw const SecureChannelException("secure_sequence_unavailable");
    }
  }

  /// Short fingerprint of the active channel key, sent as `kid` in every
  /// sealed envelope (H4): during a key rotation the backend serves an
  /// overlap window with two keys and picks the right one by `kid`.
  static String? _keyIdCache;
  static String get keyId {
    if (!enabled) return '';
    return _keyIdCache ??= crypto.sha256
        .convert(utf8.encode(PaymentGatewayConfig.secureChannelKey))
        .toString()
        .substring(0, 12);
  }

  static Future<Map<String, dynamic>> sealForDevice(
    String plainJson,
    String deviceId,
  ) async {
    await initializeDevice(deviceId);
    final key = _sequenceStorageKey;
    if (key == null) {
      throw const SecureChannelException("secure_device_id_missing");
    }
    // Sealing runs inside the sequence-write chain so seq numbers are handed
    // out strictly monotonically. The seq is persisted only AFTER a
    // successful seal — a failed seal must not burn a sequence number (the
    // backend enforces strict monotonicity; gaps are fine, reuse is not).
    final completer = Completer<Map<String, dynamic>>();
    _sequenceWrites = _sequenceWrites.then((_) async {
      final next = _seq + 1;
      try {
        final iv = enc.IV.fromSecureRandom(12);
        final encrypted =
            _encrypter().encryptBytes(utf8.encode(plainJson), iv: iv);
        await EncryptedKvStoreService.storage.write(key: key, value: "$next");
        _seq = next;
        completer.complete({
          "v": 1,
          "iv": iv.base64,
          "ct": encrypted.base64,
          "seq": next,
          "kid": keyId,
        });
      } catch (error, stack) {
        AppLogger.log.e('SecureChannel: seal failed: $error');
        AppLogger.reportError(error, stack);
        completer.completeError(
          error is SecureChannelException
              ? error
              : const SecureChannelException("secure_sequence_persist_failed"),
        );
      }
    }, onError: (_) async {});
    return completer.future;
  }

  /// True when a valid 32-byte key is configured.
  static bool get enabled {
    const k = PaymentGatewayConfig.secureChannelKey;
    if (k.isEmpty) return false;
    try {
      return base64.decode(k).length == 32;
    } catch (e) {
      AppLogger.log.d('SecureChannel: invalid key format (${e.toString()})');
      return false;
    }
  }

  /// Zero-width carrier on top of the sealed channel (backend `ZW_WIRE`).
  static bool get zwEnabled => enabled && PaymentGatewayConfig.zwWire;

  /// Encodes [plain] as invisible zero-width characters (4 chars per byte).
  static String zwEncode(String plain) {
    final bytes = utf8.encode(plain);
    final sb = StringBuffer();
    for (final b in bytes) {
      sb.write(_zwChars[(b >> 6) & 3]);
      sb.write(_zwChars[(b >> 4) & 3]);
      sb.write(_zwChars[(b >> 2) & 3]);
      sb.write(_zwChars[b & 3]);
    }
    return sb.toString();
  }

  /// Decodes a zero-width carrier back to its string, or null when malformed
  /// (unknown character or dangling bits).
  static String? zwDecode(String zw) {
    var cur = 0;
    var n = 0;
    final out = <int>[];
    for (final rune in zw.runes) {
      final v = _zwIndex[String.fromCharCode(rune)];
      if (v == null) return null;
      cur = (cur << 2) | v;
      if (++n == 4) {
        out.add(cur);
        cur = 0;
        n = 0;
      }
    }
    if (n != 0) return null;
    try {
      return utf8.decode(out);
    } catch (e) {
      // Malformed carrier bytes — surfaced to the caller as a typed null, but
      // logged so silent transport corruption is detectable.
      AppLogger.log.w(
          'SecureChannel.zwDecode: invalid UTF-8 in carrier: ${e.toString()}');
      return null;
    }
  }

  /// True when [data] is the zero-width carrier {"v":3,"zw":"…"}.
  static bool isZwEnvelope(Object? data) =>
      data is Map && data["v"] == 3 && data["zw"] is String;

  static enc.Encrypter _encrypter() {
    final key = enc.Key.fromBase64(PaymentGatewayConfig.secureChannelKey);
    return enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));
  }

  /// Paths that must stay plaintext (mirrors the backend exemptions).
  static bool isExemptPath(String path) {
    return path == "/health" ||
        path == "/" ||
        path.startsWith("/webhooks") ||
        path.startsWith("/integrity") ||
        path.startsWith("/payments/return") ||
        RegExp(r"/(callback|return)(\b|/)").hasMatch(path) ||
        path == "/admin/auth/login" ||
        path.startsWith("/creator/uploads/");
  }

  /// Open an envelope map back into its JSON string.
  static String open(Map<String, dynamic> envelope) {
    if (!isEnvelope(envelope)) {
      throw ArgumentError(
          'SecureChannel.open: invalid envelope — missing iv or ct');
    }
    try {
      final iv = enc.IV.fromBase64(envelope["iv"] as String);
      final ct = enc.Encrypted.fromBase64(envelope["ct"] as String);
      return utf8.decode(_encrypter().decryptBytes(ct, iv: iv));
    } catch (e, stack) {
      AppLogger.log.e('SecureChannel: open/decrypt failed: $e');
      AppLogger.reportError(e, stack);
      rethrow;
    }
  }

  /// True if [data] looks like one of our envelopes.
  static bool isEnvelope(Object? data) =>
      data is Map && data["iv"] is String && data["ct"] is String;
}
