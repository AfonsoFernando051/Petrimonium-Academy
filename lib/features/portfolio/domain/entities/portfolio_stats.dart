import 'package:petrimonium/features/portfolio/domain/entities/allocation_slice.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_summary.dart';

/// A convenience snapshot bundling everything the gamification calculators
/// (`PortfolioHealthCalculator`, `InsightGenerator`, `AchievementCatalog`,
/// `PassiveIncomeEstimator`) need, so each of those pure functions takes one
/// argument instead of three.
class PortfolioStats {
  final PortfolioSummary summary;
  final List<Holding> holdings;
  final List<AllocationSlice> allocation;

  const PortfolioStats({
    required this.summary,
    required this.holdings,
    required this.allocation,
  });

  static const empty = PortfolioStats(
    summary: PortfolioSummary.empty,
    holdings: [],
    allocation: [],
  );

  bool get hasHoldings => holdings.isNotEmpty;

  int get distinctTypeCount => holdings.map((h) => h.type).toSet().length;

  DateTime? get firstPurchaseDate {
    if (holdings.isEmpty) return null;
    return holdings.map((h) => h.firstPurchaseDate).reduce((a, b) => a.isBefore(b) ? a : b);
  }

  double get largestHoldingPercent =>
      holdings.isEmpty ? 0 : holdings.map((h) => h.portfolioPercent).reduce((a, b) => a > b ? a : b);
}
