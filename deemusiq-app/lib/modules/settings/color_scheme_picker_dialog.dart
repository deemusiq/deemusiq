import 'package:collection/collection.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:deemusiq/extensions/context.dart';

import 'package:deemusiq/provider/user_preferences/user_preferences_provider.dart';
import 'package:deemusiq/modules/settings/deemusiq_theme.dart';

class DeeMusiqColor extends Color {
  final String name;

  const DeeMusiqColor(super.color, {required this.name});

  const DeeMusiqColor.from(super.value, {required this.name});

  factory DeeMusiqColor.fromString(String string) {
    final slices = string.split(":");
    return DeeMusiqColor(int.parse(slices.last), name: slices.first);
  }

  @override
  String toString() {
    return "$name:${toARGB32()}";
  }
}

final Set<DeeMusiqColor> colorsMap = {
  DeeMusiqColor(const Color.fromARGB(255, 103, 80, 164).toARGB32(), name: "dynamic"),
  DeeMusiqColor(Colors.slate.toARGB32(), name: "slate"),
  DeeMusiqColor(Colors.gray.toARGB32(), name: "gray"),
  DeeMusiqColor(Colors.zinc.toARGB32(), name: "zinc"),
  DeeMusiqColor(Colors.neutral.toARGB32(), name: "neutral"),
  DeeMusiqColor(Colors.stone.toARGB32(), name: "stone"),
  DeeMusiqColor(Colors.red.toARGB32(), name: "red"),
  DeeMusiqColor(Colors.orange.toARGB32(), name: "orange"),
  DeeMusiqColor(Colors.yellow.toARGB32(), name: "yellow"),
  DeeMusiqColor(Colors.green.toARGB32(), name: "green"),
  DeeMusiqColor(Colors.blue.toARGB32(), name: "blue"),
  DeeMusiqColor(Colors.violet.toARGB32(), name: "violet"),
  DeeMusiqColor(Colors.rose.toARGB32(), name: "rose"),
};

final colorSchemeMap = <String, ColorScheme Function(ThemeMode)>{
  "dynamic": (ThemeMode mode) =>
      _dynamicColorScheme(mode == ThemeMode.light ? Brightness.light : Brightness.dark),
  "slate": LegacyColorSchemes.slate,
  "gray": LegacyColorSchemes.gray,
  "zinc": LegacyColorSchemes.zinc,
  "neutral": LegacyColorSchemes.neutral,
  "stone": LegacyColorSchemes.stone,
  "red": LegacyColorSchemes.red,
  // Override built-in orange with DeeMusiq brand orange.
  "orange": DeeMusiqTheme.schemeFactory,
  "yellow": LegacyColorSchemes.yellow,
  "green": LegacyColorSchemes.green,
  "blue": LegacyColorSchemes.blue,
  "violet": LegacyColorSchemes.violet,
  "rose": LegacyColorSchemes.rose,
};

ColorScheme _dynamicColorScheme(Brightness brightness) {
  if (brightness == Brightness.dark) {
    return ColorScheme(
      brightness: Brightness.dark,
      background: const Color(0xFF1C1B1F),
      foreground: const Color(0xFFE6E1E5),
      primary: const Color(0xFFD0BCFE),
      primaryForeground: const Color(0xFF381E72),
      secondary: const Color(0xFFCCC2DC),
      secondaryForeground: const Color(0xFF332D41),
      muted: const Color(0xFF2B2930),
      mutedForeground: const Color(0xFFCAC4D0),
      card: const Color(0xFF242329),
      cardForeground: const Color(0xFFE6E1E5),
      popover: const Color(0xFF2B2930),
      popoverForeground: const Color(0xFFE6E1E5),
      border: const Color(0x29FFFFFF),
      input: const Color(0xFF2B2930),
      accent: const Color(0xFFCCC2DC),
      accentForeground: const Color(0xFF332D41),
      destructive: const Color(0xFFF2B8B5),
      destructiveForeground: const Color(0xFF601410),
      ring: const Color(0xFFD0BCFE),
      chart1: const Color(0xFFD0BCFE),
      chart2: const Color(0xFFE8DEF8),
      chart3: const Color(0xFFCCC2DC),
      chart4: const Color(0xFFE8DEF8),
      chart5: const Color(0xFFE6E1E5),
      sidebar: const Color(0xFF1C1B1F),
      sidebarForeground: const Color(0xFFE6E1E5),
      sidebarPrimary: const Color(0xFFD0BCFE),
      sidebarPrimaryForeground: const Color(0xFF381E72),
      sidebarAccent: const Color(0xFF2B2930),
      sidebarAccentForeground: const Color(0xFFE6E1E5),
      sidebarBorder: const Color(0x29FFFFFF),
      sidebarRing: const Color(0xFFD0BCFE),
    );
  }
  return ColorScheme(
    brightness: Brightness.light,
    background: const Color(0xFFFFFBFE),
    foreground: const Color(0xFF1C1B1F),
    primary: const Color(0xFF6750A4),
    primaryForeground: const Color(0xFFFFFFFF),
    secondary: const Color(0xFF625B71),
    secondaryForeground: const Color(0xFFFFFFFF),
    muted: const Color(0xFFE7E0EC),
    mutedForeground: const Color(0xFF49454F),
    card: const Color(0xFFFFFBFE),
    cardForeground: const Color(0xFF1C1B1F),
    popover: const Color(0xFFFFFBFE),
    popoverForeground: const Color(0xFF1C1B1F),
    border: const Color(0x1F000000),
    input: const Color(0xFFE7E0EC),
    accent: const Color(0xFF625B71),
    accentForeground: const Color(0xFFFFFFFF),
    destructive: const Color(0xFFB3261E),
    destructiveForeground: const Color(0xFFFFFFFF),
    ring: const Color(0xFF6750A4),
    chart1: const Color(0xFF6750A4),
    chart2: const Color(0xFFE8DEF8),
    chart3: const Color(0xFF625B71),
    chart4: const Color(0xFFE8DEF8),
    chart5: const Color(0xFF1C1B1F),
    sidebar: const Color(0xFFF5F0F7),
    sidebarForeground: const Color(0xFF1C1B1F),
    sidebarPrimary: const Color(0xFF6750A4),
    sidebarPrimaryForeground: const Color(0xFFFFFFFF),
    sidebarAccent: const Color(0xFFE7E0EC),
    sidebarAccentForeground: const Color(0xFF1C1B1F),
    sidebarBorder: const Color(0x1F000000),
    sidebarRing: const Color(0xFF6750A4),
  );
}

class ColorSchemePickerDialog extends HookConsumerWidget {
  const ColorSchemePickerDialog({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final preferences = ref.watch(userPreferencesProvider);
    final preferencesNotifier = ref.watch(userPreferencesProvider.notifier);

    final scheme = preferences.accentColorScheme;
    final active = useState<String?>(
      colorsMap.firstWhereOrNull(
        (element) {
          return scheme.name == element.name;
        },
      )?.name,
    );

    return AlertDialog(
      title: Text(
        context.l10n.pick_color_scheme,
        style: TextStyle(color: context.theme.colorScheme.foreground),
      ).large(),
      actions: [
        Button.outline(
          child: Text(context.l10n.cancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        Button.primary(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(context.l10n.save),
        ),
      ],
      content: SizedBox(
        height: 200,
        width: 400,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colorsMap.map(
            (color) {
              return ColorChip(
                name: color.name == "dynamic" ? "Dynamic (Wallpaper)" : color.name,
                color: color,
                isDynamic: color.name == "dynamic",
                isActive: color.name == active.value,
                onPressed: () {
                  active.value = color.name;
                  preferencesNotifier.setAccentColorScheme(
                    colorsMap.firstWhere(
                      (element) {
                        return element.name == color.name;
                      },
                    ),
                  );
                },
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}

class ColorChip extends StatelessWidget {
  final String name;
  final Color color;
  final bool isActive;
  final bool isDynamic;
  final VoidCallback onPressed;
  const ColorChip({
    super.key,
    required this.name,
    required this.color,
    required this.isActive,
    this.isDynamic = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      leading: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: isDynamic ? null : color,
          gradient: isDynamic
              ? const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 103, 80, 164),
                    Color.fromARGB(255, 0, 150, 136),
                    Color.fromARGB(255, 76, 175, 80),
                    Color.fromARGB(255, 255, 152, 0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onPressed,
      style: isActive ? ButtonVariance.primary : ButtonVariance.outline,
      child: Text(name),
    );
  }
}
