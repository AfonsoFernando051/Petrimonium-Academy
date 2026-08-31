import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/home/domain/entities/next_action.dart';
import 'package:petrimonium/features/portfolio/domain/entities/mission_status.dart';

/// Ranks the real, currently-known signals from Academy and Portfolio/
/// Missions into Home's single primary CTA — the "Next Action Engine".
/// Pure function over already-loaded state, same shape as
/// `AcademyRecommendationService`/`AcademyProgressCalculator`: nothing
/// stored, nothing that can drift from the source of truth.
///
/// Deliberately narrow: this does not re-rank Academy's own "continue vs
/// review" priority (`docs/ACADEMY_ENGINE.md` §5 already settled that —
/// continuing is always the strongest CTA when nothing more urgent is
/// happening), it only decides whether a real, time-bound mission is close
/// enough to completion to outrank it.
class NextActionResolver {
  const NextActionResolver._();

  static NextAction resolve({
    required Lesson? nextLesson,
    required String? moduleTitle,
    required List<MissionStatus> missions,
  }) {
    final urgentMission = _oneAwayFromCompletion(missions);
    if (urgentMission != null) return CompleteMissionAction(urgentMission);

    if (nextLesson != null) {
      return ContinueLessonAction(lesson: nextLesson, moduleTitle: moduleTitle);
    }

    return const AllLessonsCompleteAction();
  }

  /// The first not-yet-completed mission that needs exactly one more real
  /// completion to finish its current period — `null` if none qualify.
  /// First-match, not "closest to target percent-wise", so behavior is
  /// deterministic when several missions happen to tie.
  static MissionStatus? _oneAwayFromCompletion(List<MissionStatus> missions) {
    for (final mission in missions) {
      if (!mission.completed && mission.target > 0 && mission.target - mission.progress == 1) {
        return mission;
      }
    }
    return null;
  }
}
