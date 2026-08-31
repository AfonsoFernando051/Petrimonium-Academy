import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/passive_income_estimate.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_type_display.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_stats.dart';

class PassiveIncomeEstimator {
  const PassiveIncomeEstimator._();

  static PassiveIncomeEstimate estimate(PortfolioStats stats) {
    if (!stats.hasHoldings) return PassiveIncomeEstimate.empty;

    double annual = 0;
    final monthlyByType = <InvestmentTypeEnum, double>{};

    for (final slice in stats.allocation) {
      final annualForType = slice.currentValue * slice.type.assumedAnnualYield;
      annual += annualForType;
      if (annualForType > 0) monthlyByType[slice.type] = annualForType / 12;
    }

    return PassiveIncomeEstimate(
      monthlyEstimate: annual / 12,
      annualEstimate: annual,
      monthlyByType: monthlyByType,
    );
  }
}
