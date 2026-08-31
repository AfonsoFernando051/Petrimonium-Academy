import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_indicator.dart';

void main() {
  group('AssetIndicator', () {
    test('constructs with the given fields', () {
      const indicator = AssetIndicator(
        id: 'pe',
        label: 'P/E',
        value: '12.3x',
        rawValue: 12.3,
        unit: 'x',
      );

      expect(indicator.id, 'pe');
      expect(indicator.label, 'P/E');
      expect(indicator.value, '12.3x');
      expect(indicator.rawValue, 12.3);
      expect(indicator.unit, 'x');
    });

    group('isAvailable', () {
      test('is true when value is non-null', () {
        const indicator = AssetIndicator(id: 'pe', label: 'P/E', value: '12.3x');
        expect(indicator.isAvailable, isTrue);
      });

      test('is false when value is null, even if rawValue is present', () {
        const indicator = AssetIndicator(id: 'pe', label: 'P/E', rawValue: 12.3);
        expect(indicator.isAvailable, isFalse);
      });
    });
  });
}
