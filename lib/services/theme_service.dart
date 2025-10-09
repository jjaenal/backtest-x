import 'package:flutter/material.dart';

class ThemeService {
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
  }

  void toggleTheme() {
    final current = themeMode.value;
    switch (current) {
      case ThemeMode.light:
        themeMode.value = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        themeMode.value = ThemeMode.light;
        break;
      case ThemeMode.system:
        themeMode.value = ThemeMode.dark;
        break;
    }
  }
}