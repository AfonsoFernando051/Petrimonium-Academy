import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';

void main() {
  group('PetAccessoryId.slot', () {
    test('headwear accessories map to AccessoryType.headwear', () {
      for (final id in [
        PetAccessoryId.baseballCap,
        PetAccessoryId.wizardHat,
        PetAccessoryId.spaceHelmet,
        PetAccessoryId.goldenCrown,
      ]) {
        expect(id.slot, AccessoryType.headwear, reason: id.name);
      }
    });

    test('eyewear accessories map to AccessoryType.eyewear', () {
      for (final id in [PetAccessoryId.smartGlasses, PetAccessoryId.sunglasses]) {
        expect(id.slot, AccessoryType.eyewear, reason: id.name);
      }
    });

    test('neck/back accessories map to AccessoryType.neckBack', () {
      for (final id in [
        PetAccessoryId.bowTie,
        PetAccessoryId.scarf,
        PetAccessoryId.headphones,
        PetAccessoryId.backpack,
        PetAccessoryId.angelWings,
        PetAccessoryId.heroCape,
      ]) {
        expect(id.slot, AccessoryType.neckBack, reason: id.name);
      }
    });
  });

  test('assetKey matches the enum name for every accessory', () {
    for (final id in PetAccessoryId.values) {
      expect(id.assetKey, id.name);
    }
  });

  test('every AccessoryType has at least one accessory', () {
    for (final type in AccessoryType.values) {
      expect(PetAccessoryId.values.any((id) => id.slot == type), isTrue, reason: type.name);
    }
  });
}
