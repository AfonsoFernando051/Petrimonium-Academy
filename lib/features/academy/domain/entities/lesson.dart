import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';

/// A single, short (2-5 minute) unit of the Academy curriculum: a fixed
/// sequence of [steps] worth [xpReward] once completed.
class Lesson {
  final String id;
  final String moduleId;
  final String title;
  final int order;
  final int xpReward;
  final List<LessonStep> steps;

  /// Portfolio indicator ids (matching `IndicatorEducationCatalog`'s ids, e.g.
  /// `"pe"`, `"dy"`, `"roe"`) this lesson genuinely teaches — usually empty.
  /// Authored per-lesson in the backend content, not derived. Drives the
  /// "you just learned about X — here's how it looks on this asset" callback
  /// on the asset-details screen (`PortfolioLearningBridge`) once the lesson
  /// is completed. See `docs/ACADEMY_ENGINE.md`'s Educational Portfolio
  /// Intelligence section.
  final List<String> portfolioConcepts;

  const Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.order,
    required this.xpReward,
    required this.steps,
    this.portfolioConcepts = const [],
  });
}
