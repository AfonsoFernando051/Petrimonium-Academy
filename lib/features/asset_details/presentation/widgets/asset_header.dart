import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_radii.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/core/utils/formatters.dart';

/// The top section of the asset details screen — immediately communicates
/// what asset the user is viewing, its current price, and movement.
class AssetHeader extends StatelessWidget {
  const AssetHeader({super.key, required this.asset});

  final AssetDetails asset;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final isPositive = (asset.dailyChangePercent ?? 0) >= 0;
    final changeColor = isPositive ? tokens.success : tokens.error;

    return GlassCard(
      backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.6 : 0.94),
      borderColor: AppColors.neonCyan.withValues(alpha: 0.25),
      borderRadius: AppRadii.xl,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Asset type badge + logo ─────────────────────────
            Row(
              children: [
                _AssetTypeBadge(assetType: asset.assetType),
                if (asset.sector != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '· ${asset.sector}',
                    style: AppTextStyles.caption.copyWith(color: tokens.textSecondary),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // ── Name ────────────────────────────────────────────
            Text(
              asset.displayName,
              style: AppTextStyles.bodyEmphasis.copyWith(color: tokens.textPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),

            // ── Price + Change ──────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (asset.currentPrice != null)
                  Text(
                    AppFormatters.currency(asset.currentPrice!),
                    style: AppTextStyles.display.copyWith(color: tokens.textPrimary),
                  )
                else
                  Text(
                    'Preço indisponível',
                    style: AppTextStyles.title.copyWith(color: tokens.textSecondary, fontWeight: FontWeight.normal),
                  ),
                const Spacer(),
                if (asset.dailyChangePercent != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: changeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                      border: Border.all(color: changeColor.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          color: changeColor,
                          size: 20,
                        ),
                        Text(
                          AppFormatters.percent(asset.dailyChangePercent!),
                          style: AppTextStyles.body.copyWith(color: changeColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // ── 52-week range ──────────────────────────────────
            if (asset.fiftyTwoWeekLow != null && asset.fiftyTwoWeekHigh != null) ...[
              const SizedBox(height: 14),
              _FiftyTwoWeekRange(
                low: asset.fiftyTwoWeekLow!,
                high: asset.fiftyTwoWeekHigh!,
                current: asset.currentPrice,
              ),
            ],

            // ── Freshness indicator ────────────────────────────
            if (asset.lastUpdated != null) ...[
              const SizedBox(height: 10),
              Text(
                _formatLastUpdated(asset.lastUpdated!),
                style: AppTextStyles.caption.copyWith(color: tokens.textTertiary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatLastUpdated(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Atualizado agora';
      if (diff.inMinutes < 60) return 'Atualizado há ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Atualizado há ${diff.inHours}h';
      return 'Última atualização: ${AppFormatters.date(dt)}';
    } catch (_) {
      return '';
    }
  }
}

// ── Asset Type Badge ────────────────────────────────────────────────────

class _AssetTypeBadge extends StatelessWidget {
  const _AssetTypeBadge({required this.assetType});

  final String assetType;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (assetType) {
      'stock' => ('Ação', AppColors.neonCyan),
      'fii' => ('FII', AppColors.goldenBorder),
      'etf' => ('ETF', AppColors.neonPurple),
      'bdr' => ('BDR', AppColors.neonBlue),
      _ => ('Ativo', context.colors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ── 52-Week Range Bar ───────────────────────────────────────────────────

class _FiftyTwoWeekRange extends StatelessWidget {
  const _FiftyTwoWeekRange({
    required this.low,
    required this.high,
    this.current,
  });

  final double low;
  final double high;
  final double? current;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final range = high - low;
    final position = (current != null && range > 0) ? ((current! - low) / range).clamp(0.0, 1.0) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '52 sem: ${AppFormatters.currency(low, showCents: false)}',
              style: AppTextStyles.caption.copyWith(color: tokens.textSecondary),
            ),
            const Spacer(),
            Text(
              AppFormatters.currency(high, showCents: false),
              style: AppTextStyles.caption.copyWith(color: tokens.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 4,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: tokens.textPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                if (position != null)
                  FractionallySizedBox(
                    widthFactor: position,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [tokens.error, tokens.warning, tokens.success],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
