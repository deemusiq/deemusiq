import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/services/logger/logger.dart';

abstract class EncryptedKvStoreService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static FlutterSecureStorage get storage => _storage;

  static String? _encryptionKeySync;

  /// Preference key historically used as a last-resort plaintext fallback.
  /// Kept only so we can MIGRATE the value into the platform keystore and
  /// then remove it from plain SharedPreferences.
  static const _plainFallbackKey = 'encryption';

  /// Fresh key material for NEW installs: 32 random bytes, base64-encoded
  /// (44 chars). Older installs keep their existing key string — rotating it
  /// would orphan every already-encrypted blob, and the v2 cipher derives a
  /// full 256-bit AES key from whatever key string is present (see
  /// [aesKeyBytes]).
  static String generateEncryptionKey() {
    final rng = Random.secure();
    final bytes = Uint8List.fromList(
      List.generate(32, (_) => rng.nextInt(256)),
    );
    return base64Encode(bytes);
  }

  /// The 32-byte AES-256 key for the v2 (AES-256-GCM) blob formats, derived
  /// as SHA-256 over the stored key string. Deriving uniformly — instead of
  /// using the key string bytes directly — works for both the legacy
  /// UUID-shaped keys and the new base64 random keys.
  static Uint8List get aesKeyBytes =>
      Uint8List.fromList(sha256.convert(utf8.encode(encryptionKeySync)).bytes);

  static Future<void> initialize() async {
    _encryptionKeySync = await encryptionKey;
  }

  static String get encryptionKeySync {
    if (_encryptionKeySync == null) {
      throw StateError(
        'EncryptedKvStoreService not initialized. Call EncryptedKvStoreService.initialize() first.',
      );
    }
    return _encryptionKeySync!;
  }

  static Future<String> get encryptionKey async {
    try {
      final secureValue = await _storage.read(key: _plainFallbackKey);

      // Prefer the platform keystore. If it already has a key, use it and
      // scrub any plaintext copy left by older builds.
      if (secureValue != null && secureValue.isNotEmpty) {
        await _scrubPlaintextCopy();
        return secureValue;
      }

      // Migrate a plaintext key (older builds) into the keystore so existing
      // Salsa20-encrypted rows keep decrypting with the same key material.
      final plain = KVStoreService.sharedPreferences.getString(_plainFallbackKey);
      if (plain != null && plain.isNotEmpty) {
        try {
          await _storage.write(key: _plainFallbackKey, value: plain);
          await _scrubPlaintextCopy();
          AppLogger.log.i(
            'EncryptedKvStore: migrated encryption key from plain prefs into secure storage',
          );
          return plain;
        } catch (e) {
          // Keystore still unavailable — keep working with the existing key.
          AppLogger.log.w(
            'EncryptedKvStore: could not migrate key to secure storage: ${e.toString()}',
          );
          return plain;
        }
      }

      final key = generateEncryptionKey();
      await setEncryptionKey(key);
      return key;
    } catch (e) {
      AppLogger.log.w(
        'FlutterSecureStorage unavailable, falling back to SharedPreferences for encryption key',
      );
      return KVStoreService.encryptionKey;
    }
  }

  static Future<void> setEncryptionKey(String key) async {
    try {
      await _storage.write(key: _plainFallbackKey, value: key);
      await _scrubPlaintextCopy();
    } catch (e) {
      AppLogger.log.w(
        'FlutterSecureStorage write failed, falling back to SharedPreferences for encryption key',
      );
      await KVStoreService.setEncryptionKey(key);
    } finally {
      _encryptionKeySync = key;
    }
  }

  /// Remove the plaintext copy once the key lives in the platform keystore.
  static Future<void> _scrubPlaintextCopy() async {
    try {
      await KVStoreService.sharedPreferences.remove(_plainFallbackKey);
    } catch (_) {
      // Best-effort: a leftover plain copy is less critical than a failed init.
    }
  }
}
