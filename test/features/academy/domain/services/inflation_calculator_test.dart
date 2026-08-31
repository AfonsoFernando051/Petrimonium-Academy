import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/academy/domain/services/inflation_calculator.dart';

void main() {
  group('InflationCalculator.simulate', () {
    test('zero inflation leaves real value equal to nominal at every point', () {
      final result = InflationCalculator.simulate(
        initialAmount: 10000,
        annualInflationPercent: 0,
        nominalReturnPercent: 8,
        years: 10,
      );

      expect(result.finalRealValue, closeTo(10000, 0.001));
      expect(result.totalPurchasingPowerLostPercent, closeTo(0, 0.001));
      expect(result.basketCostMultiplier, closeTo(1, 0.001));
      for (final point in result.yearlyBreakdown) {
        expect(point.realValue, closeTo(point.nominalValue, 0.001));
      }
    });

    test('positive inflation strictly decays real value year over year', () {
      final result = InflationCalculator.simulate(
        initialAmount: 10000,
        annualInflationPercent: 6,
        nominalReturnPercent: 8,
        years: 10,
      );

      for (var i = 1; i < result.yearlyBreakdown.length; i++) {
        expect(
          result.yearlyBreakdown[i].realValue,
          lessThan(result.yearlyBreakdown[i - 1].realValue),
        );
      }
      expect(result.totalPurchasingPowerLostPercent, greaterThan(0));
    });

    test('years: 0 produces a single anchor point equal to the initial amount', () {
      final result = InflationCalculator.simulate(
        initialAmount: 5000,
        annualInflationPercent: 5,
        nominalReturnPercent: 8,
        years: 0,
      );

      expect(result.yearlyBreakdown, hasLength(1));
      expect(result.finalRealValue, closeTo(5000, 0.001));
      expect(result.basketCostMultiplier, closeTo(1, 0.001));
    });

    test('amount: 0 produces all-zero values, never NaN', () {
      final result = InflationCalculator.simulate(
        initialAmount: 0,
        annualInflationPercent: 5,
        nominalReturnPercent: 8,
        years: 10,
      );

      expect(result.finalRealValue, 0);
      expect(result.finalRealValue.isNaN, isFalse);
      for (final point in result.yearlyBreakdown) {
        expect(point.realValue, 0);
      }
    });

    test('a high inflation rate over a long period stays finite', () {
      final result = InflationCalculator.simulate(
        initialAmount: 100000,
        annualInflationPercent: 20,
        nominalReturnPercent: 8,
        years: 40,
      );

      expect(result.finalRealValue.isFinite, isTrue);
      expect(result.basketCostMultiplier.isFinite, isTrue);
      expect(result.totalPurchasingPowerLostPercent.isFinite, isTrue);
    });

    test('exact real return uses the Fisher relationship, not a bare subtraction', () {
      final result = InflationCalculator.simulate(
        initialAmount: 10000,
        annualInflationPercent: 5,
        nominalReturnPercent: 10,
        years: 10,
      );

      final expectedExact = (1 + 0.10) / (1 + 0.05) - 1;
      expect(result.realReturnExact, closeTo(expectedExact, 0.0001));
      expect(result.realReturnApproximate, closeTo(0.05, 0.0001));
      // The approximation and the exact figure genuinely differ — that gap
      // is the whole point of showing both.
      expect(result.realReturnExact, isNot(closeTo(result.realReturnApproximate, 0.0001)));
    });

    test('at zero inflation, exact real return equals the nominal return', () {
      final result = InflationCalculator.simulate(
        initialAmount: 10000,
        annualInflationPercent: 0,
        nominalReturnPercent: 8,
        years: 10,
      );

      expect(result.realReturnExact, closeTo(0.08, 0.0001));
    });
  });
}
