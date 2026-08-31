import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_recommendation.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';

/// "What should I do next" (`docs/ACADEMY_ENGINE.md` §3d, brief §20/22) —
/// up to two reason-annotated suggestions from
/// `AcademyController.recommendations`: continuing the learning path, and
/// (when relevant) reviewing a lesson that wasn't answered perfectly.
/// Deliberately below `AcademyContinueCard`, not competing with it — that
/// card remains the screen's single primary CTA
/// (`docs/ACADEMY_ENGINE.md` §5), this section is secondary guidance.
class RecommendedForYouSection extends StatelessWidget {
  const RecommendedForYouSection({super.key, required this.recommendations, required this.onTapLesson});

  final List<AcademyRecommendation> recommendations;
  final void Function(Lesson lesson) onTapLesson;

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) return const SizedBox.shrink();
    final tokens = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Translator.translate(AppStrings.academyRecommendedSectionLabel),
          style: TextStyle(color: tokens.primary.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2),
        ),
        const SizedBox(height: 10),
        for (final recommendation in recommendations) ...[
          _RecommendationCard(recommendation: recommendation, onTap: () => onTapLesson(recommendation.lesson)),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.recommendation, required this.onTap});

  final AcademyRecommendation recommendation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final isReview = recommendation.type == RecommendationType.review;
    final accent = isReview ? AppColors.neonBlue : AppColors.neonCyan;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: GlassCard(
        borderColor: accent.withValues(alpha: 0.3),
        borderRadius: 16,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(color: accent.withValues(alpha: 0.14), shape: BoxShape.circle),
                child: Icon(isReview ? Icons.refresh_rounded : Icons.arrow_forward_rounded, color: accent, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.lesson.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Translator.translate(recommendation.reasonKey, params: recommendation.reasonParams),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: tokens.textTertiary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: tokens.textTertiary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
