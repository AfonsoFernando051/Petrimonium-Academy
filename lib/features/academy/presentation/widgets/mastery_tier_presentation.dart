import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/features/academy/domain/entities/mastery_tier.dart';

/// Shared tier → copy/color mapping, reused by every widget that displays a
/// [MasteryTier] (`MasteryBarRow`, `SchoolDetailScreen`), so the visual
/// language for Mastery stays consistent app-wide.
class MasteryTierPresentation {
  const MasteryTierPresentation._();

  static String labelKey(MasteryTier tier) => switch (tier) {
        MasteryTier.exploring => AppStrings.masteryTierExploring,
        MasteryTier.understanding => AppStrings.masteryTierUnderstanding,
        MasteryTier.applying => AppStrings.masteryTierApplying,
        MasteryTier.mastering => AppStrings.masteryTierMastering,
      };

  static Color color(MasteryTier tier) => switch (tier) {
        MasteryTier.exploring => AppColors.neonBlue,
        MasteryTier.understanding => AppColors.neonCyan,
        MasteryTier.applying => AppColors.neonViolet,
        MasteryTier.mastering => AppColors.goldenBorder,
      };
}
