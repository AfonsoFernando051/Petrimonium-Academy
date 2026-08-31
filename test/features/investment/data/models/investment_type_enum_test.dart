import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';

void main() {
  group('InvestmentTypePayout.paysDividends', () {
    test('is true for stocks, real estate and funds', () {
      expect(InvestmentTypeEnum.STOCKS.paysDividends, isTrue);
      expect(InvestmentTypeEnum.REAL_ESTATE.paysDividends, isTrue);
      expect(InvestmentTypeEnum.FUNDS.paysDividends, isTrue);
    });

    test('is false for fixed income, crypto and others', () {
      expect(InvestmentTypeEnum.FIXED_INCOME.paysDividends, isFalse);
      expect(InvestmentTypeEnum.CRYPTO.paysDividends, isFalse);
      expect(InvestmentTypeEnum.OTHERS.paysDividends, isFalse);
    });

    test('covers every enum value with no default fallthrough gap', () {
      for (final type in InvestmentTypeEnum.values) {
        // Merely calling the getter would throw if the switch were
        // non-exhaustive for a newly added value.
        expect(type.paysDividends, isA<bool>());
      }
    });
  });
}
