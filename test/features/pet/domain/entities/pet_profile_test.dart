import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';

void main() {
  group('PetProfile — defaults', () {
    test('has sensible defaults when nothing is provided', () {
      final profile = PetProfile();

      expect(profile.specie, PetSpecieEnum.DOG);
      expect(profile.name, isNull);
      expect(profile.stage, PetEvolutionStage.babyDog);
      expect(profile.netWorth, 0);
      expect(profile.xp, 0);
      expect(profile.animationState, PetAnimationState.idle);
      expect(profile.unlockedAccessories, isEmpty);
      expect(profile.equippedAccessories, isEmpty);
    });

    test('defaults lastActiveAt to roughly now', () {
      final before = DateTime.now();
      final profile = PetProfile();
      final after = DateTime.now();

      expect(
        profile.lastActiveAt.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        profile.lastActiveAt.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });
  });

  group('PetProfile.copyWith', () {
    test('overrides only the given fields, keeping the rest', () {
      final lastActiveAt = DateTime(2024, 1, 1);
      final original = PetProfile(
        specie: PetSpecieEnum.CAT,
        name: 'Bolt',
        stage: PetEvolutionStage.teenDog,
        netWorth: 100,
        xp: 50,
        animationState: PetAnimationState.happy,
        lastActiveAt: lastActiveAt,
      );

      final updated = original.copyWith(xp: 200, stage: PetEvolutionStage.adultDog);

      expect(updated.xp, 200);
      expect(updated.stage, PetEvolutionStage.adultDog);
      // Everything else carries over unchanged.
      expect(updated.specie, PetSpecieEnum.CAT);
      expect(updated.name, 'Bolt');
      expect(updated.netWorth, 100);
      expect(updated.animationState, PetAnimationState.happy);
      expect(updated.lastActiveAt, lastActiveAt);
    });

    test('with no args returns an equal copy', () {
      final original = PetProfile(name: 'Loki', xp: 10);
      final copy = original.copyWith();

      expect(copy, original);
    });

    test('can override accessories maps/sets', () {
      final original = PetProfile();
      final updated = original.copyWith(
        unlockedAccessories: {PetAccessoryId.baseballCap},
        equippedAccessories: {AccessoryType.headwear: PetAccessoryId.baseballCap},
      );

      expect(updated.unlockedAccessories, {PetAccessoryId.baseballCap});
      expect(updated.equippedAccessories, {AccessoryType.headwear: PetAccessoryId.baseballCap});
    });
  });

  group('PetProfile equality', () {
    test('two profiles with the same field values are equal', () {
      final lastActiveAt = DateTime(2024, 6, 1);
      final a = PetProfile(
        specie: PetSpecieEnum.FOX,
        name: 'Max',
        stage: PetEvolutionStage.masterDog,
        netWorth: 500,
        xp: 700,
        animationState: PetAnimationState.think,
        unlockedAccessories: {PetAccessoryId.sunglasses},
        equippedAccessories: {AccessoryType.eyewear: PetAccessoryId.sunglasses},
        lastActiveAt: lastActiveAt,
      );
      final b = PetProfile(
        specie: PetSpecieEnum.FOX,
        name: 'Max',
        stage: PetEvolutionStage.masterDog,
        netWorth: 500,
        xp: 700,
        animationState: PetAnimationState.think,
        unlockedAccessories: {PetAccessoryId.sunglasses},
        equippedAccessories: {AccessoryType.eyewear: PetAccessoryId.sunglasses},
        lastActiveAt: lastActiveAt,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('differs when a single field differs (xp)', () {
      final lastActiveAt = DateTime(2024, 6, 1);
      final a = PetProfile(xp: 10, lastActiveAt: lastActiveAt);
      final b = PetProfile(xp: 20, lastActiveAt: lastActiveAt);

      expect(a == b, isFalse);
    });

    test('unlockedAccessories equality does not depend on insertion order', () {
      final lastActiveAt = DateTime(2024, 6, 1);
      final a = PetProfile(
        lastActiveAt: lastActiveAt,
        unlockedAccessories: {PetAccessoryId.baseballCap, PetAccessoryId.scarf},
      );
      final b = PetProfile(
        lastActiveAt: lastActiveAt,
        unlockedAccessories: {PetAccessoryId.scarf, PetAccessoryId.baseballCap},
      );

      expect(a, b);
    });

    test('equippedAccessories equality compares by key/value, not identity', () {
      final lastActiveAt = DateTime(2024, 6, 1);
      final a = PetProfile(
        lastActiveAt: lastActiveAt,
        equippedAccessories: {AccessoryType.headwear: PetAccessoryId.wizardHat},
      );
      final b = PetProfile(
        lastActiveAt: lastActiveAt,
        equippedAccessories: {AccessoryType.headwear: PetAccessoryId.wizardHat},
      );
      final c = PetProfile(
        lastActiveAt: lastActiveAt,
        equippedAccessories: {AccessoryType.headwear: PetAccessoryId.goldenCrown},
      );

      expect(a, b);
      expect(a == c, isFalse);
    });

    test('a profile equals itself (identical)', () {
      final profile = PetProfile();
      expect(profile, profile);
    });

    test('is not equal to an object of a different type', () {
      final profile = PetProfile();
      // ignore: unrelated_type_equality_checks
      expect(profile == 'not a profile', isFalse);
    });
  });

  test('toString includes the key identifying fields', () {
    final profile = PetProfile(specie: PetSpecieEnum.LION, name: 'Simba', xp: 42);
    final text = profile.toString();

    expect(text, contains('LION'));
    expect(text, contains('Simba'));
    expect(text, contains('42'));
  });
}
