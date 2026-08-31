import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';

/// A single cosmetic item the user has (or hasn't yet) unlocked.
class PetAccessory {
  final PetAccessoryId id;
  final bool unlocked;

  const PetAccessory({required this.id, this.unlocked = false});

  AccessoryType get type => id.slot;

  PetAccessory copyWith({PetAccessoryId? id, bool? unlocked}) {
    return PetAccessory(
      id: id ?? this.id,
      unlocked: unlocked ?? this.unlocked,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetAccessory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          unlocked == other.unlocked;

  @override
  int get hashCode => Object.hash(id, unlocked);

  @override
  String toString() => 'PetAccessory(id: $id, unlocked: $unlocked)';
}
