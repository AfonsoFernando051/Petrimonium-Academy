import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/features/portfolio/domain/entities/insight.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_type_display.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_stats.dart';
import 'package:petrimonium/features/portfolio/domain/enums/insight_priority.dart';

/// Generates rule-based "Portfolio Insights" cards from a real
/// [PortfolioStats] snapshot. These are transparent, explainable rules over
/// the user's own data — not a fabricated "AI" recommendation engine.
class InsightGenerator {
  const InsightGenerator._();

  static List<Insight> generate(
    PortfolioStats stats, {
    VoidCallback? onOpenAllocation,
    VoidCallback? onOpenConfigure,
  }) {
    final insights = <Insight>[];

    if (!stats.hasHoldings) {
      insights.add(Insight(
        title: 'Comece sua jornada',
        description: 'Você ainda não tem nenhum ativo. Registre seu primeiro investimento para começar a evoluir seu companheiro.',
        icon: Icons.rocket_launch,
        priority: InsightPriority.high,
        color: AppColors.neonViolet,
        actionLabel: 'Investir agora',
        onAction: onOpenConfigure,
      ));
      return insights;
    }

    final gain = stats.summary.totalGainPercent;
    if (gain > 0) {
      insights.add(Insight(
        title: 'Retorno positivo',
        description: 'Seu portfólio acumula ${gain.toStringAsFixed(1)}% de retorno sobre o capital investido. Continue assim, Comandante.',
        icon: Icons.trending_up,
        priority: InsightPriority.low,
        color: AppColors.positiveGreen,
      ));
    } else if (gain < -5) {
      insights.add(Insight(
        title: 'Mercado em correção',
        description: 'Seu portfólio está ${gain.toStringAsFixed(1)}% abaixo do capital investido. Quedas fazem parte do ciclo — paciência e diversificação ajudam a atravessar.',
        icon: Icons.timeline,
        priority: InsightPriority.medium,
        color: AppColors.warningAmber,
      ));
    }

    if (stats.largestHoldingPercent > 40) {
      final biggest = stats.holdings.first;
      insights.add(Insight(
        title: 'Concentração elevada',
        description: '${biggest.ticker} representa ${stats.largestHoldingPercent.toStringAsFixed(0)}% do seu portfólio. Considere diversificar para reduzir o risco.',
        icon: Icons.warning_amber_rounded,
        priority: InsightPriority.high,
        color: AppColors.negativeRed,
        actionLabel: 'Ver alocação',
        onAction: onOpenAllocation,
      ));
    }

    if (stats.distinctTypeCount < 3) {
      insights.add(Insight(
        title: 'Diversificação baixa',
        description: 'Você investe em apenas ${stats.distinctTypeCount} categoria(s) de ativos. Diversificar entre ações, renda fixa e fundos imobiliários reduz sua exposição a risco.',
        icon: Icons.hub,
        priority: InsightPriority.medium,
        color: AppColors.neonPurple,
        actionLabel: 'Ver alocação',
        onAction: onOpenAllocation,
      ));
    }

    for (final slice in stats.allocation) {
      final diff = slice.portfolioPercent - slice.type.idealTargetPercent;
      if (diff > 15) {
        insights.add(Insight(
          title: '${slice.type.shortLabel} acima do ideal',
          description: '${slice.type.label} representa ${slice.portfolioPercent.toStringAsFixed(0)}% do portfólio, acima da meta sugerida de ${slice.type.idealTargetPercent.toStringAsFixed(0)}%.',
          icon: Icons.arrow_circle_up,
          priority: InsightPriority.medium,
          color: slice.type.color,
          actionLabel: 'Rebalancear',
          onAction: onOpenAllocation,
        ));
      } else if (diff < -15 && slice.portfolioPercent > 0) {
        insights.add(Insight(
          title: '${slice.type.shortLabel} abaixo do ideal',
          description: '${slice.type.label} está com apenas ${slice.portfolioPercent.toStringAsFixed(0)}% do portfólio, abaixo da meta sugerida de ${slice.type.idealTargetPercent.toStringAsFixed(0)}%.',
          icon: Icons.arrow_circle_down,
          priority: InsightPriority.low,
          color: slice.type.color,
        ));
      }
    }

    final firstPurchase = stats.firstPurchaseDate;
    final lastPurchase = stats.holdings
        .expand((h) => h.lots)
        .map((l) => l.purchaseDate)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final daysSinceLast = DateTime.now().difference(lastPurchase).inDays;
    if (daysSinceLast >= 15) {
      insights.add(Insight(
        title: 'Sem novos aportes',
        description: 'Já se passaram $daysSinceLast dias desde seu último investimento. Aportes regulares aceleram sua evolução.',
        icon: Icons.hourglass_bottom,
        priority: InsightPriority.medium,
        color: AppColors.neonCyan,
        actionLabel: 'Investir agora',
        onAction: onOpenConfigure,
      ));
    }

    if (firstPurchase != null && DateTime.now().difference(firstPurchase).inDays >= 365) {
      insights.add(Insight(
        title: 'Investidor de longo prazo',
        description: 'Você já mantém investimentos há mais de um ano. A consistência é uma das maiores forças de um investidor.',
        icon: Icons.emoji_events,
        priority: InsightPriority.low,
        color: AppColors.goldenBorder,
      ));
    }

    insights.sort((a, b) => a.priority.index.compareTo(b.priority.index));
    return insights;
  }
}
