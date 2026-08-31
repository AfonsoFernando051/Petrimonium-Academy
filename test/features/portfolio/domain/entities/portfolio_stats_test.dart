import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/allocation_slice.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_lot.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_stats.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_summary.dart';

Holding _holding({
  String ticker = 'PETR4',
  InvestmentTypeEnum type = InvestmentTypeEnum.STOCKS,
  double portfolioPercent = 10,
}) {
  return Holding(
    ticker: ticker,
    type: type,
    quantity: 10,
    averagePrice: 10,
    currentPrice: 12,
    investedValue: 100,
    currentValue: 120,
    portfolioPercent: portfolioPercent,
    lots: [], // portfolioPercent/type tests never touch firstPurchaseDate
  );
}

InvestmentLot _lotAt(String ticker, DateTime date) {
  return InvestmentLot(
    id: 1,
    ticker: ticker,
    type: InvestmentTypeEnum.STOCKS,
    quantity: 1,
    purchasePrice: 10,
    purchaseDate: date,
    currentPrice: 12,
    investedValue: 10,
    currentValue: 12,
  );
}

void main() {
  group('PortfolioStats', () {
    test('empty constant has no holdings/allocation and empty summary', () {
      expect(PortfolioStats.empty.hasHoldings, isFalse);
      expect(PortfolioStats.empty.holdings, isEmpty);
      expect(PortfolioStats.empty.allocation, isEmpty);
      expect(PortfolioStats.empty.summary, PortfolioSummary.empty);
    });

    test('hasHoldings is true when holdings list is non-empty', () {
      final stats = PortfolioStats(
        summary: PortfolioSummary.empty,
        holdings: [_holding()],
        allocation: const [],
      );

      expect(stats.hasHoldings, isTrue);
    });

    test('distinctTypeCount counts unique holding types', () {
      final stats = PortfolioStats(
        summary: PortfolioSummary.empty,
        holdings: [
          _holding(ticker: 'PETR4', type: InvestmentTypeEnum.STOCKS),
          _holding(ticker: 'VALE3', type: InvestmentTypeEnum.STOCKS),
          _holding(ticker: 'HGLG11', type: InvestmentTypeEnum.REAL_ESTATE),
        ],
        allocation: const [],
      );

      expect(stats.distinctTypeCount, 2);
    });

    test('distinctTypeCount is 0 for no holdings', () {
      expect(PortfolioStats.empty.distinctTypeCount, 0);
    });

    test('firstPurchaseDate is null when there are no holdings', () {
      expect(PortfolioStats.empty.firstPurchaseDate, isNull);
    });

    test('firstPurchaseDate returns earliest across all holdings', () {
      final holdingsWithLots = Holding.fromLots([
        _lotAt('A', DateTime(2021, 5, 1)),
        _lotAt('B', DateTime(2020, 1, 1)),
      ]);

      final stats = PortfolioStats(
        summary: PortfolioSummary.empty,
        holdings: holdingsWithLots,
        allocation: const [],
      );

      expect(stats.firstPurchaseDate, DateTime(2020, 1, 1));
    });

    test('largestHoldingPercent is 0 when there are no holdings', () {
      expect(PortfolioStats.empty.largestHoldingPercent, 0);
    });

    test('largestHoldingPercent returns the max portfolioPercent across holdings', () {
      final stats = PortfolioStats(
        summary: PortfolioSummary.empty,
        holdings: [
          _holding(ticker: 'A', portfolioPercent: 20),
          _holding(ticker: 'B', portfolioPercent: 55),
          _holding(ticker: 'C', portfolioPercent: 25),
        ],
        allocation: const [],
      );

      expect(stats.largestHoldingPercent, 55);
    });

    test('holds provided summary and allocation lists', () {
      const summary = PortfolioSummary(
        investedCapital: 1000,
        currentValue: 1200,
        totalGain: 200,
        totalGainPercent: 20,
        totalAssets: 2,
      );
      const allocation = [
        AllocationSlice(type: InvestmentTypeEnum.STOCKS, currentValue: 1200, portfolioPercent: 100),
      ];

      final stats = PortfolioStats(summary: summary, holdings: const [], allocation: allocation);

      expect(stats.summary, summary);
      expect(stats.allocation, allocation);
    });
  });
}
