import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/features/academy/domain/entities/mastery_tier.dart';
import 'package:petrimonium/features/academy/presentation/widgets/mastery_tier_presentation.dart';

void main() {
  group('MasteryTierPresentation.labelKey', () {
    test('maps every tier to its expected AppStrings key', () {
      expect(MasteryTierPresentation.labelKey(MasteryTier.exploring), AppStrings.masteryTierExploring);
      expect(MasteryTierPresentation.labelKey(MasteryTier.understanding), AppStrings.masteryTierUnderstanding);
      expect(MasteryTierPresentation.labelKey(MasteryTier.applying), AppStrings.masteryTierApplying);
      expect(MasteryTierPresentation.labelKey(MasteryTier.mastering), AppStrings.masteryTierMastering);
    });
  });

  group('MasteryTierPresentation.color', () {
    test('maps every tier to its expected color', () {
      expect(MasteryTierPresentation.color(MasteryTier.exploring), AppColors.neonBlue);
      expect(MasteryTierPresentation.color(MasteryTier.understanding), AppColors.neonCyan);
      expect(MasteryTierPresentation.color(MasteryTier.applying), AppColors.neonViolet);
      expect(MasteryTierPresentation.color(MasteryTier.mastering), AppColors.goldenBorder);
    });
  });
}
