import 'package:flutter/material.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_type_display.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/section_label.dart';

/// Compares this holding's real share of the portfolio against its asset
/// type's target allocation range — a transparent heuristic, not an
/// invented "AI rating" (see `AssetDetailsSheet`'s original doc comment,
/// which this card is ported from). Only meaningful for a real [Holding]
/// with a known `portfolioPercent`.
class AllocationSuggestionCard extends StatelessWidget {
  const AllocationSuggestionCard({super.key, required this.holding});

  final Holding holding;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final overweight = holding.portfolioPercent - holding.type.idealTargetPercent;
    final aligned = overweight.abs() <= 5;
    final color = aligned ? tokens.success : tokens.warning;

    final label = aligned
        ? 'Alinhado com a meta da categoria (${holding.type.idealTargetPercent.toStringAsFixed(0)}%).'
        : overweight > 0
            ? 'Categoria acima da meta sugerida (${holding.type.idealTargetPercent.toStringAsFixed(0)}%).'
            : 'Categoria abaixo da meta sugerida (${holding.type.idealTargetPercent.toStringAsFixed(0)}%).';

    return GlassCard(
      backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.55 : 0.94),
      borderColor: color.withValues(alpha: 0.25),
      borderRadius: 18,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('SUGESTÃO DE ALOCAÇÃO'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(overweight > 0 ? Icons.arrow_circle_up : Icons.arrow_circle_down, color: color, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(label, style: TextStyle(color: tokens.textSecondary, fontSize: 11))),
                  Text(
                    '${holding.portfolioPercent.toStringAsFixed(0)}%',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
