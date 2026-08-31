import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/utils/translator.dart';

/// "Today's Review" (`docs/ACADEMY_ENGINE.md` §3d, brief §25) — a compact
/// nudge to revisit the lessons in `AcademyController.reviewQueue`
/// (completed but not answered perfectly). Only rendered by the caller when
/// that queue is non-empty — an "all caught up" state isn't worth a card,
/// same convention as `AcademyMasterySection`'s `masterySchools.isNotEmpty`
/// gate. Starting a review replays the single oldest due lesson via the
/// existing `LessonScreen` — no new multi-lesson session type, no XP is
/// re-granted (the backend is the only source of truth for XP; see
/// `LessonSessionController`).
///
/// Deliberately a quieter, secondary-action treatment (tinted row, text
/// action, no border/glow/GameButton) rather than its own bordered CTA card
/// — `AcademyContinueCard` above it is the one primary action this screen
/// should visually push toward; having two full CTA cards competing for the
/// same "what should I do next" attention was the exact problem a signal-
/// hierarchy audit flagged here.
class AcademyReviewCard extends StatelessWidget {
  const AcademyReviewCard({super.key, required this.lessonCount, required this.estimatedMinutes, required this.onStart});

  final int lessonCount;
  final int estimatedMinutes;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onStart,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.neonBlue.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.neonBlue.withValues(alpha: 0.18)),
          ),
          child: Row(
            children: [
              const Icon(Icons.refresh_rounded, color: AppColors.neonBlue, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Translator.translate(AppStrings.academyReviewCardTitle),
                      style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      Translator.translate(
                        AppStrings.academyReviewCardSubtitle,
                        params: {'count': '$lessonCount', 'minutes': '$estimatedMinutes'},
                      ),
                      style: TextStyle(color: tokens.textSecondary, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                Translator.translate(AppStrings.academyReviewStartButton),
                style: const TextStyle(color: AppColors.neonBlue, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.chevron_right, color: AppColors.neonBlue, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
