import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';

void main() {
  group('PetSpecieEnum', () {
    test('has exactly the seven species mirroring the backend enum', () {
      expect(
        PetSpecieEnum.values,
        containsAll(<PetSpecieEnum>[
          PetSpecieEnum.DOG,
          PetSpecieEnum.CAT,
          PetSpecieEnum.WOLF,
          PetSpecieEnum.FOX,
          PetSpecieEnum.BEAR,
          PetSpecieEnum.LION,
          PetSpecieEnum.OWL,
        ]),
      );
      expect(PetSpecieEnum.values.length, 7);
    });

    test('name matches the backend\'s upper-case wire format for every value', () {
      expect(PetSpecieEnum.DOG.name, 'DOG');
      expect(PetSpecieEnum.CAT.name, 'CAT');
      expect(PetSpecieEnum.WOLF.name, 'WOLF');
      expect(PetSpecieEnum.FOX.name, 'FOX');
      expect(PetSpecieEnum.BEAR.name, 'BEAR');
      expect(PetSpecieEnum.LION.name, 'LION');
      expect(PetSpecieEnum.OWL.name, 'OWL');
    });

    test('firstWhere-by-name round-trips for every value, as used by repositories', () {
      for (final specie in PetSpecieEnum.values) {
        final resolved = PetSpecieEnum.values.firstWhere((s) => s.name == specie.name);
        expect(resolved, specie);
      }
    });
  });
}
