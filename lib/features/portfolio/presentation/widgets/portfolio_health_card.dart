import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_health.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/section_label.dart';

/// The RPG-inspired "Portfolio Health" panel: an overall 0-100 score/grade,
/// a radar chart across six facets, and per-facet animated progress bars.
class PortfolioHealthCard extends StatelessWidget {
  const PortfolioHealthCard({super.key, required this.health});

  final PortfolioHealth health;

  Color _scoreColor(BuildContext context) => _colorForTier(health.tier, context);

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return GlassCard(
      backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.68 : 0.94),
      borderColor: AppColors.neonViolet.withValues(alpha: 0.35),
      borderRadius: 20,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionLabel('SAÚDE DO PORTFÓLIO'),
                _ScoreBadge(score: health.overallScore, grade: health.grade, color: _scoreColor(context)),
              ],
            ),
            const SizedBox(height: 12),
            if (health.metrics.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'Invista em ao menos um ativo para revelar sua saúde de portfólio.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: tokens.textSecondary, fontSize: 12),
                  ),
                ),
              )
            else ...[
              SizedBox(
                height: 190,
                child: RadarChart(
                  RadarChartData(
                    tickCount: 4,
                    ticksTextStyle: const TextStyle(fontSize: 0, color: Colors.transparent),
                    titlePositionPercentageOffset: 0.18,
                    radarBorderData: BorderSide(color: tokens.divider),
                    gridBorderData: BorderSide(color: tokens.divider, width: 1),
                    radarShape: RadarShape.polygon,
                    titleTextStyle: TextStyle(color: tokens.textPrimary, fontSize: 10),
                    getTitle: (index, angle) => RadarChartTitle(
                      text: index < health.metrics.length ? _shortName(health.metrics[index].name) : '',
                    ),
                    dataSets: [
                      RadarDataSet(
                        fillColor: AppColors.neonCyan.withValues(alpha: 0.25),
                        borderColor: AppColors.neonCyan,
                        entryRadius: 2,
                        borderWidth: 2,
                        dataEntries: [for (final m in health.metrics) RadarEntry(value: m.score)],
                      ),
                    ],
                  ),
                  duration: const Duration(milliseconds: 600),
                ),
              ),
              const SizedBox(height: 8),
              for (final metric in health.metrics) _MetricBar(metric: metric),
            ],
          ],
        ),
      ),
    );
  }

  String _shortName(String name) => name.length > 10 ? '${name.substring(0, 9)}…' : name;
}

/// Shared by [PortfolioHealthCard] (overall score) and [_MetricBar] (per-facet
/// score) — both read a computed [HealthTier] rather than re-deriving it from
/// a raw score, so only the tier→color mapping (a presentation concern)
/// lives here; the score→tier thresholds live on the domain entities.
Color _colorForTier(HealthTier tier, BuildContext context) {
  final tokens = context.colors;
  return switch (tier) {
    HealthTier.strong => tokens.success,
    HealthTier.moderate => AppColors.goldenBorder,
    HealthTier.weak => tokens.error,
  };
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score, required this.grade, required this.color});

  final double score;
  final String grade;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.6)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 1)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(grade, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            score.toStringAsFixed(0),
            style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({required this.metric});

  final HealthMetric metric;

  Color _color(BuildContext context) => _colorForTier(metric.tier, context);

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final color = _color(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(metric.icon, size: 14, color: AppColors.neonCyan),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(metric.name, style: TextStyle(color: tokens.textSecondary, fontSize: 11)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  Container(height: 6, color: tokens.textTertiary.withValues(alpha: 0.18)),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: metric.score / 100),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => FractionallySizedBox(
                      widthFactor: value.clamp(0.0, 1.0),
                      child: Container(height: 6, color: color),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            child: Text(
              metric.score.toStringAsFixed(0),
              textAlign: TextAlign.end,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
