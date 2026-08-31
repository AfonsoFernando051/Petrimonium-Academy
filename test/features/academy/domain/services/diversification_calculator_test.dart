import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/academy/domain/services/diversification_calculator.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';

void main() {
  group('DiversificationCalculator.evaluate', () {
    test('100% in one category maxes out concentration', () {
      final result = DiversificationCalculator.evaluate({
        InvestmentTypeEnum.STOCKS: 100,
      });

      expect(result.isValid, isTrue);
      expect(result.hhi, closeTo(1, 0.0001));
      expect(result.diversificationScore, closeTo(0, 0.0001));
      expect(result.effectiveNumberOfAssets, closeTo(1, 0.0001));
      expect(result.band, ConcentrationBand.concentrated);
    });

    test('an equal 6-way split gives an effective count of 6', () {
      final weight = 100 / 6;
      final result = DiversificationCalculator.evaluate({
        for (final type in InvestmentTypeEnum.values) type: weight,
      });

      expect(result.isValid, isTrue);
      expect(result.effectiveNumberOfAssets, closeTo(6, 0.001));
      expect(result.band, ConcentrationBand.wellSpread);
    });

    test('weights summing to 90 are invalid and report a positive remainder', () {
      final result = DiversificationCalculator.evaluate({
        InvestmentTypeEnum.STOCKS: 60,
        InvestmentTypeEnum.FIXED_INCOME: 30,
      });

      expect(result.isValid, isFalse);
      expect(result.remainderPercent, closeTo(10, 0.0001));
    });

    test('weights summing to 110 are invalid and report a negative remainder', () {
      final result = DiversificationCalculator.evaluate({
        InvestmentTypeEnum.STOCKS: 60,
        InvestmentTypeEnum.FIXED_INCOME: 50,
      });

      expect(result.isValid, isFalse);
      expect(result.remainderPercent, closeTo(-10, 0.0001));
    });

    test('never silently normalizes an invalid allocation', () {
      final input = {
        InvestmentTypeEnum.STOCKS: 60.0,
        InvestmentTypeEnum.FIXED_INCOME: 30.0,
      };
      final before = Map.of(input);

      DiversificationCalculator.evaluate(input);

      expect(input, equals(before));
    });

    test('all-zero weights are invalid, with effectiveNumberOfAssets 0 not Infinity', () {
      final result = DiversificationCalculator.evaluate({
        InvestmentTypeEnum.STOCKS: 0,
        InvestmentTypeEnum.FIXED_INCOME: 0,
      });

      expect(result.isValid, isFalse);
      expect(result.effectiveNumberOfAssets, 0);
      expect(result.effectiveNumberOfAssets.isInfinite, isFalse);
    });

    test('the market shock is invariant to allocation — always 15%', () {
      final concentrated = DiversificationCalculator.evaluate({
        InvestmentTypeEnum.STOCKS: 90,
        InvestmentTypeEnum.FIXED_INCOME: 10,
      });
      final spread = DiversificationCalculator.evaluate({
        InvestmentTypeEnum.STOCKS: 20,
        InvestmentTypeEnum.FIXED_INCOME: 20,
        InvestmentTypeEnum.REAL_ESTATE: 20,
        InvestmentTypeEnum.CRYPTO: 20,
        InvestmentTypeEnum.FUNDS: 20,
      });

      expect(concentrated.marketShockImpactPercent, 15);
      expect(spread.marketShockImpactPercent, 15);
    });

    test('the concentration shock scales with the largest single weight', () {
      final result = DiversificationCalculator.evaluate({
        InvestmentTypeEnum.STOCKS: 80,
        InvestmentTypeEnum.FIXED_INCOME: 20,
      });

      expect(result.largestCategory, InvestmentTypeEnum.STOCKS);
      expect(result.largestWeightPercent, 80);
      expect(result.concentrationShockImpactPercent, closeTo(24, 0.0001)); // 80% * 30%
    });
  });
}
