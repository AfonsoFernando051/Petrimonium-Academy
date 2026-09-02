import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/pet/data/models/investment_horizon_enum.dart';

void main() {
  group('InvestmentHorizonEnumDisplay', () {
    test('every value has a non-empty label', () {
      for (final horizon in InvestmentHorizonEnum.values) {
        expect(horizon.label, isNotEmpty);
      }
    });

    test('label distinguishes each horizon', () {
      expect(InvestmentHorizonEnum.upToOneYear.label, 'Até 1 ano');
      expect(InvestmentHorizonEnum.oneToFiveYears.label, '1 a 5 anos');
      expect(InvestmentHorizonEnum.moreThanFiveYears.label, 'Mais de 5 anos');
      expect(InvestmentHorizonEnum.notSureYet.label, 'Ainda não sei');
    });
  });

  group('InvestmentHorizonEnumDisplay.fromName', () {
    test('resolves a matching name back to its enum value', () {
      for (final horizon in InvestmentHorizonEnum.values) {
        expect(InvestmentHorizonEnumDisplay.fromName(horizon.name), horizon);
      }
    });

    test('falls back to oneToFiveYears for an unknown or null name', () {
      expect(InvestmentHorizonEnumDisplay.fromName('bogus'), InvestmentHorizonEnum.oneToFiveYears);
      expect(InvestmentHorizonEnumDisplay.fromName(null), InvestmentHorizonEnum.oneToFiveYears);
    });
  });
}
