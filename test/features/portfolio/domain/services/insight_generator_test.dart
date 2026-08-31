import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_stats.dart';
import 'package:petrimonium/features/portfolio/domain/services/insight_generator.dart';

import 'portfolio_test_fixtures.dart';

DateTime _daysAgo(int days) => DateTime.now().subtract(Duration(days: days));

void main() {
  group('InsightGenerator.generate — empty portfolio', () {
    test('produces exactly one insight nudging the user to invest', () {
      final insights = InsightGenerator.generate(PortfolioStats.empty);
      expect(insights, hasLength(1));
      expect(insights.single.title, 'Comece sua jornada');
    });
  });

  group('InsightGenerator.generate — gain/loss framing', () {
    test('a portfolio in profit surfaces a positive-return insight', () {
      final stats = statsFromLots([lot(quantity: 100, purchasePrice: 10, currentPrice: 12, purchaseDate: _daysAgo(1))]);
      final insights = InsightGenerator.generate(stats);
      expect(insights.any((i) => i.title == 'Retorno positivo'), isTrue);
    });

    test('a portfolio down more than 5% surfaces a correction insight, not a positive one', () {
      final stats = statsFromLots([lot(quantity: 100, purchasePrice: 10, currentPrice: 9, purchaseDate: _daysAgo(1))]);
      final insights = InsightGenerator.generate(stats);
      expect(insights.any((i) => i.title == 'Mercado em correção'), isTrue);
      expect(insights.any((i) => i.title == 'Retorno positivo'), isFalse);
    });

    test('a small loss (within 5%) triggers neither framing — noise, not signal', () {
      final stats = statsFromLots([lot(quantity: 100, purchasePrice: 10, currentPrice: 9.8, purchaseDate: _daysAgo(1))]);
      final insights = InsightGenerator.generate(stats);
      expect(insights.any((i) => i.title == 'Mercado em correção'), isFalse);
      expect(insights.any((i) => i.title == 'Retorno positivo'), isFalse);
    });
  });

  group('InsightGenerator.generate — concentration and diversification', () {
    test('a single holding (100% concentration) warns about concentration and low diversification', () {
      final stats = statsFromLots([lot(quantity: 100, purchasePrice: 10, purchaseDate: _daysAgo(1))]);
      final insights = InsightGenerator.generate(stats);
      expect(insights.any((i) => i.title == 'Concentração elevada'), isTrue);
      expect(insights.any((i) => i.title == 'Diversificação baixa'), isTrue);
    });

    test('a well-spread 4-category portfolio triggers neither warning', () {
      final stats = statsFromLots([
        lot(id: 1, ticker: 'A', type: InvestmentTypeEnum.STOCKS, quantity: 100, purchasePrice: 10, purchaseDate: _daysAgo(1)),
        lot(id: 2, ticker: 'B', type: InvestmentTypeEnum.FIXED_INCOME, quantity: 100, purchasePrice: 10, purchaseDate: _daysAgo(1)),
        lot(id: 3, ticker: 'C', type: InvestmentTypeEnum.REAL_ESTATE, quantity: 100, purchasePrice: 10, purchaseDate: _daysAgo(1)),
        lot(id: 4, ticker: 'D', type: InvestmentTypeEnum.FUNDS, quantity: 100, purchasePrice: 10, purchaseDate: _daysAgo(1)),
      ]);
      final insights = InsightGenerator.generate(stats);
      expect(insights.any((i) => i.title == 'Concentração elevada'), isFalse);
      expect(insights.any((i) => i.title == 'Diversificação baixa'), isFalse);
    });
  });

  group('InsightGenerator.generate — contribution cadence', () {
    test('no contribution in 15+ days nudges the user to invest again', () {
      final stats = statsFromLots([lot(quantity: 100, purchasePrice: 10, purchaseDate: _daysAgo(20))]);
      final insights = InsightGenerator.generate(stats);
      expect(insights.any((i) => i.title == 'Sem novos aportes'), isTrue);
    });

    test('a recent contribution does not trigger the nudge', () {
      final stats = statsFromLots([lot(quantity: 100, purchasePrice: 10, purchaseDate: _daysAgo(2))]);
      final insights = InsightGenerator.generate(stats);
      expect(insights.any((i) => i.title == 'Sem novos aportes'), isFalse);
    });

    test('a year-plus track record is recognized as long-term investing', () {
      final stats = statsFromLots([lot(quantity: 100, purchasePrice: 10, purchaseDate: _daysAgo(400))]);
      final insights = InsightGenerator.generate(stats);
      expect(insights.any((i) => i.title == 'Investidor de longo prazo'), isTrue);
    });
  });

  group('InsightGenerator.generate — ordering', () {
    test('insights are sorted by priority, high first', () {
      // A concentrated, unbalanced, recently-untouched portfolio triggers
      // several insights across different priorities at once.
      final stats = statsFromLots([lot(quantity: 100, purchasePrice: 10, currentPrice: 12, purchaseDate: _daysAgo(20))]);
      final insights = InsightGenerator.generate(stats);

      expect(insights.length, greaterThan(1));
      for (var i = 1; i < insights.length; i++) {
        expect(insights[i].priority.index, greaterThanOrEqualTo(insights[i - 1].priority.index));
      }
    });
  });
}
