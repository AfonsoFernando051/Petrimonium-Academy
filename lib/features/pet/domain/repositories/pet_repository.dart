import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';

/// Contract for reading and writing the user's core pet record
/// (specie selection, activation status, raw pet payload).
abstract class PetRepository {
  Future<void> configurePet(PetSpecieEnum specie);

  Future<bool> getPetStatus();

  Future<Map<String, dynamic>?> getMyPet();
}
