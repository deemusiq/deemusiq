import 'package:flutter/material.dart' show ListTile;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/dialogs/prompt_dialog.dart';
import 'package:deemusiq/modules/settings/section_card_with_heading.dart';
import 'package:deemusiq/provider/local_tracks/local_tracks_provider.dart';
import 'package:deemusiq/provider/offline_queue/offline_queue_provider.dart';
import 'package:deemusiq/provider/user_preferences/user_preferences_provider.dart';
import 'package:deemusiq/services/offline_drm/offline_license.dart';
import 'package:deemusiq/services/storage/download_storage.dart';

/// Storage management: total space used by downloads + the encrypted offline
/// store, per-download rows with sizes, individual delete and clear-all, plus
/// the offline-DRM license state (see OfflineLicenseManager).
class SettingsStorageSection extends HookConsumerWidget {
  const SettingsStorageSection({super.key});

  Future<StorageReport> _scan(WidgetRef ref) async {
    final downloadLocation =
        ref.read(userPreferencesProvider.select((s) => s.downloadLocation));
    final cacheDir = await UserPreferencesNotifier.getMusicCacheDir();
    final documentsDir = await getApplicationDocumentsDirectory();
    return DownloadStorage.scan(
      downloadLocation: downloadLocation,
      cacheDir: cacheDir,
      documentsDir: documentsDir.path,
    );
  }

  String _licenseText(OfflineLicenseStatus status) {
    String day(DateTime? d) =>
        d == null ? '—' : d.toLocal().toString().split(' ').first;
    switch (status.state) {
      case OfflineLicenseState.valid:
        return 'Offline license valid until ${day(status.validUntil)}';
      case OfflineLicenseState.grace:
        return 'Offline license expired — grace period, reconnect to renew '
            '(last confirmed ${day(status.lastConfirmedAt)})';
      case OfflineLicenseState.locked:
        return 'Offline playback locked since ${day(status.lockedSince)} — '
            'connect to the internet to renew the license';
      case OfflineLicenseState.unconfirmed:
        return 'Offline license not active (no backend confirmation yet)';
    }
  }

  @override
  Widget build(BuildContext context, ref) {
    final refreshCounter = useState(0);
    final reportFuture = useFuture(
      useMemoized(() => _scan(ref), [refreshCounter.value]),
    );
    final licenseFuture = useFuture(
      useMemoized(
        () => OfflineLicenseManager.instance.status(),
        [refreshCounter.value],
      ),
    );
    final pendingActions = ref.watch(pendingOfflineActionsCountProvider);

    Future<void> refresh() async {
      refreshCounter.value++;
      ref.invalidate(localTracksProvider);
      ref.invalidate(pendingOfflineActionsCountProvider);
    }

    final report = reportFuture.data;
    final theme = Theme.of(context);

    return SectionCardWithHeading(
      heading: "Storage",
      children: [
        ListTile(
          leading: const Icon(DeeMusiqIcons.download),
          title: const Text("Downloaded music"),
          subtitle: Text(
            report == null
                ? "Scanning…"
                : "${DownloadStorage.formatBytes(report.totalBytes)} "
                    "across ${report.entries.length} file(s)",
          ),
          trailing: Tooltip(
            tooltip: const TooltipContainer(
              child: Text("Refresh"),
            ).call,
            child: IconButton.secondary(
              icon: const Icon(DeeMusiqIcons.refresh),
              onPressed: reportFuture.connectionState == ConnectionState.waiting
                  ? null
                  : refresh,
            ),
          ),
        ),
        if (licenseFuture.hasData)
          ListTile(
            leading: Icon(
              licenseFuture.data!.state == OfflineLicenseState.locked
                  ? DeeMusiqIcons.lock
                  : DeeMusiqIcons.shield,
            ),
            title: const Text("Offline playback license"),
            subtitle: Text(_licenseText(licenseFuture.data!)),
          ),
        if ((pendingActions.asData?.value ?? 0) > 0)
          ListTile(
            leading: const Icon(DeeMusiqIcons.refresh),
            title: const Text("Pending sync"),
            subtitle: Text(
              "${pendingActions.asData!.value} action(s) will sync when you're back online",
            ),
          ),
        if (report != null && report.entries.isNotEmpty) ...[
          for (final entry in report.entries)
            ListTile(
              leading: Icon(
                entry.encrypted ? DeeMusiqIcons.lock : DeeMusiqIcons.download,
              ),
              title: Text(
                entry.fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(DownloadStorage.formatBytes(entry.sizeBytes)),
              trailing: Tooltip(
                tooltip: const TooltipContainer(
                  child: Text("Delete"),
                ).call,
                child: IconButton.ghost(
                  icon: const Icon(DeeMusiqIcons.trash),
                  onPressed: () async {
                    final confirmed = await showPromptDialog(
                      context: context,
                      title: "Delete download",
                      message:
                          "Delete \"${entry.fileName}\" (${DownloadStorage.formatBytes(entry.sizeBytes)})? This frees the space but the song won't be playable offline anymore.",
                    );
                    if (!confirmed) return;
                    await DownloadStorage.delete(entry);
                    await refresh();
                  },
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Button.destructive(
                leading: const Icon(DeeMusiqIcons.trash),
                onPressed: () async {
                  final confirmed = await showPromptDialog(
                    context: context,
                    title: "Clear all downloads",
                    message:
                        "Delete all ${report.entries.length} downloaded file(s) "
                        "(${DownloadStorage.formatBytes(report.totalBytes)})? "
                        "They won't be playable offline anymore.",
                  );
                  if (!confirmed) return;
                  await DownloadStorage.deleteAll(report.entries);
                  await refresh();
                },
                child: const Text("Clear all downloads"),
              ),
            ),
          ),
        ],
        if (reportFuture.hasError)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Could not scan downloads: ${reportFuture.error}",
              style: TextStyle(color: theme.colorScheme.destructive),
            ),
          ),
      ],
    );
  }
}
