import 'package:flutter/material.dart';
import 'package:backtestx/services/prefs_service.dart';

class ThemeService {
  final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.dark);

  // Nullable Locale: null means follow system
  final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  final PrefsService _prefs = PrefsService();

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

  /// Load persisted locale (if any). "en" or "id"; otherwise follow system.
  Future<void> loadLocale() async {
    try {
      final code = await _prefs.getString('app.locale');
      if (code == 'en') {
        locale.value = const Locale('en');
      } else if (code == 'id') {
        locale.value = const Locale('id');
      } else {
        locale.value = null;
      }
    } catch (_) {
      locale.value = null;
    }
  }

  /// Persist and set locale. Pass null to follow system language.
  Future<void> setLocaleCode(String? code) async {
    try {
      if (code == null || code.isEmpty) {
        await _prefs.remove('app.locale');
        locale.value = null;
        return;
      }
      await _prefs.setString('app.locale', code);
      locale.value = Locale(code);
    } catch (_) {
      locale.value = code != null ? Locale(code) : null;
    }
  }
}
