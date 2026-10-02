import 'dart:io';

import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:deemusiq/provider/local_tracks/local_tracks_provider.dart'
    show supportedAudioTypes;
import 'package:deemusiq/services/logger/logger.dart';

/// One downloaded/cached audio file on disk, as shown in the Storage
/// settings section.
class DownloadedFileEntry {
  final File file;
  final int sizeBytes;

  /// True for `.deemusiq` DRM-encrypted files (app documents directory).
  final bool encrypted;

  const DownloadedFileEntry({
    required this.file,
    required this.sizeBytes,
    required this.encrypted,
  });

  String get fileName => basename(file.path);
}

class StorageReport {
  final List<DownloadedFileEntry> entries;

  const StorageReport(this.entries);

  int get totalBytes => entries.fold(0, (sum, e) => sum + e.sizeBytes);
}

/// Filesystem source of truth for downloaded/cached audio. The download
/// manager's task list is session-scoped, so after a restart the disk is the
/// only reliable record — this scans the download directory, the music cache
/// directory, and the encrypted (`.deemusiq`) store in the app documents
/// directory.
class DownloadStorage {
  DownloadStorage._();

  static const _encryptedExtension = '.deemusiq';

  static bool _isAudioFile(String path) {
    final mime = lookupMimeType(path) ??
        (extension(path) == '.opus' ? 'audio/opus' : null);
    return supportedAudioTypes.contains(mime);
  }

  static Future<List<DownloadedFileEntry>> _scanDirectory(
    Directory dir, {
    required bool encrypted,
  }) async {
    final entries = <DownloadedFileEntry>[];
    if (!await dir.exists()) return entries;
    try {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is! File) continue;
        final isEncryptedFile =
            entity.path.toLowerCase().endsWith(_encryptedExtension);
        if (encrypted != isEncryptedFile) continue;
        if (!encrypted && !_isAudioFile(entity.path)) continue;
        try {
          entries.add(
            DownloadedFileEntry(
              file: entity,
              sizeBytes: await entity.length(),
              encrypted: encrypted,
            ),
          );
        } catch (e, stack) {
          AppLogger.reportError(e, stack, 'DownloadStorage.stat');
        }
      }
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'DownloadStorage.scan');
    }
    entries.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
    return entries;
  }

  /// Scans [downloadLocation] and [cacheDir] for plain audio files and
  /// [documentsDir] for encrypted `.deemusiq` files.
  static Future<StorageReport> scan({
    required String downloadLocation,
    required String cacheDir,
    required String documentsDir,
  }) async {
    final results = await Future.wait([
      if (downloadLocation.trim().isNotEmpty)
        _scanDirectory(Directory(downloadLocation), encrypted: false),
      if (cacheDir.trim().isNotEmpty)
        _scanDirectory(Directory(cacheDir), encrypted: false),
      if (documentsDir.trim().isNotEmpty)
        _scanDirectory(Directory(documentsDir), encrypted: true),
    ]);
    final entries = results.expand((r) => r).toList()
      ..sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
    return StorageReport(entries);
  }

  /// Deletes [entry]'s file. Returns true when the file is gone.
  static Future<bool> delete(DownloadedFileEntry entry) async {
    try {
      if (await entry.file.exists()) {
        await entry.file.delete();
      }
      return true;
    } catch (e, stack) {
      AppLogger.reportError(e, stack, 'DownloadStorage.delete');
      return false;
    }
  }

  /// Deletes every file in [entries]. Returns the number actually removed.
  static Future<int> deleteAll(List<DownloadedFileEntry> entries) async {
    var removed = 0;
    for (final entry in entries) {
      if (await delete(entry)) removed++;
    }
    return removed;
  }

  /// Compact byte formatting for the settings UI (e.g. `128 MB`).
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    const units = ['KB', 'MB', 'GB', 'TB'];
    var value = bytes / 1024.0;
    var unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024.0;
      unit++;
    }
    final text =
        value >= 100 ? value.round().toString() : value.toStringAsFixed(1);
    return '$text ${units[unit]}';
  }
}
