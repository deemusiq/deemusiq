import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/titlebar/titlebar.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/models/wallet/linked_account.dart';
import 'package:deemusiq/provider/creator/creator_provider.dart';
import 'package:deemusiq/provider/local_favorites/local_favorites_provider.dart';
import 'package:deemusiq/provider/wallet/wallet_provider.dart';
import 'package:deemusiq/services/auth/google_auth.dart';
import 'package:deemusiq/services/logger/logger.dart';
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
        headers: [TitleBar(title: const Text("Creator Studio"))],
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
        await syncFavoritesFromBackend(ref.read(localFavoritesProvider.notifier));
        ref.invalidate(myArtistProvider);
        ref.invalidate(mySongsProvider);
      } catch (e, stack) {
        AppLogger.reportError(e, stack, 'creator google sign-in');
        if (context.mounted) {
          showWalletToast(context, "Google sign-in failed", icon: DeeMusiqIcons.info);
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
        body: error is WalletApiException ? error.message : error.toString(),
      ),
      data: (data) {
        final artist = data["artist"] as Map?;
        if (artist == null) return const _ClaimProfile();
        final stats = (data["stats"] as Map?) ?? const {};
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileHeader(artist: artist, stats: stats),
            const Gap(16),
            const _SubmitSong(),
            const Gap(16),
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
          showWalletToast(context, "Creator profile created", icon: DeeMusiqIcons.verified);
        }
      } on WalletApiException catch (e) {
        if (context.mounted) showWalletToast(context, e.message, icon: DeeMusiqIcons.info);
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
                value: formatTokens((stats["totalTokensThisYear"] as num?)?.toInt() ?? 0),
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

class _SubmitSong extends HookConsumerWidget {
  const _SubmitSong();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = useTextEditingController();
    final youtubeId = useTextEditingController();
    final cover = useTextEditingController();
    final loading = useState(false);

    Future<void> submit() async {
      if (loading.value) return;
      loading.value = true;
      try {
        await WalletApiClient.instance.submitSong(
          title: title.text.trim(),
          youtubeId: youtubeId.text.trim(),
          coverUrl: cover.text.trim().isEmpty ? null : cover.text.trim(),
        );
        title.clear();
        youtubeId.clear();
        cover.clear();
        ref.invalidate(mySongsProvider);
        ref.invalidate(myArtistProvider);
        if (context.mounted) {
          showWalletToast(context, "Song submitted", icon: DeeMusiqIcons.upload);
        }
      } on WalletApiException catch (e) {
        if (context.mounted) showWalletToast(context, e.message, icon: DeeMusiqIcons.info);
      } catch (e, stack) {
        AppLogger.reportError(e, stack, 'submit song');
      } finally {
        loading.value = false;
      }
    }

    return Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(DeeMusiqIcons.youtube, color: deeMusiqOrange, size: 18),
              const Gap(8),
              const Text("Submit a song").semiBold(),
            ],
          ),
          const Gap(4),
          const Text("Paste the 11-character YouTube video id of your track.")
              .muted()
              .small(),
          const Gap(12),
          TextField(controller: title, placeholder: const Text("Song title")),
          const Gap(8),
          TextField(
            controller: youtubeId,
            placeholder: const Text("YouTube video id (e.g. dQw4w9WgXcQ)"),
          ),
          const Gap(8),
          TextField(
            controller: cover,
            placeholder: const Text("Cover image URL (optional)"),
          ),
          const Gap(12),
          Button.primary(
            onPressed: loading.value ? null : submit,
            child: Text(loading.value ? "Please wait…" : "Submit song"),
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
        error is WalletApiException ? error.message : error.toString(),
      ).muted().small(),
      data: (songs) => songs.isEmpty
          ? const Text("No songs yet — submit your first above.").muted().small()
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
        if (context.mounted) showWalletToast(context, ok, icon: DeeMusiqIcons.verified);
      } on WalletApiException catch (e) {
        if (context.mounted) showWalletToast(context, e.message, icon: DeeMusiqIcons.info);
      } catch (e, stack) {
        AppLogger.reportError(e, stack, 'manage song');
      } finally {
        busy.value = false;
      }
    }

    final hidden = song.status == 'hidden';
    return Card(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(song.title, maxLines: 1).semiBold()),
              if (hidden) const Text("Hidden").muted().xSmall(),
            ],
          ),
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
          const Gap(6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Button.ghost(
                onPressed: busy.value
                    ? null
                    : () => run(
                          () => WalletApiClient.instance.updateSong(
                            songId: song.id,
                            status: hidden ? 'published' : 'hidden',
                          ),
                          hidden ? "Song published" : "Song hidden",
                        ),
                child: Text(hidden ? "Publish" : "Hide"),
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

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _MessageCard({required this.icon, required this.title, required this.body});

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
