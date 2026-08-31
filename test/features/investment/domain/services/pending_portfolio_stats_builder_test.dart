import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/investment/data/models/asset_registration_model.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/investment/domain/services/pending_portfolio_stats_builder.dart';

AssetRegistrationModel asset({
  String name = 'PETR4',
  double quantity = 100,
  double purchasePrice = 10,
  String purchaseDate = '2024-01-01',
  InvestmentTypeEnum type = InvestmentTypeEnum.STOCKS,
}) {
  return AssetRegistrationModel(
    name: name,
    quantity: quantity,
    purchasePrice: purchasePrice,
    purchaseDate: purchaseDate,
    type: type,
  );
}

void main() {
  group('PendingPortfolioStatsBuilder.build — empty input', () {
    test('no assets returns PortfolioStats.empty', () {
      final stats = PendingPortfolioStatsBuilder.build([]);
      expect(stats.hasHoldings, isFalse);
      expect(stats.summary.currentValue, 0);
    });
  });

  group('PendingPortfolioStatsBuilder.build — a pending asset has no gain/loss yet', () {
    test('invested capital equals current value (nothing has moved yet)', () {
      final stats = PendingPortfolioStatsBuilder.build([asset(quantity: 100, purchasePrice: 10)]);

      expect(stats.summary.investedCapital, 1000.0);
      expect(stats.summary.currentValue, 1000.0);
      expect(stats.summary.totalGain, 0);
      expect(stats.summary.totalGainPercent, 0);
    });

    test('the resulting holding carries currentPrice equal to purchasePrice', () {
      final stats = PendingPortfolioStatsBuilder.build([asset(purchasePrice: 35.5)]);

      expect(stats.holdings.single.currentPrice, 35.5);
      expect(stats.holdings.single.gainValue, 0);
    });
  });

  group('PendingPortfolioStatsBuilder.build — ticker normalization', () {
    test('the ticker is upper-cased regardless of how the user typed it', () {
      final stats = PendingPortfolioStatsBuilder.build([asset(name: 'petr4')]);

      expect(stats.holdings.single.ticker, 'PETR4');
    });
  });

  group('PendingPortfolioStatsBuilder.build — allocation', () {
    test('a single asset is 100% of the allocation', () {
      final stats = PendingPortfolioStatsBuilder.build([asset(type: InvestmentTypeEnum.STOCKS)]);

      expect(stats.allocation, hasLength(1));
      expect(stats.allocation.single.portfolioPercent, 100.0);
    });

    test('two asset classes split the allocation proportionally', () {
      final stats = PendingPortfolioStatsBuilder.build([
        asset(name: 'PETR4', type: InvestmentTypeEnum.STOCKS, quantity: 100, purchasePrice: 10), // 1000
        asset(name: 'TESOURO', type: InvestmentTypeEnum.FIXED_INCOME, quantity: 1, purchasePrice: 1000), // 1000
      ]);

      final totalPercent = stats.allocation.fold<double>(0, (sum, slice) => sum + slice.portfolioPercent);
      expect(totalPercent, closeTo(100.0, 0.001));
      expect(stats.allocation.length, 2);
      for (final slice in stats.allocation) {
        expect(slice.portfolioPercent, closeTo(50.0, 0.001));
      }
    });

    test('multiple lots of the same type are grouped into one allocation slice', () {
      final stats = PendingPortfolioStatsBuilder.build([
        asset(name: 'PETR4', type: InvestmentTypeEnum.STOCKS, quantity: 10, purchasePrice: 10),
        asset(name: 'VALE3', type: InvestmentTypeEnum.STOCKS, quantity: 10, purchasePrice: 10),
      ]);

      expect(stats.allocation, hasLength(1));
      expect(stats.allocation.single.currentValue, 200.0);
    });
  });

  group('PendingPortfolioStatsBuilder.build — malformed purchase date', () {
    test('an unparsable date falls back to now rather than throwing', () {
      expect(
        () => PendingPortfolioStatsBuilder.build([asset(purchaseDate: 'not-a-date')]),
        returnsNormally,
      );
    });
  });

  group('PendingPortfolioStatsBuilder.build — totalAssets', () {
    test('reflects the number of distinct holdings, not raw asset entries', () {
      final stats = PendingPortfolioStatsBuilder.build([
        asset(name: 'PETR4', quantity: 10),
        asset(name: 'PETR4', quantity: 5), // same ticker again -> still one holding
        asset(name: 'VALE3', quantity: 3),
      ]);

      expect(stats.summary.totalAssets, 2);
    });
  });
}
