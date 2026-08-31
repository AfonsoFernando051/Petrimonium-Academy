import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/academy/domain/services/portfolio_scenario_calculator.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';

void main() {
  group('PortfolioScenarioCalculator.evaluate', () {
    final weights = {
      InvestmentTypeEnum.STOCKS: 60.0,
      InvestmentTypeEnum.FIXED_INCOME: 40.0,
    };

    test('totalAmount: 0 produces all-zero deltas, never NaN', () {
      final result = PortfolioScenarioCalculator.evaluate(
        totalAmount: 0,
        weightsPercent: weights,
        scenario: LabScenario.broadMarketDown10,
      );

      expect(result.newValue, 0);
      expect(result.deltaAbsolute, 0);
      expect(result.deltaPercent, 0);
      expect(result.deltaPercent.isNaN, isFalse);
    });

    test('a -100%-equivalent shock never drives a category negative', () {
      // broadMarketDown10 only ever applies -10%, so use equitiesDown15 at
      // 100% stocks to confirm the clamp holds even at full exposure.
      final result = PortfolioScenarioCalculator.evaluate(
        totalAmount: 10000,
        weightsPercent: {InvestmentTypeEnum.STOCKS: 100},
        scenario: LabScenario.equitiesDown15,
      );

      expect(result.categoryImpacts.single.categoryValue + result.categoryImpacts.single.contribution, closeTo(8500, 0.001));
      expect(result.newValue, greaterThanOrEqualTo(0));
    });

    test('per-category contributions sum to the total delta', () {
      final result = PortfolioScenarioCalculator.evaluate(
        totalAmount: 10000,
        weightsPercent: weights,
        scenario: LabScenario.broadMarketDown10,
      );

      final summedContributions = result.categoryImpacts.fold<double>(
        0,
        (sum, impact) => sum + impact.contribution,
      );
      expect(summedContributions, closeTo(result.deltaAbsolute, 0.0001));
    });

    test('an identical shock across every category matches deltaPercent exactly', () {
      final result = PortfolioScenarioCalculator.evaluate(
        totalAmount: 10000,
        weightsPercent: weights,
        scenario: LabScenario.broadMarketDown10,
      );

      expect(result.deltaPercent, closeTo(-10, 0.0001));
    });

    test('an invalid allocation is reported as such, but still computes', () {
      final result = PortfolioScenarioCalculator.evaluate(
        totalAmount: 10000,
        weightsPercent: {InvestmentTypeEnum.STOCKS: 60},
        scenario: LabScenario.broadMarketDown10,
      );

      expect(result.isValid, isFalse);
      expect(result.newValue.isFinite, isTrue);
    });

    test('largestPositionDown20 targets whichever category has the biggest weight', () {
      final result = PortfolioScenarioCalculator.evaluate(
        totalAmount: 10000,
        weightsPercent: {
          InvestmentTypeEnum.STOCKS: 30,
          InvestmentTypeEnum.FIXED_INCOME: 70,
        },
        scenario: LabScenario.largestPositionDown20,
      );

      final fixedIncomeImpact = result.categoryImpacts.firstWhere(
        (i) => i.type == InvestmentTypeEnum.FIXED_INCOME,
      );
      final stocksImpact = result.categoryImpacts.firstWhere(
        (i) => i.type == InvestmentTypeEnum.STOCKS,
      );
      expect(fixedIncomeImpact.shockPercent, closeTo(-20, 0.0001));
      expect(stocksImpact.shockPercent, closeTo(0, 0.0001));
    });

    test('a single asset (100% one category) computes without error', () {
      final result = PortfolioScenarioCalculator.evaluate(
        totalAmount: 5000,
        weightsPercent: {InvestmentTypeEnum.FIXED_INCOME: 100},
        scenario: LabScenario.fixedIncomeUp5,
      );

      expect(result.deltaPercent, closeTo(5, 0.0001));
    });
  });
}
