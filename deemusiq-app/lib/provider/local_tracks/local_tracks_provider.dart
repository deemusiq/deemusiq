import 'dart:async';
import 'dart:io';

import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:deemusiq/provider/user_preferences/user_preferences_provider.dart';
import 'package:deemusiq/services/offline_drm/offline_drm.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart' show FrbException;
import 'package:deemusiq/utils/service_utils.dart';

const supportedAudioTypes = [
  "audio/webm",
  "audio/ogg",
  "audio/mpeg",
  "audio/mp4",
  "audio/opus",
  "audio/wav",
  "audio/aac",
  "audio/flac",
  "audio/x-flac",
  "audio/x-wav",
];

const imgMimeToExt = {
  "image/png": ".png",
  "image/jpeg": ".jpg",
  "image/webp": ".webp",
  "image/gif": ".gif",
};

typedef MetadataFile = ({
  Metadata? metadata,
  File file,
  String? art,
});

final localTracksProvider =
    FutureProvider<Map<String, List<DeeMusiqLocalTrackObject>>>((ref) async {
  try {
    if (kIsWeb) return {};
    final Map<String, List<DeeMusiqLocalTrackObject>> libraryToTracks = {};

    final downloadLocation = ref.watch(
      userPreferencesProvider.select((s) => s.downloadLocation),
    );

    if (downloadLocation.isEmpty) {
      return {};
    }

    final downloadDir = Directory(downloadLocation);
    final cacheDir =
        Directory(await UserPreferencesNotifier.getMusicCacheDir());
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    final localLibraryLocations = ref.watch(
      userPreferencesProvider.select((s) => s.localLibraryLocation),
    );

    // Encrypted offline downloads (`.deemusiq`) live in the app-private
    // documents directory. They can't be mime-sniffed or read by MetadataGod
    // (ciphertext), so the track object is derived from the file name and
    // playback goes through the license-gated `/offline/` server route
    // (decrypt-on-play, in memory).
    final documentsDir = await getApplicationDocumentsDirectory();
    final drm = OfflineTrackEncryption.instance;

    for (final (location, encryptedBucket) in [
      (downloadLocation, false),
      (cacheDir.path, false),
      ...localLibraryLocations.map((e) => (e, false)),
      (documentsDir.path, true),
    ]) {
      if (location.isEmpty) continue;
      final entities = <File>[];
      if (await Directory(location).exists()) {
        try {
          final dirEntities =
              await Directory(location).list(recursive: true).toList();

          entities.addAll(
            dirEntities.where(
              (e) {
                if (e is! File) return false;
                final isEncrypted = drm.isEncryptedTrack(e.path);
                // `.deemusiq` files are surfaced only by the encrypted bucket;
                // plaintext audio in the documents dir (e.g. transient staging
                // files) is never shown as library tracks.
                if (encryptedBucket) return isEncrypted;
                if (isEncrypted) return false;
                final mime = lookupMimeType(e.path) ??
                    (extension(e.path) == ".opus" ? "audio/opus" : null);

                return supportedAudioTypes.contains(mime);
              },
            ).cast<File>(),
          );
        } catch (e, stack) {
          AppLogger.reportError(e, stack);
        }
      }

      final List<MetadataFile> filesWithMetadata = await Future.wait(
        entities.map((file) async {
          try {
            return await (() async {
              try {
                if (encryptedBucket) {
                  return (file: file, metadata: null, art: null);
                }
                final metadata = await MetadataGod.readMetadata(file: file.path);

                final imageFile = File(
                  join(
                    (await getTemporaryDirectory()).path,
                    "deemusiq",
                    ServiceUtils.sanitizeFilename(
                            basenameWithoutExtension(file.path)) +
                        imgMimeToExt[metadata.picture?.mimeType ?? "image/jpeg"]!,
                  ),
                );
                if (!await imageFile.exists() && metadata.picture != null) {
                  await imageFile.create(recursive: true);
                  await imageFile.writeAsBytes(
                    metadata.picture?.data ?? [],
                    mode: FileMode.writeOnly,
                  );
                }

                return (metadata: metadata, file: file, art: imageFile.path);
              } catch (e, stack) {
                if (e case FrbException() || TimeoutException()) {
                  return (file: file, metadata: null, art: null);
                }
                AppLogger.reportError(e, stack);
                return null;
              }
            })();
          } catch (e) {
            AppLogger.log.w('Local track metadata read failed: ${e.toString()}');
            return null;
          }
        }),
      ).then((value) => value.nonNulls.toList());

      final tracksFromMetadata = filesWithMetadata
          .map(
            (fileWithMetadata) {
              var track = DeeMusiqTrackObject.localTrackFromFile(
                fileWithMetadata.file,
                metadata: fileWithMetadata.metadata,
                art: fileWithMetadata.art,
              ) as DeeMusiqLocalTrackObject;
              if (encryptedBucket) {
                // "Name - Artist.mp3.deemusiq" → display "Name - Artist".
                final displayName = basenameWithoutExtension(
                  basenameWithoutExtension(fileWithMetadata.file.path),
                );
                if (displayName.isNotEmpty) {
                  track = track.copyWith(name: displayName);
                }
              }
              return track;
            },
          )
          .toList();

      // Don't add a permanent empty "downloads" group for the encrypted
      // bucket when the user has no encrypted downloads yet.
      if (tracksFromMetadata.isNotEmpty || !encryptedBucket) {
        libraryToTracks[location] = tracksFromMetadata;
      }
    }
    return libraryToTracks;
  } catch (e, stack) {
    AppLogger.reportError(e, stack);
    return {};
  }
});
