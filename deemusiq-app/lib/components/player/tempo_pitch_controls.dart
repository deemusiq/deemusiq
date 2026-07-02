import 'package:flutter/material.dart' hide Slider;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/services/audio_player/audio_player.dart';

class TempoPitchControls extends HookWidget {
  const TempoPitchControls({super.key});

  @override
  Widget build(BuildContext context) {
    final speed = useState(1.0);
    final pitch = useState(1.0);

    return Column(children: [
      Text('Speed: ${speed.value.toStringAsFixed(1)}x'),
      Slider(
        value: SliderValue.single(speed.value),
        min: 0.5,
        max: 2.0,
        onChanged: (v) {
          final val = v is SliderValue ? v.value : (v as double);
          speed.value = val.toDouble();
          audioPlayer.setSpeed(speed.value);
        },
      ),
      const SizedBox(height: 8),
      Text('Pitch: ${pitch.value.toStringAsFixed(1)}x'),
      Slider(
        value: SliderValue.single(pitch.value),
        min: 0.5,
        max: 2.0,
        onChanged: (v) {
          final val = v is SliderValue ? v.value : (v as double);
          pitch.value = val.toDouble();
          audioPlayer.setPitch(pitch.value);
        },
      ),
    ]);
  }
}
