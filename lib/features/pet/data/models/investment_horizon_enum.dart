import 'package:flutter/material.dart';

/// How long the user expects to keep investing before needing the money
/// back, chosen during pet profile creation. Mirrors the onboarding
/// assessment's "horizonte de tempo" question, kept as a standalone
/// selection here rather than a scored risk input.
enum InvestmentHorizonEnum { shortTerm, mediumTerm, longTerm }

extension InvestmentHorizonEnumDisplay on InvestmentHorizonEnum {
  String get label => switch (this) {
    InvestmentHorizonEnum.shortTerm => 'Curto Prazo',
    InvestmentHorizonEnum.mediumTerm => 'Médio Prazo',
    InvestmentHorizonEnum.longTerm => 'Longo Prazo',
  };

  String get description => switch (this) {
    InvestmentHorizonEnum.shortTerm => 'Menos de 1 ano.',
    InvestmentHorizonEnum.mediumTerm => 'De 1 a 5 anos.',
    InvestmentHorizonEnum.longTerm => 'Mais de 5 anos.',
  };

  /// A growth metaphor (sprout → park → mountain) rather than literal clocks
  /// — reinforces "further out = more mature" for the onboarding Time
  /// Horizon screen, where this is shown as a large icon per option.
  IconData get icon => switch (this) {
    InvestmentHorizonEnum.shortTerm => Icons.eco_outlined,
    InvestmentHorizonEnum.mediumTerm => Icons.park_outlined,
    InvestmentHorizonEnum.longTerm => Icons.terrain_outlined,
  };

  static InvestmentHorizonEnum fromName(String? name) {
    return InvestmentHorizonEnum.values.firstWhere(
      (h) => h.name == name,
      orElse: () => InvestmentHorizonEnum.mediumTerm,
    );
  }
}
