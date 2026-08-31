import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/domain/entities/knowledge_level.dart';
import 'package:petrimonium/features/academy/domain/services/knowledge_progress_calculator.dart';

/// `AcademyHomeScreen`'s top-of-screen status line: Game Level + XP earned,
/// plus Knowledge Progress underneath. Kept deliberately visually distinct
/// from Game Level (no icon circle, secondary color) — Knowledge Progress
/// must never read as the same kind of number (PRODUCT_VISION.md §9).
///
/// Deliberately chrome-free (no card/border/glow) — this is status text, not
/// a decision point, and `AcademyContinueCard` right below it is meant to be
/// the one bordered/glowing surface the user's eye lands on first. See the
/// signal-hierarchy audit that motivated this: five same-weight bordered
/// cards were stacked above the module list with no clear winner.
class AcademyLevelHeader extends StatelessWidget {
  const AcademyLevelHeader({super.key, required this.level, required this.totalXpEarned, required this.knowledgeLevel});

  final int level;
  final int totalXpEarned;
  final KnowledgeLevel knowledgeLevel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonCyan.withValues(alpha: 0.12),
                border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4), width: 1.5),
              ),
              child: const Icon(Icons.school_outlined, color: AppColors.neonCyan, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Translator.translate(AppStrings.academyLevelLabel, params: {'level': '$level'}),
                    style: AppTextStyles.bodyEmphasis.copyWith(color: tokens.textPrimary),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    Translator.translate(AppStrings.academyXpEarnedLabel, params: {'xp': '$totalXpEarned'}),
                    style: AppTextStyles.caption.copyWith(color: tokens.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Icon(Icons.psychology_alt_outlined, color: AppColors.goldenBorder.withValues(alpha: 0.8), size: 15),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                Translator.translate(
                  AppStrings.academyKnowledgeLevelLabel,
                  params: {'tier': KnowledgeProgressCalculator.labelFor(knowledgeLevel)},
                ),
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(color: tokens.textTertiary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
