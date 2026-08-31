import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_radii.dart';

void main() {
  group('AppRadii', () {
    test('scale is strictly increasing sm < md < lg < xl < xxl', () {
      expect(AppRadii.sm, lessThan(AppRadii.md));
      expect(AppRadii.md, lessThan(AppRadii.lg));
      expect(AppRadii.lg, lessThan(AppRadii.xl));
      expect(AppRadii.xl, lessThan(AppRadii.xxl));
    });

    test('pill exceeds any realistic widget dimension', () {
      expect(AppRadii.pill, greaterThan(AppRadii.xxl));
      expect(AppRadii.pill, 999);
    });
  });
}
