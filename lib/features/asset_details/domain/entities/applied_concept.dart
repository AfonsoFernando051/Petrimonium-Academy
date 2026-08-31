import 'package:petrimonium/features/asset_details/domain/entities/asset_indicator.dart';
import 'package:petrimonium/features/asset_details/domain/entities/educational_explanation.dart';

/// A portfolio concept the user has already learned (via a completed Academy
/// lesson) that genuinely applies to the asset currently being viewed — the
/// "you just learned about P/E, here's how it looks on this asset" callback
/// (`docs/ACADEMY_ENGINE.md`'s Educational Portfolio Intelligence section).
///
/// Only ever built from a real, completed lesson and a real, present
/// indicator value on the asset — never fabricated. See
/// `PortfolioLearningBridge`.
class AppliedConcept {
  final AssetIndicator indicator;
  final EducationalExplanation explanation;
  final String lessonId;
  final String lessonTitle;

  const AppliedConcept({
    required this.indicator,
    required this.explanation,
    required this.lessonId,
    required this.lessonTitle,
  });
}
