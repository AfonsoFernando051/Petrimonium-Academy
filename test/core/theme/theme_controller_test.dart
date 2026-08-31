import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Reset the shared static notifier between tests so state doesn't leak.
    ThemeController.themeModeNotifier.value = ThemeMode.system;
  });

  group('ThemeController', () {
    test('defaults to ThemeMode.system', () {
      expect(ThemeController.currentThemeMode, ThemeMode.system);
    });

    test('load() leaves the default when nothing was persisted', () async {
      await ThemeController.load();

      expect(ThemeController.currentThemeMode, ThemeMode.system);
    });

    test('setThemeMode updates the notifier immediately', () async {
      await ThemeController.setThemeMode(ThemeMode.dark);

      expect(ThemeController.currentThemeMode, ThemeMode.dark);
      expect(ThemeController.themeModeNotifier.value, ThemeMode.dark);
    });

    test('setThemeMode persists the preference so a later load() round-trips it', () async {
      await ThemeController.setThemeMode(ThemeMode.light);
      ThemeController.themeModeNotifier.value = ThemeMode.system; // simulate a fresh app start

      await ThemeController.load();

      expect(ThemeController.currentThemeMode, ThemeMode.light);
    });

    test('setThemeMode(dark) then setThemeMode(system) round-trips back to system', () async {
      await ThemeController.setThemeMode(ThemeMode.dark);
      await ThemeController.setThemeMode(ThemeMode.system);
      ThemeController.themeModeNotifier.value = ThemeMode.dark; // simulate a fresh app start

      await ThemeController.load();

      expect(ThemeController.currentThemeMode, ThemeMode.system);
    });

    test('load() ignores a corrupt/unrecognized persisted value', () async {
      SharedPreferences.setMockInitialValues({'app_theme_mode': 'not_a_real_mode'});

      await ThemeController.load();

      expect(ThemeController.currentThemeMode, ThemeMode.system);
    });

    test('themeModeNotifier notifies listeners when the mode changes', () async {
      var notified = false;
      void listener() => notified = true;
      ThemeController.themeModeNotifier.addListener(listener);

      await ThemeController.setThemeMode(ThemeMode.dark);

      expect(notified, isTrue);
      ThemeController.themeModeNotifier.removeListener(listener);
    });
  });
}
