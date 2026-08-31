import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/asset_details/domain/services/indicator_education_catalog.dart';

/// Pet teacher interaction zone — the pet is contextually aware of which
/// asset the user is viewing and offers educational suggestions.
/// Integrates with the existing Character Engine concept.
class PetTeacherWidget extends StatelessWidget {
  const PetTeacherWidget({super.key, required this.asset});

  final AssetDetails asset;

  @override
  Widget build(BuildContext context) {
    final questions = IndicatorEducationCatalog.suggestedQuestions(asset);

    return GlassCard(
      backgroundColor: AppColors.neonCyan.withValues(alpha: 0.04),
      borderColor: AppColors.neonCyan.withValues(alpha: 0.15),
      borderRadius: 20,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Pet header ──────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neonCyan.withValues(alpha: 0.1),
                    border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.pets, color: AppColors.neonCyan, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seu Companheiro',
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        _petGreeting(),
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Suggested questions ─────────────────────────────
            Text(
              Translator.translate(AppStrings.petTeacherAskMentor),
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: questions.take(5).map((q) => _QuestionChip(question: q)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _petGreeting() {
    final params = {'assetName': asset.displayName};
    if (asset.isOwned) {
      return Translator.translate(AppStrings.petTeacherOwnedGreeting, params: params);
    }
    return Translator.translate(AppStrings.petTeacherNotOwnedGreeting, params: params);
  }
}

class _QuestionChip extends StatelessWidget {
  const _QuestionChip({required this.question});

  final String question;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // TODO: Navigate to mentor chat with pre-filled question
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pergunta enviada ao mentor: "$question"'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.neonCyan.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.2)),
          ),
          child: Text(
            question,
            style: TextStyle(
              color: AppColors.neonCyan,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}
