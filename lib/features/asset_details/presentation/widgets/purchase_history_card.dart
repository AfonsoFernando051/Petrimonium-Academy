import 'package:flutter/material.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_lot.dart';
import 'package:petrimonium/core/utils/formatters.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/section_label.dart';

/// One row per purchase lot, most recent first — ported from the old
/// `AssetDetailsSheet` as part of consolidating asset details into one
/// canonical, full-screen implementation. Only rendered for a real
/// [Holding] (with lots), same constraint as [AssetValuationChartCard].
class PurchaseHistoryCard extends StatelessWidget {
  const PurchaseHistoryCard({super.key, required this.holding});

  final Holding holding;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;

    return GlassCard(
      backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.55 : 0.94),
      borderColor: tokens.border,
      borderRadius: 18,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('HISTÓRICO DE COMPRAS'),
            const SizedBox(height: 8),
            for (final lot in holding.lots.reversed) _LotTile(lot: lot),
          ],
        ),
      ),
    );
  }
}

class _LotTile extends StatelessWidget {
  const _LotTile({required this.lot});

  final InvestmentLot lot;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.shopping_cart_outlined, size: 14, color: tokens.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppFormatters.date(lot.purchaseDate),
              style: TextStyle(color: tokens.textSecondary, fontSize: 11),
            ),
          ),
          Text(
            '${lot.quantity.toStringAsFixed(lot.quantity.truncateToDouble() == lot.quantity ? 0 : 2)} un · ${AppFormatters.currency(lot.purchasePrice)}',
            style: TextStyle(color: tokens.textPrimary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
