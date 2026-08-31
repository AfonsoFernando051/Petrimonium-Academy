import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';

/// `PetConfigurationScreen`'s right panel: what the companion actually is —
/// a description of the relationship ahead, not a stat sheet. No numbers are
/// invented here; the pet has no financial metrics of its own, those belong
/// to the user's portfolio.
class PetPreviewPanel extends StatelessWidget {
  const PetPreviewPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: AppColors.neonCyan.withValues(alpha: 0.3),
      boxShadow: [
        BoxShadow(
          color: AppColors.neonCyan.withValues(alpha: 0.1),
          blurRadius: 15,
          spreadRadius: 2,
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Translator.translate(AppStrings.meetPetPreviewTitle),
              style: AppTextStyles.titleLarge.copyWith(color: context.colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xl),
            _PreviewRow(
              icon: Icons.celebration,
              color: AppColors.goldenBorder,
              label: Translator.translate(AppStrings.meetPetPreviewCelebrate),
            ),
            const SizedBox(height: AppSpacing.lg),
            _PreviewRow(
              icon: Icons.school,
              color: AppColors.neonCyan,
              label: Translator.translate(AppStrings.meetPetPreviewLearn),
            ),
            const SizedBox(height: AppSpacing.lg),
            _PreviewRow(
              icon: Icons.favorite,
              color: AppColors.neonPink,
              label: Translator.translate(AppStrings.meetPetPreviewRemember),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.icon, required this.color, required this.label});

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              label,
              style: AppTextStyles.bodyEmphasis.copyWith(color: context.colors.textSecondary, fontWeight: FontWeight.normal, height: 1.3),
            ),
          ),
        ),
      ],
    );
  }
}
