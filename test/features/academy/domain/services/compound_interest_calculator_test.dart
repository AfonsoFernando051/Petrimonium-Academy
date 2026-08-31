import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/academy/domain/services/compound_interest_calculator.dart';

void main() {
  group('CompoundInterestCalculator.simulate', () {
    test('zero return means final value equals total contributions', () {
      final result = CompoundInterestCalculator.simulate(
        initialAmount: 1000,
        monthlyContribution: 100,
        annualRatePercent: 0,
        years: 5,
      );
      expect(result.finalValue, closeTo(result.totalContributions, 0.001));
      expect(result.totalGrowth, closeTo(0, 0.001));
    });

    test('total contributions equal initial plus every monthly deposit', () {
      final result = CompoundInterestCalculator.simulate(
        initialAmount: 1000,
        monthlyContribution: 100,
        annualRatePercent: 5,
        years: 3,
      );
      expect(result.totalContributions, closeTo(1000 + 100 * 12 * 3, 0.001));
    });

    test('a positive return produces positive growth', () {
      final result = CompoundInterestCalculator.simulate(
        initialAmount: 1000,
        monthlyContribution: 100,
        annualRatePercent: 8,
        years: 10,
      );
      expect(result.totalGrowth, greaterThan(0));
      expect(result.finalValue, greaterThan(result.totalContributions));
    });

    test('more years never decreases the final value, holding other inputs constant', () {
      final shorter = CompoundInterestCalculator.simulate(
        initialAmount: 1000,
        monthlyContribution: 100,
        annualRatePercent: 8,
        years: 10,
      );
      final longer = CompoundInterestCalculator.simulate(
        initialAmount: 1000,
        monthlyContribution: 100,
        annualRatePercent: 8,
        years: 20,
      );
      expect(longer.finalValue, greaterThan(shorter.finalValue));
    });

    test('zero years returns just the initial amount, no growth', () {
      final result = CompoundInterestCalculator.simulate(
        initialAmount: 1000,
        monthlyContribution: 100,
        annualRatePercent: 8,
        years: 0,
      );
      expect(result.finalValue, 1000);
      expect(result.totalContributions, 1000);
      expect(result.totalGrowth, 0);
      expect(result.yearlyBreakdown, hasLength(1));
    });

    test('yearlyBreakdown has one point per year plus the year-0 starting point', () {
      final result = CompoundInterestCalculator.simulate(
        initialAmount: 500,
        monthlyContribution: 50,
        annualRatePercent: 6,
        years: 4,
      );
      expect(result.yearlyBreakdown, hasLength(5));
      expect(result.yearlyBreakdown.first.year, 0);
      expect(result.yearlyBreakdown.last.year, 4);
    });
  });
}
