import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_accessory.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';

void main() {
  group('PetAccessory', () {
    test('defaults unlocked to false', () {
      const accessory = PetAccessory(id: PetAccessoryId.baseballCap);
      expect(accessory.unlocked, isFalse);
    });

    test('type delegates to the accessory id\'s slot', () {
      const accessory = PetAccessory(id: PetAccessoryId.smartGlasses);
      expect(accessory.type, AccessoryType.eyewear);
    });

    test('copyWith overrides only the given fields', () {
      const accessory = PetAccessory(id: PetAccessoryId.wizardHat, unlocked: false);
      final updated = accessory.copyWith(unlocked: true);

      expect(updated.id, PetAccessoryId.wizardHat);
      expect(updated.unlocked, isTrue);
    });

    test('copyWith with no args returns an equal copy', () {
      const accessory = PetAccessory(id: PetAccessoryId.scarf, unlocked: true);
      final copy = accessory.copyWith();

      expect(copy, accessory);
    });

    test('equality and hashCode are based on id and unlocked', () {
      const a = PetAccessory(id: PetAccessoryId.bowTie, unlocked: true);
      const b = PetAccessory(id: PetAccessoryId.bowTie, unlocked: true);
      const c = PetAccessory(id: PetAccessoryId.bowTie, unlocked: false);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });

    test('toString includes id and unlocked', () {
      const accessory = PetAccessory(id: PetAccessoryId.heroCape, unlocked: true);
      expect(accessory.toString(), contains('heroCape'));
      expect(accessory.toString(), contains('true'));
    });
  });
}
