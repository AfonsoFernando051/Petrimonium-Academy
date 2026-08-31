import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';

/// The XP threshold a user must reach to unlock [stage].
///
/// The pet represents the learner's educational/practice progression, not
/// their wealth or investment performance (`docs/PRODUCT_VISION.md` §9,
/// §11) — a rule is satisfied purely by accumulated XP from
/// learning/practice actions. Net worth is intentionally not a factor here;
/// see `PetProfile.netWorth`, which is still stored/displayed as a plain
/// portfolio fact, just no longer an evolution gate.
class PetEvolutionRule {
  final PetEvolutionStage stage;
  final int minXp;

  const PetEvolutionRule({
    required this.stage,
    required this.minXp,
  });

  bool isSatisfiedBy({required int xp}) {
    return xp >= minXp;
  }

  PetEvolutionRule copyWith({
    PetEvolutionStage? stage,
    int? minXp,
  }) {
    return PetEvolutionRule(
      stage: stage ?? this.stage,
      minXp: minXp ?? this.minXp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetEvolutionRule &&
          runtimeType == other.runtimeType &&
          stage == other.stage &&
          minXp == other.minXp;

  @override
  int get hashCode => Object.hash(stage, minXp);

  @override
  String toString() => 'PetEvolutionRule(stage: $stage, minXp: $minXp)';

  /// Default tier progression, ordered weakest to strongest. Kept as the
  /// single source of truth for `MascotController.evaluateEvolution`.
  static const List<PetEvolutionRule> defaultRules = [
    PetEvolutionRule(stage: PetEvolutionStage.babyDog, minXp: 0),
    PetEvolutionRule(stage: PetEvolutionStage.teenDog, minXp: 100),
    PetEvolutionRule(stage: PetEvolutionStage.adultDog, minXp: 300),
    PetEvolutionRule(stage: PetEvolutionStage.masterDog, minXp: 600),
    PetEvolutionRule(stage: PetEvolutionStage.legendaryDog, minXp: 1200),
    PetEvolutionRule(stage: PetEvolutionStage.royalDog, minXp: 2500),
    PetEvolutionRule(stage: PetEvolutionStage.cyberMysticDog, minXp: 5000),
    PetEvolutionRule(stage: PetEvolutionStage.cosmicGuardianDog, minXp: 10000),
    PetEvolutionRule(stage: PetEvolutionStage.goldenFinanceDog, minXp: 20000),
  ];
}
