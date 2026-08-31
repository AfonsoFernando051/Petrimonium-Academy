import 'package:petrimonium/features/academy/domain/services/diversification_calculator.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';

/// A deterministic, named "what if" scenario for [PortfolioScenarioCalculator]
/// — never random, so nothing here can read as a forecast
/// (`docs/DECISIONS.md` DECISION-037).
enum LabScenario {
  equitiesDown15,
  largestPositionDown20,
  broadMarketDown10,
  fixedIncomeUp5,
}

/// One category's contribution to a scenario's total impact.
class CategoryImpact {
  final InvestmentTypeEnum type;
  final double categoryValue;
  final double shockPercent;
  final double contribution;

  const CategoryImpact({
    required this.type,
    required this.categoryValue,
    required this.shockPercent,
    required this.contribution,
  });
}

/// The outcome of one [PortfolioScenarioCalculator.evaluate] run.
class PortfolioScenarioResult {
  /// Mirrors [DiversificationCalculator]'s validity contract — `false` when
  /// the allocation doesn't sum to 100%. The scenario still computes (so
  /// the UI can explain why it's disabled), but the host screen must refuse
  /// to present it as a real result while this is `false`.
  final bool isValid;

  final double totalAmount;
  final double newValue;
  final double deltaAbsolute;
  final double deltaPercent;
  final List<CategoryImpact> categoryImpacts;

  const PortfolioScenarioResult({
    required this.isValid,
    required this.totalAmount,
    required this.newValue,
    required this.deltaAbsolute,
    required this.deltaPercent,
    required this.categoryImpacts,
  });
}

/// The Financial Lab's Portfolio simulator (`docs/DECISIONS.md`
/// DECISION-037) — an educational sandbox showing how a hypothetical
/// portfolio's composition changes its response to different scenarios.
/// Explicitly not a duplicate of the real Portfolio dashboard, and not a
/// forecast: every scenario is a fixed, named, deterministic shock.
class PortfolioScenarioCalculator {
  const PortfolioScenarioCalculator._();

  /// The shock each category takes under [scenario] — always within
  /// `[-1.0, 1.0]` (a category can lose at most its entire value, never go
  /// negative).
  static Map<InvestmentTypeEnum, double> shocksFor(
    LabScenario scenario,
    Map<InvestmentTypeEnum, double> weightsPercent,
  ) {
    switch (scenario) {
      case LabScenario.equitiesDown15:
        return {
          for (final type in weightsPercent.keys)
            type: type == InvestmentTypeEnum.STOCKS ? -0.15 : 0.0,
        };
      case LabScenario.largestPositionDown20:
        InvestmentTypeEnum? largest;
        var largestWeight = -1.0;
        weightsPercent.forEach((type, weight) {
          if (weight > largestWeight) {
            largestWeight = weight;
            largest = type;
          }
        });
        return {
          for (final type in weightsPercent.keys)
            type: type == largest ? -0.20 : 0.0,
        };
      case LabScenario.broadMarketDown10:
        return {for (final type in weightsPercent.keys) type: -0.10};
      case LabScenario.fixedIncomeUp5:
        return {
          for (final type in weightsPercent.keys)
            type: type == InvestmentTypeEnum.FIXED_INCOME ? 0.05 : 0.0,
        };
    }
  }

  static PortfolioScenarioResult evaluate({
    required double totalAmount,
    required Map<InvestmentTypeEnum, double> weightsPercent,
    required LabScenario scenario,
  }) {
    final isValid = DiversificationCalculator.evaluate(weightsPercent).isValid;
    final shocks = shocksFor(scenario, weightsPercent);

    final impacts = <CategoryImpact>[];
    var newValue = 0.0;
    for (final entry in weightsPercent.entries) {
      final categoryValue = totalAmount * entry.value / 100;
      final shock = (shocks[entry.key] ?? 0.0).clamp(-1.0, 1.0);
      final contribution = categoryValue * shock;
      newValue += categoryValue + contribution;
      impacts.add(
        CategoryImpact(
          type: entry.key,
          categoryValue: categoryValue,
          shockPercent: shock * 100,
          contribution: contribution,
        ),
      );
    }

    final deltaAbsolute = newValue - totalAmount;
    final deltaPercent = totalAmount == 0 ? 0.0 : deltaAbsolute / totalAmount * 100;

    return PortfolioScenarioResult(
      isValid: isValid,
      totalAmount: totalAmount,
      newValue: newValue,
      deltaAbsolute: deltaAbsolute,
      deltaPercent: deltaPercent,
      categoryImpacts: impacts,
    );
  }
}
