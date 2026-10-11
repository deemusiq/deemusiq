import 'package:flutter/material.dart' show ListTile;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/dialogs/prompt_dialog.dart';
import 'package:deemusiq/extensions/context.dart';
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

  String _licenseText(BuildContext context, OfflineLicenseStatus status) {
    String day(DateTime? d) =>
        d == null ? '—' : d.toLocal().toString().split(' ').first;
    switch (status.state) {
      case OfflineLicenseState.valid:
        return context.l10n.storage_license_valid(day(status.validUntil));
      case OfflineLicenseState.grace:
        return context.l10n.storage_license_grace(day(status.lastConfirmedAt));
      case OfflineLicenseState.locked:
        return context.l10n.storage_license_locked(day(status.lockedSince));
      case OfflineLicenseState.unconfirmed:
        return context.l10n.storage_license_unconfirmed;
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
      heading: context.l10n.storage_heading,
      children: [
        ListTile(
          leading: const Icon(DeeMusiqIcons.download),
          title: Text(context.l10n.storage_downloaded_music),
          subtitle: Text(
            report == null
                ? context.l10n.storage_scanning
                : context.l10n.storage_usage(
                    DownloadStorage.formatBytes(report.totalBytes),
                    report.entries.length),
          ),
          trailing: Tooltip(
            tooltip: TooltipContainer(
              child: Text(context.l10n.refresh),
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
            title: Text(context.l10n.storage_license_title),
            subtitle: Text(_licenseText(context, licenseFuture.data!)),
          ),
        if ((pendingActions.asData?.value ?? 0) > 0)
          ListTile(
            leading: const Icon(DeeMusiqIcons.refresh),
            title: Text(context.l10n.storage_pending_sync),
            subtitle: Text(
              context.l10n
                  .storage_pending_sync_body(pendingActions.asData!.value),
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
                tooltip: TooltipContainer(
                  child: Text(context.l10n.delete),
                ).call,
                child: IconButton.ghost(
                  icon: const Icon(DeeMusiqIcons.trash),
                  onPressed: () async {
                    final confirmed = await showPromptDialog(
                      context: context,
                      title: context.l10n.storage_delete_title,
                      message: context.l10n.storage_delete_message(
                          entry.fileName,
                          DownloadStorage.formatBytes(entry.sizeBytes)),
                    );
                    if (!confirmed) return;
                    await DownloadStorage.delete(entry);
                    if (!context.mounted) return;
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
                    title: context.l10n.storage_clear_all,
                    message: context.l10n.storage_clear_all_message(
                        report.entries.length,
                        DownloadStorage.formatBytes(report.totalBytes)),
                  );
                  if (!confirmed) return;
                  await DownloadStorage.deleteAll(report.entries);
                  if (!context.mounted) return;
                  await refresh();
                },
                child: Text(context.l10n.storage_clear_all),
              ),
            ),
          ),
        ],
        if (reportFuture.hasError)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              context.l10n.storage_scan_failed("${reportFuture.error}"),
              style: TextStyle(color: theme.colorScheme.destructive),
            ),
          ),
      ],
    );
  }
}
