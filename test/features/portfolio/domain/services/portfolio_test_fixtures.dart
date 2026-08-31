import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/allocation_slice.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_lot.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_stats.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_summary.dart';

/// Test-only builder for a single purchase lot, with sensible defaults so
/// each test only spells out the fields it actually cares about.
InvestmentLot lot({
  int id = 1,
  String ticker = 'PETR4',
  InvestmentTypeEnum type = InvestmentTypeEnum.STOCKS,
  double quantity = 100,
  double purchasePrice = 10,
  DateTime? purchaseDate,
  double? currentPrice,
}) {
  final resolvedCurrentPrice = currentPrice ?? purchasePrice;
  return InvestmentLot(
    id: id,
    ticker: ticker,
    type: type,
    quantity: quantity,
    purchasePrice: purchasePrice,
    purchaseDate: purchaseDate ?? DateTime(2024, 1, 1),
    currentPrice: resolvedCurrentPrice,
    investedValue: quantity * purchasePrice,
    currentValue: quantity * resolvedCurrentPrice,
  );
}

/// Builds a [PortfolioStats] the same way the real pipeline would
/// (`Holding.fromLots` + a summary/allocation derived from the same lots),
/// so calculator tests exercise realistic, internally-consistent data.
PortfolioStats statsFromLots(List<InvestmentLot> lots) {
  final holdings = Holding.fromLots(lots);
  final investedCapital = lots.fold<double>(0, (sum, l) => sum + l.investedValue);
  final currentValue = lots.fold<double>(0, (sum, l) => sum + l.currentValue);
  final totalGain = currentValue - investedCapital;
  final totalGainPercent = investedCapital == 0 ? 0.0 : (totalGain / investedCapital) * 100;

  final summary = PortfolioSummary(
    investedCapital: investedCapital,
    currentValue: currentValue,
    totalGain: totalGain,
    totalGainPercent: totalGainPercent,
    totalAssets: holdings.length,
  );

  final valueByType = <InvestmentTypeEnum, double>{};
  for (final holding in holdings) {
    valueByType.update(holding.type, (v) => v + holding.currentValue, ifAbsent: () => holding.currentValue);
  }
  final allocation = valueByType.entries
      .map((entry) => AllocationSlice(
            type: entry.key,
            currentValue: entry.value,
            portfolioPercent: currentValue == 0 ? 0.0 : (entry.value / currentValue) * 100,
          ))
      .toList();

  return PortfolioStats(summary: summary, holdings: holdings, allocation: allocation);
}
