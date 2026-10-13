import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:uuid/uuid.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/collections/routes.gr.dart';
import 'package:deemusiq/components/titlebar/titlebar.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/pages/auth/mfa_prompt.dart';
import 'package:deemusiq/provider/creator/creator_provider.dart';
import 'package:deemusiq/provider/local_favorites/local_favorites_provider.dart';
import 'package:deemusiq/provider/wallet/wallet_provider.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/wallet/payment_service.dart'
    show DeeMusiqPaymentService;
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// Creator Studio: submit and manage your songs and see their stats. The
/// creator identity is the email + password account — the studio unlocks once
/// the emailed 6-digit code has confirmed the address.
@RoutePage()
class CreatorStudioPage extends HookConsumerWidget {
  static const name = "creator-studio";

  const CreatorStudioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = WalletApiClient.instance.isConfigured;
    final hasSession = WalletApiClient.instance.hasToken();
    final accountAsync = ref.watch(accountStatusProvider);

    return SafeArea(
      bottom: false,
      child: Scaffold(
        headers: [TitleBar(title: Text(context.l10n.creator_studio))],
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
                      _MessageCard(
                        icon: DeeMusiqIcons.upload,
                        title: context.l10n.creator_connect_title,
                        body: context.l10n.creator_connect_body,
                      )
                    else if (!hasSession)
                      const _EmailSignInGate()
                    else
                      accountAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, _) => _MessageCard(
                          icon: DeeMusiqIcons.info,
                          title: context.l10n.creator_studio_load_failed,
                          body: error is WalletApiException
                              ? error.friendlyMessage
                              : error.toString(),
                        ),
                        data: (account) => account["emailVerified"] == true
                            ? const _Dashboard()
                            : _VerifyEmailGate(account: account),
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

/// Shown when this device holds no backend session. Sign in with the email +
/// password account — the identity the backend anchors creators to. A
/// brand-new user follows "Create account", which emails a 6-digit code and
/// signs in once it is confirmed.
class _EmailSignInGate extends HookConsumerWidget {
  const _EmailSignInGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = useTextEditingController();
    final password = useTextEditingController();
    final loading = useState(false);

    Future<void> signIn() async {
      if (loading.value) return;
      final mail = email.text.trim();
      if (mail.isEmpty) {
        showWalletToast(context, context.l10n.signup_invalid_email,
            icon: DeeMusiqIcons.info);
        return;
      }
      if (password.text.isEmpty) {
        showWalletToast(context, context.l10n.signup_enter_password,
            icon: DeeMusiqIcons.info);
        return;
      }
      loading.value = true;
      try {
        try {
          await WalletApiClient.instance
              .loginEmail(email: mail, password: password.text);
        } on WalletApiException catch (e) {
          // A 2FA-enrolled account answers with a challenge instead of a
          // token: collect the authenticator code and finish the login rather
          // than dead-ending (same flow as the auth page).
          if (e.code == "mfa_required" && e.mfaToken != null) {
            if (!context.mounted) return;
            final code = await promptMfaCode(context);
            if (code == null) return;
            await WalletApiClient.instance
                .mfaVerify(mfaToken: e.mfaToken!, code: code);
          } else {
            rethrow;
          }
        }
        // Pull account-carried state down, then let the gate re-evaluate.
        await syncFavoritesFromBackend(
            ref.read(localFavoritesProvider.notifier));
        await ref.read(walletProvider.notifier).syncFromBackend();
        ref.invalidate(accountStatusProvider);
        ref.invalidate(myArtistProvider);
        ref.invalidate(mySongsProvider);
      } on WalletApiException catch (e) {
        if (context.mounted) {
          showWalletToast(context, e.friendlyMessage, icon: DeeMusiqIcons.info);
        }
      } catch (e, stack) {
        AppLogger.reportError(e, stack, 'creator email sign-in');
      } finally {
        if (context.mounted) loading.value = false;
      }
    }

    return Card(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(DeeMusiqIcons.artist, size: 32, color: deeMusiqOrange),
          const Gap(10),
          Text(context.l10n.creator_email_gate_title)
              .large()
              .semiBold()
              .center(),
          const Gap(6),
          Text(
            context.l10n.creator_email_gate_body,
            textAlign: TextAlign.center,
          ).muted().small(),
          const Gap(16),
          TextField(
            controller: email,
            placeholder: Text(context.l10n.signup_email_hint),
            keyboardType: TextInputType.emailAddress,
          ),
          const Gap(8),
          TextField(
            controller: password,
            placeholder: Text(context.l10n.signup_password_hint),
            obscureText: true,
            onSubmitted: (_) => signIn(),
          ),
          const Gap(12),
          Button.primary(
            onPressed: loading.value ? null : signIn,
            child: Text(loading.value
                ? context.l10n.please_wait
                : context.l10n.creator_sign_in_cta),
          ),
          const Gap(8),
          TextButton(
            onPressed: loading.value
                ? null
                : () => context.router.push(const Signup()),
            child: Text(context.l10n.signup_create_account).muted(),
          ),
        ],
      ),
    );
  }
}

/// Shown for a signed-in account whose email address is not confirmed yet.
/// Device-only accounts first attach an email + password; the emailed
/// 6-digit code is then the verification token that unlocks the studio.
class _VerifyEmailGate extends HookConsumerWidget {
  final Map<String, dynamic> account;
  const _VerifyEmailGate({required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final email = ((account["email"] as String?) ?? "").trim();
    final hasEmail = email.isNotEmpty;
    final emailController = useTextEditingController(text: email);
    final password = useTextEditingController();
    final code = useTextEditingController();
    final busy = useState(false);
    // An account that already carries an email goes straight to code entry;
    // a device-only one must save credentials first.
    final awaitingCode = useState(hasEmail);
    final acceptTerms = useState(false);
    final errorText = useState<String?>(null);

    Future<void> afterVerified() async {
      await syncFavoritesFromBackend(
          ref.read(localFavoritesProvider.notifier));
      await ref.read(walletProvider.notifier).syncFromBackend();
      ref.invalidate(accountStatusProvider);
      ref.invalidate(myArtistProvider);
      ref.invalidate(mySongsProvider);
    }

    Future<void> saveCredentials() async {
      if (busy.value) return;
      final mail = emailController.text.trim();
      if (mail.isEmpty) {
        errorText.value = l10n.signup_invalid_email;
        return;
      }
      if (password.text.isEmpty) {
        errorText.value = l10n.signup_enter_password;
        return;
      }
      if (!acceptTerms.value) {
        errorText.value = l10n.must_agree_privacy_policy;
        return;
      }
      busy.value = true;
      errorText.value = null;
      try {
        await WalletApiClient.instance.registerEmail(
          email: mail,
          password: password.text,
          acceptTerms: true,
        );
        // /auth/register emails a signed link; ask for the 6-digit code too so
        // verification can complete inside the app.
        await WalletApiClient.instance.resendSignupCode(email: mail);
        awaitingCode.value = true;
        if (context.mounted) {
          showWalletToast(context, l10n.creator_email_code_sent,
              icon: DeeMusiqIcons.info);
        }
      } on WalletApiException catch (e) {
        errorText.value = e.friendlyMessage;
      } catch (e, stack) {
        AppLogger.reportError(e, stack, 'creator attach email');
        errorText.value = l10n.something_went_wrong;
      } finally {
        if (context.mounted) busy.value = false;
      }
    }

    Future<void> verify() async {
      if (busy.value) return;
      final mail = emailController.text.trim();
      final value = code.text.trim();
      if (value.length != 6 || int.tryParse(value) == null) {
        errorText.value = l10n.signup_code_length;
        return;
      }
      busy.value = true;
      errorText.value = null;
      try {
        await WalletApiClient.instance
            .verifySignupCode(email: mail, code: value);
        await afterVerified();
      } on WalletApiException catch (e) {
        errorText.value = e.friendlyMessage;
      } catch (e, stack) {
        AppLogger.reportError(e, stack, 'creator verify email');
        errorText.value = l10n.something_went_wrong;
      } finally {
        if (context.mounted) busy.value = false;
      }
    }

    Future<void> resend() async {
      if (busy.value) return;
      final mail = emailController.text.trim();
      if (mail.isEmpty) {
        errorText.value = l10n.signup_invalid_email;
        return;
      }
      busy.value = true;
      try {
        await WalletApiClient.instance.resendSignupCode(email: mail);
        if (context.mounted) {
          showWalletToast(context, l10n.creator_email_code_sent,
              icon: DeeMusiqIcons.info);
        }
      } on WalletApiException catch (e) {
        if (context.mounted) {
          showWalletToast(context, e.friendlyMessage, icon: DeeMusiqIcons.info);
        }
      } finally {
        if (context.mounted) busy.value = false;
      }
    }

    return Card(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(DeeMusiqIcons.verified, size: 32, color: deeMusiqOrange),
          const Gap(10),
          Text(awaitingCode.value
                  ? l10n.creator_verify_email_title
                  : l10n.creator_add_email_title)
              .large()
              .semiBold()
              .center(),
          const Gap(6),
          Text(
            awaitingCode.value
                ? l10n.creator_verify_email_body(emailController.text.trim())
                : l10n.creator_add_email_body,
            textAlign: TextAlign.center,
          ).muted().small(),
          const Gap(16),
          if (awaitingCode.value) ...[
            if (!hasEmail) ...[
              TextField(
                controller: emailController,
                placeholder: Text(l10n.signup_email_hint),
                keyboardType: TextInputType.emailAddress,
                enabled: !busy.value,
                onChanged: (_) => errorText.value = null,
              ),
              const Gap(8),
            ],
            TextField(
              controller: code,
              placeholder: Text(l10n.signup_code_hint),
              keyboardType: TextInputType.number,
              maxLength: 6,
              enabled: !busy.value,
              onSubmitted: (_) => verify(),
            ),
            const Gap(12),
            Button.primary(
              onPressed: busy.value ? null : verify,
              child: Text(
                  busy.value ? l10n.please_wait : l10n.signup_confirm),
            ),
            const Gap(8),
            TextButton(
              onPressed: busy.value ? null : resend,
              child: Text(l10n.signup_resend_code).muted(),
            ),
          ] else ...[
            TextField(
              controller: emailController,
              placeholder: Text(l10n.signup_email_hint),
              keyboardType: TextInputType.emailAddress,
              enabled: !busy.value,
              onChanged: (_) => errorText.value = null,
            ),
            const Gap(8),
            TextField(
              controller: password,
              placeholder: Text(l10n.signup_password_hint),
              obscureText: true,
              enabled: !busy.value,
              onChanged: (_) => errorText.value = null,
            ),
            const Gap(8),
            Row(
              children: [
                Checkbox(
                  state: acceptTerms.value
                      ? CheckboxState.checked
                      : CheckboxState.unchecked,
                  onChanged: busy.value
                      ? null
                      : (v) =>
                          acceptTerms.value = v == CheckboxState.checked,
                ),
                const Gap(8),
                Expanded(
                  child: TextButton(
                    onPressed: busy.value
                        ? null
                        : () => acceptTerms.value = !acceptTerms.value,
                    child: Text(l10n.agree_privacy_policy).muted(),
                  ),
                ),
              ],
            ),
            const Gap(12),
            Button.primary(
              onPressed: busy.value ? null : saveCredentials,
              child: Text(busy.value
                  ? l10n.please_wait
                  : l10n.creator_save_and_email_code),
            ),
          ],
          if (errorText.value != null) ...[
            const Gap(12),
            Text(
              errorText.value!,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.destructive,
              ),
            ),
          ],
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
        title: context.l10n.creator_studio_load_failed,
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
                    child: Text(context.l10n.creator_release_console),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: Button.secondary(
                    onPressed: () =>
                        context.navigateTo(const VerificationRoute()),
                    leading: const Icon(DeeMusiqIcons.verified, size: 16),
                    child: Text(
                      artist["verified"] == true
                          ? context.l10n.verified
                          : context.l10n.creator_get_verified,
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
            Text(context.l10n.creator_your_songs).large().semiBold(),
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
      if (name.text.trim().isEmpty) {
        showWalletToast(context, context.l10n.artist_name_required,
            icon: DeeMusiqIcons.info);
        return;
      }
      loading.value = true;
      try {
        await WalletApiClient.instance
            .createArtist(name: name.text.trim(), bio: bio.text.trim());
        ref.invalidate(myArtistProvider);
        if (context.mounted) {
          showWalletToast(context, context.l10n.creator_profile_created,
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
        if (context.mounted) loading.value = false;
      }
    }

    return Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.l10n.creator_claim_title).large().semiBold(),
          const Gap(4),
          Text(context.l10n.creator_claim_body).muted().small(),
          const Gap(12),
          TextField(
              controller: name,
              placeholder: Text(context.l10n.creator_artist_name_hint)),
          const Gap(8),
          TextField(
            controller: bio,
            placeholder: Text(context.l10n.creator_bio_hint),
            maxLines: 3,
          ),
          const Gap(12),
          Button.primary(
            onPressed: loading.value ? null : claim,
            child: Text(loading.value
                ? context.l10n.please_wait
                : context.l10n.creator_create_profile),
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
                label: context.l10n.creator_stat_songs,
                value: "${stats["songCount"] ?? 0}",
              ),
              _Stat(
                label: context.l10n.creator_stat_tokens_year,
                value: formatTokens(
                    (stats["totalTokensThisYear"] as num?)?.toInt() ?? 0),
              ),
              _Stat(
                label: context.l10n.creator_stat_rank_year,
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

/// Extensions the audio picker offers. Sourced from GET
/// /creator/uploads/formats (`formats[].exts`) so the picker tracks the
/// backend allowlist; the hardcoded list only applies when the fetch fails.
Future<List<String>> _allowedAudioExtensions() async {
  const fallback = [
    "mp3", "m4a", "aac", "wav", "flac", "ogg", "opus", "webm",
    "aiff", "aif", "mp4",
  ];
  try {
    final res = await WalletApiClient.instance.fetchUploadFormats();
    final formats = res["formats"];
    if (formats is! List) return fallback;
    final extensions = <String>{};
    for (final format in formats) {
      if (format is! Map) continue;
      final exts = format["exts"];
      if (exts is! List) continue;
      for (final ext in exts) {
        if (ext is String && ext.isNotEmpty) {
          extensions.add(ext.startsWith(".") ? ext.substring(1) : ext);
        }
      }
    }
    return extensions.isEmpty ? fallback : extensions.toList();
  } catch (e, stack) {
    debugPrint('[CreatorStudio.allowedAudioExtensions] formats fetch failed, '
        'using fallback: $e');
    AppLogger.reportError(e, stack, 'upload formats fetch');
    return fallback;
  }
}

/// New upload flow: pick an audio file + cover image, upload to the backend,
/// then explicitly submit for operator review. Status transitions:
///   (none) -> draft -> pending -> approved -> (artist publishes) -> published.
class _SubmitSong extends HookConsumerWidget {
  const _SubmitSong();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
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
        final extensions = await _allowedAudioExtensions();
        final r = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: extensions,
        );
        final picked = r?.files.isNotEmpty == true ? r!.files.first.path : null;
        if (picked == null || picked.isEmpty) {
          error.value = l10n.creator_file_picker_failed;
          return;
        }
        audioPath.value = picked;
        audioUploaded.value = false;
      } catch (e, st) {
        AppLogger.reportError(e, st, 'pick audio');
        error.value = l10n.creator_file_picker_failed;
      }
    }

    Future<void> pickCover() async {
      try {
        final r = await FilePicker.platform.pickFiles(
          type: FileType.image,
        );
        final picked = r?.files.isNotEmpty == true ? r!.files.first.path : null;
        if (picked == null || picked.isEmpty) {
          error.value = l10n.creator_file_picker_failed;
          return;
        }
        coverPath.value = picked;
        coverUploaded.value = false;
      } catch (e, st) {
        AppLogger.reportError(e, st, 'pick cover');
        error.value = l10n.creator_file_picker_failed;
      }
    }

    Future<void> createAndUpload() async {
      if (loading.value) return;
      if (draftId.value == null && title.text.trim().isEmpty) {
        error.value = l10n.creator_title_required;
        return;
      }
      if (draftId.value == null && audioPath.value == null) {
        error.value = l10n.creator_pick_audio_required;
        return;
      }
      if (draftId.value == null && coverPath.value == null) {
        error.value = l10n.creator_pick_cover_required;
        return;
      }
      if (draftId.value != null &&
          !audioUploaded.value &&
          audioPath.value == null) {
        error.value = l10n.creator_pick_audio_missing;
        return;
      }
      if (draftId.value != null &&
          !coverUploaded.value &&
          coverPath.value == null) {
        error.value = l10n.creator_pick_cover_missing;
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
            throw WalletApiException(l10n.creator_upload_start_failed);
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
            l10n.creator_uploaded_submit_hint,
            icon: DeeMusiqIcons.upload,
          );
        }
      } on WalletApiException catch (e) {
        error.value = e.friendlyMessage;
      } catch (e, st) {
        AppLogger.reportError(e, st, 'upload song');
        error.value = l10n.creator_upload_failed;
      } finally {
        if (context.mounted) loading.value = false;
      }
    }

    Future<void> submitForReview() async {
      final id = draftId.value;
      if (id == null || !audioUploaded.value || !coverUploaded.value) {
        error.value = l10n.creator_upload_before_review;
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
            l10n.creator_submitted_for_review,
            icon: DeeMusiqIcons.upload,
          );
        }
      } on WalletApiException catch (e) {
        error.value = e.friendlyMessage;
      } catch (e, st) {
        AppLogger.reportError(e, st, 'submit song');
        error.value = l10n.creator_submit_review_failed;
      } finally {
        if (context.mounted) loading.value = false;
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
              Text(l10n.creator_submit_song_title).semiBold(),
            ],
          ),
          const Gap(4),
          Text(l10n.creator_submit_song_body).muted().small(),
          const Gap(12),
          TextField(
              controller: title,
              placeholder: Text(l10n.creator_song_title_hint)),
          const Gap(8),
          TextField(
            controller: description,
            placeholder: Text(l10n.creator_description_hint),
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
                        ? l10n.creator_pick_audio
                        : l10n.creator_audio_picked(
                            fileName(audioPath.value) ?? ""),
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
                        ? l10n.creator_pick_cover
                        : l10n.creator_cover_picked(
                            fileName(coverPath.value) ?? ""),
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
                          ? l10n.creator_uploading
                          : (draftId.value == null
                              ? l10n.creator_upload
                              : l10n.creator_retry_upload),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Button.primary(
                    onPressed: loading.value ? null : submitForReview,
                    child: Text(
                      loading.value
                          ? l10n.creator_submitting
                          : l10n.creator_submit_for_review,
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
          ? Text(context.l10n.creator_no_songs).muted().small()
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
    final l10n = context.l10n;
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
        if (context.mounted) busy.value = false;
      }
    }

    final status = song.status;
    final statusLabel = switch (status) {
      'draft' => l10n.creator_status_draft,
      'pending' => l10n.creator_status_pending,
      'approved' => l10n.creator_status_approved,
      'scheduled' => l10n.creator_status_scheduled,
      'published' => l10n.creator_status_published,
      'hidden' => l10n.creator_status_hidden,
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
              l10n.creator_publishes_at(
                  _fmtDateTime(song.scheduledPublishAt!.toIso8601String())),
            ).muted().xSmall()
          else if (song.audioSizeBytes != null)
            Text(
              l10n.creator_audio_size(
                  (song.audioSizeBytes! / 1024 / 1024).toStringAsFixed(1)),
            ).muted().xSmall(),
          if (song.reviewNote != null && song.reviewNote!.isNotEmpty) ...[
            const Gap(4),
            Text(l10n.creator_review_note(song.reviewNote!)).muted().xSmall(),
          ],
          if (status == 'draft' && !song.canSubmitForReview)
            Text(l10n.creator_upload_before_review).muted().xSmall(),
          const Gap(6),
          Row(
            children: [
              const Icon(DeeMusiqIcons.boost, size: 13, color: deeMusiqOrange),
              const Gap(4),
              Text(l10n.creator_song_stats(
                      song.pushes, formatTokens(song.tokens)))
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
                child: Text(l10n.creator_open_release_console),
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
                            l10n.creator_submitted_for_review,
                          ),
                  child: Text(l10n.creator_submit_for_review),
                ),
              if (status == 'published')
                Button.ghost(
                  leading: const Icon(DeeMusiqIcons.flag, size: 14),
                  onPressed: busy.value
                      ? null
                      : () => showDialog(
                            context: context,
                            builder: (_) => _TakedownDialog(song: song),
                          ),
                  child: Text(l10n.takedown_request_title),
                )
              else
                Button.ghost(
                  leading: const Icon(DeeMusiqIcons.trash, size: 14),
                  onPressed: busy.value
                      ? null
                      : () => run(
                            () => WalletApiClient.instance.deleteSong(song.id),
                            l10n.creator_song_removed,
                          ),
                  child: Text(l10n.remove),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Takedown-request dialog for PUBLISHED songs — the only sanctioned removal
/// path (hide/delete are rejected server-side for published songs). The track
/// stays live until an operator actions the request.
class _TakedownDialog extends HookConsumerWidget {
  final CreatorSong song;
  const _TakedownDialog({required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reason = useTextEditingController();
    final busy = useState(false);
    final error = useState<String?>(null);

    Future<void> submit() async {
      final text = reason.text.trim();
      if (text.isEmpty) {
        error.value = context.l10n.takedown_reason_required;
        return;
      }
      if (busy.value) return;
      busy.value = true;
      try {
        await WalletApiClient.instance
            .requestTakedown(songId: song.id, reason: text);
        ref.invalidate(mySongsProvider);
        ref.invalidate(myArtistProvider);
        if (context.mounted) {
          Navigator.of(context).pop();
          showWalletToast(context, context.l10n.takedown_request_sent,
              icon: DeeMusiqIcons.verified);
        }
      } on WalletApiException catch (e) {
        error.value = e.friendlyMessage;
      } catch (e, stack) {
        AppLogger.reportError(e, stack, 'takedown request');
        if (context.mounted) {
          error.value = context.l10n.something_went_wrong;
        }
      } finally {
        if (context.mounted) busy.value = false;
      }
    }

    return Alert(
      title: Text(context.l10n.takedown_request_title).h4(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.l10n.takedown_request_body).muted().small(),
          const Gap(10),
          TextField(
            controller: reason,
            placeholder: Text(context.l10n.takedown_reason_hint),
            maxLines: 3,
          ),
          if (error.value != null) ...[
            const Gap(8),
            Text(
              error.value!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
          const Gap(12),
          Row(
            children: [
              Expanded(
                child: Button.secondary(
                  onPressed: busy.value
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text(context.l10n.cancel),
                ),
              ),
              const Gap(10),
              Expanded(
                child: Button.primary(
                  onPressed: busy.value ? null : submit,
                  child: Text(context.l10n.submit),
                ),
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
  /// `z.enum(["payshap", "bank", "manual"])` on PUT
  /// /creator/payouts/method) — anything else is rejected server-side.
  /// A legacy saved "card" method simply isn't pre-selected in load(); the
  /// raw value still renders in the "Saved:" line below.
  static const _payoutMethodKeys = ["payshap", "bank", "manual"];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final methodKinds = {
      "payshap": l10n.payout_method_payshap,
      "bank": l10n.payout_method_bank,
      "manual": l10n.payout_method_manual,
    };
    final methodHints = {
      "payshap": l10n.payout_hint_payshap,
      "bank": l10n.payout_hint_bank,
      "manual": l10n.payout_hint_manual,
    };
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
    // One Idempotency-Key per cash-out form intent (backend dedups replays):
    // generated on first submit, kept across retries, cleared on success and
    // whenever the form values change (a changed request is a NEW intent).
    final payoutIdemKey = useState<String?>(null);
    useEffect(() {
      void resetKey() {
        payoutIdemKey.value = null;
      }

      payoutTokens.addListener(resetKey);
      payoutDetails.addListener(resetKey);
      return () {
        payoutTokens.removeListener(resetKey);
        payoutDetails.removeListener(resetKey);
      };
    }, [payoutTokens, payoutDetails]);

    Future<void> load() async {
      loading.value = true;
      error.value = null;
      try {
        final results = await Future.wait([
          WalletApiClient.instance.fetchCreatorAnalytics(artistId: artistId),
          WalletApiClient.instance.fetchRevenueSplit(artistId: artistId),
          WalletApiClient.instance.fetchPayoutMethod(artistId: artistId),
          // Optional panels: a failure here must not take down the whole
          // monetization card, so they degrade to "unavailable" — but the
          // failure is still logged, never swallowed.
          WalletApiClient.instance.fetchPayoutBalance().catchError((Object e) {
            AppLogger.log.w('payout balance fetch failed: $e');
            return <String, dynamic>{};
          }),
          WalletApiClient.instance.fetchPayoutHistory().catchError((Object e) {
            AppLogger.log.w('payout history fetch failed: $e');
            return <String, dynamic>{"payouts": []};
          }),
        ]);
        analytics.value = results[0] as Map<String, dynamic>;
        split.value = results[1] as Map<String, dynamic>;
        method.value = results[2];
        payoutBalance.value = (results[3] as Map).isEmpty ? null : results[3] as Map<String, dynamic>;
        final hist = (results[4] as Map)["payouts"];
        payoutHistory.value = hist is List ? hist : const [];
        final savedKind = method.value?["method"];
        if (savedKind is String &&
            _payoutMethodKeys.contains(savedKind)) {
          methodKind.value = savedKind;
          payoutMethod.value = savedKind;
        }
        final current = (split.value!["currentCutPct"] as num?)?.toInt() ?? 30;
        cutInput.text = "$current";
      } catch (e) {
        error.value =
            e is WalletApiException ? e.friendlyMessage : e.toString();
      } finally {
        if (context.mounted) loading.value = false;
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
              l10n.payout_phone_invalid,
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
          showWalletToast(context, l10n.payout_destination_saved,
              icon: DeeMusiqIcons.verified);
        }
      } on WalletApiException catch (e) {
        if (context.mounted) {
          showWalletToast(context, e.friendlyMessage,
              icon: DeeMusiqIcons.info);
        }
      } finally {
        if (context.mounted) saving.value = false;
      }
    }

    Future<void> requestCut() async {
      final pct = int.tryParse(cutInput.text.trim());
      if (pct == null || pct < 0 || pct > 50) {
        if (context.mounted) {
          showWalletToast(context, l10n.payout_cut_range_hint,
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
          showWalletToast(context, l10n.payout_cut_request_sent,
              icon: DeeMusiqIcons.verified);
        }
      } on WalletApiException catch (e) {
        if (context.mounted) {
          showWalletToast(context, e.friendlyMessage,
              icon: DeeMusiqIcons.info);
        }
      } finally {
        if (context.mounted) saving.value = false;
      }
    }

    Future<void> requestCashout() async {
      final tokens = int.tryParse(payoutTokens.text.trim());
      if (tokens == null || tokens <= 0) {
        if (context.mounted) {
          showWalletToast(context, l10n.payout_enter_tokens,
              icon: DeeMusiqIcons.info);
        }
        return;
      }
      if (saving.value) return;
      saving.value = true;
      try {
        payoutIdemKey.value ??= const Uuid().v4();
        final res = await WalletApiClient.instance.requestPayout(
          artistId: artistId,
          tokens: tokens,
          method: payoutMethod.value,
          details: payoutDetails.text.trim().isEmpty
              ? null
              : payoutDetails.text.trim(),
          idempotencyKey: payoutIdemKey.value,
        );
        payoutTokens.text = "";
        payoutDetails.text = "";
        payoutIdemKey.value = null;
        await load();
        if (context.mounted) {
          final payout = (res["payout"] as Map?) ?? const {};
          final payoutId = "${payout["id"] ?? ""}";
          final payoutStatus = "${payout["status"] ?? "requested"}";
          showWalletToast(
            context,
            res["requiresManual"] == true
                ? l10n.payout_request_result_manual(payoutId, payoutStatus)
                : l10n.payout_request_result(payoutId, payoutStatus),
            icon: DeeMusiqIcons.verified,
          );
        }
      } on WalletApiException catch (e) {
        if (context.mounted) {
          showWalletToast(context, e.friendlyMessage,
              icon: DeeMusiqIcons.info);
        }
      } finally {
        if (context.mounted) saving.value = false;
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
            Text(l10n.payout_monetization).semiBold(),
            const Gap(4),
            Text(error.value!).muted().small(),
            const Gap(8),
            Button.secondary(onPressed: load, child: Text(l10n.retry)),
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
          Text(l10n.payout_analytics_title).semiBold(),
          const Gap(4),
          Text(
            l10n.payout_totals(
              "${totals["gross"] ?? 0}",
              "${totals["platformFees"] ?? 0}",
              "${totals["net"] ?? 0}",
              "${totals["tips"] ?? 0}",
              "${totals["listens"] ?? 0}",
            ),
          ).muted().small(),
          const Gap(12),
          Text(l10n.payout_destination_title).small().semiBold(),
          const Gap(4),
          if (method.value != null)
            Text(l10n.payout_saved_method(
                    "${method.value!["masked"] ?? method.value!["method"]}"))
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
                    Text(methodKinds[value] ?? value),
                popupConstraints: const BoxConstraints(maxWidth: 200),
                popupWidthConstraint: PopoverConstraint.flexible,
                popup: (context) => SelectPopup(
                  items: SelectItemBuilder(
                    childCount: methodKinds.length,
                    builder: (context, index) {
                      final kind = methodKinds.keys.elementAt(index);
                      return SelectItemButton(
                        value: kind,
                        child: Text(methodKinds[kind]!),
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
                    methodHints[methodKind.value] ?? l10n.payout_hint_manual,
                  ),
                ),
              ),
              const Gap(8),
              Button.secondary(
                onPressed: saving.value ? null : saveMethod,
                child: Text(saving.value ? "…" : l10n.save),
              ),
            ],
          ),
          const Gap(12),
          Text(l10n.payout_platform_cut).small().semiBold(),
          const Gap(4),
          Text(
            pending != null
                ? l10n.payout_cut_pending(
                    "${pending["requestedPct"]}", currentCut)
                : l10n.payout_cut_current(currentCut, 100 - currentCut),
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
                child: Text(l10n.payout_request_cut),
              ),
            ],
          ),
          const Gap(12),
          Text(l10n.payout_cash_out_title).small().semiBold(),
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
              return Text(l10n.payout_balance_unavailable).muted().small();
            }
            final payable = (mine?["payable"] as num?)?.toInt() ?? 0;
            // Tips still inside the backend's settlement window — shown
            // separately from the payable balance (payouts.ts creatorBalance).
            final pendingSettlement =
                (mine?["pendingSettlement"] as num?)?.toInt() ?? 0;
            final minTokens =
                (bal["minTokens"] as num?)?.toInt() ?? 0;
            final rate =
                (bal["rateZarPerTokenMinor"] as num?)?.toInt() ?? 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.payout_balance_summary(
                    payable,
                    (payable * rate / 100).toStringAsFixed(2),
                    minTokens,
                    "${mine?["received"] ?? 0}",
                    "${mine?["pending"] ?? 0}",
                    "${mine?["paidOut"] ?? 0}",
                  ),
                ).muted().small(),
                if (pendingSettlement > 0) ...[
                  const Gap(4),
                  Text(
                    l10n.payout_pending_settlement(pendingSettlement),
                  ).semiBold().small(),
                  Text(l10n.payout_settlement_explainer).muted().xSmall(),
                ],
                const Gap(4),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: payoutTokens,
                        placeholder: Text(l10n.payout_tokens_hint),
                      ),
                    ),
                    const Gap(8),
                    Select<String>(
                      value: payoutMethod.value,
                      onChanged: (v) {
                        if (v != null) payoutMethod.value = v;
                        payoutIdemKey.value = null;
                      },
                      itemBuilder: (context, value) =>
                          Text(methodKinds[value] ?? value),
                      popup: (context) => SelectPopup(
                        items: SelectItemBuilder(
                          childCount: methodKinds.length,
                          builder: (context, index) {
                            final k = methodKinds.keys.elementAt(index);
                            return SelectItemButton(
                                value: k, child: Text(methodKinds[k]!));
                          },
                        ),
                      ),
                    ),
                    const Gap(8),
                    Button.secondary(
                      onPressed: saving.value ? null : requestCashout,
                      child: Text(saving.value ? "…" : l10n.payout_cash_out),
                    ),
                  ],
                ),
                const Gap(4),
                TextField(
                  controller: payoutDetails,
                  placeholder: Text(l10n.payout_settlement_hint),
                ),
                const Gap(8),
                if (payoutHistory.value.isEmpty)
                  Text(l10n.payout_history_empty).muted().small()
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final p
                          in payoutHistory.value.take(10))
                        Text(
                          (p as Map)["reference"] != null
                              ? l10n.payout_history_entry_ref(
                                  "${p["tokens"]}",
                                  "${p["amount"] ?? p["zarMinor"]}",
                                  "${p["status"]}",
                                  "${p["reference"]}",
                                )
                              : l10n.payout_history_entry(
                                  "${p["tokens"]}",
                                  "${p["amount"] ?? p["zarMinor"]}",
                                  "${p["status"]}",
                                ),
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
