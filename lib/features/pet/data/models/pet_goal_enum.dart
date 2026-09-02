import 'package:flutter/material.dart';

/// The user's main financial-life objective, chosen during onboarding's
/// "Qual é o seu objetivo agora?" step. Matches the Notion mockup's 5
/// options exactly (a 6th option exists in the mockup but its label is cut
/// off in every capture available — left out rather than guessed).
enum PetGoalEnum {
  emergencyFund,
  getOutOfDebt,
  buyImportantThing,
  investWithConfidence,
  justWantToLearn,
}

extension PetGoalEnumDisplay on PetGoalEnum {
  String get label => switch (this) {
        PetGoalEnum.emergencyFund => 'Reserva de emergência',
        PetGoalEnum.getOutOfDebt => 'Sair das dívidas',
        PetGoalEnum.buyImportantThing => 'Comprar algo importante',
        PetGoalEnum.investWithConfidence => 'Investir com confiança',
        PetGoalEnum.justWantToLearn => 'Só quero aprender',
      };

  /// The mockup's goal-picker card uses a literal emoji per option (not a
  /// monochrome icon) — this is what [_GoalCard] renders. [icon] below
  /// stays available for the handful of places (e.g. the onboarding summary
  /// row) that need an `IconData` instead.
  String get emoji => switch (this) {
        PetGoalEnum.emergencyFund => '🆘',
        PetGoalEnum.getOutOfDebt => '⚖️',
        PetGoalEnum.buyImportantThing => '🎯',
        PetGoalEnum.investWithConfidence => '📈',
        PetGoalEnum.justWantToLearn => '🌱',
      };

  IconData get icon => switch (this) {
        PetGoalEnum.emergencyFund => Icons.health_and_safety_outlined,
        PetGoalEnum.getOutOfDebt => Icons.balance,
        PetGoalEnum.buyImportantThing => Icons.track_changes_outlined,
        PetGoalEnum.investWithConfidence => Icons.trending_up,
        PetGoalEnum.justWantToLearn => Icons.eco_outlined,
      };

  static PetGoalEnum fromName(String? name) {
    return PetGoalEnum.values.firstWhere(
      (g) => g.name == name,
      orElse: () => PetGoalEnum.investWithConfidence,
    );
  }
}
