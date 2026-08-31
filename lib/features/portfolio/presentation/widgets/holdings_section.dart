import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/empty_state_view.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/expandable_category.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/section_label.dart';

/// Groups holdings by category (Investidor10-inspired usability): each
/// category is collapsible and shows aggregate stats in its header.
class HoldingsSection extends StatelessWidget {
  const HoldingsSection({super.key, required this.holdings, required this.totalPortfolioValue});

  final List<Holding> holdings;
  final double totalPortfolioValue;

  @override
  Widget build(BuildContext context) {
    final byType = <InvestmentTypeEnum, List<Holding>>{};
    for (final holding in holdings) {
      byType.putIfAbsent(holding.type, () => []).add(holding);
    }
    final sortedTypes = byType.keys.toList()
      ..sort((a, b) => byType[b]!.fold<double>(0, (s, h) => s + h.currentValue)
          .compareTo(byType[a]!.fold<double>(0, (s, h) => s + h.currentValue)));

    return GlassCard(
      backgroundColor: context.colors.surface.withValues(alpha: context.isDarkMode ? 0.55 : 0.94),
      borderColor: AppColors.neonCyan.withValues(alpha: 0.2),
      borderRadius: 20,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('MEUS ATIVOS'),
            const SizedBox(height: 12),
            if (holdings.isEmpty)
              EmptyStateView(
                icon: Icons.inventory_2_outlined,
                message: Translator.translate(AppStrings.noAssetsRegisteredYet),
                style: EmptyStateStyle.compact,
              )
            else
              for (var i = 0; i < sortedTypes.length; i++)
                ExpandableCategory(
                  type: sortedTypes[i],
                  holdings: byType[sortedTypes[i]]!,
                  totalPortfolioValue: totalPortfolioValue,
                  initiallyExpanded: i == 0,
                ),
          ],
        ),
      ),
    );
  }
}
