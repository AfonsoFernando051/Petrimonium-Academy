import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_type_display.dart';

void main() {
  group('InvestmentTypeDisplay', () {
    test('label/shortLabel/icon/color/idealTargetPercent/assumedAnnualYield are defined for every type', () {
      for (final type in InvestmentTypeEnum.values) {
        expect(type.label, isNotEmpty);
        expect(type.shortLabel, isNotEmpty);
        expect(type.icon, isNotNull);
        expect(type.color, isNotNull);
        expect(type.idealTargetPercent, isA<double>());
        expect(type.assumedAnnualYield, isA<double>());
      }
    });

    test('idealTargetPercent values sum to 100', () {
      final total = InvestmentTypeEnum.values.fold<double>(0, (sum, t) => sum + t.idealTargetPercent);
      expect(total, 100);
    });

    test('crypto and others have zero assumed annual yield', () {
      expect(InvestmentTypeEnum.CRYPTO.assumedAnnualYield, 0.0);
      expect(InvestmentTypeEnum.OTHERS.assumedAnnualYield, 0.0);
    });

    test('label differs from shortLabel for real estate specifically', () {
      expect(InvestmentTypeEnum.REAL_ESTATE.label, 'Fundos Imobiliários');
      expect(InvestmentTypeEnum.REAL_ESTATE.shortLabel, 'FIIs');
    });
  });
}
