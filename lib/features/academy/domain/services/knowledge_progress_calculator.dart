import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/data/models/academy_catalog_snapshot.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_domain.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_module.dart';
import 'package:petrimonium/features/academy/domain/entities/knowledge_level.dart';

/// Derives **Knowledge Progress** — how much of the curriculum the learner
/// has actually completed — kept deliberately separate from Game Level
/// (`LevelCalculator`, XP-driven). `docs/PRODUCT_VISION.md` §9: "Level 20
/// does not mean 'advanced investor'" — Knowledge Progress is the honest
/// answer to "how much have I actually learned"; motivational XP is not.
///
/// "Mastery"/"competency" (the brief's term) is modeled here as **per-school
/// completion percent** rather than a second, parallel taxonomy to keep in
/// sync with the School list — a school already is a competency grouping.
///
/// Both are computed only against lessons in `contentAvailable` modules —
/// the same boundary `AcademyProgressCalculator.nextLessonToContinue`/
/// `AcademyCatalogSnapshot.xpEarnedFor` already use — so progress reflects
/// mastery of what's actually offered today, and doesn't retroactively drop
/// every time a new school ships content. Pure functions over the catalog +
/// completed ids, nothing stored.
class KnowledgeProgressCalculator {
  const KnowledgeProgressCalculator._();

  static double overallCompletionPercent(AcademyCatalogSnapshot catalog, Set<String> completedLessonIds) {
    return _completionPercent(
      catalog.modules.where((m) => m.contentAvailable),
      completedLessonIds,
    );
  }

  static double percentForSchool(AcademyCatalogSnapshot catalog, String schoolId, Set<String> completedLessonIds) {
    return _completionPercent(
      catalog.modulesForSchool(schoolId).where((m) => m.contentAvailable),
      completedLessonIds,
    );
  }

  /// Same as [percentForSchool], aggregated across every school belonging to
  /// [domain] — mirrors `AcademyProgressCalculator.domainStatus`'s
  /// aggregation shape.
  static double percentForDomain(AcademyCatalogSnapshot catalog, AcademyDomain domain, Set<String> completedLessonIds) {
    return _completionPercent(
      domain.schoolIds
          .expand(catalog.modulesForSchool)
          .where((m) => m.contentAvailable),
      completedLessonIds,
    );
  }

  static double _completionPercent(Iterable<AcademyModule> modules, Set<String> completedLessonIds) {
    var total = 0;
    var completed = 0;
    for (final module in modules) {
      total += module.lessonIds.length;
      completed += module.lessonIds.where(completedLessonIds.contains).length;
    }
    if (total == 0) return 0;
    return completed / total;
  }

  /// Buckets [percent] (0.0-1.0) into one of the 10 [KnowledgeLevel] tiers.
  static KnowledgeLevel levelForCompletion(double percent) {
    final clamped = percent.clamp(0.0, 1.0);
    final tier = (clamped * 10).floor().clamp(0, 9);
    return KnowledgeLevel.values[tier];
  }

  static String labelFor(KnowledgeLevel level) {
    final key = switch (level) {
      KnowledgeLevel.absoluteBeginner => AppStrings.knowledgeLevelAbsoluteBeginner,
      KnowledgeLevel.financialApprentice => AppStrings.knowledgeLevelFinancialApprentice,
      KnowledgeLevel.financialOrganizer => AppStrings.knowledgeLevelFinancialOrganizer,
      KnowledgeLevel.financialProtector => AppStrings.knowledgeLevelFinancialProtector,
      KnowledgeLevel.beginnerInvestor => AppStrings.knowledgeLevelBeginnerInvestor,
      KnowledgeLevel.investor => AppStrings.knowledgeLevelInvestor,
      KnowledgeLevel.analyst => AppStrings.knowledgeLevelAnalyst,
      KnowledgeLevel.wealthBuilder => AppStrings.knowledgeLevelWealthBuilder,
      KnowledgeLevel.financialStrategist => AppStrings.knowledgeLevelFinancialStrategist,
      KnowledgeLevel.financialMaster => AppStrings.knowledgeLevelFinancialMaster,
    };
    return Translator.translate(key);
  }
}
