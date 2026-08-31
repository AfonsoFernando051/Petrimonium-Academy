import 'dart:math' as math;

import 'package:petrimonium/features/academy/domain/services/compound_interest_calculator.dart';

/// One year's checkpoint in a [FixedIncomeResult]'s trajectory — principal
/// (money actually put in) vs. total value at that point, for charting.
class FixedIncomePoint {
  final int year;
  final double principal;
  final double value;

  const FixedIncomePoint({
    required this.year,
    required this.principal,
    required this.value,
  });
}

/// The outcome of one [FixedIncomeCalculator.simulate] run. Deliberately
/// gross — see the class doc for why taxation is not modeled.
class FixedIncomeResult {
  final double totalPrincipal;
  final double totalInterest;
  final double grossFinalValue;

  /// What share of the final value is interest, not principal — `0` when
  /// the final value is `0` (no division by zero).
  final double interestSharePercent;

  final double nominalAnnualRatePercent;

  /// `(1 + nominalRate/12)^12 - 1`, as a percent — always strictly greater
  /// than [nominalAnnualRatePercent] for any positive rate, which is this
  /// simulator's own lesson: monthly compounding earns more than the
  /// nominal rate alone suggests.
  final double effectiveAnnualRatePercent;

  final List<FixedIncomePoint> yearlyBreakdown;

  const FixedIncomeResult({
    required this.totalPrincipal,
    required this.totalInterest,
    required this.grossFinalValue,
    required this.interestSharePercent,
    required this.nominalAnnualRatePercent,
    required this.effectiveAnnualRatePercent,
    required this.yearlyBreakdown,
  });
}

/// The Financial Lab's Fixed Income simulator (`docs/DECISIONS.md`
/// DECISION-037) — delegates its accrual math to
/// [CompoundInterestCalculator.simulate] (identical monthly-compounding
/// model) and relabels the result in fixed-income vocabulary, adding the
/// nominal-vs-effective-rate distinction as its own unique lesson.
///
/// **Deliberately gross, no taxation modeled.** Brazil's fixed-income
/// taxation varies by product (CDB/LCI/LCA/Tesouro each differ, and the IR
/// table is itself regressive by holding period) — asserting a single tax
/// model here would be a compliance claim this codebase hasn't verified.
/// The UI carries a mandatory disclaimer instead of guessing.
class FixedIncomeCalculator {
  const FixedIncomeCalculator._();

  static FixedIncomeResult simulate({
    required double initialAmount,
    required double monthlyContribution,
    required double annualRatePercent,
    required int years,
  }) {
    final base = CompoundInterestCalculator.simulate(
      initialAmount: initialAmount,
      monthlyContribution: monthlyContribution,
      annualRatePercent: annualRatePercent,
      years: years,
    );

    final monthlyRate = annualRatePercent / 100 / 12;
    final effectiveAnnualRatePercent =
        (math.pow(1 + monthlyRate, 12).toDouble() - 1) * 100;

    final interestSharePercent = base.finalValue == 0
        ? 0.0
        : (base.totalGrowth / base.finalValue) * 100;

    return FixedIncomeResult(
      totalPrincipal: base.totalContributions,
      totalInterest: base.totalGrowth,
      grossFinalValue: base.finalValue,
      interestSharePercent: interestSharePercent,
      nominalAnnualRatePercent: annualRatePercent,
      effectiveAnnualRatePercent: effectiveAnnualRatePercent,
      yearlyBreakdown: [
        for (final point in base.yearlyBreakdown)
          FixedIncomePoint(
            year: point.year,
            principal: point.contributions,
            value: point.value,
          ),
      ],
    );
  }
}
