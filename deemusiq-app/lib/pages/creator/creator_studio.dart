import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/collections/routes.gr.dart';
import 'package:deemusiq/components/titlebar/titlebar.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/models/wallet/linked_account.dart';
import 'package:deemusiq/provider/creator/creator_provider.dart';
import 'package:deemusiq/provider/local_favorites/local_favorites_provider.dart';
import 'package:deemusiq/provider/wallet/wallet_provider.dart';
import 'package:deemusiq/services/auth/google_auth.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/wallet/payment_service.dart'
    show DeeMusiqPaymentService;
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// Creator Studio: submit and manage your songs and see their stats. Gated by a
/// Google sign-in — the backend requires a linked (server-verified) Google
/// account for every creator action.
@RoutePage()
class CreatorStudioPage extends HookConsumerWidget {
  static const name = "creator-studio";

  const CreatorStudioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = WalletApiClient.instance.isConfigured;
    final hasGoogle = ref.watch(
      walletProvider.select(
        (s) => s.linkedAccounts.any((a) => a.provider == LinkedProvider.google),
      ),
    );

    return SafeArea(
      bottom: false,
      child: Scaffold(
        headers: const [TitleBar(title: Text("Creator Studio"))],
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!online)
                      const _MessageCard(
                        icon: DeeMusiqIcons.upload,
                        title: "Connect to become a creator",
                        body:
                            "Creator Studio needs DeeMusiq's backend to be configured.",
                      )
                    else if (!hasGoogle)
                      const _GoogleGate()
                    else
                      const _Dashboard(),
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

/// Shown when the user isn't signed in with Google yet.
class _GoogleGate extends HookConsumerWidget {
  const _GoogleGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = useState(false);

    Future<void> signIn() async {
      if (loading.value) return;
      loading.value = true;
      try {
        final result = await GoogleAuthService.instance.signIn();
        final wallet = ref.read(walletProvider.notifier);
        if (result.displayName != null || result.email != null) {
          await wallet.linkAccount(
            LinkedProvider.google,
            displayName: result.displayName ?? result.email ?? 'Google User',
            externalId: result.email,
          );
        }
        await wallet.syncFromBackend();
        await syncFavoritesFromBackend(
            ref.read(localFavoritesProvider.notifier));
        ref.invalidate(myArtistProvider);
        ref.invalidate(mySongsProvider);
      } catch (e, stack) {
        AppLogger.reportError(e, stack, 'creator google sign-in');
        if (context.mounted) {
          showWalletToast(context, "Google sign-in failed",
              icon: DeeMusiqIcons.info);
        }
      } finally {
        loading.value = false;
      }
    }

    return Card(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(DeeMusiqIcons.artist, size: 32, color: deeMusiqOrange),
          const Gap(10),
          const Text("Become a DeeMusiq creator").large().semiBold(),
          const Gap(6),
          const Text(
            "Sign in with Google to claim your artist profile, submit songs, and "
            "track how they're doing. Your Google account also carries your likes "
            "and library across devices.",
            textAlign: TextAlign.center,
          ).muted().small(),
          const Gap(16),
          Button.primary(
            onPressed: loading.value ? null : signIn,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(DeeMusiqIcons.google, size: 18),
                const Gap(8),
                Text(loading.value ? "Please wait…" : "Sign in with Google"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dashboard extends HookConsumerWidget {
  const _Dashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistAsync = ref.watch(myArtistProvider);

    return artistAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _MessageCard(
        icon: DeeMusiqIcons.info,
        title: "Couldn't load your studio",
        body: error is WalletApiException
            ? error.friendlyMessage
            : error.toString(),
      ),
      data: (data) {
        final artist = data["artist"] as Map?;
        if (artist == null) return const _ClaimProfile();
        final stats = (data["stats"] as Map?) ?? const {};
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileHeader(artist: artist, stats: stats),
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: Button.secondary(
                    onPressed: () =>
                        context.navigateTo(const ReleaseConsoleRoute()),
                    leading: const Icon(DeeMusiqIcons.timer, size: 16),
                    child: const Text("Release Console"),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: Button.secondary(
                    onPressed: () =>
                        context.navigateTo(const VerificationRoute()),
                    leading: const Icon(DeeMusiqIcons.verified, size: 16),
                    child: Text(
                      artist["verified"] == true ? "Verified" : "Get Verified",
                    ),
                  ),
                ),
              ],
            ),
            const Gap(16),
            const _SubmitSong(),
            const Gap(16),
            if (artist["verified"] == true) ...[
              _MonetizationPanel(artistId: (artist["id"] ?? "").toString()),
              const Gap(16),
            ],
            const Text("Your songs").large().semiBold(),
            const Gap(8),
            const _SongList(),
          ],
        );
      },
    );
  }
}

class _ClaimProfile extends HookConsumerWidget {
  const _ClaimProfile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = useTextEditingController();
    final bio = useTextEditingController();
    final loading = useState(false);

    Future<void> claim() async {
      if (loading.value) return;
      loading.value = true;
      try {
        await WalletApiClient.instance
            .createArtist(name: name.text.trim(), bio: bio.text.trim());
        ref.invalidate(myArtistProvider);
        if (context.mounted) {
          showWalletToast(context, "Creator profile created",
              icon: DeeMusiqIcons.verified);
        }
      } on WalletApiException catch (e) {
        if (context.mounted) {
          showWalletToast(context, e.friendlyMessage,
              icon: DeeMusiqIcons.info);
        }
      } catch (e, stack) {
        AppLogger.reportError(e, stack, 'claim artist');
      } finally {
        loading.value = false;
      }
    }

    return Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Claim your artist name").large().semiBold(),
          const Gap(4),
          const Text("This is how listeners will find you. Names are unique.")
              .muted()
              .small(),
          const Gap(12),
          TextField(controller: name, placeholder: const Text("Artist name")),
          const Gap(8),
          TextField(
            controller: bio,
            placeholder: const Text("Short bio (optional)"),
            maxLines: 3,
          ),
          const Gap(12),
          Button.primary(
            onPressed: loading.value ? null : claim,
            child: Text(loading.value ? "Please wait…" : "Create profile"),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Map artist;
  final Map stats;
  const _ProfileHeader({required this.artist, required this.stats});

  @override
  Widget build(BuildContext context) {
    final rank = stats["rankThisYear"];
    return Card(
      filled: true,
      fillColor: context.theme.colorScheme.muted,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(DeeMusiqIcons.artist, color: deeMusiqOrange),
              const Gap(8),
              Expanded(
                child: Text((artist["name"] ?? "").toString(), maxLines: 1)
                    .large()
                    .semiBold(),
              ),
              if (artist["verified"] == true)
                const Icon(DeeMusiqIcons.verified,
                    size: 16, color: deeMusiqOrange),
            ],
          ),
          const Gap(12),
          Row(
            children: [
              _Stat(
                label: "Songs",
                value: "${stats["songCount"] ?? 0}",
              ),
              _Stat(
                label: "Tokens (yr)",
                value: formatTokens(
                    (stats["totalTokensThisYear"] as num?)?.toInt() ?? 0),
              ),
              _Stat(
                label: "Rank (yr)",
                value: rank == null ? "—" : "#$rank",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: deeMusiqOrange, fontWeight: FontWeight.w800)),
          const Gap(2),
          Text(label).muted().xSmall(),
        ],
      ),
    );
  }
}

/// New upload flow: pick an audio file + cover image, upload to the backend,
/// then explicitly submit for operator review. Status transitions:
///   (none) -> draft -> pending -> approved -> (artist publishes) -> published.
class _SubmitSong extends HookConsumerWidget {
  const _SubmitSong();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = useTextEditingController();
    final description = useTextEditingController();
    final loading = useState(false);
    final progress = useState<double?>(null);
    final error = useState<String?>(null);
    final audioPath = useState<String?>(null);
    final coverPath = useState<String?>(null);
    final draftId = useState<String?>(null);
    final audioUploaded = useState(false);
    final coverUploaded = useState(false);

    Future<void> pickAudio() async {
      try {
        // Multi-format masters: keep in sync with GET /creator/uploads/formats.
        final r = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: const [
            "mp3", "m4a", "aac", "wav", "flac", "ogg", "opus", "webm",
            "aiff", "aif", "mp4",
          ],
        );
        if (r != null && r.files.isNotEmpty) {
          audioPath.value = r.files.first.path;
          audioUploaded.value = false;
        }
      } catch (e, st) {
        AppLogger.reportError(e, st, 'pick audio');
        error.value = "Could not open file picker";
      }
    }

    Future<void> pickCover() async {
      try {
        final r = await FilePicker.platform.pickFiles(
          type: FileType.image,
        );
        if (r != null && r.files.isNotEmpty) {
          coverPath.value = r.files.first.path;
          coverUploaded.value = false;
        }
      } catch (e, st) {
        AppLogger.reportError(e, st, 'pick cover');
        error.value = "Could not open file picker";
      }
    }

    Future<void> createAndUpload() async {
      if (loading.value) return;
      if (draftId.value == null && title.text.trim().isEmpty) {
        error.value = "Title is required.";
        return;
      }
      if (draftId.value == null && audioPath.value == null) {
        error.value = "Pick an audio file.";
        return;
      }
      if (draftId.value == null && coverPath.value == null) {
        error.value = "Pick a cover image.";
        return;
      }
      if (draftId.value != null &&
          !audioUploaded.value &&
          audioPath.value == null) {
        error.value = "Pick the missing audio file.";
        return;
      }
      if (draftId.value != null &&
          !coverUploaded.value &&
          coverPath.value == null) {
        error.value = "Pick the missing cover image.";
        return;
      }
      loading.value = true;
      error.value = null;
      try {
        if (draftId.value == null) {
          final created = await WalletApiClient.instance.submitSong(
            title: title.text.trim(),
            description: description.text.trim().isEmpty
                ? null
                : description.text.trim(),
          );
          final id = created["id"];
          if (id is! String || id.isEmpty || created["status"] != "draft") {
            throw const WalletApiException(
                "Upload didn't start — please try again.");
          }
          draftId.value = id;
        }
        if (!audioUploaded.value) {
          await WalletApiClient.instance.uploadAudio(
            creatorSongId: draftId.value!,
            filePath: audioPath.value!,
            onProgress: (p) => progress.value = p,
          );
          audioUploaded.value = true;
        }
        if (!coverUploaded.value) {
          await WalletApiClient.instance.uploadCover(
            creatorSongId: draftId.value!,
            filePath: coverPath.value!,
          );
          coverUploaded.value = true;
        }
        progress.value = null;
        ref.invalidate(mySongsProvider);
        if (context.mounted) {
          showWalletToast(
            context,
            "Uploaded! Tap Submit for review.",
            icon: DeeMusiqIcons.upload,
          );
        }
      } on WalletApiException catch (e) {
        error.value = e.friendlyMessage;
      } catch (e, st) {
        AppLogger.reportError(e, st, 'upload song');
        error.value = "Upload failed.";
      } finally {
        loading.value = false;
      }
    }

    Future<void> submitForReview() async {
      final id = draftId.value;
      if (id == null || !audioUploaded.value || !coverUploaded.value) {
        error.value = "Upload audio and cover before review.";
        return;
      }
      if (loading.value) return;
      loading.value = true;
      error.value = null;
      try {
        await WalletApiClient.instance.submitSongForReview(id);
        ref.invalidate(mySongsProvider);
        title.clear();
        description.clear();
        audioPath.value = null;
        coverPath.value = null;
        draftId.value = null;
        audioUploaded.value = false;
        coverUploaded.value = false;
        if (context.mounted) {
          showWalletToast(
            context,
            "Submitted for review",
            icon: DeeMusiqIcons.upload,
          );
        }
      } on WalletApiException catch (e) {
        error.value = e.friendlyMessage;
      } catch (e, st) {
        AppLogger.reportError(e, st, 'submit song');
        error.value = "Could not submit for review.";
      } finally {
        loading.value = false;
      }
    }

    String? fileName(String? p) => p?.split(RegExp(r'[/\\]')).last;

    return Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(DeeMusiqIcons.upload, color: deeMusiqOrange, size: 18),
              const Gap(8),
              const Text("Submit a song").semiBold(),
            ],
          ),
          const Gap(4),
          const Text(
            "Pick an audio master (MP3 · M4A · AAC · WAV · FLAC · OGG · Opus · WebM · AIFF) "
            "and a cover image. The operator reviews the submission; once approved, "
            "you choose when to publish — then add payment, set your cut and track analytics below.",
          ).muted().small(),
          const Gap(12),
          TextField(controller: title, placeholder: const Text("Song title")),
          const Gap(8),
          TextField(
            controller: description,
            placeholder: const Text("Description (optional)"),
            maxLines: 2,
          ),
          const Gap(12),
          // Audio picker
          Row(
            children: [
              Expanded(
                child: OutlineButton(
                  onPressed: loading.value ? null : pickAudio,
                  child: Text(
                    audioPath.value == null
                        ? "Pick audio file"
                        : "Audio: ${fileName(audioPath.value)}",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const Gap(8),
          // Cover picker
          Row(
            children: [
              Expanded(
                child: OutlineButton(
                  onPressed: loading.value ? null : pickCover,
                  child: Text(
                    coverPath.value == null
                        ? "Pick cover image"
                        : "Cover: ${fileName(coverPath.value)}",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (coverPath.value != null) ...[
                const Gap(8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.file(
                    File(coverPath.value!),
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image, size: 40),
                  ),
                ),
              ],
            ],
          ),
          if (progress.value != null) ...[
            const Gap(8),
            LinearProgressIndicator(value: progress.value),
          ],
          if (error.value != null) ...[
            const Gap(8),
            Text(error.value!,
                style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
          const Gap(12),
          Row(
            children: [
              if (draftId.value == null ||
                  !audioUploaded.value ||
                  !coverUploaded.value)
                Expanded(
                  child: Button.primary(
                    onPressed: loading.value ? null : createAndUpload,
                    child: Text(
                      loading.value
                          ? "Uploading…"
                          : (draftId.value == null ? "Upload" : "Retry upload"),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Button.primary(
                    onPressed: loading.value ? null : submitForReview,
                    child: Text(
                      loading.value ? "Submitting…" : "Submit for review",
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SongList extends HookConsumerWidget {
  const _SongList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(mySongsProvider);
    return songsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Text(
        error is WalletApiException
            ? error.friendlyMessage
            : error.toString(),
      ).muted().small(),
      data: (songs) => songs.isEmpty
          ? const Text("No songs yet — submit your first above.")
              .muted()
              .small()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final song in songs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SongTile(song: song),
                  ),
              ],
            ),
    );
  }
}

class _SongTile extends HookConsumerWidget {
  final CreatorSong song;
  const _SongTile({required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = useState(false);

    Future<void> run(Future<void> Function() action, String ok) async {
      if (busy.value) return;
      busy.value = true;
      try {
        await action();
        ref.invalidate(mySongsProvider);
        ref.invalidate(myArtistProvider);
        if (context.mounted) {
          showWalletToast(context, ok, icon: DeeMusiqIcons.verified);
        }
      } on WalletApiException catch (e) {
        if (context.mounted) {
          showWalletToast(context, e.friendlyMessage,
              icon: DeeMusiqIcons.info);
        }
      } catch (e, stack) {
        AppLogger.reportError(e, stack, 'manage song');
      } finally {
        busy.value = false;
      }
    }

    final status = song.status;
    final statusLabel = switch (status) {
      'draft' => 'Draft',
      'pending' => 'In review',
      'approved' => 'Approved',
      'scheduled' => 'Scheduled',
      'published' => 'Published',
      'hidden' => 'Hidden / Cancelled',
      _ => status,
    };
    final colorScheme = context.theme.colorScheme;
    final statusColor = switch (status) {
      'draft' => colorScheme.mutedForeground,
      'pending' => colorScheme.chart4,
      'approved' => colorScheme.primary,
      'scheduled' => colorScheme.chart1,
      'published' => colorScheme.chart2,
      'hidden' => colorScheme.destructive,
      _ => colorScheme.mutedForeground,
    };
    return Card(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(song.title, maxLines: 1).semiBold()),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(color: statusColor, fontSize: 11),
                ),
              ),
            ],
          ),
          const Gap(6),
          if (song.scheduledPublishAt != null)
            Text(
              "Publishes ${_fmtDateTime(song.scheduledPublishAt!.toIso8601String())}",
            ).muted().xSmall()
          else if (song.audioSizeBytes != null)
            Text(
              "${(song.audioSizeBytes! / 1024 / 1024).toStringAsFixed(1)} MB audio",
            ).muted().xSmall(),
          if (song.reviewNote != null && song.reviewNote!.isNotEmpty) ...[
            const Gap(4),
            Text("Note: ${song.reviewNote}").muted().xSmall(),
          ],
          if (status == 'draft' && !song.canSubmitForReview)
            const Text("Upload audio and cover before review.").muted().xSmall(),
          const Gap(6),
          Row(
            children: [
              const Icon(DeeMusiqIcons.boost, size: 13, color: deeMusiqOrange),
              const Gap(4),
              Text("${song.pushes} · ${formatTokens(song.tokens)} tokens")
                  .muted()
                  .xSmall(),
              const Gap(12),
              const Icon(DeeMusiqIcons.heart, size: 13, color: deeMusiqOrange),
              const Gap(4),
              Text("${song.likes}").muted().xSmall(),
            ],
          ),
          if (status == 'approved' || status == 'scheduled') ...[
            const Gap(6),
            Align(
              alignment: Alignment.centerRight,
              child: Button.ghost(
                onPressed: () => context.navigateTo(const ReleaseConsoleRoute()),
                child: const Text("Open Release Console"),
              ),
            ),
          ],
          const Gap(6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (status == 'draft' && song.canSubmitForReview)
                Button.ghost(
                  onPressed: busy.value
                      ? null
                      : () => run(
                            () async {
                              await WalletApiClient.instance
                                  .submitSongForReview(song.id);
                            },
                            "Submitted for review",
                          ),
                  child: const Text("Submit for review"),
                ),
              if (status == 'published')
                Button.ghost(
                  onPressed: busy.value
                      ? null
                      : () => run(
                            () => WalletApiClient.instance.updateSong(
                              songId: song.id,
                              status: 'hidden',
                            ),
                            "Song hidden",
                          ),
                  child: const Text("Hide"),
                ),
              Button.ghost(
                leading: const Icon(DeeMusiqIcons.trash, size: 14),
                onPressed: busy.value
                    ? null
                    : () => run(
                          () => WalletApiClient.instance.deleteSong(song.id),
                          "Song removed",
                        ),
                child: const Text("Remove"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _fmtDateTime(String iso) {
  final d = DateTime.tryParse(iso)?.toLocal();
  if (d == null) return iso;
  String two(int n) => n.toString().padLeft(2, "0");
  return "${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}";
}

/// Post-approval monetization panel: saved payout destination, platform-cut
/// request (default 30% or custom), and automated-split analytics.
/// Visible only for verified (approved) artists.
class _MonetizationPanel extends HookConsumerWidget {
  final String artistId;
  const _MonetizationPanel({required this.artistId});

  /// Must stay in sync with the backend's payout-method validation
  /// (`payoutMethodSchema` in backend/src/routes/creatorMonetization.ts:
  /// `z.enum(["payshap", "bank", "manual", "card"])` on PUT
  /// /creator/payouts/method) — anything else is rejected server-side.
  static const _payoutMethodKinds = {
    "payshap": "PayShap",
    "bank": "Bank transfer",
    "manual": "Manual",
    "card": "Card",
  };

  static const _payoutMethodPlaceholders = {
    "payshap": "PayShap phone number",
    "bank": "Account number / branch code",
    "manual": "Payout details",
    "card": "Card reference",
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = useState<Map<String, dynamic>?>(null);
    final split = useState<Map<String, dynamic>?>(null);
    final method = useState<Map<String, dynamic>?>(null);
    final payoutBalance = useState<Map<String, dynamic>?>(null);
    final payoutHistory = useState<List<dynamic>>(const []);
    final loading = useState(true);
    final error = useState<String?>(null);
    final methodInput = useTextEditingController();
    final methodKind = useState("payshap");
    final cutInput = useTextEditingController(text: "30");
    final payoutTokens = useTextEditingController();
    final payoutDetails = useTextEditingController();
    final payoutMethod = useState("payshap");
    final saving = useState(false);

    Future<void> load() async {
      loading.value = true;
      error.value = null;
      try {
        final results = await Future.wait([
          WalletApiClient.instance.fetchCreatorAnalytics(artistId: artistId),
          WalletApiClient.instance.fetchRevenueSplit(artistId: artistId),
          WalletApiClient.instance.fetchPayoutMethod(artistId: artistId),
          WalletApiClient.instance.fetchPayoutBalance().catchError((_) => <String, dynamic>{}),
          WalletApiClient.instance.fetchPayoutHistory().catchError((_) => <String, dynamic>{"payouts": []}),
        ]);
        analytics.value = results[0] as Map<String, dynamic>;
        split.value = results[1] as Map<String, dynamic>;
        method.value = results[2];
        payoutBalance.value = (results[3] as Map).isEmpty ? null : results[3] as Map<String, dynamic>;
        final hist = (results[4] as Map)["payouts"];
        payoutHistory.value = hist is List ? hist : const [];
        final savedKind = method.value?["method"];
        if (savedKind is String &&
            _payoutMethodKinds.containsKey(savedKind)) {
          methodKind.value = savedKind;
          payoutMethod.value = savedKind;
        }
        final current = (split.value!["currentCutPct"] as num?)?.toInt() ?? 30;
        cutInput.text = "$current";
      } catch (e) {
        error.value =
            e is WalletApiException ? e.friendlyMessage : e.toString();
      } finally {
        loading.value = false;
      }
    }

    useEffect(() {
      Future.microtask(load);
      return null;
    }, [artistId]);

    Future<void> saveMethod() async {
      if (saving.value || methodInput.text.trim().isEmpty) return;
      // PayShap payouts are addressed by phone: normalise to E.164 client-side
      // (same rules as the backend) so the saved destination masks correctly.
      var details = methodInput.text.trim();
      if (methodKind.value == "payshap") {
        final e164 = DeeMusiqPaymentService.normalizePayerPhone(details);
        if (e164 == null) {
          if (context.mounted) {
            showWalletToast(
              context,
              "Enter a valid phone number (e.g. +27 82 123 4567).",
              icon: DeeMusiqIcons.info,
            );
          }
          return;
        }
        details = e164;
      }
      saving.value = true;
      try {
        final res = await WalletApiClient.instance.savePayoutMethod(
          artistId: artistId,
          method: methodKind.value,
          details: details,
        );
        method.value = (res["method"] as Map?)?.map(
          (k, v) => MapEntry(k.toString(), v),
        );
        if (context.mounted) {
          showWalletToast(context, "Payment destination saved",
              icon: DeeMusiqIcons.verified);
        }
      } on WalletApiException catch (e) {
        if (context.mounted) {
          showWalletToast(context, e.friendlyMessage,
              icon: DeeMusiqIcons.info);
        }
      } finally {
        saving.value = false;
      }
    }

    Future<void> requestCut() async {
      final pct = int.tryParse(cutInput.text.trim());
      if (pct == null || pct < 0 || pct > 50) {
        if (context.mounted) {
          showWalletToast(context, "Cut must be 0–50 (30 = default)",
              icon: DeeMusiqIcons.info);
        }
        return;
      }
      if (saving.value) return;
      saving.value = true;
      try {
        await WalletApiClient.instance.requestRevenueSplit(
          artistId: artistId,
          requestedPct: pct,
        );
        await load();
        if (context.mounted) {
          showWalletToast(context, "Cut request sent for approval",
              icon: DeeMusiqIcons.verified);
        }
      } on WalletApiException catch (e) {
        if (context.mounted) {
          showWalletToast(context, e.friendlyMessage,
              icon: DeeMusiqIcons.info);
        }
      } finally {
        saving.value = false;
      }
    }

    Future<void> requestCashout() async {
      final tokens = int.tryParse(payoutTokens.text.trim());
      if (tokens == null || tokens <= 0) {
        if (context.mounted) {
          showWalletToast(context, "Enter tokens to cash out",
              icon: DeeMusiqIcons.info);
        }
        return;
      }
      if (saving.value) return;
      saving.value = true;
      try {
        final res = await WalletApiClient.instance.requestPayout(
          artistId: artistId,
          tokens: tokens,
          method: payoutMethod.value,
          details: payoutDetails.text.trim().isEmpty
              ? null
              : payoutDetails.text.trim(),
        );
        payoutTokens.text = "";
        payoutDetails.text = "";
        await load();
        if (context.mounted) {
          final payout = (res["payout"] as Map?) ?? const {};
          showWalletToast(
            context,
            "Payout ${payout["id"] ?? ""} ${payout["status"] ?? "requested"}"
            "${res["requiresManual"] == true ? " (manual review)" : ""}",
            icon: DeeMusiqIcons.verified,
          );
        }
      } on WalletApiException catch (e) {
        if (context.mounted) {
          showWalletToast(context, e.friendlyMessage,
              icon: DeeMusiqIcons.info);
        }
      } finally {
        saving.value = false;
      }
    }

    if (loading.value) {
      return const Card(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (error.value != null && analytics.value == null) {
      return Card(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Monetization").semiBold(),
            const Gap(4),
            Text(error.value!).muted().small(),
            const Gap(8),
            Button.secondary(onPressed: load, child: const Text("Retry")),
          ],
        ),
      );
    }

    final totals =
        (analytics.value?["analytics"] as Map?)?["totals"] as Map? ?? const {};
    final currentCut =
        (split.value?["currentCutPct"] as num?)?.toInt() ?? 30;
    final pending = split.value?["pending"] as Map?;

    return Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Payments & analytics").semiBold(),
          const Gap(4),
          Text(
            "Gross ${totals["gross"] ?? 0} · fee ${totals["platformFees"] ?? 0} · "
            "net ${totals["net"] ?? 0} · ${totals["tips"] ?? 0} tips · "
            "${totals["listens"] ?? 0} listens",
          ).muted().small(),
          const Gap(12),
          const Text("Payout destination").small().semiBold(),
          const Gap(4),
          if (method.value != null)
            Text("Saved: ${method.value!["masked"] ?? method.value!["method"]}")
                .muted()
                .small(),
          const Gap(4),
          Row(
            children: [
              Select<String>(
                value: methodKind.value,
                onChanged: (value) {
                  if (value != null) methodKind.value = value;
                },
                itemBuilder: (context, value) =>
                    Text(_payoutMethodKinds[value]!),
                popupConstraints: const BoxConstraints(maxWidth: 200),
                popupWidthConstraint: PopoverConstraint.flexible,
                popup: (context) => SelectPopup(
                  items: SelectItemBuilder(
                    childCount: _payoutMethodKinds.length,
                    builder: (context, index) {
                      final kind = _payoutMethodKinds.keys.elementAt(index);
                      return SelectItemButton(
                        value: kind,
                        child: Text(_payoutMethodKinds[kind]!),
                      );
                    },
                  ),
                ),
              ),
              const Gap(8),
              Expanded(
                child: TextField(
                  controller: methodInput,
                  placeholder: Text(
                    _payoutMethodPlaceholders[methodKind.value] ??
                        "Payout details",
                  ),
                ),
              ),
              const Gap(8),
              Button.secondary(
                onPressed: saving.value ? null : saveMethod,
                child: Text(saving.value ? "…" : "Save"),
              ),
            ],
          ),
          const Gap(12),
          const Text("Platform cut").small().semiBold(),
          const Gap(4),
          Text(
            pending != null
                ? "Request pending: ${pending["requestedPct"]}% (current $currentCut%)"
                : "Current cut $currentCut% (artist keeps ${100 - currentCut}%). Request 30% or a custom 0–50%.",
          ).muted().small(),
          const Gap(4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: cutInput,
                  placeholder: const Text("30"),
                ),
              ),
              const Gap(8),
              Button.secondary(
                onPressed: saving.value ? null : requestCut,
                child: const Text("Request cut"),
              ),
            ],
          ),
          const Gap(12),
          const Text("Cash out (tokens → ZAR)").small().semiBold(),
          const Gap(4),
          Builder(builder: (context) {
            final bal = payoutBalance.value;
            final mine = bal == null
                ? null
                : ((bal["balances"] as List?) ?? const [])
                    .cast<Map<String, dynamic>>()
                    .where((b) => b["artistId"] == artistId)
                    .firstOrNull;
            if (bal == null) {
              return const Text(
                      "Balance unavailable — connect backend to cash out.")
                  .muted()
                  .small();
            }
            final payable = (mine?["payable"] as num?)?.toInt() ?? 0;
            final minTokens =
                (bal["minTokens"] as num?)?.toInt() ?? 0;
            final rate =
                (bal["rateZarPerTokenMinor"] as num?)?.toInt() ?? 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Payable $payable tokens (≈ R${(payable * rate / 100).toStringAsFixed(2)}) · "
                  "min $minTokens · received ${mine?["received"] ?? 0} · "
                  "pending ${mine?["pending"] ?? 0} · paid out ${mine?["paidOut"] ?? 0}",
                ).muted().small(),
                const Gap(4),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: payoutTokens,
                        placeholder: const Text("Tokens"),
                      ),
                    ),
                    const Gap(8),
                    Select<String>(
                      value: payoutMethod.value,
                      onChanged: (v) {
                        if (v != null) payoutMethod.value = v;
                      },
                      itemBuilder: (context, value) =>
                          Text(_payoutMethodKinds[value]!),
                      popup: (context) => SelectPopup(
                        items: SelectItemBuilder(
                          childCount: _payoutMethodKinds.length,
                          builder: (context, index) {
                            final k =
                                _payoutMethodKinds.keys.elementAt(index);
                            return SelectItemButton(
                                value: k,
                                child: Text(_payoutMethodKinds[k]!));
                          },
                        ),
                      ),
                    ),
                    const Gap(8),
                    Button.secondary(
                      onPressed: saving.value ? null : requestCashout,
                      child: Text(saving.value ? "…" : "Cash out"),
                    ),
                  ],
                ),
                const Gap(4),
                TextField(
                  controller: payoutDetails,
                  placeholder: const Text(
                      "Settlement details (optional — uses saved method)"),
                ),
                const Gap(8),
                if (payoutHistory.value.isEmpty)
                  const Text("No payout requests yet.").muted().small()
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final p
                          in payoutHistory.value.take(10))
                        Text(
                          "${(p as Map)["tokens"]} tokens → ${(p["amount"] ?? p["zarMinor"])}c · ${p["status"]}"
                          "${p["reference"] != null ? " · ${p["reference"]}" : ""}",
                        ).muted().small(),
                    ],
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _MessageCard(
      {required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(icon, size: 32, color: deeMusiqOrange),
          const Gap(10),
          Text(title).semiBold(),
          const Gap(4),
          Text(body, textAlign: TextAlign.center).muted().small(),
        ],
      ),
    );
  }
}
