import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';

/// `AcademyHomeScreen`'s "what's next" CTA — always the first thing under
/// the level header when there's a lesson in progress (see
/// `docs/ACADEMY_ENGINE.md` §5: "the answer to 'what should I learn next?'
/// is always on screen").
class AcademyContinueCard extends StatelessWidget {
  const AcademyContinueCard({super.key, required this.lesson, required this.onStart});

  final Lesson lesson;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return GlassCard(
      borderColor: AppColors.goldenBorder.withValues(alpha: 0.4),
      borderRadius: AppRadii.xl,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Translator.translate(AppStrings.academyContinueSectionLabel),
              style: AppTextStyles.caption.copyWith(color: AppColors.goldenBorder, fontWeight: FontWeight.w700, letterSpacing: 2),
            ),
            const SizedBox(height: 6),
            Text(
              lesson.title,
              style: AppTextStyles.titleLarge.copyWith(color: tokens.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              Translator.translate(AppStrings.academyXpToCompleteLabel, params: {'xp': '${lesson.xpReward}'}),
              style: AppTextStyles.label.copyWith(color: tokens.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md + 2),
            GameButton(
              label: Translator.translate(AppStrings.academyStartLessonButton),
              icon: Icons.play_arrow_rounded,
              colors: const [AppColors.neonViolet, AppColors.neonPink],
              pulse: true,
              onPressed: onStart,
            ),
          ],
        ),
      ),
    );
  }
}
