import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/passive_income_estimate.dart';

void main() {
  group('PassiveIncomeEstimate', () {
    test('constructs with the given fields', () {
      const estimate = PassiveIncomeEstimate(
        monthlyEstimate: 100.0,
        annualEstimate: 1200.0,
        monthlyByType: {InvestmentTypeEnum.STOCKS: 60.0, InvestmentTypeEnum.FIXED_INCOME: 40.0},
      );

      expect(estimate.monthlyEstimate, 100.0);
      expect(estimate.annualEstimate, 1200.0);
      expect(estimate.monthlyByType[InvestmentTypeEnum.STOCKS], 60.0);
    });

    test('empty is a zeroed-out constant', () {
      expect(PassiveIncomeEstimate.empty.monthlyEstimate, 0);
      expect(PassiveIncomeEstimate.empty.annualEstimate, 0);
      expect(PassiveIncomeEstimate.empty.monthlyByType, isEmpty);
    });
  });
}
