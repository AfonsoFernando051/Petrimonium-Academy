import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/portfolio/domain/entities/mission_status.dart';

/// Home's single, ranked answer to "what should I do now" — see
/// `NextActionResolver`. Exactly one variant is ever active at a time; the
/// screen renders whichever is current as its one primary CTA rather than
/// juggling several competing cards for that slot.
sealed class NextAction {
  const NextAction();
}

/// The default, most common state: resume the learner's real next lesson.
/// This remains the product's strongest CTA when nothing more urgent is
/// happening (`docs/ACADEMY_ENGINE.md` §5 — continuing is always offered
/// first) — [NextActionResolver] only ranks something above it when there's
/// a genuine, time-bound reason to.
class ContinueLessonAction extends NextAction {
  final Lesson lesson;

  /// Resolved by the caller (which already has the loaded catalog in
  /// scope) — `null` while the catalog is still loading.
  final String? moduleTitle;

  const ContinueLessonAction({required this.lesson, this.moduleTitle});
}

/// A real mission is exactly one lesson completion away from finishing —
/// worth surfacing above the default continue-lesson action since it's a
/// genuine, time-bound (daily/weekly) opportunity that would otherwise stay
/// invisible on Home (missions render only on the Portfolio tab).
class CompleteMissionAction extends NextAction {
  final MissionStatus mission;

  const CompleteMissionAction(this.mission);
}

/// Every currently-available lesson has been completed — there's genuinely
/// nothing left to continue. Distinct from a loading/error state.
class AllLessonsCompleteAction extends NextAction {
  const AllLessonsCompleteAction();
}
