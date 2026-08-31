import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_indicator.dart';
import 'package:petrimonium/features/asset_details/domain/services/indicator_education_catalog.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/indicator_education_sheet.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/section_label.dart';

/// Displays key indicators adapted to the asset type. Each indicator
/// is tappable — opening an educational bottom sheet that explains
/// what it means and why it matters.
class KeyIndicatorsSection extends StatelessWidget {
  const KeyIndicatorsSection({super.key, required this.asset});

  final AssetDetails asset;

  @override
  Widget build(BuildContext context) {
    final indicators = IndicatorEducationCatalog.buildIndicators(asset);

    if (indicators.isEmpty) {
      return GlassCard(
        backgroundColor: context.colors.surface.withValues(alpha: context.isDarkMode ? 0.55 : 0.94),
        borderColor: context.colors.border,
        borderRadius: 18,
        borderWidth: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('INDICADORES'),
              const SizedBox(height: 12),
              Text(
                'Indicadores não disponíveis para este ativo.',
                style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return GlassCard(
      backgroundColor: context.colors.surface.withValues(alpha: context.isDarkMode ? 0.55 : 0.94),
      borderColor: AppColors.neonPurple.withValues(alpha: 0.2),
      borderRadius: 18,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SectionLabel('INDICADORES'),
                const Spacer(),
                Text(
                  'Toque para entender',
                  style: TextStyle(color: AppColors.neonCyan.withValues(alpha: 0.6), fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: indicators.map((ind) => _IndicatorChip(indicator: ind)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _IndicatorChip extends StatelessWidget {
  const _IndicatorChip({required this.indicator});

  final AssetIndicator indicator;

  @override
  Widget build(BuildContext context) {
    final hasExplanation = IndicatorEducationCatalog.getExplanation(indicator.id) != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: hasExplanation
            ? () {
                HapticFeedback.selectionClick();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => IndicatorEducationSheet(indicator: indicator),
                );
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: context.colors.textPrimary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasExplanation
                  ? AppColors.neonCyan.withValues(alpha: 0.2)
                  : context.colors.textPrimary.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    indicator.label,
                    style: TextStyle(color: context.colors.textSecondary, fontSize: 10),
                  ),
                  if (hasExplanation) ...[
                    const SizedBox(width: 3),
                    Icon(
                      Icons.info_outline,
                      size: 11,
                      color: AppColors.neonCyan.withValues(alpha: 0.5),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                indicator.value ?? '--',
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
