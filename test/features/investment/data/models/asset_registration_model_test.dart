import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/investment/data/models/asset_registration_model.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';

void main() {
  group('AssetRegistrationModel.toJson', () {
    test('serializes every field, using the enum\'s wire name for type', () {
      final model = AssetRegistrationModel(
        name: 'PETR4',
        quantity: 10.5,
        purchasePrice: 32.1,
        purchaseDate: '2024-03-01',
        type: InvestmentTypeEnum.STOCKS,
      );

      expect(model.toJson(), {
        'name': 'PETR4',
        'quantity': 10.5,
        'purchasePrice': 32.1,
        'purchaseDate': '2024-03-01',
        'type': 'STOCKS',
      });
    });

    test('serializes each InvestmentTypeEnum value under its own name', () {
      for (final type in InvestmentTypeEnum.values) {
        final model = AssetRegistrationModel(
          name: 'X',
          quantity: 1,
          purchasePrice: 1,
          purchaseDate: '2024-01-01',
          type: type,
        );

        expect(model.toJson()['type'], type.name);
      }
    });
  });
}
