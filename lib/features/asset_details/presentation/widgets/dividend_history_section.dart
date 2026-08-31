import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/portfolio/domain/entities/dividend_event.dart';
import 'package:petrimonium/core/utils/formatters.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/section_label.dart';

/// Real dividend history from the financial data provider — not estimated.
/// Shows upcoming (announced) dividends first, then paid history.
class DividendHistorySection extends StatefulWidget {
  const DividendHistorySection({super.key, required this.asset});

  final AssetDetails asset;

  @override
  State<DividendHistorySection> createState() => _DividendHistorySectionState();
}

class _DividendHistorySectionState extends State<DividendHistorySection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final upcoming = widget.asset.upcomingDividends;
    final history = widget.asset.paidDividends;

    // Show at most 3 items initially
    final visibleHistory = _expanded ? history : history.take(3).toList();

    return GlassCard(
      backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.55 : 0.94),
      borderColor: AppColors.goldenBorder.withValues(alpha: 0.2),
      borderRadius: 18,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SectionLabel('PROVENTOS'),
                const Spacer(),
                Icon(Icons.paid_outlined, color: AppColors.goldenBorder, size: 18),
              ],
            ),

            // ── Upcoming dividends ─────────────────────────────
            if (upcoming.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tokens.success.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: tokens.success.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Próximos pagamentos',
                      style: TextStyle(
                        color: tokens.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final div in upcoming) _DividendTile(event: div, isUpcoming: true),
                  ],
                ),
              ),
            ],

            // ── History ────────────────────────────────────────
            if (history.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Histórico',
                style: TextStyle(color: tokens.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              for (final div in visibleHistory) _DividendTile(event: div),

              if (history.length > 3) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    _expanded ? 'Mostrar menos' : 'Ver todos (${history.length})',
                    style: TextStyle(
                      color: AppColors.neonCyan,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],

            if (upcoming.isEmpty && history.isEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Nenhum provento registrado para este ativo.',
                style: TextStyle(color: tokens.textSecondary, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DividendTile extends StatelessWidget {
  const _DividendTile({required this.event, this.isUpcoming = false});

  final DividendEvent event;
  final bool isUpcoming;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final dateStr = event.paymentDate != null
        ? AppFormatters.shortDate(event.paymentDate!)
        : '—';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isUpcoming ? Icons.schedule : Icons.check_circle_outline,
            size: 14,
            color: isUpcoming ? tokens.success : tokens.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              dateStr,
              style: TextStyle(color: tokens.textSecondary, fontSize: 11),
            ),
          ),
          Text(
            'R\$ ${event.ratePerShare.toStringAsFixed(2)}/cota',
            style: TextStyle(color: tokens.textPrimary, fontSize: 11),
          ),
          if (event.estimatedGrossAmount > 0) ...[
            const SizedBox(width: 8),
            Text(
              isUpcoming ? 'est. ${AppFormatters.currency(event.estimatedGrossAmount)}'
                  : AppFormatters.currency(event.estimatedGrossAmount),
              style: TextStyle(
                color: isUpcoming ? tokens.success : AppColors.goldenBorder,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
