import 'dart:math' as math;

/// One year's checkpoint in an [InflationResult]'s trajectory — the nominal
/// amount (unchanged — money sitting still) vs. its real purchasing power
/// at that point, for charting.
class InflationYearPoint {
  final int year;
  final double nominalValue;
  final double realValue;

  const InflationYearPoint({
    required this.year,
    required this.nominalValue,
    required this.realValue,
  });
}

/// The outcome of one [InflationCalculator.simulate] run.
class InflationResult {
  final double finalRealValue;
  final double totalPurchasingPowerLostPercent;

  /// How many times more the same basket of goods costs after the period —
  /// `(1 + inflation)^years`.
  final double basketCostMultiplier;

  /// `(1 + nominal) / (1 + inflation) - 1` — the exact real-return
  /// relationship (Fisher equation), not an approximation.
  final double realReturnExact;

  /// `nominal - inflation` — the commonly-used shorthand, always shown
  /// alongside [realReturnExact] and explicitly labeled as an
  /// approximation, never presented alone (`docs/DECISIONS.md`
  /// DECISION-037).
  final double realReturnApproximate;

  final List<InflationYearPoint> yearlyBreakdown;

  const InflationResult({
    required this.finalRealValue,
    required this.totalPurchasingPowerLostPercent,
    required this.basketCostMultiplier,
    required this.realReturnExact,
    required this.realReturnApproximate,
    required this.yearlyBreakdown,
  });
}

/// The Financial Lab's Inflation simulator (`docs/DECISIONS.md`
/// DECISION-037) — a pure, stateless calculation demonstrating that
/// inflation erodes purchasing power even when the nominal amount never
/// changes, and that comparing investment returns to inflation (real
/// return) needs the exact Fisher relationship, not a bare subtraction.
class InflationCalculator {
  const InflationCalculator._();

  static InflationResult simulate({
    required double initialAmount,
    required double annualInflationPercent,
    required double nominalReturnPercent,
    required int years,
  }) {
    final inflationRate = annualInflationPercent / 100;
    final nominalRate = nominalReturnPercent / 100;

    final breakdown = <InflationYearPoint>[
      for (var year = 0; year <= years; year++)
        InflationYearPoint(
          year: year,
          nominalValue: initialAmount,
          realValue:
              initialAmount / math.pow(1 + inflationRate, year).toDouble(),
        ),
    ];

    final basketCostMultiplier = math
        .pow(1 + inflationRate, years)
        .toDouble();
    final finalRealValue = initialAmount / basketCostMultiplier;
    // basketCostMultiplier = (1 + inflationRate)^years is always >= 1 for a
    // non-negative inflation rate (the slider's own floor), so this never
    // divides by zero.
    final lostPercent = (1 - 1 / basketCostMultiplier) * 100;

    return InflationResult(
      finalRealValue: finalRealValue,
      totalPurchasingPowerLostPercent: lostPercent,
      basketCostMultiplier: basketCostMultiplier,
      realReturnExact: (1 + nominalRate) / (1 + inflationRate) - 1,
      realReturnApproximate: nominalRate - inflationRate,
      yearlyBreakdown: breakdown,
    );
  }
}
