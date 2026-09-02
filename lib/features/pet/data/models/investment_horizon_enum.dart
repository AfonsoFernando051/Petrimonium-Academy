/// How long the user expects to keep investing before needing the money
/// back, chosen during onboarding's "Para quando é esse objetivo?" step.
/// Matches the Notion mockup's 4 concrete options exactly (a "not sure yet"
/// option, not just three abstract terms).
enum InvestmentHorizonEnum { upToOneYear, oneToFiveYears, moreThanFiveYears, notSureYet }

extension InvestmentHorizonEnumDisplay on InvestmentHorizonEnum {
  String get label => switch (this) {
    InvestmentHorizonEnum.upToOneYear => 'Até 1 ano',
    InvestmentHorizonEnum.oneToFiveYears => '1 a 5 anos',
    InvestmentHorizonEnum.moreThanFiveYears => 'Mais de 5 anos',
    InvestmentHorizonEnum.notSureYet => 'Ainda não sei',
  };

  static InvestmentHorizonEnum fromName(String? name) {
    return InvestmentHorizonEnum.values.firstWhere(
      (h) => h.name == name,
      orElse: () => InvestmentHorizonEnum.oneToFiveYears,
    );
  }
}
