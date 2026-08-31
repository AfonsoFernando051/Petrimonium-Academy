import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/portfolio/domain/enums/history_range.dart';
import 'package:petrimonium/features/portfolio/domain/services/wealth_history_calculator.dart';

import 'portfolio_test_fixtures.dart';

DateTime _daysAgo(int days) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return today.subtract(Duration(days: days));
}

void main() {
  group('WealthHistoryCalculator.compute — empty input', () {
    test('no lots produces no points', () {
      expect(WealthHistoryCalculator.compute([], HistoryRange.d7), isEmpty);
    });
  });

  group('WealthHistoryCalculator.compute — single lot over a 7-day window', () {
    // Purchased 5 days ago: 10 units at R$10 -> currentPrice R$20.
    final testLot = lot(quantity: 10, purchasePrice: 10, currentPrice: 20, purchaseDate: _daysAgo(5));
    final points = WealthHistoryCalculator.compute([testLot], HistoryRange.d7);

    test('produces one sample per day across the 7-day window', () {
      expect(points.length, 8); // windowStart..today inclusive = 8 daily samples
    });

    test('dates are in ascending order and the last one is today', () {
      for (var i = 1; i < points.length; i++) {
        expect(points[i].date.isAfter(points[i - 1].date), isTrue);
      }
      final today = DateTime.now();
      final expectedLast = DateTime(today.year, today.month, today.day);
      expect(points.last.date, expectedLast);
    });

    test('samples before the purchase date show zero invested capital and zero value', () {
      final beforePurchase = points.first; // windowStart = 7 days ago, purchase was 5 days ago
      expect(beforePurchase.investedCapital, 0);
      expect(beforePurchase.portfolioValue, 0);
    });

    test('the sample on the purchase date shows the cost basis, no progress toward the gain yet', () {
      final purchaseDaySample = points.firstWhere((p) => p.investedCapital > 0);
      expect(purchaseDaySample.investedCapital, closeTo(100, 0.01)); // 10 * 10
      expect(purchaseDaySample.portfolioValue, closeTo(100, 0.01)); // no progress yet
    });

    test('today\'s sample reflects the full current value (100% progress)', () {
      final todaySample = points.last;
      expect(todaySample.investedCapital, closeTo(100, 0.01));
      expect(todaySample.portfolioValue, closeTo(200, 0.01)); // 10 * 20
      expect(todaySample.profit, closeTo(100, 0.01));
    });
  });

  group('WealthHistoryCalculator.compute — HistoryRange.all', () {
    test('window starts at the earliest purchase date across all lots', () {
      final oldLot = lot(id: 1, ticker: 'OLD', purchaseDate: _daysAgo(40), quantity: 1, purchasePrice: 10, currentPrice: 10);
      final newLot = lot(id: 2, ticker: 'NEW', purchaseDate: _daysAgo(5), quantity: 1, purchasePrice: 10, currentPrice: 10);

      final points = WealthHistoryCalculator.compute([oldLot, newLot], HistoryRange.all);

      expect(points.first.date, _daysAgo(40));
    });
  });

  group('WealthHistoryCalculator.compute — multiple lots on the same day', () {
    test('today\'s sample sums every lot\'s current value', () {
      final lotA = lot(id: 1, ticker: 'A', purchaseDate: _daysAgo(2), quantity: 10, purchasePrice: 10, currentPrice: 10);
      final lotB = lot(id: 2, ticker: 'B', purchaseDate: _daysAgo(2), quantity: 5, purchasePrice: 20, currentPrice: 20);

      final points = WealthHistoryCalculator.compute([lotA, lotB], HistoryRange.d7);
      final todaySample = points.last;

      expect(todaySample.investedCapital, closeTo(100 + 100, 0.01)); // 10*10 + 5*20
      expect(todaySample.portfolioValue, closeTo(100 + 100, 0.01));
    });
  });
}
