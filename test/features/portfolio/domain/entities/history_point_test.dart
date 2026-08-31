import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/portfolio/domain/entities/history_point.dart';

void main() {
  group('HistoryPoint', () {
    test('constructs with the given fields', () {
      final point = HistoryPoint(
        date: DateTime(2026, 1, 1),
        investedCapital: 1000.0,
        portfolioValue: 1200.0,
      );

      expect(point.date, DateTime(2026, 1, 1));
      expect(point.investedCapital, 1000.0);
      expect(point.portfolioValue, 1200.0);
    });

    group('profit', () {
      test('is portfolioValue minus investedCapital', () {
        final point = HistoryPoint(
          date: DateTime(2026, 1, 1),
          investedCapital: 1000.0,
          portfolioValue: 1200.0,
        );
        expect(point.profit, 200.0);
      });

      test('can be negative when the portfolio is underwater', () {
        final point = HistoryPoint(
          date: DateTime(2026, 1, 1),
          investedCapital: 1000.0,
          portfolioValue: 800.0,
        );
        expect(point.profit, -200.0);
      });
    });

    group('fromJson', () {
      test('parses date and numeric fields', () {
        final point = HistoryPoint.fromJson(const {
          'date': '2026-01-15',
          'investedCapital': 500,
          'portfolioValue': 600,
        });

        expect(point.date, DateTime.parse('2026-01-15'));
        expect(point.investedCapital, 500.0);
        expect(point.portfolioValue, 600.0);
      });
    });
  });
}
