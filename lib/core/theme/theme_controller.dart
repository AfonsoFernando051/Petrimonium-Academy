import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide theme preference. Mirrors `Translator`'s pattern exactly: a
/// static `ValueNotifier` lets widgets (starting with the root `MaterialApp`)
/// rebuild reactively when the user switches theme in Settings, persisted
/// via shared_preferences, without pulling in a state-management package.
///
/// [ThemeMode.system] is the default — Flutter re-evaluates it automatically
/// whenever the OS brightness changes, no manual listening required.
class ThemeController {
  ThemeController._();

  static const String _prefsKey = 'app_theme_mode';

  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.system);

  static ThemeMode get currentThemeMode => themeModeNotifier.value;

  /// Loads the persisted theme preference. Call once during app startup,
  /// before the first screen is built.
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = _fromKey(prefs.getString(_prefsKey));
    if (mode != null) {
      themeModeNotifier.value = mode;
    }
  }

  /// Updates the current theme mode and persists it locally.
  static Future<void> setThemeMode(ThemeMode mode) async {
    themeModeNotifier.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _toKey(mode));
  }

  static ThemeMode? _fromKey(String? key) {
    switch (key) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }

  static String _toKey(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
