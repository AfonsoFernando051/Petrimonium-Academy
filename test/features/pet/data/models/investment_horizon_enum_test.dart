import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/pet/data/models/investment_horizon_enum.dart';

void main() {
  group('InvestmentHorizonEnumDisplay', () {
    test('every value has a non-empty label, description and icon', () {
      for (final horizon in InvestmentHorizonEnum.values) {
        expect(horizon.label, isNotEmpty);
        expect(horizon.description, isNotEmpty);
        expect(horizon.icon, isNotNull);
      }
    });

    test('label distinguishes each horizon', () {
      expect(InvestmentHorizonEnum.shortTerm.label, 'Curto Prazo');
      expect(InvestmentHorizonEnum.mediumTerm.label, 'Médio Prazo');
      expect(InvestmentHorizonEnum.longTerm.label, 'Longo Prazo');
    });
  });

  group('InvestmentHorizonEnumDisplay.fromName', () {
    test('resolves a matching name back to its enum value', () {
      for (final horizon in InvestmentHorizonEnum.values) {
        expect(InvestmentHorizonEnumDisplay.fromName(horizon.name), horizon);
      }
    });

    test('falls back to mediumTerm for an unknown or null name', () {
      expect(InvestmentHorizonEnumDisplay.fromName('bogus'), InvestmentHorizonEnum.mediumTerm);
      expect(InvestmentHorizonEnumDisplay.fromName(null), InvestmentHorizonEnum.mediumTerm);
    });
  });
}
