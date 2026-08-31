import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_type_display.dart';
import 'package:petrimonium/features/portfolio/domain/enums/history_range.dart';
import 'package:petrimonium/features/portfolio/domain/services/wealth_history_calculator.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/section_label.dart';

/// A held position's own cost-basis → current-value trend line — ported
/// from the old `AssetDetailsSheet` into the canonical full-screen asset
/// page as part of consolidating the two competing asset-detail
/// implementations into one. Deliberately chart-only: the Sheet's
/// accompanying invested/current/average-price stats already live on
/// [UserPositionCard] and current price on [AssetHeader], so repeating them
/// here would just be the same numbers twice. Renders nothing until there
/// are at least two points to draw a line between — a single point isn't a
/// trend, and a real [Holding] (with purchase lots) is required, since the
/// plain `AssetDetails` entity from the backend has no per-lot data.
class AssetValuationChartCard extends StatelessWidget {
  const AssetValuationChartCard({super.key, required this.holding});

  final Holding holding;

  @override
  Widget build(BuildContext context) {
    final chartPoints = WealthHistoryCalculator.compute(holding.lots, HistoryRange.all);
    if (chartPoints.length < 2) return const SizedBox.shrink();

    final tokens = context.colors;
    return GlassCard(
      backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.55 : 0.94),
      borderColor: holding.type.color.withValues(alpha: 0.25),
      borderRadius: 18,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('EVOLUÇÃO DA POSIÇÃO'),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineTouchData: const LineTouchData(enabled: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [for (var i = 0; i < chartPoints.length; i++) FlSpot(i.toDouble(), chartPoints[i].portfolioValue)],
                      isCurved: true,
                      color: holding.type.color,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: holding.type.color.withValues(alpha: 0.15)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
