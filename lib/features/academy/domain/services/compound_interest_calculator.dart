/// One year's checkpoint in a [CompoundInterestResult]'s trajectory —
/// cumulative contributions vs. total value at that point, for charting.
class CompoundInterestYearPoint {
  final int year;
  final double contributions;
  final double value;

  const CompoundInterestYearPoint({required this.year, required this.contributions, required this.value});
}

/// The outcome of one [CompoundInterestCalculator.simulate] run.
class CompoundInterestResult {
  final double totalContributions;
  final double totalGrowth;
  final double finalValue;
  final List<CompoundInterestYearPoint> yearlyBreakdown;

  const CompoundInterestResult({
    required this.totalContributions,
    required this.totalGrowth,
    required this.finalValue,
    required this.yearlyBreakdown,
  });
}

/// The Financial Lab's Compound Interest simulator
/// (`docs/ACADEMY_ENGINE.md` §3d, brief §27/28) — a pure, stateless
/// calculation with no persistence, no XP, no backend: a sandbox for
/// building intuition, not a graded activity. Deliberately the only lab
/// implemented in this pass; `FinancialLabHomeScreen` shows the rest
/// (Inflation, Fixed Income, Diversification, Portfolio) as "coming soon"
/// placeholders, mirroring the exact pattern already used for
/// not-yet-authored Schools.
class CompoundInterestCalculator {
  const CompoundInterestCalculator._();

  /// Monthly compounding, contribution added at the end of each month —
  /// the simplest, most explainable convention for a teaching tool (not
  /// modeling a specific real product's exact accrual rules).
  static CompoundInterestResult simulate({
    required double initialAmount,
    required double monthlyContribution,
    required double annualRatePercent,
    required int years,
  }) {
    final monthlyRate = annualRatePercent / 100 / 12;

    var balance = initialAmount;
    var contributed = initialAmount;
    final breakdown = <CompoundInterestYearPoint>[
      CompoundInterestYearPoint(year: 0, contributions: contributed, value: balance),
    ];

    for (var year = 1; year <= years; year++) {
      for (var month = 0; month < 12; month++) {
        balance = balance * (1 + monthlyRate) + monthlyContribution;
        contributed += monthlyContribution;
      }
      breakdown.add(CompoundInterestYearPoint(year: year, contributions: contributed, value: balance));
    }

    return CompoundInterestResult(
      totalContributions: contributed,
      totalGrowth: balance - contributed,
      finalValue: balance,
      yearlyBreakdown: breakdown,
    );
  }
}
