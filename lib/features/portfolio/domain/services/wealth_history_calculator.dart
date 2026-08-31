import 'package:petrimonium/features/portfolio/domain/entities/history_point.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_lot.dart';
import 'package:petrimonium/features/portfolio/domain/enums/history_range.dart';

/// Client-side mirror of the backend's `GetPortfolioHistoryUseCaseImpl`
/// cost-basis → current-value interpolation. The backend endpoint is the
/// source of truth for the "All Assets" chart view; this local copy exists
/// so the Wealth Evolution chart's asset-class filter (Stocks/REITs/
/// ETFs/Crypto/Fixed Income) can redraw instantly from already-fetched
/// holdings, since the backend endpoint has no per-type breakdown — adding
/// one wasn't warranted just to avoid ~30 lines of shared, well-understood
/// math. Same deterministic approach: no randomness, always resolves to the
/// real current value today.
class WealthHistoryCalculator {
  const WealthHistoryCalculator._();

  static List<HistoryPoint> compute(List<InvestmentLot> lots, HistoryRange range) {
    if (lots.isEmpty) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final DateTime windowStart;
    switch (range) {
      case HistoryRange.d7:
        windowStart = today.subtract(const Duration(days: 7));
        break;
      case HistoryRange.d30:
        windowStart = today.subtract(const Duration(days: 30));
        break;
      case HistoryRange.m3:
        windowStart = today.subtract(const Duration(days: 90));
        break;
      case HistoryRange.m6:
        windowStart = today.subtract(const Duration(days: 180));
        break;
      case HistoryRange.y1:
        windowStart = today.subtract(const Duration(days: 365));
        break;
      case HistoryRange.y3:
        windowStart = today.subtract(const Duration(days: 365 * 3));
        break;
      case HistoryRange.y5:
        windowStart = today.subtract(const Duration(days: 365 * 5));
        break;
      case HistoryRange.all:
        windowStart = lots.map((l) => l.purchaseDate).reduce((a, b) => a.isBefore(b) ? a : b);
        break;
    }

    final totalDays = today.difference(windowStart).inDays;
    final sampleCount = totalDays <= 60 ? totalDays + 1 : 60;

    final dates = <DateTime>[];
    if (sampleCount <= 1) {
      dates.add(today);
    } else {
      for (var i = 0; i < sampleCount; i++) {
        final offset = (totalDays * i / (sampleCount - 1)).round();
        dates.add(windowStart.add(Duration(days: offset)));
      }
    }

    return dates.map((d) => _pointAt(lots, d, today)).toList();
  }

  static HistoryPoint _pointAt(List<InvestmentLot> lots, DateTime date, DateTime today) {
    double invested = 0;
    double value = 0;

    for (final lot in lots) {
      final purchaseDay = DateTime(lot.purchaseDate.year, lot.purchaseDate.month, lot.purchaseDate.day);
      if (purchaseDay.isAfter(date)) continue;

      invested += lot.quantity * lot.purchasePrice;

      final totalOwnedDays = today.difference(purchaseDay).inDays;
      final elapsedDays = date.difference(purchaseDay).inDays;
      final progress = totalOwnedDays <= 0 ? 1.0 : (elapsedDays / totalOwnedDays).clamp(0.0, 1.0);
      value += lot.quantity * (lot.purchasePrice + (lot.currentPrice - lot.purchasePrice) * progress);
    }

    return HistoryPoint(date: date, investedCapital: invested, portfolioValue: value);
  }
}
