import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/utils/pet_assets.dart';

void main() {
  group('PetAssets.imageFor', () {
    test('resolves a known species to its asset path', () {
      expect(PetAssets.imageFor('fox'), 'assets/images/generated_fox.png');
    });

    test('lower-cases the species regardless of how it was stored', () {
      expect(PetAssets.imageFor('FOX'), 'assets/images/generated_fox.png');
      expect(PetAssets.imageFor('Dog'), 'assets/images/generated_dog.png');
    });

    test('falls back to the default species (dog) when null', () {
      expect(PetAssets.imageFor(null), 'assets/images/generated_dog.png');
    });

    test('falls back to the default species when blank', () {
      expect(PetAssets.imageFor(''), 'assets/images/generated_dog.png');
      expect(PetAssets.imageFor('   '), 'assets/images/generated_dog.png');
    });

    test('trims surrounding whitespace', () {
      expect(PetAssets.imageFor('  cat  '), 'assets/images/generated_cat.png');
    });

    test('every species produces a distinct path', () {
      const species = ['dog', 'cat', 'wolf', 'fox', 'bear', 'lion'];
      final paths = species.map(PetAssets.imageFor).toSet();
      expect(paths.length, species.length);
    });
  });
}
