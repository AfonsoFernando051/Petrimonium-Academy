import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/portfolio/domain/entities/allocation_slice.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_type_display.dart';
import 'package:petrimonium/core/utils/formatters.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/section_label.dart';

/// The "Asset Allocation" premium donut: current vs. ideal target per
/// category, with an animated, touch-reactive legend.
class AssetAllocationCard extends StatefulWidget {
  const AssetAllocationCard({super.key, required this.allocation, required this.totalValue});

  final List<AllocationSlice> allocation;
  final double totalValue;

  @override
  State<AssetAllocationCard> createState() => _AssetAllocationCardState();
}

class _AssetAllocationCardState extends State<AssetAllocationCard> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final slices = [...widget.allocation]..sort((a, b) => b.currentValue.compareTo(a.currentValue));

    return GlassCard(
      backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.62 : 0.94),
      borderColor: AppColors.neonPurple.withValues(alpha: 0.3),
      borderRadius: 20,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('ALOCAÇÃO DE ATIVOS'),
            const SizedBox(height: 16),
            if (slices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(Translator.translate(AppStrings.noAssetsRegisteredYet), style: TextStyle(color: tokens.textSecondary)),
                ),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 42,
                            pieTouchData: PieTouchData(
                              touchCallback: (event, response) {
                                if (!event.isInterestedForInteractions ||
                                    response == null ||
                                    response.touchedSection == null) {
                                  setState(() => _touchedIndex = -1);
                                  return;
                                }
                                HapticFeedback.selectionClick();
                                setState(() => _touchedIndex = response.touchedSection!.touchedSectionIndex);
                              },
                            ),
                            sections: [
                              for (var i = 0; i < slices.length; i++)
                                PieChartSectionData(
                                  value: slices[i].currentValue <= 0 ? 0.0001 : slices[i].currentValue,
                                  color: slices[i].type.color,
                                  title: '',
                                  radius: i == _touchedIndex ? 26 : 20,
                                ),
                            ],
                          ),
                          duration: const Duration(milliseconds: 500),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppFormatters.compactCurrency(widget.totalValue),
                              style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text('total', style: TextStyle(color: tokens.textSecondary, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        for (var i = 0; i < slices.length; i++)
                          _LegendRow(slice: slices[i], highlighted: i == _touchedIndex),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.slice, required this.highlighted});

  final AllocationSlice slice;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final diff = slice.portfolioPercent - slice.type.idealTargetPercent;
    final diffColor = diff.abs() <= 5
        ? tokens.success
        : (diff > 0 ? tokens.warning : tokens.primary);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: highlighted ? slice.type.color.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: slice.type.color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              slice.type.shortLabel,
              style: TextStyle(color: tokens.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${slice.portfolioPercent.toStringAsFixed(0)}%',
            style: TextStyle(color: tokens.textPrimary, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          Text(
            '/ ${slice.type.idealTargetPercent.toStringAsFixed(0)}%',
            style: TextStyle(color: tokens.textSecondary, fontSize: 10),
          ),
          const SizedBox(width: 4),
          Text(
            '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(0)}',
            style: TextStyle(color: diffColor, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
