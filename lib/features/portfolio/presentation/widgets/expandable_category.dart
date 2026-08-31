import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_type_display.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/asset_row.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/performance_badge.dart';

/// A collapsible category (Ações/FIIs/ETFs/Cripto/...) inside Holdings,
/// showing an aggregate header and expanding to its individual [AssetRow]s.
class ExpandableCategory extends StatefulWidget {
  const ExpandableCategory({
    super.key,
    required this.type,
    required this.holdings,
    required this.totalPortfolioValue,
    this.initiallyExpanded = false,
  });

  final InvestmentTypeEnum type;
  final List<Holding> holdings;
  final double totalPortfolioValue;
  final bool initiallyExpanded;

  @override
  State<ExpandableCategory> createState() => _ExpandableCategoryState();
}

class _ExpandableCategoryState extends State<ExpandableCategory> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final categoryValue = widget.holdings.fold<double>(0, (sum, h) => sum + h.currentValue);
    final investedValue = widget.holdings.fold<double>(0, (sum, h) => sum + h.investedValue);
    final gainPercent = investedValue == 0 ? 0.0 : ((categoryValue - investedValue) / investedValue) * 100;
    final portfolioPercent = widget.totalPortfolioValue == 0 ? 0.0 : (categoryValue / widget.totalPortfolioValue) * 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: tokens.surface.withValues(alpha: context.isDarkMode ? 0.5 : 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.type.color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _expanded = !_expanded);
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: widget.type.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(widget.type.icon, color: widget.type.color, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.type.label,
                            style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            '${widget.holdings.length} ativo(s) · ${portfolioPercent.toStringAsFixed(1)}% da carteira',
                            style: TextStyle(color: tokens.textSecondary, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _compact(categoryValue),
                          style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        PerformanceBadge(percent: gainPercent, compact: true),
                      ],
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 250),
                      turns: _expanded ? 0.5 : 0,
                      child: Icon(Icons.expand_more, color: tokens.textSecondary, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Column(
                children: [
                  Divider(color: tokens.divider),
                  for (final holding in widget.holdings) AssetRow(holding: holding),
                ],
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  String _compact(double value) {
    if (value.abs() >= 1000) return 'R\$ ${(value / 1000).toStringAsFixed(1)}K';
    return 'R\$ ${value.toStringAsFixed(0)}';
  }
}
