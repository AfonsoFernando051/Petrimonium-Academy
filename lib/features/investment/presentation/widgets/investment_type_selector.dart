import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_type_display.dart';

/// Replaces the plain `DropdownButtonFormField` type picker with a row of
/// tappable, colored type cards plus a contextual one-line tip that changes
/// with the selection — turns "pick from a list" into a small moment of
/// reassurance about the choice just made.
class InvestmentTypeSelector extends StatelessWidget {
  const InvestmentTypeSelector({super.key, required this.selected, required this.onChanged});

  final InvestmentTypeEnum? selected;
  final ValueChanged<InvestmentTypeEnum> onChanged;

  static const Map<InvestmentTypeEnum, String> _tips = {
    InvestmentTypeEnum.STOCKS: '🚀 Maior potencial de crescimento no longo prazo.',
    InvestmentTypeEnum.FIXED_INCOME: '🛡 Investimento mais previsível e seguro.',
    InvestmentTypeEnum.REAL_ESTATE: '🏢 Ótima fonte de renda passiva mensal.',
    InvestmentTypeEnum.CRYPTO: '⚡ Alto potencial, alta volatilidade.',
    InvestmentTypeEnum.FUNDS: '📈 Excelente escolha para diversificação de longo prazo.',
    InvestmentTypeEnum.OTHERS: '📦 Registre qualquer outro ativo do seu portfólio.',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Investimento',
          style: TextStyle(color: context.colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: InvestmentTypeEnum.values.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final type = InvestmentTypeEnum.values[index];
              final isSelected = selected == type;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChanged(type);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 88,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? type.color.withValues(alpha: 0.18)
                        : context.colors.textPrimary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? type.color : context.colors.textPrimary.withValues(alpha: 0.15),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: type.color.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 1)]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(type.icon, color: isSelected ? type.color : context.colors.textSecondary, size: 24),
                      const SizedBox(height: 6),
                      Text(
                        type.shortLabel,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? context.colors.textPrimary : context.colors.textSecondary,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (selected != null) ...[
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Container(
              key: ValueKey(selected),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selected!.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _tips[selected]!,
                style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
