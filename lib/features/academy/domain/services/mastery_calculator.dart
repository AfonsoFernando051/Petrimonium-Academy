import 'package:petrimonium/features/academy/data/models/academy_catalog_snapshot.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_module.dart';
import 'package:petrimonium/features/academy/domain/entities/mastery_tier.dart';

/// Derives **Mastery** — a performance-based signal, deliberately distinct
/// from Progress/completion (`AcademyController.masteryFor`,
/// `KnowledgeProgressCalculator`). Progress answers "how much of the
/// curriculum have I gone through"; Mastery answers "how well do I actually
/// know it" — a school can be 100% complete but only partially mastered if
/// some lessons were finished with a wrong answer along the way
/// (`docs/ACADEMY_ENGINE.md` §3d).
///
/// A lesson's mastery score is a simple three-value heuristic — not
/// completed, completed with at least one missed question, or completed
/// perfectly (every question answered correctly on the first try) — not a
/// continuous accuracy percentage, since only pass/fail-per-question data is
/// tracked today (`AcademyProgressLocalRepository.markLessonPerfect`). This
/// is deliberately simple: a real first implementation, not the brief's full
/// accuracy/decay/consistency model, but shaped so a richer scoring function
/// can replace [lessonMasteryScore] later without touching any call site.
///
/// Pure functions over the catalog + persisted state, mirroring
/// `KnowledgeProgressCalculator`'s exact aggregation shape (same
/// `contentAvailable`-only boundary, same denominator convention) so Progress
/// and Mastery are always computed over the same set of lessons and stay
/// directly comparable.
class MasteryCalculator {
  const MasteryCalculator._();

  static const double _completedNotPerfectScore = 0.55;

  static const double _understandingThreshold = 0.25;
  static const double _applyingThreshold = 0.60;
  static const double _masteringThreshold = 0.85;

  static double lessonMasteryScore({required bool completed, required bool perfect}) {
    if (!completed) return 0.0;
    return perfect ? 1.0 : _completedNotPerfectScore;
  }

  static double percentForModule({
    required AcademyModule module,
    required Set<String> completedIds,
    required Set<String> perfectIds,
  }) {
    if (module.lessonIds.isEmpty) return 0.0;
    final sum = module.lessonIds.fold<double>(
      0,
      (acc, id) => acc +
          lessonMasteryScore(completed: completedIds.contains(id), perfect: perfectIds.contains(id)),
    );
    return sum / module.lessonIds.length;
  }

  static double percentForSchool({
    required AcademyCatalogSnapshot catalog,
    required String schoolId,
    required Set<String> completedIds,
    required Set<String> perfectIds,
  }) {
    final modules = catalog.modulesForSchool(schoolId).where((m) => m.contentAvailable);
    var totalLessons = 0;
    var scoreSum = 0.0;
    for (final module in modules) {
      totalLessons += module.lessonIds.length;
      scoreSum += module.lessonIds.fold<double>(
        0,
        (acc, id) => acc +
            lessonMasteryScore(completed: completedIds.contains(id), perfect: perfectIds.contains(id)),
      );
    }
    if (totalLessons == 0) return 0.0;
    return scoreSum / totalLessons;
  }

  /// Buckets [percent] (0.0-1.0) into one of the 4 [MasteryTier]s.
  static MasteryTier tierForPercent(double percent) {
    final clamped = percent.clamp(0.0, 1.0);
    if (clamped >= _masteringThreshold) return MasteryTier.mastering;
    if (clamped >= _applyingThreshold) return MasteryTier.applying;
    if (clamped >= _understandingThreshold) return MasteryTier.understanding;
    return MasteryTier.exploring;
  }
}
