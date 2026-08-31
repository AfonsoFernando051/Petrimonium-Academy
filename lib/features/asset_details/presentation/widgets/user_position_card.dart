import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/core/utils/formatters.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/section_label.dart';

/// Displays the user's personal position in the asset — clearly separated
/// from market-wide data. This is one of the key differentiators of Invest
/// Game: the user sees how this asset fits into their own portfolio.
class UserPositionCard extends StatelessWidget {
  const UserPositionCard({super.key, required this.asset});

  final AssetDetails asset;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final pos = asset.userPosition;
    if (pos == null) return const SizedBox.shrink();

    final isPositive = pos.unrealizedGain >= 0;
    final plColor = isPositive ? tokens.success : tokens.error;

    return GlassCard(
      backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.55 : 0.94),
      borderColor: plColor.withValues(alpha: 0.3),
      borderRadius: 18,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('SUA POSIÇÃO'),
            const SizedBox(height: 12),

            // ── Main P/L display ────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppFormatters.currency(pos.currentValue, showCents: false),
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            isPositive ? Icons.trending_up : Icons.trending_down,
                            color: plColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isPositive ? '+' : ''}${AppFormatters.currency(pos.unrealizedGain, showCents: false)}',
                            style: TextStyle(color: plColor, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${AppFormatters.percent(pos.unrealizedGainPercent)})',
                            style: TextStyle(color: plColor, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.neonCyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${pos.portfolioWeight.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'da carteira',
                        style: TextStyle(
                          color: tokens.textSecondary,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(color: tokens.divider, height: 1),
            const SizedBox(height: 12),

            // ── Stats grid ──────────────────────────────────────
            Row(
              children: [
                _Stat(label: 'Cotas', value: pos.quantity.toStringAsFixed(
                    pos.quantity.truncateToDouble() == pos.quantity ? 0 : 2)),
                _Stat(label: 'PM', value: AppFormatters.currency(pos.averagePrice)),
                _Stat(label: 'Investido', value: AppFormatters.currency(pos.investedValue, showCents: false)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: context.colors.textSecondary, fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
