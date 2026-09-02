import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/pet/presentation/companion/rive/pet_rive_companion.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// The lesson's reward moment — the player's own pet (not a generic trophy)
/// celebrating, with a green "learning progress" pill rather than the app's
/// gold reward color: this is XP for learning, deliberately decoupled from
/// the gold used for financial/portfolio achievements elsewhere, per the
/// "gamification never mixes with wealth" guardrail.
class LessonCompleteCard extends StatelessWidget {
  const LessonCompleteCard({
    super.key,
    required this.lessonTitle,
    required this.xpEarned,
    required this.mascotController,
    required this.onContinue,
    required this.onBackToAcademy,
  });

  final String lessonTitle;
  final int xpEarned;
  final MascotController mascotController;
  final VoidCallback onContinue;
  final VoidCallback onBackToAcademy;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return GlassCard(
      backgroundColor: tokens.surfaceElevated.withValues(alpha: context.isDarkMode ? 0.85 : 0.96),
      borderColor: tokens.success.withValues(alpha: 0.6),
      borderRadius: 24,
      boxShadow: [
        BoxShadow(color: tokens.success.withValues(alpha: 0.25), blurRadius: 28, spreadRadius: 2),
      ],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: PetRiveCompanion(controller: mascotController, size: 64, interactive: false),
            ),
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
                color: tokens.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                Translator.translate(AppStrings.academyLearningProgressPill, params: {'xp': '$xpEarned'}),
                style: TextStyle(color: tokens.success, fontWeight: FontWeight.bold, fontSize: 15),
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
