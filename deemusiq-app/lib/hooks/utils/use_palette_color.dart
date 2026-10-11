import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:deemusiq/components/image/universal_image.dart';
import 'package:deemusiq/extensions/color.dart';

final _paletteColorState = StateProvider<PaletteColor>(
  (ref) {
    return PaletteColor(Colors.gray[300], 0);
  },
);

PaletteColor usePaletteColor(String imageUrl, WidgetRef ref) {
  final context = useContext();
  final theme = Theme.of(context);
  final paletteColor = ref.watch(_paletteColorState);

  useEffect(() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final palette = await PaletteGenerator.fromImageProvider(
        UniversalImage.imageProvider(
          imageUrl,
          height: 50,
          width: 50,
        ),
      );
      if (!context.mounted) return;
      final color = theme.brightness == Brightness.light
          ? palette.lightMutedColor ?? palette.lightVibrantColor
          : palette.darkMutedColor ?? palette.darkVibrantColor;
      if (color != null) {
        ref.read(_paletteColorState.notifier).state = color;
      }
    });
    return null;
  }, [imageUrl]);

  return paletteColor;
}

/// Readable foreground for text drawn over a [PaletteColor] wash.
///
/// Dark washes get lightened, light washes get darkened, so the "powered by"
/// labels on the lyrics wash stay legible no matter the album art.
Color readableOnPaletteColor(PaletteColor palette) {
  final base = palette.color;
  if (base.isDark()) return base.lighten(0.55);
  if (base.isLight()) return base.darken(0.55);
  // Unreachable with the current 0.5 luminance split, but keeps the helper
  // total if the threshold ever becomes a mid-luminance band.
  return base;
}

PaletteGenerator usePaletteGenerator(String imageUrl) {
  final palette = useState(PaletteGenerator.fromColors([]));
  final context = useContext();

  useEffect(() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final newPalette = await PaletteGenerator.fromImageProvider(
        UniversalImage.imageProvider(
          imageUrl,
          height: 50,
          width: 50,
        ),
      );
      if (!context.mounted) return;

      palette.value = newPalette;
    });
    return null;
  }, [imageUrl]);

  return palette.value;
}
