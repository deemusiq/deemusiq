import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deemusiq/services/kv_store/encrypted_kv_store.dart';
import 'package:deemusiq/services/logger/logger.dart';

/// Fingerprint / face / device-PIN app lock for DeeMusiq.
///
/// - Settings toggle persists in the platform keystore via
///   flutter_secure_storage (`deemusiq_biometric_lock`) — NOT plain
///   SharedPreferences, so the lock can't be switched off by editing a
///   world-readable prefs file. A legacy plain-prefs value is migrated into
///   secure storage on first read and then scrubbed.
/// - `authenticate()` uses the OS biometric prompt (fingerprint on Android,
///   Face ID / Touch ID on iOS) with a device-PIN fallback where the OS
///   allows it (`biometricOnly: false`).
/// - The app shows the lock screen on cold start when the toggle is on; a
///   successful prompt unlocks for the process lifetime (+ background grace).
class BiometricLockService {
  BiometricLockService._();
  static final BiometricLockService instance = BiometricLockService._();

  static const _prefKey = 'deemusiq_biometric_lock';
  static const _graceKey = 'deemusiq_biometric_last_unlock';

  /// Background grace: re-lock only if the app was backgrounded longer than this.
  static const gracePeriod = Duration(minutes: 2);

  final LocalAuthentication _auth = LocalAuthentication();
  bool _unlockedThisSession = false;
  DateTime? _lastBackgrounded;

  Future<bool> isEnabled() async {
    try {
      final secure = await EncryptedKvStoreService.storage.read(key: _prefKey);
      if (secure != null) return secure == 'true';

      // One-time migration from the legacy plain-SharedPreferences flag.
      final prefs = await SharedPreferences.getInstance();
      final legacy = prefs.getBool(_prefKey);
      if (legacy != null) {
        try {
          await EncryptedKvStoreService.storage
              .write(key: _prefKey, value: legacy.toString());
          await prefs.remove(_prefKey);
        } catch (e) {
          AppLogger.log.w('biometric flag migration failed: ${e.toString()}');
        }
        return legacy;
      }
      return false;
    } catch (e) {
      AppLogger.log.w('biometric isEnabled read failed: ${e.toString()}');
      return false;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    try {
      await EncryptedKvStoreService.storage
          .write(key: _prefKey, value: enabled.toString());
      // Scrub any leftover plain-prefs copy so the toggle can't be flipped
      // outside the app.
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKey);
    } catch (e) {
      AppLogger.log.w('biometric setEnabled failed: ${e.toString()}');
    }
    if (!enabled) _unlockedThisSession = false;
  }

  /// Whether the device can do biometric auth at all.
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on MissingPluginException {
      // No local_auth implementation on this platform (e.g. Linux desktop) —
      // not an error, the device simply has no biometrics.
      return false;
    } on PlatformException catch (e) {
      AppLogger.log.w('biometric canCheck failed: ${e.message}');
      return false;
    }
  }

  Future<List<BiometricType>> availableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on MissingPluginException {
      return const [];
    } on PlatformException {
      return const [];
    }
  }

  void markBackgrounded() {
    _lastBackgrounded = DateTime.now();
  }

  void markForegrounded() {
    // Keep _lastBackgrounded so needsUnlock() can apply the grace window.
  }

  /// True when the lock screen must be shown.
  Future<bool> needsUnlock() async {
    if (!await isEnabled()) return false;
    if (_unlockedThisSession) {
      if (_lastBackgrounded == null) return false;
      final away = DateTime.now().difference(_lastBackgrounded!);
      if (away <= gracePeriod) return false;
      _unlockedThisSession = false;
      return true;
    }
    return true;
  }

  /// Show the OS prompt. Returns true on success.
  Future<bool> authenticate({String reason = 'Unlock DeeMusiq'}) async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      if (ok) {
        _unlockedThisSession = true;
        _lastBackgrounded = null;
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt(_graceKey, DateTime.now().millisecondsSinceEpoch);
        } catch (_) {}
      }
      return ok;
    } on MissingPluginException {
      // No local_auth on this platform — treat as "cannot authenticate".
      return false;
    } on PlatformException catch (e, stack) {
      AppLogger.reportError(e, stack, 'biometric authenticate');
      return false;
    }
  }

  void lockNow() {
    _unlockedThisSession = false;
    _lastBackgrounded = DateTime.now().subtract(const Duration(hours: 1));
  }
}
