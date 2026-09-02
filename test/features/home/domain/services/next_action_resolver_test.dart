import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/home/domain/entities/next_action.dart';
import 'package:petrimonium/features/home/domain/services/next_action_resolver.dart';
import 'package:petrimonium/features/portfolio/domain/entities/mission_status.dart';

import '../../../academy/academy_test_fixtures.dart';

MissionStatus _mission({
  String code = 'daily_complete_lesson',
  int progress = 0,
  int target = 2,
  bool completed = false,
}) {
  return MissionStatus(
    code: code,
    period: MissionPeriod.daily,
    periodKey: '2026-08-25',
    progress: progress,
    target: target,
    xpReward: 10,
    completed: completed,
  );
}

void main() {
  group('NextActionResolver.resolve', () {
    test('defaults to ContinueLessonAction when a next lesson exists and no mission is urgent', () {
      final action = NextActionResolver.resolve(
        nextLesson: testLesson1,
        moduleTitle: testModule.title,
        missions: const [],
      );

      expect(action, isA<ContinueLessonAction>());
      expect((action as ContinueLessonAction).lesson.id, testLesson1.id);
      expect(action.moduleTitle, testModule.title);
    });

    test('threads module lesson count/completed count/goal label through to ContinueLessonAction', () {
      final action = NextActionResolver.resolve(
        nextLesson: testLesson1,
        moduleTitle: testModule.title,
        missions: const [],
        moduleLessonCount: 4,
        moduleCompletedCount: 1,
        goalLabel: 'Reserva de emergência',
      );

      expect(action, isA<ContinueLessonAction>());
      final continueAction = action as ContinueLessonAction;
      expect(continueAction.moduleLessonCount, 4);
      expect(continueAction.moduleCompletedCount, 1);
      expect(continueAction.goalLabel, 'Reserva de emergência');
    });

    test('falls back to AllLessonsCompleteAction when there is no next lesson and no urgent mission', () {
      final action = NextActionResolver.resolve(nextLesson: null, moduleTitle: null, missions: const []);

      expect(action, isA<AllLessonsCompleteAction>());
    });

    test('a mission one completion away from its target outranks the default continue-lesson action', () {
      final almostDone = _mission(progress: 1, target: 2);
      final action = NextActionResolver.resolve(
        nextLesson: testLesson1,
        moduleTitle: testModule.title,
        missions: [almostDone],
      );

      expect(action, isA<CompleteMissionAction>());
      expect((action as CompleteMissionAction).mission.code, almostDone.code);
    });

    test('a mission with more than one completion remaining does not outrank continue-lesson', () {
      final farFromDone = _mission(progress: 0, target: 3);
      final action = NextActionResolver.resolve(
        nextLesson: testLesson1,
        moduleTitle: testModule.title,
        missions: [farFromDone],
      );

      expect(action, isA<ContinueLessonAction>());
    });

    test('an already-completed mission never re-surfaces as the next action', () {
      final completedMission = _mission(progress: 2, target: 2, completed: true);
      final action = NextActionResolver.resolve(
        nextLesson: testLesson1,
        moduleTitle: testModule.title,
        missions: [completedMission],
      );

      expect(action, isA<ContinueLessonAction>());
    });

    test('picks the first qualifying mission when several are one away', () {
      final first = _mission(code: 'daily_complete_lesson', progress: 1, target: 2);
      final second = _mission(code: 'weekly_complete_module', progress: 2, target: 3);
      final action = NextActionResolver.resolve(nextLesson: null, moduleTitle: null, missions: [first, second]);

      expect(action, isA<CompleteMissionAction>());
      expect((action as CompleteMissionAction).mission.code, 'daily_complete_lesson');
    });
  });
}
