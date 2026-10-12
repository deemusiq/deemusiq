import 'dart:io';

import 'package:deemusiq/services/logger/logger.dart';

/// Best-effort delete for temp/backup files: a leftover is retried on the
/// next run, so the failure is only logged (with [context] for diagnosis),
/// never thrown into the caller's success path.
Future<void> deleteFileQuietly(FileSystemEntity entity, String context) async {
  try {
    if (await entity.exists()) await entity.delete(recursive: true);
  } catch (e) {
    AppLogger.log.w('[$context] cleanup of ${entity.path} failed: $e');
  }
}
