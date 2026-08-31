import 'package:flutter/material.dart';

/// The user's main financial-life objective, chosen during onboarding's
/// "Choose Your Financial Goal" step. Framed around life outcomes (per the
/// pet-naming/onboarding redesign) rather than investment-strategy jargon,
/// so it reads as a personal goal, not a risk-tolerance question — that
/// scored assessment is a separate, now-optional step (see `OnboardingScreen`).
enum PetGoalEnum {
  buildWealth,
  generatePassiveIncome,
  retireEarly,
  learnAboutInvesting,
  buyFirstHome,
  travel,
  financialFreedom,
}

extension PetGoalEnumDisplay on PetGoalEnum {
  String get label => switch (this) {
        PetGoalEnum.buildWealth => 'Construir Patrimônio',
        PetGoalEnum.generatePassiveIncome => 'Gerar Renda Passiva',
        PetGoalEnum.retireEarly => 'Aposentar Cedo',
        PetGoalEnum.learnAboutInvesting => 'Aprender a Investir',
        PetGoalEnum.buyFirstHome => 'Comprar Minha Casa',
        PetGoalEnum.travel => 'Viajar',
        PetGoalEnum.financialFreedom => 'Liberdade Financeira',
      };

  String get description => switch (this) {
        PetGoalEnum.buildWealth => 'Crescer meu patrimônio de forma consistente ao longo do tempo.',
        PetGoalEnum.generatePassiveIncome => 'Focar em ativos que geram renda recorrente.',
        PetGoalEnum.retireEarly => 'Construir independência financeira para parar de trabalhar mais cedo.',
        PetGoalEnum.learnAboutInvesting => 'Explorar o app e entender o básico antes de se comprometer.',
        PetGoalEnum.buyFirstHome => 'Juntar para dar entrada no meu primeiro imóvel.',
        PetGoalEnum.travel => 'Guardar dinheiro para viagens e novas experiências.',
        PetGoalEnum.financialFreedom => 'Ter liberdade para escolher como viver, sem depender de um salário.',
      };

  IconData get icon => switch (this) {
        PetGoalEnum.buildWealth => Icons.trending_up,
        PetGoalEnum.generatePassiveIncome => Icons.paid_outlined,
        PetGoalEnum.retireEarly => Icons.beach_access_outlined,
        PetGoalEnum.learnAboutInvesting => Icons.school_outlined,
        PetGoalEnum.buyFirstHome => Icons.home_outlined,
        PetGoalEnum.travel => Icons.flight_takeoff,
        PetGoalEnum.financialFreedom => Icons.rocket_launch,
      };

  static PetGoalEnum fromName(String? name) {
    return PetGoalEnum.values.firstWhere(
      (g) => g.name == name,
      orElse: () => PetGoalEnum.buildWealth,
    );
  }
}
