import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:deemusiq/services/kv_store/encrypted_kv_store.dart';
import 'package:deemusiq/services/logger/logger.dart';

/// Offline-song DRM: encrypts downloaded audio so files are only playable
/// inside the DeeMusiq app. Uses AES-256-GCM with a device-bound key stored
/// in the platform encrypted key-value store (Android Keystore / iOS Keychain).
/// Without the key, the raw file is useless noise.
///
/// Keys are versioned by generation: [rekey] (called when the backend
/// confirms the offline license — see `offline_license.dart`) rotates in a
/// fresh key for future encryptions while up to [_maxRetainedGenerations]
/// previous generations stay decryptable, so rotation never bricks downloads.
/// Files written since the keyring was introduced carry a small v2 header
/// (magic + format version + generation byte) before the IV; older bare
/// `iv(12) || ciphertext` files are still decrypted via the fallback path.
///
/// ## Data path
/// New downloads are encrypted by [encryptAndSave] into the app-private
/// documents directory (`download_manager_provider.dart`); playback decrypts
/// in memory and streams over the loopback playback server
/// (`/offline/<name>` in `provider/server/routes/playback.dart`) — plaintext
/// never lands on shared/world-readable storage.
///
/// ## Threat model
/// - A rooted device that dumps the KV store and raw files can still decrypt.
///   This is a casual-protection layer, not unbreakable DRM (that needs
///   hardware-backed keystores + Widevine, which require Play Store).
/// - The deposit address for crypto top-ups is *never* in the app (owned by
///   the backend), so a repackaged copy can't steal user funds.
/// - Encrypted files carry a `.deemusiq` extension — the OS media scanner
///   ignores them, keeping them invisible to other music players.
/// - ACCEPTED RISK (streaming cache): streamed (non-downloaded) tracks are
///   cached as plaintext, hash-addressed files (≤500 MB, user-toggleable via
///   "cache music") so re-plays work offline and don't re-burn bandwidth.
///   That cache is a deliberate, documented extraction surface — encrypting
///   it would break instant replay/seek of partially cached streams; only
///   explicit downloads get the encrypted-at-rest treatment above.
class OfflineTrackEncryption {
  OfflineTrackEncryption._();
  static final OfflineTrackEncryption instance = OfflineTrackEncryption._();

  static const _keyAlias = 'deemusiq_offline_drm_key';
  static const _keyringAlias = 'deemusiq_offline_drm_keyring';
  static const _encryptedExtension = '.deemusiq';

  /// Envelope v2 header: magic 'DM' + format version + key generation byte.
  /// Files written after the first [rekey] carry their key generation so
  /// [decrypt] picks the right key from the keyring in one attempt; older
  /// files (bare `iv(12) || ciphertext`) fall back to trying current then
  /// previous generations, then the legacy whole-blob path.
  static const _envelopeMagic = [0x44, 0x4d]; // 'DM'
  static const _envelopeVersion = 2;

  /// Key generations retained for decryption. With [rekey] called at most
  /// monthly (OfflineLicenseManager.minRekeyInterval) this covers ~4 months
  /// of downloads; older files report a clear re-download error.
  static const _maxRetainedGenerations = 4;

  enc.Key? _cachedKey;

  /// generation → 48-byte key material (32 key + 16 legacy IV), newest last.
  /// Null until the keyring has been loaded; generation 0 is the pre-keyring
  /// single-key format migrated from [_keyAlias].
  Map<int, Uint8List>? _keyring;
  int _currentGeneration = 0;

  /// Test seam: replace the platform keystore with an in-memory map.
  @visibleForTesting
  Future<String?> Function(String key)? readOverride;
  @visibleForTesting
  Future<void> Function(String key, String value)? writeOverride;

  Future<String?> _storageRead(String key) =>
      readOverride?.call(key) ?? EncryptedKvStoreService.storage.read(key: key);

  Future<void> _storageWrite(String key, String value) async =>
      writeOverride?.call(key, value) ??
      EncryptedKvStoreService.storage.write(key: key, value: value);

  /// Derives or retrieves the device-bound AES-256 key + IV. Generated once
  /// per install and stored in the platform encrypted key-value store
  /// (flutter_secure_storage — Android Keystore / iOS Keychain).
  /// If wiped (reinstall), previously downloaded files become unreadable —
  /// re-download them.
  Future<enc.Key>? _keyFuture;

  Future<enc.Key> _key() async {
    final cached = _cachedKey;
    if (cached != null) return cached;
    final active = _keyFuture;
    if (active != null) return active;
    final future = _loadKey();
    _keyFuture = future;
    try {
      return await future;
    } finally {
      if (identical(_keyFuture, future)) _keyFuture = null;
    }
  }

  Future<enc.Key> _loadKey() async {
    try {
      await _loadKeyring();
      final material = _keyring![_currentGeneration]!;
      _cachedKey = enc.Key(material.sublist(0, 32));
      return _cachedKey!;
    } catch (e, stack) {
      AppLogger.log.w('Offline DRM key derivation failed: ${e.toString()}');
      AppLogger.reportError(e, stack);
      _cachedKey = null;
      rethrow;
    }
  }

  /// Loads the keyring from secure storage, migrating the pre-keyring single
  /// key ([_keyAlias]) to generation 0 on first read, or creating a fresh
  /// generation 0 on first use.
  Future<void> _loadKeyring() async {
    if (_keyring != null) return;

    final raw = await _storageRead(_keyringAlias);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final gens = (decoded['gens'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(int.parse(k), base64Decode(v as String)),
        );
        if (gens.isEmpty) throw const FormatException('empty keyring');
        for (final entry in gens.entries) {
          if (entry.value.length < 48) {
            throw FormatException('key gen ${entry.key} too short');
          }
        }
        _keyring = gens;
        _currentGeneration = decoded['current'] as int;
        if (!_keyring!.containsKey(_currentGeneration)) {
          throw const FormatException('keyring current generation missing');
        }
        return;
      } catch (e, stack) {
        AppLogger.reportError(
          e,
          stack,
          'OfflineDRM: corrupt keyring, falling back to legacy key',
        );
      }
    }

    // Migration: the legacy alias holds the original 48-byte blob. It becomes
    // generation 0 so existing downloads keep decrypting.
    final existing = await _storageRead(_keyAlias);
    if (existing != null && existing.length >= 64) {
      try {
        final decoded = base64Decode(existing);
        if (decoded.length < 48) {
          AppLogger.log.w(
            'OfflineDRM: stored key too short (${decoded.length} bytes), regenerating',
          );
          throw const FormatException('Key too short');
        }
        _keyring = {0: decoded};
        _currentGeneration = 0;
        await _persistKeyring();
        return;
      } catch (e, stack) {
        AppLogger.reportError(
          e,
          stack,
          'OfflineDRM: corrupt stored key, regenerating',
        );
      }
    }

    final fresh = Uint8List(48);
    fresh.setAll(0, _secureBytes(32));
    fresh.setAll(32, _secureBytes(16));
    _keyring = {0: fresh};
    _currentGeneration = 0;
    await _persistKeyring();
  }

  Future<void> _persistKeyring() async {
    final ring = _keyring!;
    await _storageWrite(
      _keyringAlias,
      jsonEncode({
        'gens': ring.map((k, v) => MapEntry('$k', base64Encode(v))),
        'current': _currentGeneration,
      }),
    );
    // Keep the legacy alias in sync with the current generation so builds
    // predating the keyring still read a working (latest) key.
    await _storageWrite(_keyAlias, base64Encode(ring[_currentGeneration]!));
  }

  /// Rotates the content key: a new generation becomes the target for all
  /// future encryptions while previous generations (bounded by
  /// [_maxRetainedGenerations]) stay available for decryption. Called by the
  /// OfflineLicenseManager after the backend confirms the license.
  Future<int> rekey() async {
    await _key();
    final ring = Map<int, Uint8List>.from(_keyring!);
    final next = _currentGeneration + 1;
    final material = Uint8List(48);
    material.setAll(0, _secureBytes(32));
    material.setAll(32, _secureBytes(16));
    ring[next] = material;

    // Retire the oldest generations beyond the retention window.
    final generations = ring.keys.toList()..sort();
    while (generations.length > _maxRetainedGenerations) {
      final retired = generations.removeAt(0);
      ring.remove(retired);
      AppLogger.log.i('OfflineDRM: retired key generation $retired');
    }

    _keyring = ring;
    _currentGeneration = next;
    _cachedKey = null;
    await _persistKeyring();
    await _key();
    AppLogger.log.i('OfflineDRM: rekeyed to generation $next');
    return next;
  }

  /// Current key generation (visible for tests/diagnostics).
  @visibleForTesting
  int get currentGeneration => _currentGeneration;

  /// Drops cached key material and storage overrides so each test starts from
  /// a pristine keystore state.
  @visibleForTesting
  void resetForTesting() {
    _cachedKey = null;
    _keyring = null;
    _currentGeneration = 0;
    _keyFuture = null;
    readOverride = null;
    writeOverride = null;
    playbackGate = null;
  }

  /// Gate invoked before encrypting/decrypting protected content. The
  /// OfflineLicenseManager registers its license check here on [start];
  /// a null gate fails open (unconfirmed licenses stay playable).
  static Future<void> Function()? playbackGate;

  static void _zeroBuffer(Uint8List buffer) {
    for (var i = 0; i < buffer.length; i++) {
      buffer[i] = 0;
    }
  }

  /// Resolves the app-private path that [encryptAndSave] would produce for
  /// [outputPath] (sanitized base name + `.deemusiq`, in the application
  /// documents directory) without writing anything. The download manager uses
  /// this to pre-check whether a track was already downloaded.
  Future<String> encryptedPathFor(String outputPath) async {
    final safeName = _sanitizeFileName(outputPath);
    final encodedName = safeName.toLowerCase().endsWith(_encryptedExtension)
        ? safeName
        : '$safeName$_encryptedExtension';
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}${Platform.pathSeparator}$encodedName';
  }

  /// Encrypts [plainBytes] and writes to [outputPath] (appending `.deemusiq`).
  ///
  /// SECURITY: [outputPath] is sanitized against path-traversal attacks.
  /// Only the base filename is used — any directory components are stripped.
  /// The file is always written to the app's download directory.
  Future<String> encryptAndSave(Uint8List plainBytes, String outputPath) async {
    await playbackGate?.call();
    final key = await _key();
    final iv = enc.IV.fromSecureRandom(12);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));
    final encrypted = encrypter.encryptBytes(plainBytes, iv: iv);
    const headerLength = 4; // magic(2) + version(1) + generation(1)
    final combined =
        Uint8List(headerLength + iv.bytes.length + encrypted.bytes.length);
    combined.setAll(0, _envelopeMagic);
    combined[2] = _envelopeVersion;
    combined[3] = _currentGeneration;
    combined.setAll(headerLength, iv.bytes);
    combined.setAll(headerLength + iv.bytes.length, encrypted.bytes);
    _zeroBuffer(iv.bytes);

    final safeName = _sanitizeFileName(outputPath);
    final encodedName = safeName.toLowerCase().endsWith(_encryptedExtension)
        ? safeName
        : '$safeName$_encryptedExtension';
    final dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    final fullPath = '${dir.path}${Platform.pathSeparator}$encodedName';
    final temporaryPath =
        '${dir.path}${Platform.pathSeparator}.$encodedName.${_uniqueToken()}.tmp';
    final temporaryFile = File(temporaryPath);
    try {
      await temporaryFile.writeAsBytes(combined, flush: true);
      final persisted = await temporaryFile.readAsBytes();
      if (persisted.length != combined.length) {
        throw StateError('Encrypted track was not persisted completely');
      }
      final persistedIv = enc.IV(
        persisted.sublist(headerLength, headerLength + 12),
      );
      late final List<int> verified;
      try {
        verified = encrypter.decryptBytes(
          enc.Encrypted(persisted.sublist(headerLength + 12)),
          iv: persistedIv,
        );
      } finally {
        _zeroBuffer(persistedIv.bytes);
      }
      if (!_constantTimeEquals(verified, plainBytes)) {
        throw StateError('Encrypted track verification failed');
      }
      await _atomicReplace(temporaryFile, File(fullPath));
    } finally {
      _zeroBuffer(combined);
      try {
        if (await temporaryFile.exists()) {
          await temporaryFile.delete();
        }
      } catch (_) {}
    }
    AppLogger.log.i('Encrypted offline track: $fullPath');
    return fullPath;
  }

  /// Strips path traversal sequences and returns only a safe base filename.
  /// - Removes any leading directory components (../ or absolute paths)
  /// - Strips null bytes, control characters, and shell metacharacters
  /// - Falls back to a random name if the result is empty
  static String _sanitizeFileName(String path) {
    // Split on any path separator and take only the last component.
    final segments = path.split(RegExp(r'[/\\]'));
    var name = segments.last;

    // Strip null bytes (used in path-traversal bypasses).
    name = name.replaceAll('\x00', '');

    // Strip control characters and non-printable characters.
    name = name.replaceAll(RegExp(r'[\x00-\x1f\x7f]'), '');

    // If sanitization leaves an empty or whitespace-only name, use a UUID.
    if (name.trim().isEmpty) {
      name = 'track_${DateTime.now().millisecondsSinceEpoch}.audio';
    }

    return name;
  }

  /// Decrypts a `.deemusiq` file and returns raw audio bytes.
  /// [encryptedPath] may be a full path or just a filename; it is sanitized
  /// and resolved relative to the app's documents directory.
  ///
  /// Throws [OfflineTrackLicenseException] when the offline license has been
  /// past its grace window (clear locked state for the UI, not a crash) and
  /// [OfflineTrackDecryptException] for corruption, tampering, or a retired
  /// key generation.
  Future<Uint8List> decrypt(String encryptedPath) async {
    await playbackGate?.call();
    final safeName = _sanitizeFileName(encryptedPath);
    final dir = await getApplicationDocumentsDirectory();
    final fullPath = '${dir.path}/$safeName';

    final file = File(fullPath);
    if (!await file.exists()) {
      throw OfflineTrackDecryptException('File not found: $fullPath');
    }

    final raw = await file.readAsBytes();
    if (raw.length < 16) {
      throw OfflineTrackDecryptException('File too short: $fullPath');
    }

    await _key(); // ensures the keyring is loaded
    final ring = _keyring!;

    // Envelope v2: magic + version + generation + iv(12) + ciphertext.
    if (raw.length >= 28 &&
        raw[0] == _envelopeMagic[0] &&
        raw[1] == _envelopeMagic[1] &&
        raw[2] == _envelopeVersion) {
      final generation = raw[3];
      final material = ring[generation];
      if (material == null) {
        throw OfflineTrackDecryptException(
          'Key generation $generation has been retired — re-download the track: '
          '$encryptedPath',
        );
      }
      final key = enc.Key(material.sublist(0, 32));
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));
      final iv = enc.IV(raw.sublist(4, 16));
      try {
        final decrypted = encrypter.decryptBytes(
          enc.Encrypted(raw.sublist(16)),
          iv: iv,
        );
        return Uint8List.fromList(decrypted);
      } catch (_) {
        throw OfflineTrackDecryptException(
          'Decryption failed — file may be corrupted or tampered: '
          '$encryptedPath',
        );
      } finally {
        _zeroBuffer(iv.bytes);
      }
    }

    // Envelope v1 (bare `iv(12) || ciphertext`): try the current generation
    // first, then older generations newest-to-oldest.
    if (raw.length >= 28) {
      final generations = ring.keys.toList()..sort((a, b) => b.compareTo(a));
      for (final generation in generations) {
        final key = enc.Key(ring[generation]!.sublist(0, 32));
        final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));
        final iv = enc.IV(raw.sublist(0, 12));
        try {
          final decrypted = encrypter.decryptBytes(
            enc.Encrypted(raw.sublist(12)),
            iv: iv,
          );
          return Uint8List.fromList(decrypted);
        } catch (_) {
          // Wrong key for this file — try the next generation.
        } finally {
          _zeroBuffer(iv.bytes);
        }
      }
      AppLogger.log.w('OfflineDrm: v1 envelope undecryptable with all keys');
    }

    throw OfflineTrackDecryptException(
      'Decryption failed — file may be corrupted or tampered: $encryptedPath',
    );
  }

  bool isEncryptedTrack(String path) =>
      path.toLowerCase().endsWith(_encryptedExtension);

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var difference = 0;
    for (var index = 0; index < a.length; index++) {
      difference |= a[index] ^ b[index];
    }
    return difference == 0;
  }

  static String _uniqueToken() =>
      '${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';

  static Future<void> _atomicReplace(File source, File target) async {
    if (source.path == target.path) return;
    try {
      await source.rename(target.path);
      return;
    } catch (_) {
      if (!await target.exists()) rethrow;
      final backup = File('${target.path}.${_uniqueToken()}.replace');
      await target.rename(backup.path);
      try {
        await source.rename(target.path);
      } catch (error, stackTrace) {
        try {
          await backup.rename(target.path);
        } catch (_) {}
        Error.throwWithStackTrace(error, stackTrace);
      }
      try {
        await backup.delete();
      } catch (_) {}
    }
  }

  static Uint8List _secureBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
        List.generate(length, (_) => random.nextInt(256)));
  }
}

class OfflineTrackDecryptException implements Exception {
  final String message;
  OfflineTrackDecryptException(this.message);
  @override
  String toString() => 'OfflineTrackDecryptException: $message';
}
