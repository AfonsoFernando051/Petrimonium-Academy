import 'package:flutter/material.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_type_display.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_health.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_stats.dart';

/// Pure, explainable heuristic that turns real holdings/allocation data into
/// the 0-100 "Portfolio Health" score and its six facets. There is no
/// pre-existing scoring model to match (confirmed absent from both the
/// backend and product docs), so this is intentionally transparent — every
/// number here is derived from a documented formula below, never a black box.
class PortfolioHealthCalculator {
  const PortfolioHealthCalculator._();

  static PortfolioHealth calculate(PortfolioStats stats) {
    if (!stats.hasHoldings) return PortfolioHealth.empty;

    final diversification = _diversification(stats);
    final growth = _growth(stats);
    final incomeStability = _incomeStability(stats);
    final dividendStrength = _dividendStrength(stats);
    final volatilityControl = _volatilityControl(stats);
    final longTermPotential = (growth + diversification + dividendStrength) / 3;

    final overall = diversification * 0.20 +
        growth * 0.20 +
        incomeStability * 0.15 +
        dividendStrength * 0.15 +
        volatilityControl * 0.15 +
        longTermPotential * 0.15;

    return PortfolioHealth(
      overallScore: overall.clamp(0, 100),
      metrics: [
        HealthMetric(name: 'Diversificação', score: diversification, icon: Icons.hub),
        HealthMetric(name: 'Crescimento', score: growth, icon: Icons.trending_up),
        HealthMetric(name: 'Estab. de Renda', score: incomeStability, icon: Icons.savings),
        HealthMetric(name: 'Força de Dividendos', score: dividendStrength, icon: Icons.paid),
        HealthMetric(name: 'Controle de Volatilidade', score: volatilityControl, icon: Icons.shield),
        HealthMetric(name: 'Potencial Longo Prazo', score: longTermPotential, icon: Icons.rocket_launch),
      ],
    );
  }

  /// 100 * (1 - Herfindahl-Hirschman Index) over allocation percentages —
  /// rewards spreading value across categories instead of concentrating it.
  static double _diversification(PortfolioStats stats) {
    final hhi = stats.allocation.fold<double>(0, (sum, slice) {
      final fraction = slice.portfolioPercent / 100;
      return sum + (fraction * fraction);
    });
    return ((1 - hhi) * 100).clamp(0, 100);
  }

  static double _growth(PortfolioStats stats) {
    final gain = stats.summary.totalGainPercent;
    if (gain <= -20) return 0;
    if (gain <= 0) return _lerp(0, 50, (gain + 20) / 20);
    if (gain <= 30) return _lerp(50, 100, gain / 30);
    return 100;
  }

  /// Share of current value sitting in the two income-generating categories.
  static double _incomeStability(PortfolioStats stats) {
    final total = stats.summary.currentValue;
    if (total == 0) return 0;
    final incomeValue = stats.allocation
        .where((s) => s.type == InvestmentTypeEnum.FIXED_INCOME || s.type == InvestmentTypeEnum.REAL_ESTATE)
        .fold<double>(0, (sum, s) => sum + s.currentValue);
    return ((incomeValue / total) * 100).clamp(0, 100);
  }

  /// Allocation-weighted average of each category's assumed dividend/coupon
  /// yield, scaled so a 10%+ blended yield reaches a perfect score.
  static double _dividendStrength(PortfolioStats stats) {
    final total = stats.summary.currentValue;
    if (total == 0) return 0;
    final weightedYield = stats.allocation.fold<double>(
      0,
      (sum, s) => sum + (s.currentValue / total) * s.type.assumedAnnualYield,
    );
    return ((weightedYield / 0.10) * 100).clamp(0, 100);
  }

  /// Penalizes concentration in higher-volatility categories (crypto most,
  /// equities moderately); fixed income/REITs/funds don't detract.
  static double _volatilityControl(PortfolioStats stats) {
    double cryptoPct = 0;
    double stocksPct = 0;
    for (final slice in stats.allocation) {
      if (slice.type == InvestmentTypeEnum.CRYPTO) cryptoPct = slice.portfolioPercent;
      if (slice.type == InvestmentTypeEnum.STOCKS) stocksPct = slice.portfolioPercent;
    }
    return (100 - (cryptoPct * 1.2 + stocksPct * 0.3)).clamp(0, 100);
  }

  static double _lerp(double from, double to, double t) => from + (to - from) * t.clamp(0.0, 1.0);
}
