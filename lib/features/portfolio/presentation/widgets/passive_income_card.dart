import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_type_display.dart';
import 'package:petrimonium/features/portfolio/domain/entities/passive_income_estimate.dart';
import 'package:petrimonium/core/utils/formatters.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/section_label.dart';

/// "Passive Income" section. No real dividend/coupon payment feed exists
/// anywhere in this system (see `PassiveIncomeEstimator`), so this is a
/// forward-looking projection by asset category — clearly labeled as an
/// estimate, with a 6-month projection rather than fabricated payment dates.
class PassiveIncomeCard extends StatelessWidget {
  const PassiveIncomeCard({super.key, required this.estimate});

  final PassiveIncomeEstimate estimate;

  @override
  Widget build(BuildContext context) {
    final months = List.generate(6, (i) {
      final date = DateTime.now();
      return DateTime(date.year, date.month + i + 1);
    });

    return GlassCard(
      backgroundColor: context.colors.surface.withValues(alpha: context.isDarkMode ? 0.6 : 0.94),
      borderColor: AppColors.goldenBorder.withValues(alpha: 0.35),
      borderRadius: 20,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('RENDA PASSIVA (ESTIMADA)'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _figure(context, 'Mensal', estimate.monthlyEstimate, AppColors.goldenBorder),
                ),
                Expanded(
                  child: _figure(context, 'Anual', estimate.annualEstimate, AppColors.neonCyan),
                ),
              ],
            ),
            if (estimate.monthlyByType.isNotEmpty) ...[
              const SizedBox(height: 16),
              for (final entry in estimate.monthlyByType.entries)
                _breakdownRow(context, entry.key.shortLabel, entry.value, entry.key.color),
              const SizedBox(height: 16),
              Text(
                'Projeção para os próximos 6 meses',
                style: TextStyle(color: context.colors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: months.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => _monthChip(context, months[i], estimate.monthlyEstimate),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Estimativa baseada no rendimento médio histórico de cada categoria de ativo — não representa pagamentos confirmados.',
                style: TextStyle(color: context.colors.textSecondary, fontSize: 10),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Invista em ativos geradores de renda (renda fixa, FIIs, ações) para projetar sua renda passiva.',
                  style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _figure(BuildContext context, String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: context.colors.textSecondary, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          AppFormatters.currency(value, showCents: false),
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }

  Widget _breakdownRow(BuildContext context, String label, double monthlyValue, Color color) {
    final tokens = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(color: tokens.textPrimary, fontSize: 12))),
          Text(
            '${AppFormatters.currency(monthlyValue, showCents: false)}/mês',
            style: TextStyle(color: tokens.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _monthChip(BuildContext context, DateTime month, double value) {
    final tokens = context.colors;
    const monthNames = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];
    return Container(
      width: 76,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.goldenBorder.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.goldenBorder.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(monthNames[month.month - 1], style: TextStyle(color: tokens.textSecondary, fontSize: 10)),
          const SizedBox(height: 4),
          Text(
            AppFormatters.compactCurrency(value),
            style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
