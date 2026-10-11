import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/ui/button_tile.dart';
import 'package:deemusiq/modules/getting_started/action_bar.dart';
import 'package:deemusiq/modules/getting_started/blur_card.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/provider/user_preferences/user_preferences_provider.dart';

class GettingStartedPagePlaybackSection extends HookConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const GettingStartedPagePlaybackSection({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context, ref) {
    final preferences = ref.watch(userPreferencesProvider);
    final preferencesNotifier = ref.read(userPreferencesProvider.notifier);

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: BlurCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(DeeMusiqIcons.album, size: 16),
                          const Gap(8),
                          Text(context.l10n.playback).semiBold().large(),
                        ],
                      ),
                      const Gap(32),
                      ButtonTile(
                        title: Text(context.l10n.endless_playback),
                        subtitle: Text(
                          context.l10n.endless_playback_description,
                        ).small().muted(),
                        onPressed: () {
                          preferencesNotifier
                              .setEndlessPlayback(!preferences.endlessPlayback);
                        },
                        trailing: Switch(
                          value: preferences.endlessPlayback,
                          onChanged: (value) {
                            preferencesNotifier.setEndlessPlayback(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          GettingStartedActionBar(
            onPrimary: onNext,
            onPrevious: onPrevious,
          ),
        ],
      ),
    );
  }
}
