import 'dart:convert';

import 'package:deemusiq/models/wallet/wallet_state.dart';
import 'package:deemusiq/services/kv_store/encrypted_kv_store.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:encrypt/encrypt.dart' as enc;

/// Local persistence for the DeeMusiq wallet, backed by the same
/// SharedPreferences instance the rest of the app uses (already initialised at
/// startup via [KVStoreService.initialize]).
///
/// The ledger blob is encrypted at rest: `v2:` blobs use AES-256-GCM (12-byte
/// nonce || ciphertext+tag, base64) under a key derived from the store key
/// material — the same construction as the wallet secure channel. Older
/// `enc1:` Salsa20 blobs and legacy plaintext blobs are still READ so no
/// install loses its wallet; the next [save] transparently rewrites them as
/// v2. There is deliberately NO plaintext-write fallback: when the encrypter
/// can't initialise, [save] throws instead of silently degrading to
/// cleartext.
abstract class WalletPersistence {
  static const _key = "deemusiq_wallet_v1";
  static const _legacyEncPrefix = "enc1:";
  static const _v2Prefix = "v2:";

  static enc.Encrypter? _legacyEncrypter;
  static enc.Encrypter? _gcmEncrypter;

  /// Legacy Salsa20 cipher — kept ONLY to decrypt blobs written by older
  /// builds; nothing is encrypted with it anymore.
  static enc.Encrypter get _salsa20 {
    _legacyEncrypter ??= enc.Encrypter(
      enc.Salsa20(
        enc.Key.fromUtf8(EncryptedKvStoreService.encryptionKeySync),
      ),
    );
    return _legacyEncrypter!;
  }

  static enc.Encrypter get _gcm {
    _gcmEncrypter ??= enc.Encrypter(
      enc.AES(
        enc.Key(EncryptedKvStoreService.aesKeyBytes),
        mode: enc.AESMode.gcm,
      ),
    );
    return _gcmEncrypter!;
  }

  static String _encrypt(String plain) {
    // Throws (StateError from encryptionKeySync) when the key material is
    // unavailable — by design, so save() fails the operation rather than
    // writing the wallet in plaintext.
    final iv = enc.IV.fromSecureRandom(12);
    final encrypted = _gcm.encrypt(plain, iv: iv);
    return _v2Prefix + base64Encode([...iv.bytes, ...encrypted.bytes]);
  }

  static String _decrypt(String raw) {
    if (raw.startsWith(_v2Prefix)) {
      final combined = base64Decode(raw.substring(_v2Prefix.length));
      final iv = enc.IV(combined.sublist(0, 12));
      final encrypted = enc.Encrypted(combined.sublist(12));
      return _gcm.decrypt(encrypted, iv: iv);
    }
    if (raw.startsWith(_legacyEncPrefix)) {
      final combined = base64Decode(raw.substring(_legacyEncPrefix.length));
      final iv = enc.IV(combined.sublist(0, 8));
      final encrypted = enc.Encrypted(combined.sublist(8));
      return _salsa20.decrypt(encrypted, iv: iv);
    }
    return raw; // legacy plaintext blob — upgraded to v2 on the next save
  }

  static WalletState load() {
    try {
      final raw = KVStoreService.sharedPreferences.getString(_key);
      if (raw == null || raw.isEmpty) return const WalletState();
      return WalletState.fromJson(
        jsonDecode(_decrypt(raw)) as Map<String, dynamic>,
      );
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
      return const WalletState();
    }
  }

  static Future<void> save(WalletState state) async {
    try {
      await KVStoreService.sharedPreferences.setString(
        _key,
        _encrypt(jsonEncode(state.toJson())),
      );
    } on StateError {
      // Encrypter unavailable: never fall back to a plaintext write — fail
      // the save and let the caller surface the error.
      rethrow;
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
    }
  }
}
