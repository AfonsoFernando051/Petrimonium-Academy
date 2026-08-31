import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('light has Brightness.light and the AppColorTokens.light extension', () {
      final theme = AppTheme.light;

      expect(theme.brightness, Brightness.light);
      expect(theme.extension<AppColorTokens>(), AppColorTokens.light);
      expect(theme.scaffoldBackgroundColor, AppColorTokens.light.backgroundPrimary);
    });

    test('dark has Brightness.dark and the AppColorTokens.dark extension', () {
      final theme = AppTheme.dark;

      expect(theme.brightness, Brightness.dark);
      expect(theme.extension<AppColorTokens>(), AppColorTokens.dark);
      expect(theme.scaffoldBackgroundColor, AppColorTokens.dark.backgroundPrimary);
    });

    test('colorScheme brightness matches the theme brightness', () {
      expect(AppTheme.light.colorScheme.brightness, Brightness.light);
      expect(AppTheme.dark.colorScheme.brightness, Brightness.dark);
    });
  });
}
