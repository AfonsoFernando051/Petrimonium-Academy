import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/constants/app_colors.dart';

void main() {
  group('AppColors', () {
    test('brandGradient is [neonViolet, neonPink]', () {
      expect(AppColors.brandGradient, [AppColors.neonViolet, AppColors.neonPink]);
    });

    test('neon/gold accent constants are defined and opaque', () {
      for (final color in [
        AppColors.neonCyan,
        AppColors.neonPurple,
        AppColors.neonViolet,
        AppColors.neonBlue,
        AppColors.neonPink,
        AppColors.goldenBorder,
        AppColors.positiveGreen,
        AppColors.negativeRed,
        AppColors.warningAmber,
        AppColors.subtleText,
      ]) {
        expect(color.a, 1.0);
      }
    });

    test('white10/white20 are translucent variants of Colors.white', () {
      expect(AppColors.white10.a, closeTo(0.1, 0.01));
      expect(AppColors.white20.a, closeTo(0.2, 0.01));
    });

    test('primaryButton is Colors.deepPurple', () {
      expect(AppColors.primaryButton, Colors.deepPurple);
    });
  });
}
