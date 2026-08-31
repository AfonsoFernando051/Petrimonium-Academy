import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/academy/domain/services/fixed_income_calculator.dart';

void main() {
  group('FixedIncomeCalculator.simulate', () {
    test('zero rate produces zero interest and zero interest share', () {
      final result = FixedIncomeCalculator.simulate(
        initialAmount: 1000,
        monthlyContribution: 100,
        annualRatePercent: 0,
        years: 10,
      );

      expect(result.totalInterest, closeTo(0, 0.001));
      expect(result.interestSharePercent, closeTo(0, 0.001));
      expect(result.effectiveAnnualRatePercent, closeTo(0, 0.001));
      expect(result.grossFinalValue, closeTo(result.totalPrincipal, 0.001));
    });

    test('recurring contributions accumulate as principal', () {
      final result = FixedIncomeCalculator.simulate(
        initialAmount: 1000,
        monthlyContribution: 200,
        annualRatePercent: 8,
        years: 5,
      );

      expect(result.totalPrincipal, closeTo(1000 + 200 * 12 * 5, 0.001));
    });

    test('positive rate: interest share strictly increases the longer the money stays invested', () {
      final short = FixedIncomeCalculator.simulate(
        initialAmount: 1000,
        monthlyContribution: 0,
        annualRatePercent: 8,
        years: 5,
      );
      final long = FixedIncomeCalculator.simulate(
        initialAmount: 1000,
        monthlyContribution: 0,
        annualRatePercent: 8,
        years: 20,
      );

      expect(long.interestSharePercent, greaterThan(short.interestSharePercent));
    });

    test('effective annual rate exceeds nominal for any positive rate', () {
      final result = FixedIncomeCalculator.simulate(
        initialAmount: 1000,
        monthlyContribution: 0,
        annualRatePercent: 12,
        years: 1,
      );

      expect(result.effectiveAnnualRatePercent, greaterThan(result.nominalAnnualRatePercent));
    });

    test('different periods produce different final values, both finite', () {
      final tenYears = FixedIncomeCalculator.simulate(
        initialAmount: 5000,
        monthlyContribution: 100,
        annualRatePercent: 10,
        years: 10,
      );
      final thirtyYears = FixedIncomeCalculator.simulate(
        initialAmount: 5000,
        monthlyContribution: 100,
        annualRatePercent: 10,
        years: 30,
      );

      expect(tenYears.grossFinalValue.isFinite, isTrue);
      expect(thirtyYears.grossFinalValue.isFinite, isTrue);
      expect(thirtyYears.grossFinalValue, greaterThan(tenYears.grossFinalValue));
    });

    test('principal plus interest equals the gross final value', () {
      final result = FixedIncomeCalculator.simulate(
        initialAmount: 2000,
        monthlyContribution: 150,
        annualRatePercent: 9,
        years: 7,
      );

      expect(
        result.totalPrincipal + result.totalInterest,
        closeTo(result.grossFinalValue, 0.001),
      );
    });

    test('all-zero inputs produce zero values, never NaN', () {
      final result = FixedIncomeCalculator.simulate(
        initialAmount: 0,
        monthlyContribution: 0,
        annualRatePercent: 0,
        years: 10,
      );

      expect(result.grossFinalValue, 0);
      expect(result.interestSharePercent, 0);
      expect(result.interestSharePercent.isNaN, isFalse);
    });
  });
}
