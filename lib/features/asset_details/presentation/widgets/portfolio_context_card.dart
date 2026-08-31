import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/section_label.dart';

/// Shows how this asset fits into the user's portfolio — the main
/// differentiator between Invest Game and generic financial platforms.
class PortfolioContextCard extends StatelessWidget {
  const PortfolioContextCard({super.key, required this.asset});

  final AssetDetails asset;

  @override
  Widget build(BuildContext context) {
    final pos = asset.userPosition;
    if (pos == null) return const SizedBox.shrink();

    final typeLabel = switch (asset.assetType) {
      'fii' => 'FIIs',
      'etf' => 'ETFs',
      'bdr' => 'BDRs',
      'stock' => 'ações',
      _ => 'ativos',
    };

    return GlassCard(
      backgroundColor: context.colors.surface.withValues(alpha: context.isDarkMode ? 0.55 : 0.94),
      borderColor: AppColors.neonBlue.withValues(alpha: 0.2),
      borderRadius: 18,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('NA SUA CARTEIRA'),
            const SizedBox(height: 12),

            _ContextLine(
              icon: Icons.pie_chart_outline,
              text: '${asset.displayName} representa '
                  '${pos.portfolioWeight.toStringAsFixed(1)}% do seu portfólio total.',
            ),
            const SizedBox(height: 8),

            _ContextLine(
              icon: Icons.category_outlined,
              text: 'Categoria: $typeLabel.',
            ),

            if (asset.sector != null) ...[
              const SizedBox(height: 8),
              _ContextLine(
                icon: Icons.business_outlined,
                text: 'Setor: ${asset.sector}.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContextLine extends StatelessWidget {
  const _ContextLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.neonBlue, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: context.colors.textSecondary, fontSize: 12, height: 1.4),
          ),
        ),
      ],
    );
  }
}
