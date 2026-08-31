import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/allocation_slice.dart';

void main() {
  group('AllocationSlice', () {
    test('constructs with the given fields', () {
      const slice = AllocationSlice(
        type: InvestmentTypeEnum.STOCKS,
        currentValue: 1000.0,
        portfolioPercent: 35.0,
      );

      expect(slice.type, InvestmentTypeEnum.STOCKS);
      expect(slice.currentValue, 1000.0);
      expect(slice.portfolioPercent, 35.0);
    });

    group('fromJson', () {
      test('parses type by name and numeric fields as double', () {
        final slice = AllocationSlice.fromJson(const {
          'type': 'FIXED_INCOME',
          'currentValue': 500,
          'portfolioPercent': 25,
        });

        expect(slice.type, InvestmentTypeEnum.FIXED_INCOME);
        expect(slice.currentValue, 500.0);
        expect(slice.portfolioPercent, 25.0);
      });

      test('throws when type is not a known InvestmentTypeEnum name', () {
        expect(
          () => AllocationSlice.fromJson(const {
            'type': 'NOT_A_TYPE',
            'currentValue': 1,
            'portfolioPercent': 1,
          }),
          throwsArgumentError,
        );
      });
    });
  });
}
