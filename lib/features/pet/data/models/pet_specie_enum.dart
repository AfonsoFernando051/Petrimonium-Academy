// ignore_for_file: constant_identifier_names
// Uppercase values mirror the backend's Java enum wire format (see
// PetApp-Backend PetSpecieEnum) and must match exactly for (de)serialization.
enum PetSpecieEnum {
  DOG,
  CAT,
  WOLF,
  FOX,
  BEAR,
  LION,
  OWL
}

extension PetSpecieEnumExtension on PetSpecieEnum {
  String get name => toString().split('.').last;
}
