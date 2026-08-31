import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/chart_legend.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/core/widgets/tooltip_summary.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/history_point.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_type_display.dart';
import 'package:petrimonium/features/portfolio/domain/enums/history_range.dart';
import 'package:petrimonium/features/portfolio/presentation/controllers/portfolio_controller.dart';
import 'package:petrimonium/core/utils/formatters.dart';

/// The "Wealth Evolution" premium chart: invested capital vs. portfolio
/// value over a selectable range, with an asset-class filter, drag tooltip
/// and pinch-zoom/pan via [InteractiveViewer].
class WealthEvolutionCard extends StatefulWidget {
  const WealthEvolutionCard({super.key, required this.controller});

  final PortfolioController controller;

  @override
  State<WealthEvolutionCard> createState() => _WealthEvolutionCardState();
}

class _WealthEvolutionCardState extends State<WealthEvolutionCard> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final points = controller.chartPoints;
    final tokens = context.colors;

    return GlassCard(
      backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.62 : 0.94),
      borderColor: AppColors.neonCyan.withValues(alpha: 0.3),
      borderRadius: AppRadii.xl,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Evolução Patrimonial',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyEmphasis.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ChartLegend(items: [
                  ChartLegendItem(color: AppColors.neonCyan, label: Translator.translate(AppStrings.wealthLegendPatrimony)),
                  ChartLegendItem(color: tokens.chartNeutral, label: Translator.translate(AppStrings.wealthLegendInvested)),
                ]),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _RangeSelector(controller: controller),
            const SizedBox(height: AppSpacing.sm),
            _AssetFilterSelector(controller: controller),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 220,
              child: points.length < 2
                  ? Center(
                      child: Text(
                        'Sem dados suficientes para este período.',
                        style: AppTextStyles.label.copyWith(color: tokens.textSecondary),
                      ),
                    )
                  : InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      panEnabled: true,
                      scaleEnabled: true,
                      child: LineChart(
                        _buildChartData(points, tokens),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                      ),
                    ),
            ),
            if (_touchedIndex != null && _touchedIndex! < points.length) ...[
              const SizedBox(height: AppSpacing.md),
              _buildTooltip(points[_touchedIndex!], tokens),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTooltip(HistoryPoint point, AppColorTokens tokens) {
    final profit = point.profit;
    return TooltipSummary(
      accentColor: AppColors.neonCyan,
      children: [
        Text(
          AppFormatters.date(point.date),
          style: AppTextStyles.caption.copyWith(color: tokens.textSecondary),
        ),
        Text(
          AppFormatters.currency(point.portfolioValue, showCents: false),
          style: AppTextStyles.label.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold),
        ),
        Text(
          '${profit >= 0 ? '+' : ''}${AppFormatters.currency(profit, showCents: false)}',
          style: AppTextStyles.label.copyWith(
            color: profit >= 0 ? tokens.chartPositive : tokens.chartNegative,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  LineChartData _buildChartData(List<HistoryPoint> points, AppColorTokens tokens) {
    final investedSpots = <FlSpot>[];
    final valueSpots = <FlSpot>[];
    for (var i = 0; i < points.length; i++) {
      investedSpots.add(FlSpot(i.toDouble(), points[i].investedCapital));
      valueSpots.add(FlSpot(i.toDouble(), points[i].portfolioValue));
    }

    final allY = [...investedSpots.map((s) => s.y), ...valueSpots.map((s) => s.y)];
    final minY = allY.reduce((a, b) => a < b ? a : b);
    final maxY = allY.reduce((a, b) => a > b ? a : b);
    final pad = (maxY - minY) * 0.12 + 1;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY - minY + pad * 2) / 4,
        getDrawingHorizontalLine: (_) => FlLine(color: tokens.divider, strokeWidth: 1),
      ),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minY: minY - pad,
      maxY: maxY + pad,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(getTooltipItems: (_) => []),
        touchCallback: (event, response) {
          if (!event.isInterestedForInteractions ||
              response == null ||
              response.lineBarSpots == null ||
              response.lineBarSpots!.isEmpty) {
            if (event is FlTapUpEvent || event is FlPanEndEvent || event is FlLongPressEnd) {
              setState(() => _touchedIndex = null);
            }
            return;
          }
          HapticFeedback.selectionClick();
          setState(() => _touchedIndex = response.lineBarSpots!.first.x.round());
        },
      ),
      lineBarsData: [
        LineChartBarData(
          spots: investedSpots,
          isCurved: true,
          color: tokens.chartNeutral,
          barWidth: 2,
          isStrokeCapRound: true,
          dashArray: [6, 4],
          dotData: const FlDotData(show: false),
        ),
        LineChartBarData(
          spots: valueSpots,
          isCurved: true,
          gradient: const LinearGradient(colors: [AppColors.neonViolet, AppColors.neonCyan]),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            checkToShowDot: (spot, _) => spot.x.round() == _touchedIndex,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 4,
              color: AppColors.neonCyan,
              strokeWidth: 2,
              strokeColor: tokens.surfaceElevated,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.neonCyan.withValues(alpha: 0.22), AppColors.neonCyan.withValues(alpha: 0.0)],
            ),
          ),
        ),
      ],
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.controller});

  final PortfolioController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: HistoryRange.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final range = HistoryRange.values[i];
          final selected = controller.selectedRange == range;
          return _Chip(
            label: range.label,
            selected: selected,
            onTap: () {
              HapticFeedback.selectionClick();
              controller.setRange(range);
            },
          );
        },
      ),
    );
  }
}

class _AssetFilterSelector extends StatelessWidget {
  const _AssetFilterSelector({required this.controller});

  final PortfolioController controller;

  @override
  Widget build(BuildContext context) {
    final types = InvestmentTypeEnum.values;
    return SizedBox(
      height: 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _Chip(
            label: 'Todos',
            selected: controller.selectedAssetFilter == null,
            accent: AppColors.neonViolet,
            onTap: () {
              HapticFeedback.selectionClick();
              controller.setAssetFilter(null);
            },
          ),
          const SizedBox(width: 6),
          for (final type in types) ...[
            _Chip(
              label: type.shortLabel,
              selected: controller.selectedAssetFilter == type,
              accent: type.color,
              onTap: () {
                HapticFeedback.selectionClick();
                controller.setAssetFilter(type);
              },
            ),
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap, this.accent = AppColors.neonCyan});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.18) : tokens.textTertiary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: selected ? accent.withValues(alpha: 0.7) : tokens.border),
          ),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: selected ? tokens.textPrimary : tokens.textSecondary,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
