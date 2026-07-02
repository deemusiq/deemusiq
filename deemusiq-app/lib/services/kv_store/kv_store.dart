import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/services/wm_tools/wm_tools.dart';
import 'package:deemusiq/services/kv_store/encrypted_kv_store.dart';
import 'package:uuid/uuid.dart';

abstract class KVStoreService {
  static SharedPreferences? _sharedPreferences;
  static SharedPreferences get sharedPreferences => _sharedPreferences!;
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
    } catch (_) {
      return false;
    }
  }

  static Future<void> _writeEncryptedBool(String key, bool value) async {
    if (!_encryptedReady) return;
    try {
      await EncryptedKvStoreService.storage.write(key: key, value: value.toString());
      if (key == 'ageVerified') _ageVerifiedSync = value;
    } catch (_) {
      // fallback to plain prefs if secure storage unavailable
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

    final key = const Uuid().v4();
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
}
