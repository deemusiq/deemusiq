import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/provider/database/database.dart';
import 'package:deemusiq/services/connectivity_adapter.dart';
import 'package:deemusiq/services/offline_drm/offline_license.dart';
import 'package:deemusiq/services/offline_queue/offline_action_queue.dart';
import 'package:deemusiq/services/offline_queue/offline_action_replay.dart';

/// Bootstraps the offline-support services for the app lifetime (kept alive
/// by the `ref.listen` in `main.dart`):
///
/// - attaches the Drift-backed [OfflineActionQueue] to the app database and
///   starts [OfflineActionReplayService] so queued likes/playlist edits flush
///   FIFO to the backend on every offline→online transition;
/// - starts the [OfflineLicenseManager] so the DRM license is re-confirmed
///   (and the content key rotated) on reconnect.
final offlineSupportProvider = Provider<OfflineActionReplayService>((ref) {
  final db = ref.watch(databaseProvider);
  OfflineActionQueue.instance.attach(db);

  final connectivity = ConnectionCheckerService.instance.onConnectivityChanged;

  final replay = OfflineActionReplayService(queue: OfflineActionQueue.instance);
  replay.start(connectivity);
  OfflineLicenseManager.instance.start(connectivity);

  // Best-effort initial flush — the runner fails fast when actually offline
  // and the queue simply keeps its rows.
  if (ConnectionCheckerService.instance.isConnectedSync) {
    unawaited(replay.flush());
    unawaited(OfflineLicenseManager.instance.confirmLicense());
  }

  ref.onDispose(() async {
    await replay.dispose();
    await OfflineLicenseManager.instance.dispose();
  });
  return replay;
});

/// Live count of queued offline actions, for UI surfaces that want to show
/// pending sync work.
final pendingOfflineActionsCountProvider = FutureProvider<int>((ref) {
  ref.watch(offlineSupportProvider);
  return OfflineActionQueue.instance.pendingCount();
});
