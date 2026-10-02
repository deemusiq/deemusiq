import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide join;
import 'package:deemusiq/collections/routes.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/dialogs/replace_downloaded_dialog.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/extensions/dio.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/metadata_plugin/audio_source/quality_presets.dart';
import 'package:deemusiq/provider/server/sourced_track_provider.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/offline_drm/offline_drm.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';
import 'package:deemusiq/utils/service_utils.dart';

enum DownloadStatus {
  queued,
  downloading,
  completed,
  failed,
  canceled,
}

class DownloadTask {
  final DeeMusiqFullTrackObject track;
  final DownloadStatus status;
  final CancelToken cancelToken;
  final int? totalSizeBytes;
  final StreamController<int> _downloadedBytesStreamController;

  Stream<int> get downloadedBytesStream =>
      _downloadedBytesStreamController.stream;

  DownloadTask({
    required this.track,
    required this.status,
    required this.cancelToken,
    this.totalSizeBytes,
    StreamController<int>? downloadedBytesStreamController,
  }) : _downloadedBytesStreamController =
            downloadedBytesStreamController ?? StreamController.broadcast();

  DownloadTask copyWith({
    DeeMusiqFullTrackObject? track,
    DownloadStatus? status,
    CancelToken? cancelToken,
    int? totalSizeBytes,
    StreamController<int>? downloadedBytesStreamController,
  }) {
    return DownloadTask(
      track: track ?? this.track,
      status: status ?? this.status,
      cancelToken: cancelToken ?? this.cancelToken,
      totalSizeBytes: totalSizeBytes ?? this.totalSizeBytes,
      downloadedBytesStreamController:
          downloadedBytesStreamController ?? _downloadedBytesStreamController,
    );
  }
}

class DownloadManagerNotifier extends Notifier<List<DownloadTask>> {
  final Dio dio;
  DownloadManagerNotifier()
      : dio = Dio(),
        super();

  @override
  build() {
    ref.onDispose(() {
      for (final task in state) {
        if (task.status == DownloadStatus.downloading) {
          task.cancelToken.cancel();
        }
        task._downloadedBytesStreamController.close();
      }
    });

    return [];
  }

  DownloadTask? getTaskByTrackId(String trackId) {
    return state.firstWhereOrNull((element) => element.track.id == trackId);
  }

  void addToQueue(DeeMusiqFullTrackObject track) {
    if (state.any((element) => element.track.id == track.id)) return;
    // Downloads are an online-only feature — they require the DeeMusiq backend
    // (it authorises the catalog). When it can't be reached the app stays
    // playable for already-downloaded songs, but no NEW downloads start.
    _guardedEnqueue(() {
      // Re-checked after the async gate: the track may have been queued while
      // the backend ping was in flight (TOCTOU).
      if (state.any((element) => element.track.id == track.id)) return;
      state = [
        ...state,
        DownloadTask(
          track: track,
          status: DownloadStatus.queued,
          cancelToken: CancelToken(),
        ),
      ];

      ref.read(sourcedTrackProvider(track));

      _startDownloading(); // No await should be invoked to avoid stuck UI
    });
  }

  void addAllToQueue(List<DeeMusiqFullTrackObject> tracks) {
    if (tracks.isEmpty) return;
    _guardedEnqueue(() {
      // Filter after the async gate (TOCTOU): skip tracks already
      // queued/downloading and duplicates within the batch itself.
      final seen = <String>{};
      final fresh = tracks
          .where(
            (track) =>
                seen.add(track.id) &&
                !state.any((element) => element.track.id == track.id),
          )
          .toList();
      if (fresh.isEmpty) return;
      state = [
        ...state,
        ...fresh.map((e) => DownloadTask(
              track: e,
              status: DownloadStatus.queued,
              cancelToken: CancelToken(),
            )),
      ];

      ref.read(sourcedTrackProvider(fresh.first));
      _startDownloading(); // No await should be invoked to avoid stuck UI
    });
  }

  /// Runs [enqueue] only when the DeeMusiq backend is reachable; otherwise
  /// notifies the user and does nothing (offline = no new downloads).
  Future<void> _guardedEnqueue(void Function() enqueue) async {
    final api = WalletApiClient.instance;
    if (!api.isConfigured) {
      _notifyDownloadBlocked(
        "Downloads need the DeeMusiq backend. Add a backend in setup to download songs.",
      );
      return;
    }
    if (!await api.ping()) {
      _notifyDownloadBlocked(
        "Can't reach DeeMusiq right now — new downloads are paused. You can still play songs you've already downloaded.",
      );
      return;
    }
    enqueue();
  }

  void _notifyDownloadBlocked(String message) {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      showWalletToast(context, message, icon: DeeMusiqIcons.download);
    }
  }

  void retry(DeeMusiqFullTrackObject track) {
    if (state.firstWhereOrNull((e) => e.track.id == track.id)?.status
        case DownloadStatus.canceled || DownloadStatus.failed) {
      // A canceled task's CancelToken is spent — mint a fresh one or
      // _downloadTrack would instantly re-cancel at its first guard.
      state = state.map((e) {
        if (e.track.id == track.id) {
          return e.copyWith(
            status: DownloadStatus.queued,
            cancelToken: CancelToken(),
          );
        }
        return e;
      }).toList();
      _startDownloading(); // No await should be invoked to avoid stuck UI
    }
  }

  void cancel(DeeMusiqFullTrackObject track) {
    if (state.firstWhereOrNull((e) => e.track.id == track.id)?.status ==
        DownloadStatus.failed) {
      return;
    }
    // Ensure the cancel token is signaled before updating status to canceled.
    final task = state.firstWhereOrNull((e) => e.track.id == track.id);
    if (task != null && !task.cancelToken.isCancelled) {
      task.cancelToken.cancel();
    }
    _setStatus(track, DownloadStatus.canceled);
  }

  void clearAll() {
    for (final task in state) {
      if (task.status == DownloadStatus.downloading) {
        task.cancelToken.cancel();
      }
    }
    state = [];
  }

  void _setStatus(DeeMusiqFullTrackObject track, DownloadStatus status) {
    state = state.map((e) {
      if (e.track.id == track.id) {
        if ((status == DownloadStatus.canceled) && !e.cancelToken.isCancelled) {
          e.cancelToken.cancel();
        }

        return e.copyWith(status: status);
      }
      return e;
    }).toList();
  }

  bool _isShowingDialog = false;

  Future<bool> _shouldReplaceFileOnExist(DownloadTask task) async {
    if (rootNavigatorKey.currentContext == null || _isShowingDialog) {
      return false;
    }
    final replaceAll = ref.read(replaceDownloadedFileState);
    if (replaceAll != null) return replaceAll;
    _isShowingDialog = true;
    try {
      return await showDialog<bool>(
            context: rootNavigatorKey.currentContext!,
            builder: (context) => ReplaceDownloadedDialog(
              track: task.track,
            ),
          ) ??
          false;
    } finally {
      _isShowingDialog = false;
    }
  }

  Future<void> _downloadTrack(DownloadTask task) async {
    File? stagingFile;
    try {
      if (task.cancelToken.isCancelled) {
        _setStatus(task.track, DownloadStatus.canceled);
        return;
      }
      _setStatus(task.track, DownloadStatus.downloading);
      final track = await ref.read(sourcedTrackProvider(task.track).future);
      if (task.cancelToken.isCancelled) {
        _setStatus(task.track, DownloadStatus.canceled);
        return;
      }
      final presets = ref.read(audioSourcePresetsProvider);
      final container =
          presets.presets[presets.selectedDownloadingContainerIndex];

      final url = track.getUrlOfQuality(
        container,
        presets.selectedDownloadingQualityIndex,
      );

      if (url == null) {
        throw Exception("No download URL found for selected codec");
      }

      final fileName = ServiceUtils.sanitizeFilename(
        "${track.query.name} - ${track.query.artists.map((e) => e.name).join(", ")}.${container.getFileExtension()}",
      );

      // Downloads are DRM-protected at rest (offline DRM, C1): the encrypted
      // `.deemusiq` file lives in the app-private documents directory and is
      // only decryptable in-app (license-gated). Plaintext exists only
      // transiently in a dot-prefixed staging file inside the same private
      // directory and is deleted right after encryption — nothing is written
      // to public/shared storage. The user-facing "download location" folder
      // keeps working as before for pre-existing plaintext downloads and
      // imported audio (the local library scanner still reads it).
      final drm = OfflineTrackEncryption.instance;
      final encryptedPath = await drm.encryptedPathFor(fileName);
      if (await File(encryptedPath).exists()) {
        if (!await _shouldReplaceFileOnExist(task)) {
          _setStatus(track.query, DownloadStatus.canceled);
          return;
        }
      }

      final documentsDir = await getApplicationDocumentsDirectory();
      stagingFile = File(
        _resolveSavePath(
          documentsDir.path,
          '.dl-${DateTime.now().microsecondsSinceEpoch}-$fileName',
        ),
      );

      final response = await dio.chunkDownload(
        url,
        stagingFile.path,
        cancelToken: task.cancelToken,
        onReceiveProgress: (count, total) {
          if (total > 0) {
            state = state.map((e) {
              if (e.track.id == track.query.id && e.totalSizeBytes == null) {
                return e.copyWith(totalSizeBytes: total);
              }
              return e;
            }).toList();
          }
          task._downloadedBytesStreamController.add(count);
        },
        deleteOnError: true,
        fileAccessMode: FileAccessMode.write,
      );
      await _verifyDownloadedFile(stagingFile, response);

      if (container.getFileExtension() != "weba") {
        // Tag the plaintext staging file BEFORE encryption so the decrypted
        // stream a player gets is a fully-tagged audio file.
        try {
          final imageBytes = await ServiceUtils.downloadImage(
            (task.track.album.images).asUrlString(
              placeholder: ImagePlaceholder.albumArt,
              index: 1,
            ),
          );
          await MetadataGod.writeMetadata(
            file: stagingFile.path,
            metadata: task.track.toMetadata(
              fileLength: await stagingFile.length(),
              imageBytes: imageBytes,
            ),
          );
        } catch (error, stack) {
          AppLogger.reportError(error, stack);
        }
      }

      final encrypted = await drm.encryptAndSave(
        await stagingFile.readAsBytes(),
        fileName,
      );
      AppLogger.log.i('Download stored encrypted: $encrypted');
      _setStatus(track.query, DownloadStatus.completed);
    } catch (e, stack) {
      if (task.cancelToken.isCancelled ||
          e is DioException && e.type == DioExceptionType.cancel) {
        _setStatus(task.track, DownloadStatus.canceled);
        return;
      }
      _setStatus(task.track, DownloadStatus.failed);
      AppLogger.reportError(e, stack);
    } finally {
      if (stagingFile != null) {
        try {
          if (await stagingFile.exists()) await stagingFile.delete();
        } catch (_) {}
      }
    }
  }

  /// Resolves [downloadLocation] + [fileName] into a canonical path that is
  /// guaranteed to stay inside the download directory: an empty/whitespace
  /// base or a per-track filename with `..` (or otherwise escaping) segments
  /// must never write outside it.
  static String _resolveSavePath(String downloadLocation, String fileName) {
    final trimmed = downloadLocation.trim();
    if (trimmed.isEmpty) {
      throw StateError('Download location is empty');
    }
    if (fileName.trim().isEmpty) {
      throw StateError('Download file name is empty');
    }
    final basePath = normalize(absolute(trimmed));
    final filePath = normalize(join(basePath, fileName));
    if (!isWithin(basePath, filePath)) {
      throw StateError(
        'Download path escapes the download directory: $fileName',
      );
    }
    return filePath;
  }

  /// Post-download sanity checks. Length/hash are compared against the
  /// ORIGIN-declared validators (`x-origin-content-length` /
  /// `x-origin-sha256`) that `chunkDownload` captured from the server's
  /// probe/GET responses — NOT against the file's own recomputed values,
  /// which would be a tautology. When the origin sent no validators the
  /// comparison is skipped (chunkDownload already verified what it could).
  Future<void> _verifyDownloadedFile(
    File file,
    Response response,
  ) async {
    final status = response.statusCode;
    if (status == null || status < 200 || status >= 300) {
      throw StateError('Download returned status ${status ?? 'null'}');
    }
    if (!await file.exists()) {
      throw StateError('Download did not create ${file.path}');
    }
    final length = await file.length();
    if (length <= 0) {
      throw StateError('Download created an empty file');
    }
    final originLengthHeader = response.headers.value('x-origin-content-length');
    final declaredLength = int.tryParse(originLengthHeader?.trim() ?? '');
    if (originLengthHeader != null &&
        (declaredLength == null || declaredLength != length)) {
      throw StateError(
        'Download length mismatch: expected $declaredLength, got $length',
      );
    }
    final digest = await sha256.bind(file.openRead()).first;
    final actualHash = digest.toString();
    final expectedHash =
        normalizeSha256(response.headers.value('x-origin-sha256'));
    if (expectedHash != null && actualHash != expectedHash) {
      throw StateError(
        'Download hash mismatch: expected $expectedHash, got $actualHash',
      );
    }
  }

  /// Max downloads in flight at once. Queue order is preserved; only this
  /// many tasks run concurrently so bulk adds don't take forever serially
  /// while still avoiding a connection storm.
  static const int _maxConcurrentDownloads = 3;
  bool _pumping = false;

  Future<void> _startDownloading() async {
    if (_pumping) return;
    _pumping = true;
    try {
      while (true) {
        final active =
            state.where((t) => t.status == DownloadStatus.downloading).length;
        if (active >= _maxConcurrentDownloads) break;

        DownloadTask? next;
        for (final task in state) {
          if (task.status == DownloadStatus.queued) {
            next = task;
            break;
          }
        }
        if (next == null) break;

        // Mark in-flight before awaiting so sibling pump iterations skip it.
        _setStatus(next.track, DownloadStatus.downloading);
        unawaited(_downloadTrack(next).whenComplete(() {
          // Kick the pump again when a slot frees up.
          _startDownloading();
        }));
      }
    } finally {
      _pumping = false;
    }

    // A completion that raced the finally above may have returned early while
    // _pumping was still true — if capacity remains, pick that work up now.
    final active =
        state.where((t) => t.status == DownloadStatus.downloading).length;
    final hasQueued = state.any((t) => t.status == DownloadStatus.queued);
    if (hasQueued && active < _maxConcurrentDownloads) {
      unawaited(_startDownloading());
    }
  }
}

final downloadManagerProvider =
    NotifierProvider<DownloadManagerNotifier, List<DownloadTask>>(
  DownloadManagerNotifier.new,
);
