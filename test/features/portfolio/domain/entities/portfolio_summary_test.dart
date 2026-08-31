import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_summary.dart';

void main() {
  group('PortfolioSummary', () {
    test('constructs with the given fields', () {
      const summary = PortfolioSummary(
        investedCapital: 1000.0,
        currentValue: 1200.0,
        totalGain: 200.0,
        totalGainPercent: 20.0,
        totalAssets: 5,
      );

      expect(summary.investedCapital, 1000.0);
      expect(summary.currentValue, 1200.0);
      expect(summary.totalGain, 200.0);
      expect(summary.totalGainPercent, 20.0);
      expect(summary.totalAssets, 5);
    });

    test('empty is a zeroed-out constant', () {
      expect(PortfolioSummary.empty.investedCapital, 0);
      expect(PortfolioSummary.empty.currentValue, 0);
      expect(PortfolioSummary.empty.totalGain, 0);
      expect(PortfolioSummary.empty.totalGainPercent, 0);
      expect(PortfolioSummary.empty.totalAssets, 0);
    });

    group('fromJson', () {
      test('parses all fields', () {
        final summary = PortfolioSummary.fromJson(const {
          'investedCapital': 1000,
          'currentValue': 1200,
          'totalGain': 200,
          'totalGainPercent': 20,
          'totalAssets': 5,
        });

        expect(summary.investedCapital, 1000.0);
        expect(summary.currentValue, 1200.0);
        expect(summary.totalGain, 200.0);
        expect(summary.totalGainPercent, 20.0);
        expect(summary.totalAssets, 5);
      });
    });
  });
}
