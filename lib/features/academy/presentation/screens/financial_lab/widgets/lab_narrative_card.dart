import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';

/// Which narrative beat a [LabNarrativeCard] represents in a simulator's
/// Introduction → Inputs → Calculation → Visualization → Interpretation →
/// Takeaway → Comprehension check structure — each gets its own icon/accent
/// so the beats stay visually distinguishable while sharing one widget
/// instead of growing four near-identical private cards per simulator.
enum LabNarrativeVariant {
  introduction,
  interpretation,
  takeaway,
  investingConnection,
  disclaimer,
}

/// One prose beat in a Financial Lab simulator — extracted from Compound
/// Interest's private `_buildExplanation` (the [takeaway] look, unchanged)
/// and generalized to the other narrative beats every simulator needs.
class LabNarrativeCard extends StatelessWidget {
  const LabNarrativeCard({
    super.key,
    required this.text,
    required this.variant,
  });

  final String text;
  final LabNarrativeVariant variant;

  ({IconData icon, Color accent}) _look() => switch (variant) {
    LabNarrativeVariant.introduction => (
      icon: Icons.menu_book_outlined,
      accent: AppColors.goldenBorder,
    ),
    LabNarrativeVariant.interpretation => (
      icon: Icons.insights,
      accent: AppColors.neonCyan,
    ),
    LabNarrativeVariant.takeaway => (
      icon: Icons.lightbulb_outline_rounded,
      accent: AppColors.neonViolet,
    ),
    LabNarrativeVariant.investingConnection => (
      icon: Icons.link,
      accent: AppColors.neonCyan,
    ),
    LabNarrativeVariant.disclaimer => (
      icon: Icons.info_outline,
      accent: AppColors.subtleText,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final look = _look();

    return GlassCard(
      borderColor: look.accent.withValues(alpha: 0.3),
      borderRadius: AppRadii.lg,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(look.icon, color: look.accent, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.label.copyWith(
                  color: tokens.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
