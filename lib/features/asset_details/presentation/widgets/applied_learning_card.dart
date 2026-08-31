import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/asset_details/domain/entities/applied_concept.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/indicator_education_sheet.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/section_label.dart';

/// "Apply what you learned" — the Academy → Portfolio bridge
/// (`docs/ACADEMY_ENGINE.md`'s Educational Portfolio Intelligence section,
/// `docs/PRODUCT_VISION.md` §10). Shown only when [appliedConcepts] is
/// non-empty, i.e. the user has actually completed a lesson that teaches a
/// concept this specific asset actually has a real value for — never
/// fabricated, never a buy/sell signal, purely "here's that concept you
/// learned, applied to something real."
class AppliedLearningCard extends StatelessWidget {
  const AppliedLearningCard({
    super.key,
    required this.asset,
    required this.appliedConcepts,
  });

  final AssetDetails asset;
  final List<AppliedConcept> appliedConcepts;

  @override
  Widget build(BuildContext context) {
    if (appliedConcepts.isEmpty) return const SizedBox.shrink();

    final tokens = context.colors;
    return GlassCard(
      backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.55 : 0.94),
      borderColor: AppColors.neonPurple.withValues(alpha: 0.3),
      borderRadius: 18,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school_outlined, color: AppColors.neonPurple, size: 16),
                const SizedBox(width: 6),
                const SectionLabel('APLIQUE O QUE VOCÊ APRENDEU'),
              ],
            ),
            const SizedBox(height: 12),
            for (int i = 0; i < appliedConcepts.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _AppliedConceptTile(asset: asset, applied: appliedConcepts[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _AppliedConceptTile extends StatelessWidget {
  const _AppliedConceptTile({required this.asset, required this.applied});

  final AssetDetails asset;
  final AppliedConcept applied;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          HapticFeedback.selectionClick();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => IndicatorEducationSheet(indicator: applied.indicator),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: tokens.textPrimary.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.neonPurple.withValues(alpha: 0.15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Você aprendeu sobre ${applied.indicator.label} em "${applied.lessonTitle}" — '
                      'veja como isso aparece em ${asset.displayName} hoje:',
                      style: TextStyle(color: tokens.textSecondary, fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          applied.indicator.label,
                          style: TextStyle(color: tokens.textSecondary, fontSize: 11),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          applied.indicator.value ?? '--',
                          style: TextStyle(
                            color: tokens.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      applied.explanation.whyItMatters,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: tokens.textTertiary, fontSize: 11, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: AppColors.neonPurple.withValues(alpha: 0.6), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
