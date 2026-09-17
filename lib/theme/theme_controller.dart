import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system);

  static const _prefKey = 'theme_mode';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);

    value = ThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    value = themeMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, themeMode.name);
  }

  Future<void> toggleThemeMode() {
    final next = value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    return setThemeMode(next);
  }
}
