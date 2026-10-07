import 'dart:io' as dart_io;

import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/titlebar/titlebar.dart';
import 'package:deemusiq/provider/creator/creator_provider.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// Artist identity verification. The artist submits a photo of themselves
/// holding a sign that says "deemusiq" plus their declared legal name and
/// country. The admin web app then approves or rejects; on approval the
/// artist gets the `verified` badge.
@RoutePage()
class VerificationPage extends HookConsumerWidget {
  static const name = "creator-verification";

  const VerificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artist = ref.watch(myArtistProvider);
    final legalName = useTextEditingController();
    final country = useTextEditingController();
    final socialsJson = useTextEditingController();
    final busy = useState(false);
    final error = useState<String?>(null);
    final info = useState<String?>(null);
    final pickedImage = useState<XFile?>(null);
    // The backend rejects submissions without a proof photo, so "Submit for
    // review" stays gated until an uploadProof call has succeeded.
    final proofUploaded = useState(false);

    final a = artist.maybeWhen(
      data: (m) => (m as Map<String, dynamic>?)?["artist"] as Map<String, dynamic>?,
      orElse: () => null,
    );
    final status = a?["verificationStatus"] as String? ?? "none";
    final alreadyVerified = a?["verified"] == true;

    Future<void> pickImage(ImageSource source) async {
      try {
        final picker = ImagePicker();
        final x = await picker.pickImage(
          source: source,
          maxWidth: 1600,
          imageQuality: 85,
        );
        if (x != null) {
          pickedImage.value = x;
          proofUploaded.value = false;
        }
      } catch (e, st) {
        AppLogger.reportError(e, st, 'verification pick image');
        error.value = "Could not access camera/gallery";
      }
    }

    Future<void> uploadProof() async {
      final file = pickedImage.value;
      if (file == null) {
        error.value = "Pick a photo first.";
        return;
      }
      busy.value = true;
      error.value = null;
      try {
        await WalletApiClient.instance.uploadVerificationProof(file.path);
        if (!context.mounted) return;
        proofUploaded.value = true;
        info.value = "Photo uploaded. Fill in the form and submit.";
        ref.invalidate(myArtistProvider);
      } on WalletApiException catch (e) {
        if (context.mounted) error.value = e.friendlyMessage;
      } finally {
        if (context.mounted) busy.value = false;
      }
    }

    Future<void> submit() async {
      if (!proofUploaded.value) {
        error.value = "Upload your proof photo first.";
        return;
      }
      if (legalName.text.trim().isEmpty || country.text.trim().isEmpty) {
        error.value = "Legal name and country are required.";
        return;
      }
      busy.value = true;
      error.value = null;
      try {
        final socials = parseSocialLinks(socialsJson.text);
        await WalletApiClient.instance.submitVerification(
          legalName: legalName.text.trim(),
          country: country.text.trim(),
          socials: socials,
        );
        if (!context.mounted) return;
        info.value = "Submitted. The DeeMusiq team will review shortly.";
        ref.invalidate(myArtistProvider);
      } on WalletApiException catch (e) {
        if (context.mounted) error.value = e.friendlyMessage;
      } finally {
        if (context.mounted) busy.value = false;
      }
    }

    return SafeArea(
      bottom: false,
      child: Scaffold(
        headers: const [TitleBar(title: Text("Get Verified"))],
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (alreadyVerified)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(DeeMusiqIcons.verified,
                                  color: Colors.green),
                              const Gap(8),
                              Expanded(
                                child: const Text("You're verified!").h4(),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("How verification works").h4(),
                              const Gap(8),
                              const Text(
                                "1. Take a photo of yourself holding a sign that says \"deemusiq\" (and your artist name).\n"
                                "2. Upload the photo below.\n"
                                "3. Submit the form. An operator reviews within a few days.\n"
                                "4. On approval, the verified badge appears next to your name.",
                              ),
                              const Gap(16),
                              Text("Status: $status",
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    const Gap(16),
                    if (!alreadyVerified) ...[
                      const Text("Proof photo").h4(),
                      const Gap(8),
                      if (pickedImage.value != null)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Image.file(
                              // Image.file needs a File; XFile.path is enough.
                              // ignore: avoid_dynamic_calls
                              _fileFromXFile(pickedImage.value!),
                              fit: BoxFit.contain,
                              height: 240,
                            ),
                          ),
                        )
                      else
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.image),
                                Gap(8),
                                Expanded(
                                  child: Text("No photo selected yet."),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const Gap(8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Button.secondary(
                            onPressed: busy.value ? null : () => pickImage(ImageSource.camera),
                            leading: const Icon(Icons.camera_alt),
                            child: const Text("Take photo"),
                          ),
                          Button.secondary(
                            onPressed: busy.value ? null : () => pickImage(ImageSource.gallery),
                            leading: const Icon(DeeMusiqIcons.upload),
                            child: const Text("From gallery"),
                          ),
                          Button.primary(
                            onPressed: busy.value || pickedImage.value == null
                                ? null
                                : uploadProof,
                            child: const Text("Upload proof"),
                          ),
                        ],
                      ),
                      const Gap(24),
                      const Text("Your details").h4(),
                      const Gap(8),
                      TextField(
                        controller: legalName,
                        placeholder: const Text("Legal name (as it appears on your ID)"),
                      ),
                      const Gap(8),
                      TextField(
                        controller: country,
                        placeholder: const Text("Country (e.g. South Africa)"),
                      ),
                      const Gap(8),
                      TextField(
                        controller: socialsJson,
                        placeholder: const Text(
                            "Social links (optional): instagram: https://..., youtube: https://..."),
                        maxLines: 3,
                      ),
                      const Gap(16),
                      if (error.value != null)
                        Text(error.value!,
                            style: const TextStyle(color: Colors.red, fontSize: 12)),
                      if (info.value != null)
                        Text(info.value!,
                            style: const TextStyle(color: Colors.green, fontSize: 12)),
                      const Gap(8),
                      Button.primary(
                        onPressed: busy.value || !proofUploaded.value
                            ? null
                            : submit,
                        child: Text(busy.value ? "Submitting…" : "Submit for review"),
                      ),
                    ],
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

dart_io.File _fileFromXFile(XFile x) => dart_io.File(x.path);

/// Parses the free-text social-links field into (provider, url) pairs.
/// Accepts "provider: url" lines or bare URLs (provider defaults to
/// "website"). A bare URL like "https://…" also contains ":", so only split
/// on the colon when the line doesn't start with a URL scheme.
List<({String provider, String url})> parseSocialLinks(String raw) {
  final socials = <({String provider, String url})>[];
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return socials;
  for (final line in trimmed.split(RegExp(r"[\n,]"))) {
    final t = line.trim();
    if (t.isEmpty) continue;
    final startsWithScheme = RegExp(r"^[a-zA-Z][a-zA-Z0-9+.-]*://").hasMatch(t);
    final colon = startsWithScheme ? -1 : t.indexOf(":");
    if (colon > 0) {
      socials.add((
        provider: t.substring(0, colon).trim(),
        url: t.substring(colon + 1).trim(),
      ));
    } else {
      socials.add((provider: "website", url: t));
    }
  }
  return socials;
}
