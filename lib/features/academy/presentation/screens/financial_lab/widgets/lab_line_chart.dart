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

/// One line series in a [LabLineChart] — [dashed] marks a flat reference
/// line (e.g. nominal value that never grows) as visually distinct from the
/// line that actually moves, matching `WealthEvolutionCard`'s dashed
/// "invested capital" vs. solid "portfolio value" convention.
class LabLineSeries {
  const LabLineSeries({
    required this.label,
    required this.color,
    required this.values,
    this.dashed = false,
  });

  final String label;
  final Color color;
  final List<double> values;
  final bool dashed;
}

/// The Inflation simulator's nominal-vs-real-purchasing-power chart —
/// generalized so any simulator needing a multi-series line chart (as
/// opposed to [LabStackedBarChart]'s two-part stacked bars) can reuse it.
class LabLineChart extends StatefulWidget {
  const LabLineChart({
    super.key,
    required this.xLabels,
    required this.series,
    required this.tooltipValueFormatter,
  });

  final List<String> xLabels;
  final List<LabLineSeries> series;
  final String Function(double value) tooltipValueFormatter;

  @override
  State<LabLineChart> createState() => _LabLineChartState();
}

class _LabLineChartState extends State<LabLineChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;

    return GlassCard(
      borderRadius: AppRadii.xl,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChartLegend(
              items: [
                for (final s in widget.series)
                  ChartLegendItem(color: s.color, label: s.label),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 200,
              child: widget.xLabels.length < 2
                  ? const SizedBox.shrink()
                  : LineChart(
                      _chartData(tokens),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                    ),
            ),
            if (_touchedIndex != null &&
                _touchedIndex! < widget.xLabels.length) ...[
              const SizedBox(height: AppSpacing.md),
              _tooltip(tokens),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tooltip(AppColorTokens tokens) {
    final index = _touchedIndex!;
    return TooltipSummary(
      accentColor: widget.series.first.color,
      children: [
        Text(
          widget.xLabels[index],
          style: TextStyle(color: tokens.textSecondary, fontSize: 11),
        ),
        for (final s in widget.series)
          Text(
            widget.tooltipValueFormatter(s.values[index]),
            style: TextStyle(
              color: s.color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  LineChartData _chartData(AppColorTokens tokens) {
    final allY = widget.series.expand((s) => s.values);
    final minY = allY.reduce((a, b) => a < b ? a : b);
    final maxY = allY.reduce((a, b) => a > b ? a : b);
    final pad = (maxY - minY) * 0.12 + (maxY == minY ? 1 : 0);

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY - minY + pad * 2) / 4,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: tokens.divider, strokeWidth: 1),
      ),
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
            interval: (maxY - minY + pad * 2) / 4,
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
            interval: (widget.xLabels.length / 6).ceilToDouble().clamp(
              1.0,
              double.infinity,
            ),
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= widget.xLabels.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  widget.xLabels[index],
                  style: TextStyle(color: tokens.textSecondary, fontSize: 9),
                ),
              );
            },
          ),
        ),
      ),
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
            if (event is FlTapUpEvent ||
                event is FlPanEndEvent ||
                event is FlLongPressEnd) {
              setState(() => _touchedIndex = null);
            }
            return;
          }
          HapticFeedback.selectionClick();
          setState(
            () => _touchedIndex = response.lineBarSpots!.first.x.round(),
          );
        },
      ),
      lineBarsData: [
        for (final s in widget.series)
          LineChartBarData(
            spots: [
              for (var i = 0; i < s.values.length; i++)
                FlSpot(i.toDouble(), s.values[i]),
            ],
            isCurved: !s.dashed,
            color: s.color,
            barWidth: s.dashed ? 2 : 3,
            isStrokeCapRound: true,
            dashArray: s.dashed ? [6, 4] : null,
            dotData: FlDotData(
              show: !s.dashed,
              checkToShowDot: (spot, _) => spot.x.round() == _touchedIndex,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: s.color,
                strokeWidth: 2,
                strokeColor: tokens.surfaceElevated,
              ),
            ),
            belowBarData: s.dashed
                ? BarAreaData(show: false)
                : BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        s.color.withValues(alpha: 0.22),
                        s.color.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
          ),
      ],
    );
  }
}
