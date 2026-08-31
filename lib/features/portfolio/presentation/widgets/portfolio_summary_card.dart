import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/animated_value.dart';
import 'package:petrimonium/core/utils/formatters.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/mini_sparkline.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/performance_badge.dart';

/// One "Hero Portfolio Summary" card: animated headline value, optional
/// percent badge + sparkline. Sized for a horizontally-scrolling row.
class PortfolioSummaryCard extends StatelessWidget {
  const PortfolioSummaryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    this.subtitle,
    this.percent,
    this.sparkline,
    this.accentColor = AppColors.neonCyan,
    this.width = 168,
  });

  final String title;
  final IconData icon;
  final double value;
  final String? subtitle;
  final double? percent;
  final List<double>? sparkline;
  final Color accentColor;
  final double width;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return SizedBox(
      width: width,
      child: GlassCard(
        backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.6 : 0.94),
        borderColor: accentColor.withValues(alpha: 0.3),
        borderRadius: 18,
        borderWidth: 1,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: accentColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: tokens.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AnimatedValue(
                value: value,
                builder: (context, animated) => Text(
                  AppFormatters.compactCurrency(animated),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: tokens.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 6),
              if (percent != null)
                PerformanceBadge(percent: percent!, compact: true)
              else if (subtitle != null)
                Text(subtitle!, style: TextStyle(color: tokens.textSecondary, fontSize: 11)),
              if (sparkline != null && sparkline!.length >= 2) ...[
                const SizedBox(height: 8),
                MiniSparkline(values: sparkline!, color: accentColor, height: 28),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
