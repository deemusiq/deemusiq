import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/provider/creator/creator_provider.dart';
import 'package:deemusiq/components/titlebar/titlebar.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// Release console for approved songs. Three actions:
///   • Publish Now — enqueues a zero-delay job; the worker creates the
///     catalog Track immediately.
///   • Schedule — pick a future moment; the artist can later reschedule.
///   • Cancel Release — removes the queued job and hides the submission.
///
/// Reachable from the Creator Studio "Approved" tab.
@RoutePage()
class ReleaseConsolePage extends HookConsumerWidget {
  static const name = "release-console";

  const ReleaseConsolePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(mySongsProvider);

    return SafeArea(
      bottom: false,
      child: Scaffold(
        headers: const [
          TitleBar(title: Text("Release Console")),
        ],
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    songs.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, _) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Text(
                                "Couldn't load your releases",
                                style:
                                    TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const Gap(4),
                              Text(
                                error is WalletApiException
                                    ? error.friendlyMessage
                                    : error.toString(),
                                style: const TextStyle(fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                              const Gap(8),
                              Button.secondary(
                                onPressed: () =>
                                    ref.invalidate(mySongsProvider),
                                child: const Text("Retry"),
                              ),
                            ],
                          ),
                        ),
                      ),
                      data: (list) {
                        final approved = list
                            .where((s) =>
                                s.status == "approved" ||
                                s.status == "scheduled")
                            .toList();
                        if (approved.isEmpty) {
                          return const _MessageCard(
                            icon: DeeMusiqIcons.upload,
                            title: "Nothing to release yet",
                            body:
                                "Once an operator approves your submitted songs, they'll appear here for you to publish or schedule.",
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final s in approved) _ReleaseCard(song: s),
                          ],
                        );
                      },
                    ),
                    const Gap(40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReleaseCard extends HookConsumerWidget {
  final CreatorSong song;
  const _ReleaseCard({required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = useState(false);
    final error = useState<String?>(null);
    final id = song.id;
    final title = song.title;
    final status = song.status;
    final scheduled = song.scheduledPublishAt;

    Future<void> publishNow() async {
      if (busy.value) return;
      busy.value = true;
      error.value = null;
      try {
        await WalletApiClient.instance.publishSongNow(id);
        ref.invalidate(mySongsProvider);
      } on WalletApiException catch (e) {
        error.value = e.friendlyMessage;
      } finally {
        busy.value = false;
      }
    }

    Future<void> schedule() async {
      if (busy.value) return;
      final publishAt = await showDialog<DateTime>(
        context: context,
        builder: (context) => const _ScheduleDialog(),
      );
      if (publishAt == null) return;
      busy.value = true;
      error.value = null;
      try {
        await WalletApiClient.instance.scheduleSong(
          songId: id,
          publishAt: publishAt,
        );
        ref.invalidate(mySongsProvider);
      } on WalletApiException catch (e) {
        error.value = e.friendlyMessage;
      } finally {
        busy.value = false;
      }
    }

    Future<void> cancel() async {
      if (busy.value) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Cancel release?"),
          content: const Text(
            "The song will be hidden from the catalog. You can resubmit later.",
          ),
          actions: [
            Button.ghost(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text("Keep"),
            ),
            Button.destructive(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text("Cancel release"),
            ),
          ],
        ),
      );
      if (ok != true) return;
      busy.value = true;
      error.value = null;
      try {
        await WalletApiClient.instance.cancelSongRelease(id);
        ref.invalidate(mySongsProvider);
      } on WalletApiException catch (e) {
        error.value = e.friendlyMessage;
      } finally {
        busy.value = false;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (song.coverUrl != null)
                  Image.network(
                    song.coverUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 56,
                      height: 56,
                      color: Colors.stone.withValues(alpha: 0.4),
                    ),
                  )
                else
                  Container(
                    width: 56,
                    height: 56,
                    color: Colors.stone.withValues(alpha: 0.4),
                  ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(4),
                      Text(
                        status == "scheduled" && scheduled != null
                            ? "Scheduled for ${_fmtDateTime(scheduled)}"
                            : "Approved — ready to publish",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (error.value != null) ...[
              const Gap(8),
              Text(
                error.value!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
            const Gap(12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Button.primary(
                  onPressed: busy.value ? null : publishNow,
                  leading: const Icon(DeeMusiqIcons.play),
                  child: const Text("Publish Now"),
                ),
                Button.secondary(
                  onPressed: busy.value ? null : schedule,
                  leading: const Icon(DeeMusiqIcons.timer),
                  child: Text(status == "scheduled" ? "Reschedule" : "Schedule"),
                ),
                Button.ghost(
                  onPressed: busy.value ? null : cancel,
                  leading: const Icon(DeeMusiqIcons.trash),
                  child: const Text("Cancel Release"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// shadcn-native replacement for the old two-step material date/time pickers:
/// one dialog with a [DatePicker] (past days and anything beyond a year out
/// disabled, matching the old firstDate/lastDate bounds) and a [TimePicker].
class _ScheduleDialog extends HookWidget {
  const _ScheduleDialog();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = useState<DateTime?>(null);
    final time = useState<TimeOfDay?>(const TimeOfDay(hour: 12, minute: 0));

    final d = date.value;
    final t = time.value;
    final publishAt = d == null || t == null
        ? null
        : DateTime(d.year, d.month, d.day, t.hour, t.minute);
    final valid = publishAt != null && publishAt.isAfter(DateTime.now());

    return AlertDialog(
      title: const Text("Schedule release").large(),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pick when this song goes live.").muted().small(),
            const Gap(12),
            DatePicker(
              value: date.value,
              placeholder: const Text("Pick a date"),
              dialogTitle: const Text("Release date"),
              stateBuilder: (candidate) {
                final day = DateTime(
                  candidate.year,
                  candidate.month,
                  candidate.day,
                );
                if (day.isBefore(today) ||
                    day.isAfter(today.add(const Duration(days: 365)))) {
                  return DateState.disabled;
                }
                return DateState.enabled;
              },
              onChanged: (value) => date.value = value,
            ),
            const Gap(8),
            TimePicker(
              value: time.value,
              dialogTitle: const Text("Release time"),
              onChanged: (value) => time.value = value,
            ),
          ],
        ),
      ),
      actions: [
        Button.outline(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        Button.primary(
          onPressed: valid ? () => Navigator.pop(context, publishAt) : null,
          child: const Text("Schedule"),
        ),
      ],
    );
  }
}

String _fmtDateTime(DateTime dateTime) {
  final d = dateTime.toLocal();
  String two(int n) => n.toString().padLeft(2, "0");
  return "${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}";
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _MessageCard({required this.icon, required this.title, required this.body});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Gap(4),
                  Text(body, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
