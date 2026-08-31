import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Tiny inline trend line used inside hero summary cards. Purely decorative
/// context (shape of the trend), not meant to carry axis labels or tooltips.
class MiniSparkline extends StatelessWidget {
  const MiniSparkline({super.key, required this.values, required this.color, this.height = 32});

  final List<double> values;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) return SizedBox(height: height);

    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final pad = (maxY - minY) * 0.1 + 0.01;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minY: minY - pad,
          maxY: maxY + pad,
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: [for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])],
              isCurved: true,
              color: color,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.14)),
            ),
          ],
        ),
      ),
    );
  }
}
