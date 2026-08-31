import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/asset_details/domain/entities/applied_concept.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/asset_details/domain/services/indicator_education_catalog.dart';

/// Connects a completed Academy lesson to the asset currently being viewed —
/// the concrete implementation of "Educational Portfolio Intelligence"
/// (`docs/ACADEMY_ENGINE.md` §7, `docs/PRODUCT_VISION.md` §10): the product's
/// core differentiator, closing the Learn → Practice loop.
///
/// A pure function over already-known state (completed lesson ids, the
/// Academy catalog, and this asset's real indicator values) — no network
/// call, no fabrication. A concept only ever surfaces here if (a) the user
/// actually completed a lesson tagged with it, and (b) the asset actually
/// has a real, present value for that indicator today
/// (`AssetIndicator.isAvailable`).
class PortfolioLearningBridge {
  PortfolioLearningBridge._();

  static List<AppliedConcept> resolve({
    required List<Lesson> lessons,
    required Set<String> completedLessonIds,
    required AssetDetails asset,
  }) {
    final lessonByConceptId = <String, Lesson>{};
    for (final lesson in lessons) {
      if (!completedLessonIds.contains(lesson.id)) continue;
      for (final conceptId in lesson.portfolioConcepts) {
        // First-completed lesson for a concept wins if more than one teaches it.
        lessonByConceptId.putIfAbsent(conceptId, () => lesson);
      }
    }
    if (lessonByConceptId.isEmpty) return const [];

    final applied = <AppliedConcept>[];
    for (final indicator in IndicatorEducationCatalog.buildIndicators(asset)) {
      if (!indicator.isAvailable) continue;

      final lesson = lessonByConceptId[indicator.id];
      if (lesson == null) continue;

      final explanation = IndicatorEducationCatalog.getExplanation(indicator.id);
      if (explanation == null) continue;

      applied.add(AppliedConcept(
        indicator: indicator,
        explanation: explanation,
        lessonId: lesson.id,
        lessonTitle: lesson.title,
      ));
    }
    return applied;
  }
}
