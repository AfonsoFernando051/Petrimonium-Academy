import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_lot.dart';

InvestmentLot _lot({
  int id = 1,
  String ticker = 'PETR4',
  InvestmentTypeEnum type = InvestmentTypeEnum.STOCKS,
  double quantity = 10,
  double purchasePrice = 10,
  DateTime? purchaseDate,
  double currentPrice = 12,
  double? investedValue,
  double? currentValue,
}) {
  return InvestmentLot(
    id: id,
    ticker: ticker,
    type: type,
    quantity: quantity,
    purchasePrice: purchasePrice,
    purchaseDate: purchaseDate ?? DateTime(2023, 1, 1),
    currentPrice: currentPrice,
    investedValue: investedValue ?? quantity * purchasePrice,
    currentValue: currentValue ?? quantity * currentPrice,
  );
}

void main() {
  group('Holding', () {
    test('gainValue and gainPercent computed from invested/current value', () {
      const holding = Holding(
        ticker: 'PETR4',
        type: InvestmentTypeEnum.STOCKS,
        quantity: 10,
        averagePrice: 10,
        currentPrice: 12,
        investedValue: 100,
        currentValue: 120,
        portfolioPercent: 50,
        lots: [],
      );

      expect(holding.gainValue, 20);
      expect(holding.gainPercent, 20);
    });

    test('gainPercent is 0 when investedValue is 0 (avoids division by zero)', () {
      const holding = Holding(
        ticker: 'PETR4',
        type: InvestmentTypeEnum.STOCKS,
        quantity: 0,
        averagePrice: 0,
        currentPrice: 0,
        investedValue: 0,
        currentValue: 0,
        portfolioPercent: 0,
        lots: [],
      );

      expect(holding.gainPercent, 0.0);
    });

    test('gainValue can be negative for a loss', () {
      const holding = Holding(
        ticker: 'PETR4',
        type: InvestmentTypeEnum.STOCKS,
        quantity: 10,
        averagePrice: 10,
        currentPrice: 8,
        investedValue: 100,
        currentValue: 80,
        portfolioPercent: 50,
        lots: [],
      );

      expect(holding.gainValue, -20);
      expect(holding.gainPercent, -20);
    });

    test('firstPurchaseDate returns the earliest lot purchase date regardless of list order', () {
      final lots = [
        _lot(purchaseDate: DateTime(2023, 6, 1)),
        _lot(purchaseDate: DateTime(2022, 1, 15)),
        _lot(purchaseDate: DateTime(2023, 1, 1)),
      ];
      final holding = Holding(
        ticker: 'PETR4',
        type: InvestmentTypeEnum.STOCKS,
        quantity: 30,
        averagePrice: 10,
        currentPrice: 12,
        investedValue: 300,
        currentValue: 360,
        portfolioPercent: 100,
        lots: lots,
      );

      expect(holding.firstPurchaseDate, DateTime(2022, 1, 15));
    });

    group('fromLots', () {
      test('returns empty list for empty input', () {
        expect(Holding.fromLots([]), isEmpty);
      });

      test('groups lots by ticker and aggregates quantity/invested/current value', () {
        final lots = [
          _lot(ticker: 'PETR4', quantity: 10, purchasePrice: 10, currentPrice: 12),
          _lot(ticker: 'PETR4', quantity: 5, purchasePrice: 20, currentPrice: 12),
        ];

        final holdings = Holding.fromLots(lots);

        expect(holdings, hasLength(1));
        final h = holdings.first;
        expect(h.ticker, 'PETR4');
        expect(h.quantity, 15);
        expect(h.investedValue, 10 * 10 + 5 * 20); // 200
        expect(h.currentValue, 15 * 12); // 180
        expect(h.averagePrice, 200 / 15);
        expect(h.currentPrice, 12);
      });

      test('sorts lots within a holding oldest-first', () {
        final lots = [
          _lot(ticker: 'PETR4', purchaseDate: DateTime(2023, 6, 1)),
          _lot(ticker: 'PETR4', purchaseDate: DateTime(2022, 1, 1)),
        ];

        final holdings = Holding.fromLots(lots);

        expect(holdings.first.lots.first.purchaseDate, DateTime(2022, 1, 1));
        expect(holdings.first.lots.last.purchaseDate, DateTime(2023, 6, 1));
      });

      test('computes portfolioPercent as share of total current value across all holdings', () {
        final lots = [
          _lot(ticker: 'PETR4', quantity: 10, purchasePrice: 10, currentPrice: 10), // current 100
          _lot(ticker: 'VALE3', quantity: 10, purchasePrice: 10, currentPrice: 30), // current 300
        ];

        final holdings = Holding.fromLots(lots);
        final total = 400;
        final petr4 = holdings.firstWhere((h) => h.ticker == 'PETR4');
        final vale3 = holdings.firstWhere((h) => h.ticker == 'VALE3');

        expect(petr4.portfolioPercent, 100 / total * 100);
        expect(vale3.portfolioPercent, 300 / total * 100);
      });

      test('sorts resulting holdings by currentValue descending', () {
        final lots = [
          _lot(ticker: 'SMALL', quantity: 1, purchasePrice: 1, currentPrice: 1), // 1
          _lot(ticker: 'BIG', quantity: 1, purchasePrice: 1, currentPrice: 100), // 100
          _lot(ticker: 'MID', quantity: 1, purchasePrice: 1, currentPrice: 50), // 50
        ];

        final holdings = Holding.fromLots(lots);

        expect(holdings.map((h) => h.ticker).toList(), ['BIG', 'MID', 'SMALL']);
      });

      test('averagePrice is 0 when aggregated quantity is 0', () {
        final lots = [
          _lot(ticker: 'PETR4', quantity: 0, purchasePrice: 10, currentPrice: 10, investedValue: 0, currentValue: 0),
        ];

        final holdings = Holding.fromLots(lots);

        expect(holdings.first.averagePrice, 0.0);
      });

      test('portfolioPercent is 0 for every holding when total current value is 0', () {
        final lots = [
          _lot(ticker: 'PETR4', quantity: 1, purchasePrice: 1, currentPrice: 0, currentValue: 0),
        ];

        final holdings = Holding.fromLots(lots);

        expect(holdings.first.portfolioPercent, 0.0);
      });

      test('uses the type of the first (oldest) lot and currentPrice of the last (newest) lot', () {
        final lots = [
          _lot(
            ticker: 'PETR4',
            type: InvestmentTypeEnum.STOCKS,
            purchaseDate: DateTime(2022, 1, 1),
            currentPrice: 11,
          ),
          _lot(
            ticker: 'PETR4',
            type: InvestmentTypeEnum.STOCKS,
            purchaseDate: DateTime(2023, 1, 1),
            currentPrice: 15,
          ),
        ];

        final holdings = Holding.fromLots(lots);

        expect(holdings.first.type, InvestmentTypeEnum.STOCKS);
        expect(holdings.first.currentPrice, 15);
      });
    });
  });
}
