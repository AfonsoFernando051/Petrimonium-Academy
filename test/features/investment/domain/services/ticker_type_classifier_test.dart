import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/investment/domain/services/ticker_type_classifier.dart';

void main() {
  group('TickerTypeClassifier.classify', () {
    test('classifies tickers ending in 11 as REAL_ESTATE', () {
      expect(TickerTypeClassifier.classify('HGLG11'), InvestmentTypeEnum.REAL_ESTATE);
      expect(TickerTypeClassifier.classify('mxrf11'), InvestmentTypeEnum.REAL_ESTATE);
    });

    test('classifies single-digit-suffix tickers as STOCKS', () {
      expect(TickerTypeClassifier.classify('PETR4'), InvestmentTypeEnum.STOCKS);
      expect(TickerTypeClassifier.classify('ITSA3'), InvestmentTypeEnum.STOCKS);
    });

    test('classifies known ETF tickers ending in 11 as FUNDS, not REAL_ESTATE', () {
      expect(TickerTypeClassifier.classify('WRLD11'), InvestmentTypeEnum.FUNDS);
      expect(TickerTypeClassifier.classify('bova11'), InvestmentTypeEnum.FUNDS);
      expect(TickerTypeClassifier.classify('IVVB11'), InvestmentTypeEnum.FUNDS);
    });

    test('returns null for ambiguous two-digit suffixes (BDR/ETF/unit)', () {
      expect(TickerTypeClassifier.classify('AAPL34'), isNull);
      expect(TickerTypeClassifier.classify('BOVA39'), isNull);
    });

    test('returns null for free-text names (Renda Fixa, crypto, Outros)', () {
      expect(TickerTypeClassifier.classify('Tesouro Selic 2029'), isNull);
      expect(TickerTypeClassifier.classify('CDB Banco X'), isNull);
      expect(TickerTypeClassifier.classify('BTC'), isNull);
    });
  });
}
