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
import 'package:petrimonium/features/portfolio/domain/entities/dividend_event.dart';
import 'package:petrimonium/core/utils/formatters.dart';

class _MonthlyProventos {
  const _MonthlyProventos({required this.month, required this.received, required this.expected});

  final DateTime month;
  final double received;
  final double expected;

  double get total => received + expected;
}

/// "Evolução de Proventos" — monthly stacked bars over the trailing 12
/// months: the darker segment is what's already been paid ([DividendRadar
/// .history]), the lighter segment on top is what's still expected
/// ([DividendRadar.upcoming]) — mirroring the reference design.
class ProventosEvolutionBarCard extends StatefulWidget {
  const ProventosEvolutionBarCard({super.key, required this.radar});

  final DividendRadar radar;

  @override
  State<ProventosEvolutionBarCard> createState() => _ProventosEvolutionBarCardState();
}

class _ProventosEvolutionBarCardState extends State<ProventosEvolutionBarCard> {
  int? _touchedIndex;

  DateTime? _dateOf(DividendEvent event) => event.paymentDate ?? event.dataCom ?? event.approvedOn;

  List<_MonthlyProventos> _last12Months() {
    final now = DateTime.now();
    final months = List.generate(12, (i) => DateTime(now.year, now.month - 11 + i, 1));

    final received = <String, double>{};
    final expected = <String, double>{};

    for (final event in widget.radar.history) {
      final date = _dateOf(event);
      if (date == null) continue;
      final key = '${date.year}-${date.month}';
      received[key] = (received[key] ?? 0) + event.estimatedGrossAmount;
    }
    for (final event in widget.radar.upcoming) {
      final date = _dateOf(event);
      if (date == null) continue;
      final key = '${date.year}-${date.month}';
      expected[key] = (expected[key] ?? 0) + event.estimatedGrossAmount;
    }

    return months.map((month) {
      final key = '${month.year}-${month.month}';
      return _MonthlyProventos(month: month, received: received[key] ?? 0, expected: expected[key] ?? 0);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final months = _last12Months();
    final hasData = months.any((m) => m.total > 0);

    return GlassCard(
      backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.62 : 0.94),
      borderColor: AppColors.neonBlue.withValues(alpha: 0.3),
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
                    'Evolução de Proventos',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyEmphasis.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ChartLegend(items: [
                  ChartLegendItem(color: AppColors.neonBlue, label: Translator.translate(AppStrings.proventosLegendReceived)),
                  ChartLegendItem(
                    color: AppColors.neonBlue.withValues(alpha: 0.35),
                    label: Translator.translate(AppStrings.proventosLegendExpected),
                  ),
                ]),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 220,
              child: !hasData
                  ? Center(
                      child: Text(
                        'Sem proventos registrados ainda.',
                        style: AppTextStyles.label.copyWith(color: tokens.textSecondary),
                      ),
                    )
                  : BarChart(
                      _buildChartData(months, tokens),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                    ),
            ),
            if (_touchedIndex != null && _touchedIndex! < months.length) ...[
              const SizedBox(height: AppSpacing.md),
              _buildTooltip(months[_touchedIndex!], tokens),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTooltip(_MonthlyProventos month, AppColorTokens tokens) {
    return TooltipSummary(
      accentColor: AppColors.neonBlue,
      children: [
        Text(
          '${month.month.month.toString().padLeft(2, '0')}/${month.month.year}',
          style: AppTextStyles.caption.copyWith(color: tokens.textSecondary),
        ),
        Text(
          'Recebido: ${AppFormatters.currency(month.received, showCents: false)}',
          style: AppTextStyles.label.copyWith(color: AppColors.neonBlue, fontWeight: FontWeight.bold),
        ),
        Text(
          'A receber: ${AppFormatters.currency(month.expected, showCents: false)}',
          style: AppTextStyles.label.copyWith(color: tokens.textSecondary, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  BarChartData _buildChartData(List<_MonthlyProventos> months, AppColorTokens tokens) {
    final receivedColor = AppColors.neonBlue;
    final expectedColor = AppColors.neonBlue.withValues(alpha: 0.35);

    var maxY = 0.0;
    for (final month in months) {
      if (month.total > maxY) maxY = month.total;
    }
    if (maxY == 0) maxY = 1;
    maxY += maxY * 0.15;

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      minY: 0,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
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
            interval: maxY / 4,
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
              if (index < 0 || index >= months.length) return const SizedBox.shrink();
              final date = months[index].month;
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
        for (var i = 0; i < months.length; i++)
          BarChartGroupData(
            x: i,
            barRods: [_rodFor(months[i], i, receivedColor, expectedColor)],
          ),
      ],
    );
  }

  BarChartRodData _rodFor(_MonthlyProventos month, int index, Color receivedColor, Color expectedColor) {
    final highlighted = index == _touchedIndex;
    return BarChartRodData(
      toY: month.total,
      fromY: 0,
      width: 18,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      rodStackItems: [
        BarChartRodStackItem(0, month.received, receivedColor.withValues(alpha: highlighted ? 1 : 0.9)),
        BarChartRodStackItem(month.received, month.total, expectedColor.withValues(alpha: highlighted ? 0.7 : 0.55)),
      ],
    );
  }
}

