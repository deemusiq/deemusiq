import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/models/database/database.dart';
import 'package:deemusiq/modules/settings/youtube_engine_not_installed_dialog.dart';
import 'package:deemusiq/modules/settings/yt_dlp_install_dialog.dart';
import 'package:deemusiq/provider/user_preferences/user_preferences_provider.dart';
import 'package:deemusiq/services/youtube_engine/yt_dlp_engine.dart';

/// Startup guarantee: when the selected engine needs yt-dlp and none is usable,
/// the official latest release is installed automatically (with a progress
/// dialog). Only when that fails does the manual-path dialog show up.
void useCheckYtDlpInstalled(WidgetRef ref) {
  final context = useContext();

  useEffect(() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final youtubeEngine = ref.read(
        userPreferencesProvider.select(
          (value) => value.youtubeClientEngine,
        ),
      );

      if (youtubeEngine != YoutubeClientEngine.ytDlp || !context.mounted) {
        return;
      }
      if (await YtDlpEngine().isInstalled() || !context.mounted) return;

      final resolution = await showYtDlpInstallDialog(context);
      if ((resolution?.isApproved ?? false) || !context.mounted) return;

      await showDialog(
        context: context,
        builder: (context) =>
            YouTubeEngineNotInstalledDialog(engine: youtubeEngine),
      );
    });

    return null;
  }, []);
}
