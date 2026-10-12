import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/provider/audio_player/playback_speed.dart';
import 'package:deemusiq/services/audio_player/audio_player.dart';

class TempoPitchControls extends HookConsumerWidget {
  const TempoPitchControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Persisted speed (shared with the player speed cycler) + local pitch.
    final speed = ref.watch(playbackSpeedProvider);
    final speedNotifier = ref.watch(playbackSpeedProvider.notifier);
    final pitch = useState(1.0);

    return Column(children: [
      Text(context.l10n.tempo_speed(speed.toStringAsFixed(1))),
      Slider(
        value: SliderValue.single(speed),
        min: 0.5,
        max: 2.0,
        onChanged: (v) {
          final val = v.value.toDouble();
          speedNotifier.setSpeed(val);
        },
      ),
      const SizedBox(height: 8),
      Text(context.l10n.tempo_pitch(pitch.value.toStringAsFixed(1))),
      Slider(
        value: SliderValue.single(pitch.value),
        min: 0.5,
        max: 2.0,
        onChanged: (v) {
          final val = v.value.toDouble();
          pitch.value = val;
          audioPlayer.setPitch(val);
        },
      ),
    ]);
  }
}
