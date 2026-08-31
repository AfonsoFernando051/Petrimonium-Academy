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
import 'package:petrimonium/features/portfolio/domain/entities/history_point.dart';
import 'package:petrimonium/features/portfolio/presentation/controllers/portfolio_controller.dart';
import 'package:petrimonium/core/utils/formatters.dart';

/// The "Wealth Evolution" chart as monthly stacked bars — invested capital
/// (base) plus capital gain/loss (top segment) per month — mirroring the
/// reference "Evolução do Patrimônio" design. Buckets [PortfolioController]'s
/// existing `chartPoints` (whatever range/asset filter is selected there) by
/// calendar month, taking each month's most recent sample.
class WealthEvolutionBarCard extends StatefulWidget {
  const WealthEvolutionBarCard({super.key, required this.controller});

  final PortfolioController controller;

  @override
  State<WealthEvolutionBarCard> createState() => _WealthEvolutionBarCardState();
}

class _WealthEvolutionBarCardState extends State<WealthEvolutionBarCard> {
  int? _touchedIndex;

  List<HistoryPoint> _monthlyBuckets(List<HistoryPoint> points) {
    final byMonth = <String, HistoryPoint>{};
    for (final point in points) {
      final key = '${point.date.year}-${point.date.month}';
      byMonth[key] = point;
    }
    final entries = byMonth.entries.toList()
      ..sort((a, b) => a.value.date.compareTo(b.value.date));
    return entries.map((e) => e.value).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final buckets = _monthlyBuckets(widget.controller.chartPoints);

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
                    'Evolução do Patrimônio',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyEmphasis.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ChartLegend(items: [
                  ChartLegendItem(color: tokens.chartPositive, label: Translator.translate(AppStrings.wealthLegendAppliedValue)),
                  ChartLegendItem(
                    color: tokens.chartPositive.withValues(alpha: 0.45),
                    label: Translator.translate(AppStrings.wealthLegendCapitalGain),
                  ),
                ]),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 220,
              child: buckets.length < 2
                  ? Center(
                      child: Text(
                        'Sem dados suficientes para este período.',
                        style: AppTextStyles.label.copyWith(color: tokens.textSecondary),
                      ),
                    )
                  : BarChart(
                      _buildChartData(buckets, tokens),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                    ),
            ),
            if (_touchedIndex != null && _touchedIndex! < buckets.length) ...[
              const SizedBox(height: AppSpacing.md),
              _buildTooltip(buckets[_touchedIndex!], tokens),
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
          '${point.date.month.toString().padLeft(2, '0')}/${point.date.year}',
          style: AppTextStyles.caption.copyWith(color: tokens.textSecondary),
        ),
        Text(
          AppFormatters.currency(point.investedCapital, showCents: false),
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

  BarChartData _buildChartData(List<HistoryPoint> buckets, AppColorTokens tokens) {
    final investedColor = tokens.chartPositive;
    final gainColor = tokens.chartPositive.withValues(alpha: 0.45);
    final lossColor = tokens.chartNegative.withValues(alpha: 0.7);

    var minY = 0.0;
    var maxY = 0.0;
    for (final point in buckets) {
      if (point.portfolioValue > maxY) maxY = point.portfolioValue;
      if (point.investedCapital > maxY) maxY = point.investedCapital;
      if (point.portfolioValue < minY) minY = point.portfolioValue;
    }
    final pad = maxY == 0 ? 1.0 : maxY * 0.15;
    maxY += pad;
    if (minY < 0) minY -= pad;

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      minY: minY,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY - minY) / 4,
        getDrawingHorizontalLine: (_) => FlLine(color: tokens.divider, strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        show: true,
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 52,
            interval: (maxY - minY) / 4,
            getTitlesWidget: (value, meta) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                AppFormatters.compactCurrency(value),
                style: TextStyle(color: tokens.textSecondary, fontSize: 9),
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= buckets.length) return const SizedBox.shrink();
              final date = buckets[index].date;
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${date.month.toString().padLeft(2, '0')}/${(date.year % 100).toString().padLeft(2, '0')}',
                  style: TextStyle(color: tokens.textSecondary, fontSize: 9),
                ),
              );
            },
          ),
        ),
      ),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(getTooltipItem: (a, b, c, d) => null),
        touchCallback: (event, response) {
          if (!event.isInterestedForInteractions || response == null || response.spot == null) {
            if (event is FlTapUpEvent || event is FlPanEndEvent || event is FlLongPressEnd) {
              setState(() => _touchedIndex = null);
            }
            return;
          }
          HapticFeedback.selectionClick();
          setState(() => _touchedIndex = response.spot!.touchedBarGroupIndex);
        },
      ),
      barGroups: [
        for (var i = 0; i < buckets.length; i++)
          BarChartGroupData(
            x: i,
            barRods: [
              _rodFor(buckets[i], i, investedColor, gainColor, lossColor),
            ],
          ),
      ],
    );
  }

  BarChartRodData _rodFor(HistoryPoint point, int index, Color investedColor, Color gainColor, Color lossColor) {
    final invested = point.investedCapital;
    final value = point.portfolioValue;
    final lower = invested < value ? invested : value;
    final upper = invested < value ? value : invested;
    final gainSegmentColor = value >= invested ? gainColor : lossColor;
    final highlighted = index == _touchedIndex;

    return BarChartRodData(
      toY: upper,
      fromY: 0,
      width: 18,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      rodStackItems: [
        BarChartRodStackItem(0, lower, investedColor.withValues(alpha: highlighted ? 1 : 0.85)),
        BarChartRodStackItem(lower, upper, gainSegmentColor.withValues(alpha: highlighted ? 1 : 0.85)),
      ],
    );
  }
}

