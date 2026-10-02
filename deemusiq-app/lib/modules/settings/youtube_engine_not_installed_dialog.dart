import 'dart:io';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/form/text_form_field.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/hooks/controllers/use_shadcn_text_editing_controller.dart';
import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/services/youtube_engine/direct_ytdlp_engine.dart';
import 'package:deemusiq/utils/platform.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yt_dlp_dart/yt_dlp_dart.dart';
import 'package:deemusiq/modules/settings/yt_dlp_install_dialog.dart';

/// Fallback link for users who prefer fetching yt-dlp themselves. When the build
/// pinned a version we point at that exact tag, otherwise at the latest release.
String get engineDownloadUrl => YtDlpBinaryPolicy.hasBuildApprovedBinary
    ? 'https://github.com/yt-dlp/yt-dlp/releases/tag/${Uri.encodeComponent(YtDlpBinaryPolicy.buildApprovedVersion)}'
    : 'https://github.com/yt-dlp/yt-dlp/releases/latest';

class YouTubeEngineNotInstalledDialog extends HookConsumerWidget {
  final YoutubeClientEngine engine;
  const YouTubeEngineNotInstalledDialog({
    super.key,
    required this.engine,
  });

  @override
  Widget build(BuildContext context, ref) {
    final theme = Theme.of(context);
    final controller = useShadcnTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>(), []);

    return AlertDialog(
      title: Row(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(DeeMusiqIcons.error, color: Colors.red),
          Text(
            context.l10n.youtube_engine_not_installed_title(engine.label),
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(
              context.l10n.youtube_engine_not_installed_message(engine.label),
            ),
            if (engine == YoutubeClientEngine.ytDlp) ...[
              Text(
                context.l10n.yt_dlp_install_managed_message,
                style: theme.typography.small,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${context.l10n.download}:"),
                  Button.link(
                    child: Text(
                      YtDlpBinaryPolicy.hasBuildApprovedBinary
                          ? 'yt-dlp ${YtDlpBinaryPolicy.buildApprovedVersion}'
                          : 'yt-dlp (latest)',
                    ),
                    onPressed: () async {
                      launchUrl(Uri.parse(engineDownloadUrl));
                    },
                  ),
                ],
              ),
            ],
            Text(context.l10n.youtube_engine_set_path(engine.label)),
            const Gap(8),
            FormBuilder(
              key: formKey,
              child: TextFormBuilderField(
                name: "path",
                controller: controller,
                placeholder: Text(switch (context.theme.platform) {
                  TargetPlatform.macOS => "e.g. /opt/homebrew/bin/yt-dlp",
                  TargetPlatform.windows =>
                    r"e.g. C:\Program Files\yt-dlp\yt-dlp.exe",
                  _ => "e.g. /home/user/.local/bin/yt-dlp",
                }),
              ),
            ),
            Text(
              YtDlpBinaryPolicy.hasBuildApprovedBinary
                  ? 'Approved version: ${YtDlpBinaryPolicy.buildApprovedVersion}\nSHA-256: ${YtDlpBinaryPolicy.buildApprovedSha256}'
                  : context.l10n.yt_dlp_install_managed_message,
              style: theme.typography.small,
            ),
            if (kIsMacOS || kIsLinux)
              Text(context.l10n.youtube_engine_unix_issue_message),
          ],
        ),
      ),
      actions: [
        Button.primary(
          onPressed: () async {
            final resolution = await showYtDlpInstallDialog(context);
            if ((resolution?.isApproved ?? false) && context.mounted) {
              Navigator.of(context).pop(true);
            }
          },
          child: Text(context.l10n.yt_dlp_install_latest_action),
        ),
        Button.text(
          onPressed: () {
            if (!context.mounted) return;
            Navigator.of(context).pop(false);
          },
          child: Text(context.l10n.cancel),
        ),
        Button.secondary(
          onPressed: () async {
            if (controller.text.isNotEmpty) {
              if (!await File(controller.text).exists() && context.mounted) {
                formKey.currentState?.fields["path"]
                    ?.invalidate(context.l10n.file_not_found);
                return;
              }
              if (engine == YoutubeClientEngine.ytDlp) {
                final resolution = await const YtDlpBinaryPolicy()
                    .verify(controller.text.trim());
                if (!resolution.isApproved && context.mounted) {
                  formKey.currentState?.fields["path"]?.invalidate(
                    resolution.error ?? 'yt-dlp is unavailable',
                  );
                  return;
                }
                YtDlpBinaryPolicy.approvedPath = resolution.path;
                await YtDlp.instance.setBinaryLocation(resolution.path!);
              }
              await KVStoreService.setYoutubeEnginePath(
                engine,
                controller.text.trim(),
              );
            }
            if (!context.mounted) return;
            Navigator.of(context).pop(true);
          },
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}
