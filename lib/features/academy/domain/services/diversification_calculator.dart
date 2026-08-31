import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';

/// How concentrated a [DiversificationResult] reads, purely from its
/// largest single weight — thresholds sit below `InsightGenerator`'s
/// existing >40% single-holding alarm so the Lab's own scale stays
/// consistent with what the real Portfolio tab already warns about.
enum ConcentrationBand { wellSpread, moderate, concentrated }

/// The outcome of one [DiversificationCalculator.evaluate] run.
class DiversificationResult {
  /// `false` when the weights don't sum to 100% (within a small tolerance)
  /// — the caller must never silently normalize in that case, only report
  /// [remainderPercent] and let the UI communicate what's missing.
  final bool isValid;

  /// `100 - sum(weights)`, signed — positive means under-allocated,
  /// negative means over-allocated.
  final double remainderPercent;

  /// Herfindahl-Hirschman Index — `sum((weight/100)^2)`. The same formula
  /// `PortfolioHealthCalculator._diversification` uses for the real
  /// Portfolio tab's score, so this simulator teaches the exact metric the
  /// user is scored on elsewhere in the app, not a different invented one.
  final double hhi;

  /// `(1 - hhi) * 100`, clamped to `[0, 100]`.
  final double diversificationScore;

  /// `1 / hhi` — "it's as if you held N equally-weighted assets." `0` when
  /// [isValid] is `false` (never a divide-by-zero `Infinity`).
  final double effectiveNumberOfAssets;

  final InvestmentTypeEnum? largestCategory;
  final double largestWeightPercent;

  /// Impact if the single largest position fell 30% — `largestWeight/100 *
  /// 30`, i.e. proportional to how concentrated that one position is.
  final double concentrationShockImpactPercent;

  /// Impact if every category fell 15% uniformly — always exactly `15`,
  /// **regardless of allocation**. That invariance is the deliberate,
  /// concrete proof that diversification reduces concentration risk but
  /// never eliminates market risk (`docs/DECISIONS.md` DECISION-037) — never
  /// phrase this simulator's copy as "diversified = safe."
  final double marketShockImpactPercent;

  final ConcentrationBand band;

  const DiversificationResult({
    required this.isValid,
    required this.remainderPercent,
    required this.hhi,
    required this.diversificationScore,
    required this.effectiveNumberOfAssets,
    required this.largestCategory,
    required this.largestWeightPercent,
    required this.concentrationShockImpactPercent,
    required this.marketShockImpactPercent,
    required this.band,
  });
}

/// The Financial Lab's Diversification simulator (`docs/DECISIONS.md`
/// DECISION-037) — teaches concentration risk via the same HHI metric the
/// real Portfolio tab scores on, plus two shock scenarios whose contrast
/// (one scales with concentration, one never does) is the actual lesson.
class DiversificationCalculator {
  const DiversificationCalculator._();

  static const double _validityTolerance = 0.01;

  static DiversificationResult evaluate(
    Map<InvestmentTypeEnum, double> weightsPercent,
  ) {
    final sum = weightsPercent.values.fold(0.0, (a, b) => a + b);
    final remainder = 100 - sum;
    final isValid =
        remainder.abs() < _validityTolerance &&
        weightsPercent.values.every((w) => w >= 0);

    final hhi = weightsPercent.values.fold(
      0.0,
      (s, w) => s + (w / 100) * (w / 100),
    );
    final score = ((1 - hhi) * 100).clamp(0, 100).toDouble();

    InvestmentTypeEnum? largestCategory;
    var largestWeight = 0.0;
    weightsPercent.forEach((type, weight) {
      if (weight > largestWeight) {
        largestWeight = weight;
        largestCategory = type;
      }
    });

    final band = largestWeight <= 30
        ? ConcentrationBand.wellSpread
        : (largestWeight <= 50
              ? ConcentrationBand.moderate
              : ConcentrationBand.concentrated);

    return DiversificationResult(
      isValid: isValid,
      remainderPercent: remainder,
      hhi: hhi,
      diversificationScore: score,
      effectiveNumberOfAssets: (isValid && hhi > 0) ? 1 / hhi : 0.0,
      largestCategory: largestCategory,
      largestWeightPercent: largestWeight,
      concentrationShockImpactPercent: largestWeight / 100 * 30,
      marketShockImpactPercent: 15,
      band: band,
    );
  }
}
