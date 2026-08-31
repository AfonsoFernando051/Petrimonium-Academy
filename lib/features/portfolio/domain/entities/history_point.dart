/// One sample of the Wealth Evolution chart. `portfolioValue - investedCapital`
/// is the unrealized profit at that point in time.
///
/// Backend note: since no historical price table exists yet, the backend
/// computes this via a deterministic cost-basis → current-value interpolation
/// (see `GetPortfolioHistoryUseCaseImpl`), not true historical mark-to-market
/// data. It is a reasonable approximation, not a fabricated one — no random
/// numbers are involved and it always resolves to the real current value today.
class HistoryPoint {
  final DateTime date;
  final double investedCapital;
  final double portfolioValue;

  const HistoryPoint({
    required this.date,
    required this.investedCapital,
    required this.portfolioValue,
  });

  double get profit => portfolioValue - investedCapital;

  factory HistoryPoint.fromJson(Map<String, dynamic> json) {
    return HistoryPoint(
      date: DateTime.parse(json['date'] as String),
      investedCapital: (json['investedCapital'] as num).toDouble(),
      portfolioValue: (json['portfolioValue'] as num).toDouble(),
    );
  }
}
