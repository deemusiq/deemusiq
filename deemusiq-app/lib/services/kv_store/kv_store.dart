import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/services/wm_tools/wm_tools.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/kv_store/encrypted_kv_store.dart';

abstract class KVStoreService {
  static SharedPreferences? _sharedPreferences;
  static SharedPreferences get sharedPreferences {
    if (_sharedPreferences == null) {
      throw StateError(
        'KVStoreService not initialized. Call KVStoreService.initialize() first.',
      );
    }
    return _sharedPreferences!;
  }
  static bool _encryptedReady = false;

  static Future<void> initialize() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _encryptedReady = true;
  }

  static bool get doneGettingStarted =>
      sharedPreferences.getBool('doneGettingStarted') ?? false;
  static Future<void> setDoneGettingStarted(bool value) async =>
      await sharedPreferences.setBool('doneGettingStarted', value);

  /// SA FPB Act compliance: age verification for explicit content.
  /// Stored in platform keystore (flutter_secure_storage) — not plain prefs.
  static bool get ageVerified => _ageVerifiedSync;
  static bool _ageVerifiedSync = false;

  static Future<bool> _readEncryptedBool(String key) async {
    if (!_encryptedReady) return false;
    try {
      final v = await EncryptedKvStoreService.storage.read(key: key);
      return v == 'true';
    } catch (e) {
      AppLogger.log.w('KVStore: encrypted read of "$key" failed: ${e.toString()}');
      return false;
    }
  }

  static Future<void> _writeEncryptedBool(String key, bool value) async {
    if (!_encryptedReady) return;
    try {
      await EncryptedKvStoreService.storage.write(key: key, value: value.toString());
      if (key == 'ageVerified') _ageVerifiedSync = value;
    } catch (e) {
      // fallback to plain prefs if secure storage unavailable
      AppLogger.log.w('KVStore: encrypted write of "$key" failed, using plain prefs: ${e.toString()}');
      await sharedPreferences.setBool(key, value);
      if (key == 'ageVerified') _ageVerifiedSync = value;
    }
  }

  static Future<void> loadEncryptedFlags() async {
    _ageVerifiedSync = await _readEncryptedBool('ageVerified');
  }

  static Future<void> setAgeVerified(bool value) async =>
      await _writeEncryptedBool('ageVerified', value);

  /// SA POPIA Act compliance: privacy consent.
  /// Stored in platform keystore — not plain prefs.
  static Future<bool> get privacyConsentGiven async =>
      await _readEncryptedBool('privacyConsentGiven');
  static Future<void> setPrivacyConsentGiven(bool value) async =>
      await _writeEncryptedBool('privacyConsentGiven', value);

  static bool get askedForBatteryOptimization =>
      sharedPreferences.getBool('askedForBatteryOptimization') ?? false;
  static Future<void> setAskedForBatteryOptimization(bool value) async =>
      await sharedPreferences.setBool('askedForBatteryOptimization', value);

  static List<String> get recentSearches =>
      sharedPreferences.getStringList('recentSearches') ?? [];

  static Future<void> setRecentSearches(List<String> value) async {
    final controlCharPattern = RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\x9F]');
    final sanitized = value
        .map((e) => e.replaceAll(controlCharPattern, ''))
        .map((e) => e.length > 200 ? e.substring(0, 200) : e)
        .take(50)
        .toList();
    await sharedPreferences.setStringList('recentSearches', sanitized);
  }

  static WindowSize? get windowSize {
    final raw = sharedPreferences.getString('windowSize');

    if (raw == null) {
      return null;
    }
    return WindowSize.fromJson(jsonDecode(raw));
  }

  static Future<void> setWindowSize(WindowSize value) async =>
      await sharedPreferences.setString(
        'windowSize',
        jsonEncode(
          value.toJson(),
        ),
      );

  static String get encryptionKey {
    final value = sharedPreferences.getString('encryption');

    final key = EncryptedKvStoreService.generateEncryptionKey();
    if (value == null) {
      setEncryptionKey(key);
      return key;
    }

    return value;
  }

  static Future<void> setEncryptionKey(String key) async {
    await sharedPreferences.setString('encryption', key);
  }

  static IV get ivKey {
    final iv = sharedPreferences.getString('iv');
    final value = IV.fromSecureRandom(8);

    if (iv == null) {
      setIVKey(value);

      return value;
    }

    return IV.fromBase64(iv);
  }

  static Future<void> setIVKey(IV iv) async {
    await sharedPreferences.setString('iv', iv.base64);
  }

  static double get volume => sharedPreferences.getDouble('volume') ?? 1.0;
  static Future<void> setVolume(double value) async =>
      await sharedPreferences.setDouble('volume', value);

  static bool get hasMigratedToDrift =>
      sharedPreferences.getBool('hasMigratedToDrift') ?? false;
  static Future<void> setHasMigratedToDrift(bool value) async =>
      await sharedPreferences.setBool('hasMigratedToDrift', value);

  static Map<String, dynamic>? get _youtubeEnginePaths {
    final jsonRaw = sharedPreferences.getString('ytDlpPath');

    if (jsonRaw == null) {
      return null;
    }

    return jsonDecode(jsonRaw);
  }

  static String? getYoutubeEnginePath(YoutubeClientEngine engine) {
    return _youtubeEnginePaths?[engine.name];
  }

  static Future<void> setYoutubeEnginePath(
    YoutubeClientEngine engine,
    String path,
  ) async {
    await sharedPreferences.setString(
      'ytDlpPath',
      jsonEncode({
        ...?_youtubeEnginePaths,
        engine.name: path,
      }),
    );
  }

  static const _managedYtDlpKey = 'ytDlpManagedBinary';

  /// Provenance of the yt-dlp binary DeeMusiq downloaded and manages itself
  /// (see `YtDlpProvisioner`). Stored as JSON: path, sha256, version, asset,
  /// url, installedAt and whether the release was pinned by the build.
  ///
  /// This is an integrity record, not a secret, so plain prefs are fine — it
  /// must survive restarts and is re-checked against the file on disk before
  /// every reuse.
  static Map<String, dynamic>? get managedYtDlp {
    final raw = sharedPreferences.getString(_managedYtDlpKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e) {
      AppLogger.log.w('KVStore: corrupt managed yt-dlp record: ${e.toString()}');
      return null;
    }
  }

  static Future<void> setManagedYtDlp(Map<String, dynamic> value) async =>
      await sharedPreferences.setString(_managedYtDlpKey, jsonEncode(value));

  static Future<void> clearManagedYtDlp() async =>
      await sharedPreferences.remove(_managedYtDlpKey);

  /// POPIA account deletion: wipe every locally persisted key/value — plain
  /// SharedPreferences AND the platform keystore (session seeds, age
  /// verification, consent flags) — and reset the in-memory mirrors so
  /// nothing from the deleted account survives.
  static Future<void> clearAll() async {
    await sharedPreferences.clear();
    try {
      await EncryptedKvStoreService.storage.deleteAll();
    } catch (e) {
      AppLogger.log.w('KVStore: secure-storage wipe failed: ${e.toString()}');
    }
    _ageVerifiedSync = false;
  }

  /// Secure-storage keys that survive [clearAccountState] — device-level,
  /// not account-derived. Wiping them on sign-out would be actively harmful:
  /// - the Ed25519 seed + device id are the device identity; regenerating them
  ///   would register a phantom "new device" on the next login;
  /// - the logged-out tombstone is what makes logout stick (H2) — wiping it
  ///   would re-enable silent re-auth immediately;
  /// - the offline-DRM keyring: wiping it would brick every encrypted
  ///   download the user paid for;
  /// - the secure-channel seq: wiping it would restart the monotonic counter
  ///   and get every future sealed request rejected as a replay.
  static const _preservedSecureKeys = {
    'deemusiq_device_ed25519_seed_v1',
    'deemusiq_device_id',
    'deemusiq_logged_out',
    'deemusiq_offline_drm_key',
    'deemusiq_offline_drm_keyring',
    'deemusiq_offline_license_last_confirm',
    'deemusiq_offline_license_last_rekey',
    'deemusiq_biometric_lock',
    'ageVerified',
    'privacyConsentGiven',
  };

  static bool _isPreservedSecureKey(String key) =>
      _preservedSecureKeys.contains(key) ||
      key.startsWith('deemusiq_secure_seq_');

  /// H2: sign-out wipe — clears account-derived local state (plain prefs:
  /// recent searches, checkout idempotency keys; secure storage: cached
  /// account/session material) while preserving the device-level keys listed
  /// above. Unlike [clearAll] this does NOT wipe the DRM keyring or the
  /// device identity: logout revokes sessions, not the device, and the user's
  /// encrypted downloads must stay playable.
  static Future<void> clearAccountState() async {
    await sharedPreferences.clear();
    try {
      final all = await EncryptedKvStoreService.storage.readAll();
      for (final key in all.keys) {
        if (!_isPreservedSecureKey(key)) {
          await EncryptedKvStoreService.storage.delete(key: key);
        }
      }
    } catch (e) {
      AppLogger.log.w('KVStore: account-state wipe failed: ${e.toString()}');
    }
  }
}
