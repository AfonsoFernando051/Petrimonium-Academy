import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';

/// The lesson's reward moment — same visual language as
/// `AchievementCelebrationOverlay` (gold glow `GlassCard`, trophy icon,
/// `+N XP` pill) but rendered inline as the final state of `LessonScreen`
/// rather than a full-screen overlay, since it's the natural end of a
/// screen the user is already on, not an interrupt.
class LessonCompleteCard extends StatelessWidget {
  const LessonCompleteCard({
    super.key,
    required this.lessonTitle,
    required this.xpEarned,
    required this.onContinue,
    required this.onBackToAcademy,
  });

  final String lessonTitle;
  final int xpEarned;
  final VoidCallback onContinue;
  final VoidCallback onBackToAcademy;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return GlassCard(
      backgroundColor: tokens.surfaceElevated.withValues(alpha: context.isDarkMode ? 0.85 : 0.96),
      borderColor: AppColors.goldenBorder.withValues(alpha: 0.7),
      borderRadius: 24,
      boxShadow: [
        BoxShadow(color: AppColors.goldenBorder.withValues(alpha: 0.3), blurRadius: 28, spreadRadius: 2),
      ],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: AppColors.goldenBorder, size: 48),
            const SizedBox(height: 12),
            Text(
              Translator.translate(AppStrings.academyLessonCompleteTitle),
              style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 6),
            Text(
              lessonTitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: tokens.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.goldenBorder.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                Translator.translate(AppStrings.academyXpPill, params: {'xp': '$xpEarned'}),
                style: const TextStyle(color: AppColors.goldenBorder, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            const SizedBox(height: 24),
            GameButton(label: Translator.translate(AppStrings.academyContinueButton), onPressed: onContinue),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onBackToAcademy,
              child: Text(
                Translator.translate(AppStrings.academyBackToAcademyButton),
                style: TextStyle(color: tokens.textSecondary, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
