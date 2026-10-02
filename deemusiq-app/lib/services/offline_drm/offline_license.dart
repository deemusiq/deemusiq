import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:deemusiq/services/kv_store/encrypted_kv_store.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/offline_drm/offline_drm.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// Playback state of DRM-protected offline content.
enum OfflineLicenseState {
  /// Server-confirmed within the validity window — fully playable.
  valid,

  /// Confirmation expired but still inside the grace window — playable; the
  /// UI should nudge the user to reconnect so the license can be renewed.
  grace,

  /// Past the grace window — decryption refuses with
  /// [OfflineTrackLicenseException] until a successful revalidation.
  locked,

  /// No server confirmation has ever succeeded (fresh install, no backend
  /// configured, or the backend doesn't expose the license endpoint yet).
  /// Fail-open: content stays playable, matching the app's "fully local when
  /// no backend" contract — enforcement only activates once a backend
  /// actually confirms a license.
  unconfirmed,
}

class OfflineLicenseStatus {
  final OfflineLicenseState state;
  final DateTime? lastConfirmedAt;
  final DateTime? validUntil;
  final DateTime? lockedSince;

  const OfflineLicenseStatus({
    required this.state,
    this.lastConfirmedAt,
    this.validUntil,
    this.lockedSince,
  });
}

/// Offline-DRM license: expiry + grace model and rekey-on-reconnect.
///
/// The anchor is `lastConfirmedAt`, persisted in the platform keystore and
/// refreshed when the backend confirms the license (see [confirmLicense]).
/// Derived windows (defaults chosen for a music app that syncs likes anyway):
///
/// ```
/// lastConfirmedAt ── validity (14d) ──► grace (30d) ──► locked
///      valid playable │ playable + renew nudge │ decrypt refuses
/// ```
///
/// On every offline→online transition ([start]) the manager asks the backend
/// to confirm the license; a successful confirmation refreshes
/// `lastConfirmedAt` and, when the content key is older than
/// [minRekeyInterval], rotates it via [OfflineTrackEncryption.rekey] (old
/// generations stay decryptable — see that class).
///
/// A 404 from the backend means the license endpoint isn't deployed yet: the
/// confirmation is NOT counted and the device keeps running on the local
/// clock (and on [OfflineLicenseState.unconfirmed] if it never succeeded).
class OfflineLicenseManager {
  OfflineLicenseManager._();
  static final OfflineLicenseManager instance = OfflineLicenseManager._();

  static const licenseValidity = Duration(days: 14);
  static const gracePeriod = Duration(days: 30);
  static const minRekeyInterval = Duration(days: 30);

  static const _lastConfirmKey = 'deemusiq_offline_license_last_confirm';
  static const _lastRekeyKey = 'deemusiq_offline_license_last_rekey';

  /// Injectable storage/clock seams so the state machine is unit-testable
  /// without the platform keystore.
  @visibleForTesting
  Future<String?> Function(String key)? readOverride;
  @visibleForTesting
  Future<void> Function(String key, String value)? writeOverride;
  @visibleForTesting
  DateTime Function()? clockOverride;

  DateTime get _now => clockOverride?.call() ?? DateTime.now();

  Future<String?> _read(String key) =>
      readOverride?.call(key) ?? EncryptedKvStoreService.storage.read(key: key);

  Future<void> _write(String key, String value) async =>
      writeOverride?.call(key, value) ??
      EncryptedKvStoreService.storage.write(key: key, value: value);

  StreamSubscription<bool>? _connectivitySub;
  bool _confirming = false;

  /// Starts rekey-on-reconnect: every offline→online transition triggers a
  /// best-effort [confirmLicense]. Wire to
  /// `ConnectionCheckerService.instance.onConnectivityChanged`.
  /// Also registers [assertPlayable] as the decryption gate on
  /// [OfflineTrackEncryption].
  void start(Stream<bool> onOnline) {
    OfflineTrackEncryption.playbackGate = assertPlayable;
    _connectivitySub ??= onOnline.listen((connected) {
      if (connected) unawaited(confirmLicense());
    });
  }

  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  Future<DateTime?> _readTimestamp(String key) async {
    try {
      final raw = await _read(key);
      if (raw == null || raw.isEmpty) return null;
      return DateTime.tryParse(raw)?.toUtc();
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'OfflineLicenseManager._readTimestamp');
      return null;
    }
  }

  /// Current license status, computed from the persisted confirmation.
  Future<OfflineLicenseStatus> status() async {
    final lastConfirmed = await _readTimestamp(_lastConfirmKey);
    if (lastConfirmed == null) {
      return const OfflineLicenseStatus(state: OfflineLicenseState.unconfirmed);
    }
    final now = _now.toUtc();
    final validUntil = lastConfirmed.add(licenseValidity);
    final graceUntil = validUntil.add(gracePeriod);
    if (now.isBefore(validUntil)) {
      return OfflineLicenseStatus(
        state: OfflineLicenseState.valid,
        lastConfirmedAt: lastConfirmed,
        validUntil: validUntil,
      );
    }
    if (now.isBefore(graceUntil)) {
      return OfflineLicenseStatus(
        state: OfflineLicenseState.grace,
        lastConfirmedAt: lastConfirmed,
        validUntil: validUntil,
      );
    }
    return OfflineLicenseStatus(
      state: OfflineLicenseState.locked,
      lastConfirmedAt: lastConfirmed,
      validUntil: validUntil,
      lockedSince: graceUntil,
    );
  }

  /// True while protected content may be decrypted (valid, grace, or no
  /// backend-side enforcement yet).
  Future<bool> isPlaybackAllowed() async {
    final s = await status();
    return s.state != OfflineLicenseState.locked;
  }

  /// Asks the backend to confirm the offline license. On success the
  /// confirmation timestamp is refreshed and — when the current content key
  /// is older than [minRekeyInterval] — the key is rotated.
  ///
  /// Returns true only when the server actually confirmed. 404 (endpoint not
  /// deployed) and connectivity failures both leave the local state untouched.
  Future<bool> confirmLicense() async {
    if (_confirming) return false;
    final api = WalletApiClient.instance;
    if (!api.isConfigured) return false;
    _confirming = true;
    try {
      await api.confirmOfflineLicense();
      final now = _now.toUtc();
      await _write(_lastConfirmKey, now.toIso8601String());

      final lastRekey = await _readTimestamp(_lastRekeyKey);
      final rekeyDue = lastRekey == null ||
          now.difference(lastRekey) >= minRekeyInterval;
      if (rekeyDue) {
        await OfflineTrackEncryption.instance.rekey();
        await _write(_lastRekeyKey, now.toIso8601String());
        AppLogger.log.i('OfflineLicense: license confirmed, content key rotated');
      } else {
        AppLogger.log.i('OfflineLicense: license confirmed');
      }
      return true;
    } on WalletApiException catch (e) {
      if (e.statusCode == 404) {
        // Endpoint not deployed on this backend — local policy keeps running.
        AppLogger.log.d('OfflineLicense: backend has no license endpoint (404)');
      } else if (!e.isConnectivity) {
        AppLogger.log.w('OfflineLicense: confirmation failed: ${e.message}');
      }
      return false;
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'OfflineLicenseManager.confirmLicense');
      return false;
    } finally {
      _confirming = false;
    }
  }

  /// Gate used by [OfflineTrackEncryption] before decrypting: throws
  /// [OfflineTrackLicenseException] when past the grace window.
  Future<void> assertPlayable() async {
    final s = await status();
    if (s.state == OfflineLicenseState.locked) {
      throw OfflineTrackLicenseException(
        'Offline license expired beyond the grace window '
        '(last confirmed ${s.lastConfirmedAt}, locked since ${s.lockedSince}). '
        'Connect to the internet to renew it.',
      );
    }
  }
}

/// Thrown when DRM-protected content is played past the license grace window.
/// Distinct from [OfflineTrackDecryptException] (corruption/tamper) so the UI
/// can show a "reconnect to renew" state instead of an error.
class OfflineTrackLicenseException implements Exception {
  final String message;
  OfflineTrackLicenseException(this.message);
  @override
  String toString() => 'OfflineTrackLicenseException: $message';
}
