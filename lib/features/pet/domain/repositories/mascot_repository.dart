import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';

/// Persists the gamification side of the mascot: evolution stage, XP,
/// net worth snapshot and equipped/unlocked accessories. [loadProfile]
/// merges in the real, backend-sourced specie and XP on every call (falling
/// back to the last cached value offline) — see `MascotRepositoryImpl`.
abstract class MascotRepository {
  Future<PetProfile> loadProfile();

  Future<void> saveName(String name);

  Future<void> saveStage(PetEvolutionStage stage);

  Future<void> saveXp(int xp);

  Future<void> saveSpecie(PetSpecieEnum specie);

  Future<void> saveNetWorth(double netWorth);

  Future<void> saveEquippedAccessories(
    Map<AccessoryType, PetAccessoryId> equipped,
  );

  Future<void> saveUnlockedAccessories(Set<PetAccessoryId> unlocked);

  Future<void> saveLastActiveAt(DateTime lastActiveAt);
}
