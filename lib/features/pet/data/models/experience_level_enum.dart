/// The user's self-reported investing experience, chosen during onboarding's
/// "Como está sua experiência hoje?" step — lets the Academy skip content
/// the user already knows instead of a one-size-fits-all track. Matches the
/// Notion mockup's 3 options exactly.
enum ExperienceLevelEnum { novice, curious, practitioner }

extension ExperienceLevelEnumDisplay on ExperienceLevelEnum {
  String get label => switch (this) {
    ExperienceLevelEnum.novice => 'Iniciante',
    ExperienceLevelEnum.curious => 'Curioso',
    ExperienceLevelEnum.practitioner => 'Praticante',
  };

  String get description => switch (this) {
    ExperienceLevelEnum.novice => 'Nunca investi',
    ExperienceLevelEnum.curious => 'Já ouvi falar, nunca pratiquei',
    ExperienceLevelEnum.practitioner => 'Já invisto, quero entender melhor',
  };

  String get emoji => switch (this) {
    ExperienceLevelEnum.novice => '🌱',
    ExperienceLevelEnum.curious => '👀',
    ExperienceLevelEnum.practitioner => '📊',
  };

  static ExperienceLevelEnum fromName(String? name) {
    return ExperienceLevelEnum.values.firstWhere(
      (e) => e.name == name,
      orElse: () => ExperienceLevelEnum.novice,
    );
  }
}
