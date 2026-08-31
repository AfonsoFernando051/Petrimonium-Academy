import 'package:petrimonium/features/academy/domain/entities/academy_domain.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_module.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';
import 'package:petrimonium/features/academy/domain/entities/school.dart';
import 'package:petrimonium/features/academy/domain/services/academy_icon_registry.dart';

/// The full Academy curriculum for one language, as fetched from
/// `GET /api/v1/academy/catalog` (see `AcademyCatalogRepository`) — 4 flat
/// lists related to each other by id, exactly like the old hardcoded
/// `AcademyCatalog`/`AcademyDomainCatalog` were. Exposes the same lookup
/// methods those two classes used to (`moduleById`, `lessonsForModule`,
/// `domainForSchool`, `xpEarnedFor`, ...), now as instance methods on a
/// value fetched over the network instead of static getters over a
/// compiled-in table — every other call site's logic is unchanged, only
/// `AcademyCatalog.xxx` becomes `catalog.xxx`.
class AcademyCatalogSnapshot {
  final List<AcademyDomain> domains;
  final List<School> schools;
  final List<AcademyModule> modules;
  final List<Lesson> lessons;

  const AcademyCatalogSnapshot({
    required this.domains,
    required this.schools,
    required this.modules,
    required this.lessons,
  });

  factory AcademyCatalogSnapshot.fromJson(Map<String, dynamic> json) {
    return AcademyCatalogSnapshot(
      domains: (json['domains'] as List<dynamic>).map((e) => _domainFromJson(e as Map<String, dynamic>)).toList(),
      schools: (json['schools'] as List<dynamic>).map((e) => _schoolFromJson(e as Map<String, dynamic>)).toList(),
      modules: (json['modules'] as List<dynamic>).map((e) => _moduleFromJson(e as Map<String, dynamic>)).toList(),
      lessons: (json['lessons'] as List<dynamic>).map((e) => _lessonFromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'domains': domains.map(_domainToJson).toList(),
        'schools': schools.map(_schoolToJson).toList(),
        'modules': modules.map(_moduleToJson).toList(),
        'lessons': lessons.map(_lessonToJson).toList(),
      };

  AcademyModule? moduleById(String id) {
    for (final module in modules) {
      if (module.id == id) return module;
    }
    return null;
  }

  Lesson? lessonById(String id) {
    for (final lesson in lessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  School? schoolById(String id) {
    for (final school in schools) {
      if (school.id == id) return school;
    }
    return null;
  }

  AcademyDomain? domainById(String id) {
    for (final domain in domains) {
      if (domain.id == id) return domain;
    }
    return null;
  }

  /// The domain a given school belongs to, if any — mirrors the old
  /// `AcademyDomainCatalog.domainForSchool`.
  AcademyDomain? domainForSchool(String schoolId) {
    for (final domain in domains) {
      if (domain.schoolIds.contains(schoolId)) return domain;
    }
    return null;
  }

  List<Lesson> lessonsForModule(String moduleId) {
    final result = lessons.where((l) => l.moduleId == moduleId).toList();
    result.sort((a, b) => a.order.compareTo(b.order));
    return result;
  }

  List<AcademyModule> modulesForSchool(String schoolId) {
    final result = modules.where((m) => m.schoolId == schoolId).toList();
    result.sort((a, b) => a.order.compareTo(b.order));
    return result;
  }

  /// Sum of xpReward across every completed lesson id — xpReward is
  /// language-independent (same value in every language's snapshot), so it
  /// doesn't matter which language's snapshot this is called on.
  int xpEarnedFor(Set<String> completedLessonIds) {
    return lessons.where((l) => completedLessonIds.contains(l.id)).fold(0, (sum, l) => sum + l.xpReward);
  }

  static AcademyDomain _domainFromJson(Map<String, dynamic> json) => AcademyDomain(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        icon: AcademyIconRegistry.resolve(json['iconKey'] as String),
        order: json['order'] as int,
        schoolIds: _stringList(json['schoolIds']),
      );

  static Map<String, dynamic> _domainToJson(AcademyDomain d) => {
        'id': d.id,
        'title': d.title,
        'description': d.description,
        'iconKey': AcademyIconRegistry.keyFor(d.icon),
        'order': d.order,
        'schoolIds': d.schoolIds,
      };

  static School _schoolFromJson(Map<String, dynamic> json) => School(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        icon: AcademyIconRegistry.resolve(json['iconKey'] as String),
        order: json['order'] as int,
        prerequisites: _stringList(json['prerequisites']),
        contentAvailable: json['contentAvailable'] as bool,
      );

  static Map<String, dynamic> _schoolToJson(School s) => {
        'id': s.id,
        'title': s.title,
        'description': s.description,
        'iconKey': AcademyIconRegistry.keyFor(s.icon),
        'order': s.order,
        'prerequisites': s.prerequisites,
        'contentAvailable': s.contentAvailable,
      };

  static AcademyModule _moduleFromJson(Map<String, dynamic> json) => AcademyModule(
        id: json['id'] as String,
        schoolId: json['schoolId'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        icon: AcademyIconRegistry.resolve(json['iconKey'] as String),
        order: json['order'] as int,
        lessonIds: _stringList(json['lessonIds']),
        prerequisites: _stringList(json['prerequisites']),
        contentAvailable: json['contentAvailable'] as bool,
      );

  static Map<String, dynamic> _moduleToJson(AcademyModule m) => {
        'id': m.id,
        'schoolId': m.schoolId,
        'title': m.title,
        'description': m.description,
        'iconKey': AcademyIconRegistry.keyFor(m.icon),
        'order': m.order,
        'lessonIds': m.lessonIds,
        'prerequisites': m.prerequisites,
        'contentAvailable': m.contentAvailable,
      };

  static Lesson _lessonFromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'] as String,
        moduleId: json['moduleId'] as String,
        title: json['title'] as String,
        order: json['order'] as int,
        xpReward: json['xpReward'] as int,
        portfolioConcepts: _stringList(json['portfolioConcepts']),
        steps: (json['steps'] as List<dynamic>).map((e) => _stepFromJson(e as Map<String, dynamic>)).toList(),
      );

  static Map<String, dynamic> _lessonToJson(Lesson l) => {
        'id': l.id,
        'moduleId': l.moduleId,
        'title': l.title,
        'order': l.order,
        'xpReward': l.xpReward,
        'portfolioConcepts': l.portfolioConcepts,
        'steps': l.steps.map(_stepToJson).toList(),
      };

  static LessonStep _stepFromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'explanation':
        return ExplanationStep(title: json['title'] as String, body: json['body'] as String);
      case 'example':
        return ExampleStep(title: json['title'] as String, body: json['body'] as String);
      case 'choice_question':
        return ChoiceQuestionStep(
          framing: (json['framing'] as String?) == 'apply' ? ChoiceStepFraming.apply : ChoiceStepFraming.microExercise,
          prompt: json['prompt'] as String,
          options: _stringList(json['options']),
          correctIndex: json['correctIndex'] as int,
          explanation: json['explanation'] as String,
        );
      case 'summary':
        return SummaryStep(title: json['title'] as String, takeaways: _stringList(json['takeaways']));
      default:
        throw ArgumentError('Unknown lesson step type from academy catalog API: $type');
    }
  }

  static Map<String, dynamic> _stepToJson(LessonStep step) {
    return switch (step) {
      ExplanationStep(title: final t, body: final b) => {'type': 'explanation', 'title': t, 'body': b},
      ExampleStep(title: final t, body: final b) => {'type': 'example', 'title': t, 'body': b},
      ChoiceQuestionStep(framing: final f, prompt: final p, options: final o, correctIndex: final c, explanation: final e) => {
          'type': 'choice_question',
          'framing': f == ChoiceStepFraming.apply ? 'apply' : 'micro_exercise',
          'prompt': p,
          'options': o,
          'correctIndex': c,
          'explanation': e,
        },
      SummaryStep(title: final t, takeaways: final tk) => {'type': 'summary', 'title': t, 'takeaways': tk},
    };
  }

  static List<String> _stringList(dynamic value) => (value as List<dynamic>? ?? const []).map((e) => e as String).toList();
}
