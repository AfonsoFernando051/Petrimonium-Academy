import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';

void main() {
  test('AccessoryType has exactly the 3 expected slots', () {
    expect(AccessoryType.values, [
      AccessoryType.headwear,
      AccessoryType.eyewear,
      AccessoryType.neckBack,
    ]);
  });
}
