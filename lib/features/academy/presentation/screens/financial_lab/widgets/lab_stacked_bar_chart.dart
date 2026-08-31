import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/utils/formatters.dart';
import 'package:petrimonium/core/widgets/chart_legend.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/core/widgets/tooltip_summary.dart';

/// One bar in a [LabStackedBarChart] — [base] is the "principal" portion
/// (contributions/principal), [total] is the full bar height. The stacked
/// "growth" segment is `total - base`.
class LabStackedBarPoint {
  const LabStackedBarPoint({
    required this.xLabel,
    required this.base,
    required this.total,
  });

  final String xLabel;
  final double base;
  final double total;
}

/// The two-color stacked bar chart used by both Compound Interest and Fixed
/// Income (principal/contributions vs. growth/interest over time) —
/// extracted from Compound Interest's private `_buildChart`/`_chartData`/
/// `_tooltip`, generalized over [LabStackedBarPoint] instead of the
/// Compound-Interest-specific `CompoundInterestYearPoint`. Owns its own
/// touch state, so the host screen no longer needs to track it.
class LabStackedBarChart extends StatefulWidget {
  const LabStackedBarChart({
    super.key,
    required this.points,
    required this.baseColor,
    required this.growthColor,
    required this.baseLegendLabel,
    required this.growthLegendLabel,
  });

  final List<LabStackedBarPoint> points;
  final Color baseColor;
  final Color growthColor;
  final String baseLegendLabel;
  final String growthLegendLabel;

  @override
  State<LabStackedBarChart> createState() => _LabStackedBarChartState();
}

class _LabStackedBarChartState extends State<LabStackedBarChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final points = widget.points;

    return GlassCard(
      borderRadius: AppRadii.xl,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChartLegend(
              items: [
                ChartLegendItem(
                  color: widget.baseColor,
                  label: widget.baseLegendLabel,
                ),
                ChartLegendItem(
                  color: widget.growthColor,
                  label: widget.growthLegendLabel,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 200,
              child: points.length < 2
                  ? const SizedBox.shrink()
                  : BarChart(
                      _chartData(points, tokens),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                    ),
            ),
            if (_touchedIndex != null && _touchedIndex! < points.length) ...[
              const SizedBox(height: AppSpacing.md),
              _tooltip(points[_touchedIndex!], tokens),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tooltip(LabStackedBarPoint point, AppColorTokens tokens) {
    final growth = point.total - point.base;
    return TooltipSummary(
      accentColor: widget.baseColor,
      children: [
        Text(
          point.xLabel,
          style: TextStyle(color: tokens.textSecondary, fontSize: 11),
        ),
        Text(
          AppFormatters.currency(point.base, showCents: false),
          style: TextStyle(
            color: widget.baseColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Text(
          '+${AppFormatters.currency(growth, showCents: false)}',
          style: TextStyle(
            color: widget.growthColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  BarChartData _chartData(List<LabStackedBarPoint> points, AppColorTokens tokens) {
    final maxY = points.last.total * 1.15;
    final double safeMaxY = maxY == 0 ? 1 : maxY;

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      minY: 0,
      maxY: safeMaxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: safeMaxY / 4,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: tokens.divider, strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        show: true,
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 48,
            interval: safeMaxY / 4,
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
            reservedSize: 22,
            interval: (points.length / 6).ceilToDouble().clamp(
              1.0,
              double.infinity,
            ),
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= points.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  points[index].xLabel,
                  style: TextStyle(color: tokens.textSecondary, fontSize: 9),
                ),
              );
            },
          ),
        ),
      ),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (a, b, c, d) => null,
        ),
        touchCallback: (event, response) {
          if (!event.isInterestedForInteractions ||
              response == null ||
              response.spot == null) {
            if (event is FlTapUpEvent ||
                event is FlPanEndEvent ||
                event is FlLongPressEnd) {
              setState(() => _touchedIndex = null);
            }
            return;
          }
          HapticFeedback.selectionClick();
          setState(() => _touchedIndex = response.spot!.touchedBarGroupIndex);
        },
      ),
      barGroups: [
        for (var i = 0; i < points.length; i++)
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: points[i].total,
                fromY: 0,
                width: 10,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3),
                ),
                rodStackItems: [
                  BarChartRodStackItem(
                    0,
                    points[i].base,
                    widget.baseColor.withValues(
                      alpha: i == _touchedIndex ? 1 : 0.85,
                    ),
                  ),
                  BarChartRodStackItem(
                    points[i].base,
                    points[i].total,
                    widget.growthColor.withValues(
                      alpha: i == _touchedIndex ? 1 : 0.85,
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
