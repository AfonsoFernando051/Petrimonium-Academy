import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_stats.dart';
import 'package:petrimonium/features/portfolio/domain/services/passive_income_estimator.dart';

import 'portfolio_test_fixtures.dart';

void main() {
  group('PassiveIncomeEstimator.estimate — empty portfolio', () {
    test('returns PassiveIncomeEstimate.empty', () {
      final estimate = PassiveIncomeEstimator.estimate(PortfolioStats.empty);
      expect(estimate.monthlyEstimate, 0);
      expect(estimate.annualEstimate, 0);
      expect(estimate.monthlyByType, isEmpty);
    });
  });

  group('PassiveIncomeEstimator.estimate — single asset class', () {
    test('a R\$10,000 fixed-income position estimates its assumed 11% annual yield', () {
      final stats = statsFromLots([
        lot(type: InvestmentTypeEnum.FIXED_INCOME, quantity: 1000, purchasePrice: 10),
      ]);

      final estimate = PassiveIncomeEstimator.estimate(stats);

      expect(estimate.annualEstimate, closeTo(10000 * 0.11, 0.01));
      expect(estimate.monthlyEstimate, closeTo((10000 * 0.11) / 12, 0.01));
      expect(estimate.monthlyByType[InvestmentTypeEnum.FIXED_INCOME], closeTo((10000 * 0.11) / 12, 0.01));
    });

    test('crypto (0% assumed yield) contributes nothing and is omitted from the breakdown', () {
      final stats = statsFromLots([
        lot(type: InvestmentTypeEnum.CRYPTO, quantity: 1, purchasePrice: 50000),
      ]);

      final estimate = PassiveIncomeEstimator.estimate(stats);

      expect(estimate.annualEstimate, 0);
      expect(estimate.monthlyEstimate, 0);
      expect(estimate.monthlyByType.containsKey(InvestmentTypeEnum.CRYPTO), isFalse);
    });
  });

  group('PassiveIncomeEstimator.estimate — mixed portfolio', () {
    test('annual estimate is the sum of each category\'s own contribution', () {
      final stats = statsFromLots([
        lot(id: 1, ticker: 'A', type: InvestmentTypeEnum.FIXED_INCOME, quantity: 1000, purchasePrice: 10), // 10,000 * 11%
        lot(id: 2, ticker: 'B', type: InvestmentTypeEnum.STOCKS, quantity: 100, purchasePrice: 10), // 1,000 * 5%
      ]);

      final estimate = PassiveIncomeEstimator.estimate(stats);

      final expectedAnnual = (10000 * 0.11) + (1000 * 0.05);
      expect(estimate.annualEstimate, closeTo(expectedAnnual, 0.01));
      expect(estimate.monthlyEstimate, closeTo(expectedAnnual / 12, 0.01));
    });
  });
}
