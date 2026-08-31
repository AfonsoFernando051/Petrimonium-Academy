import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';

/// The full gamification state of a user's mascot: evolution progress, XP,
/// equipped/unlocked accessories and current animation.
class PetProfile {
  final PetSpecieEnum specie;

  /// The companion's name, chosen during onboarding's "Name Your Pet" step.
  /// `null` until the user sets it — used to gate that onboarding step and
  /// to decide whether greetings fall back to a generic label.
  final String? name;
  final PetEvolutionStage stage;
  final double netWorth;
  final int xp;
  final PetAnimationState animationState;
  final Set<PetAccessoryId> unlockedAccessories;

  /// At most one equipped accessory per [AccessoryType] slot.
  final Map<AccessoryType, PetAccessoryId> equippedAccessories;
  final DateTime lastActiveAt;

  PetProfile({
    this.specie = PetSpecieEnum.DOG,
    this.name,
    this.stage = PetEvolutionStage.babyDog,
    this.netWorth = 0,
    this.xp = 0,
    this.animationState = PetAnimationState.idle,
    Set<PetAccessoryId>? unlockedAccessories,
    Map<AccessoryType, PetAccessoryId>? equippedAccessories,
    DateTime? lastActiveAt,
  })  : unlockedAccessories = unlockedAccessories ?? const {},
        equippedAccessories = equippedAccessories ?? const {},
        lastActiveAt = lastActiveAt ?? DateTime.now();

  PetProfile copyWith({
    PetSpecieEnum? specie,
    String? name,
    PetEvolutionStage? stage,
    double? netWorth,
    int? xp,
    PetAnimationState? animationState,
    Set<PetAccessoryId>? unlockedAccessories,
    Map<AccessoryType, PetAccessoryId>? equippedAccessories,
    DateTime? lastActiveAt,
  }) {
    return PetProfile(
      specie: specie ?? this.specie,
      name: name ?? this.name,
      stage: stage ?? this.stage,
      netWorth: netWorth ?? this.netWorth,
      xp: xp ?? this.xp,
      animationState: animationState ?? this.animationState,
      unlockedAccessories: unlockedAccessories ?? this.unlockedAccessories,
      equippedAccessories: equippedAccessories ?? this.equippedAccessories,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetProfile &&
          runtimeType == other.runtimeType &&
          specie == other.specie &&
          name == other.name &&
          stage == other.stage &&
          netWorth == other.netWorth &&
          xp == other.xp &&
          animationState == other.animationState &&
          lastActiveAt == other.lastActiveAt &&
          _setEquals(unlockedAccessories, other.unlockedAccessories) &&
          _mapEquals(equippedAccessories, other.equippedAccessories);

  @override
  int get hashCode => Object.hash(
        specie,
        name,
        stage,
        netWorth,
        xp,
        animationState,
        lastActiveAt,
        Object.hashAllUnordered(unlockedAccessories),
      );

  @override
  String toString() =>
      'PetProfile(specie: $specie, name: $name, stage: $stage, netWorth: $netWorth, xp: $xp, '
      'animationState: $animationState, equipped: $equippedAccessories)';
}

bool _setEquals<T>(Set<T> a, Set<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  return a.containsAll(b);
}

bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (b[entry.key] != entry.value) return false;
  }
  return true;
}
