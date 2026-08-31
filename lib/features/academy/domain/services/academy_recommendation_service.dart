import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/features/academy/data/models/academy_catalog_snapshot.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_recommendation.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/academy/domain/services/academy_progress_calculator.dart';

/// A rough per-lesson time estimate for the Review card ("~N min"). No real
/// per-lesson duration field exists yet — this is a documented
/// approximation (one step ≈ 40s to read/answer), not a measured value.
const int kApproxSecondsPerLessonStep = 40;

/// Derives "what should I do next" (`docs/ACADEMY_ENGINE.md` §3d, brief
/// §20/22/25). Pure functions over the catalog + persisted completion state,
/// same shape as `AcademyProgressCalculator`/`MasteryCalculator` — nothing
/// stored, nothing that can drift from the source of truth.
class AcademyRecommendationService {
  const AcademyRecommendationService._();

  /// Every completed lesson (in a `contentAvailable` module) that wasn't
  /// answered perfectly, in curriculum order — the Review queue.
  static List<Lesson> reviewQueue({
    required AcademyCatalogSnapshot catalog,
    required Set<String> completedIds,
    required Set<String> perfectIds,
  }) {
    final imperfectIds = completedIds.difference(perfectIds);
    if (imperfectIds.isEmpty) return const [];

    final orderedModules = [...catalog.modules.where((m) => m.contentAvailable)]
      ..sort((a, b) => a.order.compareTo(b.order));

    final result = <Lesson>[];
    for (final module in orderedModules) {
      for (final lesson in catalog.lessonsForModule(module.id)) {
        if (imperfectIds.contains(lesson.id)) result.add(lesson);
      }
    }
    return result;
  }

  /// Sum of [reviewQueue]'s lessons' step counts, converted to a rounded
  /// minute estimate (minimum 1 minute if the queue isn't empty).
  static int reviewEstimatedMinutes({
    required AcademyCatalogSnapshot catalog,
    required Set<String> completedIds,
    required Set<String> perfectIds,
  }) {
    final queue = reviewQueue(catalog: catalog, completedIds: completedIds, perfectIds: perfectIds);
    if (queue.isEmpty) return 0;
    final totalSteps = queue.fold<int>(0, (sum, lesson) => sum + lesson.steps.length);
    final seconds = totalSteps * kApproxSecondsPerLessonStep;
    return (seconds / 60).ceil().clamp(1, 999);
  }

  /// Up to two suggestions: the learner's next new lesson (if any remain),
  /// and — when it exists — the single oldest not-yet-perfect completed
  /// lesson, framed as a weak-concept review. Order matters: continuing is
  /// always offered first (this product's single strongest CTA per
  /// `docs/ACADEMY_ENGINE.md` §5), review is a secondary suggestion.
  static List<AcademyRecommendation> recommendationsFor({
    required AcademyCatalogSnapshot catalog,
    required Set<String> completedIds,
    required Set<String> perfectIds,
  }) {
    final recommendations = <AcademyRecommendation>[];

    final next = AcademyProgressCalculator.nextLessonToContinue(catalog: catalog, completedIds: completedIds);
    if (next != null) {
      recommendations.add(
        AcademyRecommendation(
          type: RecommendationType.continueLearning,
          lesson: next,
          reasonKey: AppStrings.academyRecommendationContinueReason,
        ),
      );
    }

    final queue = reviewQueue(catalog: catalog, completedIds: completedIds, perfectIds: perfectIds);
    if (queue.isNotEmpty) {
      recommendations.add(
        AcademyRecommendation(
          type: RecommendationType.review,
          lesson: queue.first,
          reasonKey: AppStrings.academyRecommendationReviewReason,
        ),
      );
    }

    return recommendations;
  }
}
