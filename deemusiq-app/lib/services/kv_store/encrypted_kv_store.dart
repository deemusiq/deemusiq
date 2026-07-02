import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:uuid/uuid.dart';

abstract class EncryptedKvStoreService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static FlutterSecureStorage get storage => _storage;

  static String? _encryptionKeySync;

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
      final value = await _storage.read(key: 'encryption');
      final key = const Uuid().v4();

      if (value == null) {
        await setEncryptionKey(key);
        return key;
      }

      return value;
    } catch (e) {
      AppLogger.log.w(
        'FlutterSecureStorage unavailable, falling back to SharedPreferences for encryption key',
      );
      return KVStoreService.encryptionKey;
    }
  }

  static Future<void> setEncryptionKey(String key) async {
    try {
      await _storage.write(key: 'encryption', value: key);
    } catch (e) {
      AppLogger.log.w(
        'FlutterSecureStorage write failed, falling back to SharedPreferences for encryption key',
      );
      await KVStoreService.setEncryptionKey(key);
    } finally {
      _encryptionKeySync = key;
    }
  }
}
