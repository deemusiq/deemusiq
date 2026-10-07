import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Material, MaterialType;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/components/dialogs/prompt_dialog.dart';
import 'package:deemusiq/components/titlebar/titlebar.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/pages/settings/sections/about.dart';
import 'package:deemusiq/pages/settings/sections/accounts.dart';
import 'package:deemusiq/pages/settings/sections/appearance.dart';
import 'package:deemusiq/pages/settings/sections/desktop.dart';
import 'package:deemusiq/pages/settings/sections/developers.dart';
import 'package:deemusiq/pages/settings/sections/downloads.dart';
import 'package:deemusiq/pages/settings/sections/language_region.dart';
import 'package:deemusiq/pages/settings/sections/playback.dart';
import 'package:deemusiq/pages/settings/sections/security.dart';
import 'package:deemusiq/pages/settings/sections/privacy.dart';
import 'package:deemusiq/pages/settings/sections/storage.dart';
import 'package:deemusiq/provider/user_preferences/user_preferences_provider.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/utils/platform.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class SettingsPage extends HookConsumerWidget {
  static const name = "settings";

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final controller = useScrollController();
    final preferencesNotifier = ref.watch(userPreferencesProvider.notifier);

    return SafeArea(
      child: Scaffold(
        headers: [
          TitleBar(
            title: Text(context.l10n.settings),
          )
        ],
        child: Scrollbar(
          controller: controller,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1366),
              child: ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(scrollbars: false),
                child: Material(
                  type: MaterialType.transparency,
                  child: ListView(
                    controller: controller,
                    children: [
                      const SettingsAccountSection(),
                      const SettingsSecuritySection(),
                      const SettingsPrivacySection(),
                      const SettingsLanguageRegionSection(),
                      const SettingsAppearanceSection(),
                      const SettingsPlaybackSection(),
                      const SettingsDownloadsSection(),
                      const SettingsStorageSection(),
                      if (kIsDesktop) const SettingsDesktopSection(),
                      if (!kIsWeb) const SettingsDevelopersSection(),
                      const SettingsAboutSection(),
                      Center(
                        child: Button.destructive(
                          onPressed: () async {
                            final confirmed = await showPromptDialog(
                              context: context,
                              title: context.l10n.restore_defaults,
                              message:
                                  "Reset all settings to their default values? This cannot be undone.",
                            );
                            if (!confirmed) return;
                            try {
                              await preferencesNotifier.reset();
                            } catch (e, stack) {
                              AppLogger.reportError(
                                  e, stack, 'settings reset');
                              if (context.mounted) {
                                showToast(
                                  context: context,
                                  location: ToastLocation.bottomCenter,
                                  builder: (context, overlay) =>
                                      const SurfaceCard(
                                    child: Basic(
                                      title: Text(
                                          "Couldn't reset settings — try again."),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(context.l10n.restore_defaults),
                        ),
                      ),
                      const SizedBox(height: 200),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
