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
    return const ColorScheme(
      brightness: Brightness.dark,
      background: Color(0xFF1C1B1F),
      foreground: Color(0xFFE6E1E5),
      primary: Color(0xFFD0BCFE),
      primaryForeground: Color(0xFF381E72),
      secondary: Color(0xFFCCC2DC),
      secondaryForeground: Color(0xFF332D41),
      muted: Color(0xFF2B2930),
      mutedForeground: Color(0xFFCAC4D0),
      card: Color(0xFF242329),
      cardForeground: Color(0xFFE6E1E5),
      popover: Color(0xFF2B2930),
      popoverForeground: Color(0xFFE6E1E5),
      border: Color(0x29FFFFFF),
      input: Color(0xFF2B2930),
      accent: Color(0xFFCCC2DC),
      accentForeground: Color(0xFF332D41),
      destructive: Color(0xFFF2B8B5),
      destructiveForeground: Color(0xFF601410),
      ring: Color(0xFFD0BCFE),
      chart1: Color(0xFFD0BCFE),
      chart2: Color(0xFFE8DEF8),
      chart3: Color(0xFFCCC2DC),
      chart4: Color(0xFFE8DEF8),
      chart5: Color(0xFFE6E1E5),
      sidebar: Color(0xFF1C1B1F),
      sidebarForeground: Color(0xFFE6E1E5),
      sidebarPrimary: Color(0xFFD0BCFE),
      sidebarPrimaryForeground: Color(0xFF381E72),
      sidebarAccent: Color(0xFF2B2930),
      sidebarAccentForeground: Color(0xFFE6E1E5),
      sidebarBorder: Color(0x29FFFFFF),
      sidebarRing: Color(0xFFD0BCFE),
    );
  }
  return const ColorScheme(
    brightness: Brightness.light,
    background: Color(0xFFFFFBFE),
    foreground: Color(0xFF1C1B1F),
    primary: Color(0xFF6750A4),
    primaryForeground: Color(0xFFFFFFFF),
    secondary: Color(0xFF625B71),
    secondaryForeground: Color(0xFFFFFFFF),
    muted: Color(0xFFE7E0EC),
    mutedForeground: Color(0xFF49454F),
    card: Color(0xFFFFFBFE),
    cardForeground: Color(0xFF1C1B1F),
    popover: Color(0xFFFFFBFE),
    popoverForeground: Color(0xFF1C1B1F),
    border: Color(0x1F000000),
    input: Color(0xFFE7E0EC),
    accent: Color(0xFF625B71),
    accentForeground: Color(0xFFFFFFFF),
    destructive: Color(0xFFB3261E),
    destructiveForeground: Color(0xFFFFFFFF),
    ring: Color(0xFF6750A4),
    chart1: Color(0xFF6750A4),
    chart2: Color(0xFFE8DEF8),
    chart3: Color(0xFF625B71),
    chart4: Color(0xFFE8DEF8),
    chart5: Color(0xFF1C1B1F),
    sidebar: Color(0xFFF5F0F7),
    sidebarForeground: Color(0xFF1C1B1F),
    sidebarPrimary: Color(0xFF6750A4),
    sidebarPrimaryForeground: Color(0xFFFFFFFF),
    sidebarAccent: Color(0xFFE7E0EC),
    sidebarAccentForeground: Color(0xFF1C1B1F),
    sidebarBorder: Color(0x1F000000),
    sidebarRing: Color(0xFF6750A4),
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
            // The pick is only staged in `active` — persist on Save so
            // Cancel leaves the accent color untouched.
            final selected = colorsMap.firstWhereOrNull(
              (element) => element.name == active.value,
            );
            if (selected != null && selected.name != scheme.name) {
              preferencesNotifier.setAccentColorScheme(selected);
            }
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
