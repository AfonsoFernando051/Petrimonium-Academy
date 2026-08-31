import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/asset_details/domain/services/indicator_education_catalog.dart';

void main() {
  group('getExplanation / allExplanations', () {
    test('returns null for an unknown indicator id', () {
      expect(IndicatorEducationCatalog.getExplanation('not-a-real-indicator'), isNull);
    });

    test('returns a real explanation for a known id', () {
      final explanation = IndicatorEducationCatalog.getExplanation('pe');
      expect(explanation, isNotNull);
      expect(explanation!.indicatorId, 'pe');
      expect(explanation.title, isNotEmpty);
      expect(explanation.definition, isNotEmpty);
    });

    test('allExplanations contains every id retrievable via getExplanation', () {
      for (final explanation in IndicatorEducationCatalog.allExplanations) {
        expect(IndicatorEducationCatalog.getExplanation(explanation.indicatorId), explanation);
      }
    });
  });

  group('buildIndicators', () {
    test('never fabricates — only returns indicators for fields that are actually present', () {
      const bare = AssetDetails(ticker: 'PETR4', assetType: 'stock');
      expect(IndicatorEducationCatalog.buildIndicators(bare), isEmpty);
    });

    test('stock: builds P/L, P/VP and DY when those fields are present', () {
      const asset = AssetDetails(
        ticker: 'PETR4',
        assetType: 'stock',
        priceToEarnings: 8.5,
        priceToBook: 1.2,
        dividendYield: 12.3,
      );
      final indicators = IndicatorEducationCatalog.buildIndicators(asset);
      final ids = indicators.map((i) => i.id).toSet();
      expect(ids, {'pe', 'pvp', 'dy'});
    });

    test('bdr falls back to the stock indicator set', () {
      const asset = AssetDetails(ticker: 'AAPL34', assetType: 'bdr', priceToEarnings: 25.0);
      final indicators = IndicatorEducationCatalog.buildIndicators(asset);
      expect(indicators.map((i) => i.id), contains('pe'));
    });

    test('fii: uses pvp (falling back to priceToBook) and never builds a P/L indicator', () {
      const asset = AssetDetails(ticker: 'HGLG11', assetType: 'fii', pvp: 0.95, dividendYield: 9.0);
      final indicators = IndicatorEducationCatalog.buildIndicators(asset);
      final ids = indicators.map((i) => i.id).toSet();
      expect(ids, {'pvp', 'dy'});
      expect(indicators.firstWhere((i) => i.id == 'pvp').rawValue, 0.95);
    });

    test('fii: falls back to priceToBook when pvp is absent', () {
      const asset = AssetDetails(ticker: 'HGLG11', assetType: 'fii', priceToBook: 1.05);
      final indicators = IndicatorEducationCatalog.buildIndicators(asset);
      expect(indicators.single.id, 'pvp');
      expect(indicators.single.rawValue, 1.05);
    });

    test('etf: only builds market cap and DY, never P/L or P/VP', () {
      const asset = AssetDetails(ticker: 'BOVA11', assetType: 'etf', marketCap: 1000000, dividendYield: 5.0, priceToEarnings: 20);
      final indicators = IndicatorEducationCatalog.buildIndicators(asset);
      final ids = indicators.map((i) => i.id).toSet();
      expect(ids, {'market_cap', 'dy'});
    });
  });

  group('suggestedQuestions', () {
    test('always includes the three generic questions plus the beginner-friendly closer', () {
      const asset = AssetDetails(ticker: 'PETR4', assetType: 'unknown');
      final questions = IndicatorEducationCatalog.suggestedQuestions(asset);
      expect(questions.length, 4);
      expect(questions.last, 'Explique como se eu fosse iniciante.');
    });

    test('adds FII-specific questions for a fii asset', () {
      const asset = AssetDetails(ticker: 'HGLG11', assetType: 'fii');
      final questions = IndicatorEducationCatalog.suggestedQuestions(asset);
      expect(questions.length, 7);
      expect(questions, contains('O que é vacância e por que importa?'));
    });

    test('adds stock-specific questions for a stock asset', () {
      const asset = AssetDetails(ticker: 'PETR4', assetType: 'stock');
      final questions = IndicatorEducationCatalog.suggestedQuestions(asset);
      expect(questions, contains('O que o P/L desse ativo significa?'));
    });

    test('adds ETF-specific questions for an etf asset', () {
      const asset = AssetDetails(ticker: 'BOVA11', assetType: 'etf');
      final questions = IndicatorEducationCatalog.suggestedQuestions(asset);
      expect(questions, contains('O que esse ETF replica?'));
    });
  });
}
