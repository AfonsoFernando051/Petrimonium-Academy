import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';

void main() {
  test('has exactly 9 stages in ascending order', () {
    expect(PetEvolutionStage.values, hasLength(9));
  });

  group('tier', () {
    test('is 1-based and matches declaration order', () {
      for (var i = 0; i < PetEvolutionStage.values.length; i++) {
        expect(PetEvolutionStage.values[i].tier, i + 1);
      }
    });

    test('babyDog is tier 1 and goldenFinanceDog is tier 9', () {
      expect(PetEvolutionStage.babyDog.tier, 1);
      expect(PetEvolutionStage.goldenFinanceDog.tier, 9);
    });
  });

  group('assetKey', () {
    test('matches the enum name for every stage', () {
      for (final stage in PetEvolutionStage.values) {
        expect(stage.assetKey, stage.name);
      }
    });
  });

  group('hasAura', () {
    test('is false for tiers below 6', () {
      for (final stage in [
        PetEvolutionStage.babyDog,
        PetEvolutionStage.teenDog,
        PetEvolutionStage.adultDog,
        PetEvolutionStage.masterDog,
        PetEvolutionStage.legendaryDog,
      ]) {
        expect(stage.hasAura, isFalse, reason: stage.name);
      }
    });

    test('is true for tier 6 and above', () {
      for (final stage in [
        PetEvolutionStage.royalDog,
        PetEvolutionStage.cyberMysticDog,
        PetEvolutionStage.cosmicGuardianDog,
        PetEvolutionStage.goldenFinanceDog,
      ]) {
        expect(stage.hasAura, isTrue, reason: stage.name);
      }
    });
  });

  group('label', () {
    test('every stage has a distinct, non-empty product-facing label', () {
      final labels = PetEvolutionStage.values.map((s) => s.label).toSet();
      expect(labels, hasLength(PetEvolutionStage.values.length));
      for (final label in labels) {
        expect(label, isNotEmpty);
      }
    });

    test('babyDog is labeled Filhote', () {
      expect(PetEvolutionStage.babyDog.label, 'Filhote');
    });

    test('goldenFinanceDog is labeled Dourado das Finanças', () {
      expect(PetEvolutionStage.goldenFinanceDog.label, 'Dourado das Finanças');
    });
  });
}
