import 'package:petrimonium/features/academy/data/models/academy_catalog_snapshot.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_domain.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_module.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/academy/domain/entities/school.dart';

enum LessonStatus { locked, available, completed }

enum ModuleStatus { comingSoon, locked, available, inProgress, completed }

enum SchoolStatus { comingSoon, locked, available, inProgress, completed }

/// Pure functions deriving lesson/module progression state from an
/// [AcademyCatalogSnapshot] crossed with the set of completed lesson ids
/// (persisted). Nothing here is stored as a separate value that could drift
/// from the source of truth.
class AcademyProgressCalculator {
  const AcademyProgressCalculator._();

  /// A lesson unlocks once the previous lesson in its module is completed;
  /// the first lesson of a module is always available.
  static LessonStatus lessonStatus({
    required AcademyCatalogSnapshot catalog,
    required Lesson lesson,
    required Set<String> completedIds,
  }) {
    if (completedIds.contains(lesson.id)) return LessonStatus.completed;

    final moduleLessons = catalog.lessonsForModule(lesson.moduleId);
    final index = moduleLessons.indexWhere((l) => l.id == lesson.id);
    if (index <= 0) return LessonStatus.available;

    final previous = moduleLessons[index - 1];
    return completedIds.contains(previous.id) ? LessonStatus.available : LessonStatus.locked;
  }

  /// [module.prerequisites] (other module ids) are checked before a module
  /// with real content is ever offered as `available` — a module with no
  /// prerequisites is unaffected, so no pre-existing module can regress from
  /// `available`/`inProgress`/`completed` to `locked` by this check alone.
  ///
  /// Bug fix: prerequisite satisfaction is checked via [_isModuleCompleted]
  /// against the catalog, not via `completedIds.contains(prerequisiteId)`
  /// directly — [completedIds] is a set of *lesson* ids, and a prerequisite
  /// entry is a *module* id, so the two string spaces never intersect. Any
  /// module with a non-empty `prerequisites` list was therefore permanently
  /// `locked`, for every user, with no way to ever satisfy it.
  static ModuleStatus moduleStatus({
    required AcademyCatalogSnapshot catalog,
    required AcademyModule module,
    required Set<String> completedIds,
  }) {
    if (!module.contentAvailable || module.lessonIds.isEmpty) return ModuleStatus.comingSoon;
    if (module.prerequisites.any((id) => !_isModuleCompleted(catalog, id, completedIds))) return ModuleStatus.locked;

    final completedInModule = module.lessonIds.where(completedIds.contains).length;
    if (completedInModule == 0) return ModuleStatus.available;
    if (completedInModule == module.lessonIds.length) return ModuleStatus.completed;
    return ModuleStatus.inProgress;
  }

  /// Same shape as [moduleStatus], aggregated across the school's modules
  /// with real content: `comingSoon` if the school itself isn't available
  /// yet or has no such modules, `locked` if an unmet school-level
  /// prerequisite blocks it, otherwise derived from how many of those
  /// modules are complete.
  ///
  /// Same bug fix as [moduleStatus]: prerequisite entries are *school* ids,
  /// checked via [_isSchoolCompleted] against the catalog rather than
  /// against [completedIds] (lesson ids) directly.
  static SchoolStatus schoolStatus({
    required AcademyCatalogSnapshot catalog,
    required School school,
    required Set<String> completedIds,
  }) {
    if (!school.contentAvailable) return SchoolStatus.comingSoon;
    if (school.prerequisites.any((id) => !_isSchoolCompleted(catalog, id, completedIds))) return SchoolStatus.locked;

    final modules = catalog.modulesForSchool(school.id).where((m) => m.contentAvailable).toList();
    if (modules.isEmpty) return SchoolStatus.comingSoon;

    final statuses = modules.map((m) => moduleStatus(catalog: catalog, module: m, completedIds: completedIds)).toList();
    if (statuses.every((s) => s == ModuleStatus.completed)) return SchoolStatus.completed;
    if (statuses.any((s) => s == ModuleStatus.completed || s == ModuleStatus.inProgress)) {
      return SchoolStatus.inProgress;
    }
    return SchoolStatus.available;
  }

  /// Whether every lesson of module [moduleId] has been completed — the
  /// definition [moduleStatus] itself uses for `ModuleStatus.completed`,
  /// factored out so a *different* module's prerequisite check can ask the
  /// same question without going through the public [moduleStatus] API (and
  /// its own prerequisite gate, which is irrelevant to "is this module's
  /// own content done").
  static bool _isModuleCompleted(AcademyCatalogSnapshot catalog, String moduleId, Set<String> completedIds) {
    final module = catalog.moduleById(moduleId);
    if (module == null || !module.contentAvailable || module.lessonIds.isEmpty) return false;
    return module.lessonIds.every(completedIds.contains);
  }

  /// Whether every content-available module of school [schoolId] is
  /// completed — same reasoning as [_isModuleCompleted], one level up.
  static bool _isSchoolCompleted(AcademyCatalogSnapshot catalog, String schoolId, Set<String> completedIds) {
    final school = catalog.schoolById(schoolId);
    if (school == null || !school.contentAvailable) return false;
    final modules = catalog.modulesForSchool(schoolId).where((m) => m.contentAvailable).toList();
    if (modules.isEmpty) return false;
    return modules.every((m) => _isModuleCompleted(catalog, m.id, completedIds));
  }

  /// Same shape as [schoolStatus], aggregated across a domain's member
  /// schools with real content — see `AcademyDomain`'s doc comment on why
  /// domain status is always derived, never stored.
  static SchoolStatus domainStatus({
    required AcademyCatalogSnapshot catalog,
    required AcademyDomain domain,
    required Set<String> completedIds,
  }) {
    final schools = domain.schoolIds
        .map(catalog.schoolById)
        .whereType<School>()
        .where((s) => s.contentAvailable)
        .toList();
    if (schools.isEmpty) return SchoolStatus.comingSoon;

    final statuses = schools.map((s) => schoolStatus(catalog: catalog, school: s, completedIds: completedIds)).toList();
    if (statuses.every((s) => s == SchoolStatus.completed)) return SchoolStatus.completed;
    if (statuses.any((s) => s == SchoolStatus.completed || s == SchoolStatus.inProgress)) {
      return SchoolStatus.inProgress;
    }
    return SchoolStatus.available;
  }

  /// The next lesson the learner should continue with: the first
  /// not-yet-completed lesson of the first module with real content,
  /// scanning domain → school → module → lesson in curriculum order. `null`
  /// once every available lesson is completed.
  ///
  /// Bug fix: `module.order`/`school.order` are scoped to their parent
  /// (school/domain respectively), not globally unique — a flat sort of
  /// every module in the catalog by its own `order` alone ties across
  /// schools (every school's modules restart at `order: 1`), so the pick
  /// depended on an unstable sort rather than the learner's actual place in
  /// the curriculum. Walking the domain → school → module hierarchy, sorting
  /// only siblings against each other, is what "curriculum order" actually
  /// means for a per-parent-scoped `order` field.
  static Lesson? nextLessonToContinue({required AcademyCatalogSnapshot catalog, required Set<String> completedIds}) {
    final orderedDomains = [...catalog.domains]..sort((a, b) => a.order.compareTo(b.order));
    for (final domain in orderedDomains) {
      final schools = domain.schoolIds.map(catalog.schoolById).whereType<School>().toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      for (final school in schools) {
        for (final module in catalog.modulesForSchool(school.id)) {
          if (moduleStatus(catalog: catalog, module: module, completedIds: completedIds) == ModuleStatus.locked) continue;
          if (!module.contentAvailable) continue;
          for (final lesson in catalog.lessonsForModule(module.id)) {
            if (!completedIds.contains(lesson.id)) return lesson;
          }
        }
      }
    }
    return null;
  }

  /// Titles of the prerequisite modules [module] is still missing, in
  /// catalog order — empty if [module] isn't locked on a prerequisite, or
  /// has none. Powers the "Complete X first" explanation on a locked module
  /// card instead of an unexplained lock icon.
  static List<String> missingModulePrerequisiteTitles({
    required AcademyCatalogSnapshot catalog,
    required AcademyModule module,
    required Set<String> completedIds,
  }) {
    return module.prerequisites
        .where((id) => !_isModuleCompleted(catalog, id, completedIds))
        .map((id) => catalog.moduleById(id)?.title)
        .whereType<String>()
        .toList();
  }

  /// Same as [missingModulePrerequisiteTitles], for a locked school.
  static List<String> missingSchoolPrerequisiteTitles({
    required AcademyCatalogSnapshot catalog,
    required School school,
    required Set<String> completedIds,
  }) {
    return school.prerequisites
        .where((id) => !_isSchoolCompleted(catalog, id, completedIds))
        .map((id) => catalog.schoolById(id)?.title)
        .whereType<String>()
        .toList();
  }
}
