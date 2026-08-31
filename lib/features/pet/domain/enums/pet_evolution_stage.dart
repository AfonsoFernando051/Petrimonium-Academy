/// The 9 visual evolution tiers the mascot progresses through as the
/// user's financial habits and net worth grow.
///
/// Declaration order is significant: [PetEvolutionStageTier.tier] and every
/// ordinal comparison (`evaluateEvolution` picks the *highest* stage whose
/// rule is satisfied) rely on `PetEvolutionStage.values` being sorted from
/// weakest to strongest.
enum PetEvolutionStage {
  babyDog,
  teenDog,
  adultDog,
  masterDog,
  legendaryDog,
  royalDog,
  cyberMysticDog,
  cosmicGuardianDog,
  goldenFinanceDog,
}

extension PetEvolutionStageTier on PetEvolutionStage {
  /// 1-based tier number (1 = Starter, 9 = Prestige Gold Plated).
  int get tier => PetEvolutionStage.values.indexOf(this) + 1;

  /// File name (without extension) used to look up the fallback PNG under
  /// `assets/mascot/evolutions/` and the Lottie asset when it exists.
  String get assetKey => name;

  /// Tiers 6+ (royal and above) render a decorative aura/glow background
  /// layer behind the mascot.
  bool get hasAura => tier >= 6;

  /// Product-facing stage name, shown wherever the pet's evolution tier is
  /// displayed (`LearningHeroCard`, `RpgIntegrationCard`) — single source of
  /// truth so the two don't drift.
  String get label => switch (this) {
        PetEvolutionStage.babyDog => 'Filhote',
        PetEvolutionStage.teenDog => 'Jovem',
        PetEvolutionStage.adultDog => 'Adulto',
        PetEvolutionStage.masterDog => 'Mestre',
        PetEvolutionStage.legendaryDog => 'Lendário',
        PetEvolutionStage.royalDog => 'Real',
        PetEvolutionStage.cyberMysticDog => 'Ciber-Místico',
        PetEvolutionStage.cosmicGuardianDog => 'Guardião Cósmico',
        PetEvolutionStage.goldenFinanceDog => 'Dourado das Finanças',
      };
}
