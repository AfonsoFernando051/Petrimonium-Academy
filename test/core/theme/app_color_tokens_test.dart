import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';

void main() {
  group('AppColorTokens', () {
    test('dark and light presets are distinct', () {
      expect(AppColorTokens.dark.backgroundPrimary, isNot(AppColorTokens.light.backgroundPrimary));
      expect(AppColorTokens.dark.textPrimary, isNot(AppColorTokens.light.textPrimary));
    });

    test('copyWith overrides only the given fields', () {
      final copy = AppColorTokens.dark.copyWith(primary: Colors.red);

      expect(copy.primary, Colors.red);
      expect(copy.backgroundPrimary, AppColorTokens.dark.backgroundPrimary);
      expect(copy.textPrimary, AppColorTokens.dark.textPrimary);
    });

    test('copyWith with no arguments returns an equivalent instance', () {
      final copy = AppColorTokens.dark.copyWith();

      expect(copy.primary, AppColorTokens.dark.primary);
      expect(copy.surface, AppColorTokens.dark.surface);
    });

    test('lerp at t=0 returns the starting instance colors', () {
      final result = AppColorTokens.dark.lerp(AppColorTokens.light, 0);

      expect(result.backgroundPrimary, AppColorTokens.dark.backgroundPrimary);
    });

    test('lerp at t=1 returns the other instance colors', () {
      final result = AppColorTokens.dark.lerp(AppColorTokens.light, 1);

      expect(result.backgroundPrimary, AppColorTokens.light.backgroundPrimary);
    });

    test('lerp with a non-AppColorTokens other returns this unchanged', () {
      final result = AppColorTokens.dark.lerp(null, 0.5);

      expect(result, AppColorTokens.dark);
    });
  });

  group('AppThemeContextX', () {
    testWidgets('context.colors resolves the registered AppColorTokens extension', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark().copyWith(extensions: [AppColorTokens.dark]),
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedContext.colors, AppColorTokens.dark);
    });

    testWidgets('context.isDarkMode reflects the theme brightness', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedContext.isDarkMode, isTrue);
    });
  });
}
