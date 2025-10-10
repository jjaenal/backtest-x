import 'package:flutter/material.dart';

class Branding {
  static List<Color> backgroundGradientColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const [
            Color(0xFF0F2027),
            Color(0xFF203A43),
            Color(0xFF2C5364),
          ]
        : const [
            Color(0xFFE3F2FD),
            Color(0xFFBBDEFB),
            Color(0xFF90CAF9),
          ];
  }

  static Shader horizontalPrimaryGradientShader(
      BuildContext context, Rect bounds) {
    final primary = Theme.of(context).colorScheme.primary;
    final hsl = HSLColor.fromColor(primary);
    final secondary =
        hsl.withLightness((hsl.lightness + 0.25).clamp(0.0, 1.0)).toColor();
    return LinearGradient(
      colors: [primary, secondary],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(bounds);
  }
}
