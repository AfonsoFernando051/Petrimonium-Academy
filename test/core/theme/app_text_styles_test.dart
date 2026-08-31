import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';

void main() {
  group('AppTextStyles', () {
    test('font size scale is strictly increasing across the semantic ramp', () {
      expect(AppTextStyles.caption.fontSize, lessThan(AppTextStyles.label.fontSize!));
      expect(AppTextStyles.label.fontSize, lessThan(AppTextStyles.body.fontSize!));
      expect(AppTextStyles.body.fontSize, lessThan(AppTextStyles.bodyEmphasis.fontSize!));
      expect(AppTextStyles.bodyEmphasis.fontSize, lessThan(AppTextStyles.title.fontSize!));
      expect(AppTextStyles.title.fontSize, lessThan(AppTextStyles.titleLarge.fontSize!));
      expect(AppTextStyles.titleLarge.fontSize, lessThan(AppTextStyles.headline.fontSize!));
      expect(AppTextStyles.headline.fontSize, lessThan(AppTextStyles.display.fontSize!));
    });

    test('every style omits an explicit color, matching the doc comment', () {
      for (final style in [
        AppTextStyles.caption,
        AppTextStyles.label,
        AppTextStyles.body,
        AppTextStyles.bodyEmphasis,
        AppTextStyles.title,
        AppTextStyles.titleLarge,
        AppTextStyles.headline,
        AppTextStyles.display,
      ]) {
        expect(style.color, isNull);
      }
    });

    test('bodyEmphasis/title/titleLarge/headline/display are bold or semi-bold', () {
      expect(AppTextStyles.bodyEmphasis.fontWeight, FontWeight.w600);
      expect(AppTextStyles.title.fontWeight, FontWeight.bold);
      expect(AppTextStyles.titleLarge.fontWeight, FontWeight.bold);
      expect(AppTextStyles.headline.fontWeight, FontWeight.bold);
      expect(AppTextStyles.display.fontWeight, FontWeight.bold);
    });
  });
}
