import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_health.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_stats.dart';
import 'package:petrimonium/features/portfolio/domain/services/portfolio_health_calculator.dart';

import 'portfolio_test_fixtures.dart';

double _metric(PortfolioHealth health, String name) =>
    health.metrics.firstWhere((m) => m.name == name).score;

void main() {
  group('PortfolioHealthCalculator.calculate — empty portfolio', () {
    test('an empty portfolio returns PortfolioHealth.empty (score 0, no metrics)', () {
      final health = PortfolioHealthCalculator.calculate(PortfolioStats.empty);
      expect(health.overallScore, 0);
      expect(health.metrics, isEmpty);
    });
  });

  group('PortfolioHealthCalculator.calculate — single-asset portfolio at breakeven', () {
    // 100 shares of a single STOCKS holding, current price == purchase price:
    // every facet resolves to an exact, hand-verified value (see comments).
    final stats = statsFromLots([lot(type: InvestmentTypeEnum.STOCKS, quantity: 100, purchasePrice: 10)]);
    final health = PortfolioHealthCalculator.calculate(stats);

    test('a single holding scores 0 on diversification (perfect concentration)', () {
      expect(_metric(health, 'Diversificação'), closeTo(0, 0.01));
    });

    test('breakeven (0% gain) scores exactly 50 on growth', () {
      expect(_metric(health, 'Crescimento'), closeTo(50, 0.01));
    });

    test('an all-stocks portfolio scores 0 on income stability (no fixed income/REITs)', () {
      expect(_metric(health, 'Estab. de Renda'), closeTo(0, 0.01));
    });

    test('overall score is the documented weighted blend of the six facets', () {
      // diversification=0, growth=50, incomeStability=0, dividendStrength=50,
      // volatilityControl=70, longTermPotential=(50+0+50)/3=33.33...
      // overall = 0*.20 + 50*.20 + 0*.15 + 50*.15 + 70*.15 + 33.33*.15 = 33.0
      expect(health.overallScore, closeTo(33.0, 0.05));
    });

    test('overall score is always clamped to [0, 100]', () {
      expect(health.overallScore, greaterThanOrEqualTo(0));
      expect(health.overallScore, lessThanOrEqualTo(100));
    });
  });

  group('PortfolioHealthCalculator.calculate — diversification responds to spread', () {
    test('spreading equal value across 4 categories scores much higher than concentrating it in 1', () {
      final concentrated = statsFromLots([
        lot(id: 1, ticker: 'A', type: InvestmentTypeEnum.STOCKS, quantity: 400, purchasePrice: 10),
      ]);
      final diversified = statsFromLots([
        lot(id: 1, ticker: 'A', type: InvestmentTypeEnum.STOCKS, quantity: 100, purchasePrice: 10),
        lot(id: 2, ticker: 'B', type: InvestmentTypeEnum.FIXED_INCOME, quantity: 100, purchasePrice: 10),
        lot(id: 3, ticker: 'C', type: InvestmentTypeEnum.REAL_ESTATE, quantity: 100, purchasePrice: 10),
        lot(id: 4, ticker: 'D', type: InvestmentTypeEnum.FUNDS, quantity: 100, purchasePrice: 10),
      ]);

      final concentratedHealth = PortfolioHealthCalculator.calculate(concentrated);
      final diversifiedHealth = PortfolioHealthCalculator.calculate(diversified);

      expect(_metric(diversifiedHealth, 'Diversificação'), greaterThan(_metric(concentratedHealth, 'Diversificação')));
      // 4 equal 25% slices: HHI = 4 * 0.25^2 = 0.25 -> score = (1 - 0.25) * 100 = 75.
      expect(_metric(diversifiedHealth, 'Diversificação'), closeTo(75, 0.01));
    });
  });

  group('PortfolioHealthCalculator.calculate — growth responds to gain/loss', () {
    test('a portfolio down more than 20% scores 0 on growth', () {
      final stats = statsFromLots([
        lot(quantity: 100, purchasePrice: 10, currentPrice: 5), // -50%
      ]);
      final health = PortfolioHealthCalculator.calculate(stats);
      expect(_metric(health, 'Crescimento'), 0);
    });

    test('a portfolio up 30% or more scores 100 on growth', () {
      final stats = statsFromLots([
        lot(quantity: 100, purchasePrice: 10, currentPrice: 14), // +40%
      ]);
      final health = PortfolioHealthCalculator.calculate(stats);
      expect(_metric(health, 'Crescimento'), 100);
    });

    test('growth score increases monotonically with gain percent', () {
      double growthFor(double currentPrice) {
        final stats = statsFromLots([lot(quantity: 100, purchasePrice: 10, currentPrice: currentPrice)]);
        return _metric(PortfolioHealthCalculator.calculate(stats), 'Crescimento');
      }

      expect(growthFor(6), lessThan(growthFor(10)));
      expect(growthFor(10), lessThan(growthFor(13)));
    });
  });

  group('PortfolioHealthCalculator.calculate — volatility control', () {
    test('an all-crypto portfolio scores lower on volatility control than an all-fixed-income one', () {
      final crypto = statsFromLots([lot(type: InvestmentTypeEnum.CRYPTO, quantity: 1, purchasePrice: 1000)]);
      final fixedIncome = statsFromLots([lot(type: InvestmentTypeEnum.FIXED_INCOME, quantity: 1000, purchasePrice: 1)]);

      final cryptoHealth = PortfolioHealthCalculator.calculate(crypto);
      final fixedIncomeHealth = PortfolioHealthCalculator.calculate(fixedIncome);

      expect(
        _metric(cryptoHealth, 'Controle de Volatilidade'),
        lessThan(_metric(fixedIncomeHealth, 'Controle de Volatilidade')),
      );
    });
  });
}
