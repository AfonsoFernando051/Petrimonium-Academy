import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_lot.dart';

void main() {
  group('InvestmentLot', () {
    test('gainValue and gainPercent reflect current vs invested value', () {
      final lot = InvestmentLot(
        id: 1,
        ticker: 'PETR4',
        type: InvestmentTypeEnum.STOCKS,
        quantity: 10,
        purchasePrice: 20.0,
        purchaseDate: DateTime(2026, 1, 1),
        currentPrice: 25.0,
        investedValue: 200.0,
        currentValue: 250.0,
      );

      expect(lot.gainValue, 50.0);
      expect(lot.gainPercent, 25.0);
    });

    test('gainPercent is 0 when investedValue is 0, avoiding division by zero', () {
      final lot = InvestmentLot(
        id: 1,
        ticker: 'PETR4',
        type: InvestmentTypeEnum.STOCKS,
        quantity: 0,
        purchasePrice: 0,
        purchaseDate: DateTime(2026, 1, 1),
        currentPrice: 0,
        investedValue: 0,
        currentValue: 0,
      );

      expect(lot.gainPercent, 0.0);
    });

    group('fromJson', () {
      test('parses all fields, using name as ticker', () {
        final lot = InvestmentLot.fromJson(const {
          'id': 1,
          'name': 'PETR4',
          'type': 'STOCKS',
          'quantity': 10,
          'purchasePrice': 20.0,
          'purchaseDate': '2026-01-01',
          'currentPrice': 25.0,
          'investedValue': 200.0,
          'currentValue': 250.0,
        });

        expect(lot.id, 1);
        expect(lot.ticker, 'PETR4');
        expect(lot.type, InvestmentTypeEnum.STOCKS);
        expect(lot.quantity, 10.0);
        expect(lot.purchasePrice, 20.0);
        expect(lot.purchaseDate, DateTime.parse('2026-01-01'));
        expect(lot.currentPrice, 25.0);
        expect(lot.investedValue, 200.0);
        expect(lot.currentValue, 250.0);
      });

      test('currentPrice defaults to purchasePrice when missing', () {
        final lot = InvestmentLot.fromJson(const {
          'id': 1,
          'name': 'PETR4',
          'type': 'STOCKS',
          'quantity': 10,
          'purchasePrice': 20.0,
          'purchaseDate': '2026-01-01',
        });

        expect(lot.currentPrice, 20.0);
      });

      test('investedValue/currentValue default to quantity * price when missing', () {
        final lot = InvestmentLot.fromJson(const {
          'id': 1,
          'name': 'PETR4',
          'type': 'STOCKS',
          'quantity': 10,
          'purchasePrice': 20.0,
          'purchaseDate': '2026-01-01',
          'currentPrice': 25.0,
        });

        expect(lot.investedValue, 200.0);
        expect(lot.currentValue, 250.0);
      });
    });
  });
}
