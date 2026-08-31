import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/core/widgets/labeled_slider.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_investment_type_labels.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_type_display.dart';

/// A hypothetical-portfolio composition editor — one [LabeledSlider] per
/// [InvestmentTypeEnum] category (reusing its theme-invariant `.icon`/
/// `.color`, never its pt-only `.label`), plus a persistent total that
/// reports whether the allocation is currently valid. Shared by the
/// Diversification and Portfolio simulators. **Never silently normalizes**
/// — it reports [DiversificationCalculator.isValid]-style state upward via
/// [isValid]/[totalPercent] and leaves the host screen to decide what to
/// disable (`docs/DECISIONS.md` DECISION-037).
class LabAllocationEditor extends StatelessWidget {
  const LabAllocationEditor({
    super.key,
    required this.weightsPercent,
    required this.onChanged,
    required this.totalPercent,
    required this.isValid,
  });

  final Map<InvestmentTypeEnum, double> weightsPercent;
  final void Function(InvestmentTypeEnum type, double value) onChanged;
  final double totalPercent;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;

    return GlassCard(
      borderRadius: AppRadii.xl,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.md,
          children: [
            for (final entry in weightsPercent.entries)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 8, top: 18),
                    decoration: BoxDecoration(
                      color: entry.key.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: LabeledSlider(
                      label: entry.key.labLabel,
                      valueLabel: '${entry.value.round()}%',
                      value: entry.value,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      onChanged: (v) => onChanged(entry.key, v.roundToDouble()),
                    ),
                  ),
                ],
              ),
            _totalIndicator(tokens),
            Text(
              Translator.translate(AppStrings.labAllocationHint),
              style: AppTextStyles.caption.copyWith(color: tokens.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalIndicator(AppColorTokens tokens) {
    final color = isValid ? tokens.success : tokens.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isValid ? Icons.check_circle_outline : Icons.error_outline,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '${Translator.translate(AppStrings.labAllocationTotalLabel)}: '
            '${totalPercent.round()}%',
            style: AppTextStyles.label.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
