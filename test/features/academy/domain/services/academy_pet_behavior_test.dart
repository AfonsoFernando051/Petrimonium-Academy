import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/features/academy/domain/services/academy_pet_behavior.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_message.dart';

void main() {
  const behavior = AcademyPetBehavior();

  group('AcademyPetBehavior.pageEnter — home', () {
    test(
      'offers the XP-to-next-level nudge once past halfway to the next level',
      () {
        // Level 1->2 needs 50 total XP; 30 is 60% of the way there.
        final message = behavior.pageEnter(PetContext.home, userXp: 30);

        expect(message, isNotNull);
        expect(message!.id, 'home_xp_to_next_level');
        expect(message.context, PetContext.home);
        expect(message.priority, PetMessagePriority.normal);
        expect(message.textKey, AppStrings.companionHomeXpToNextLevel);
        expect(message.params, {'xp': '20'});
        expect(message.mood, PetAnimationState.happy);
        expect(message.action?.destination, PetContext.profile);
      },
    );

    test(
      'offers nothing when progress toward the next level is below half',
      () {
        final message = behavior.pageEnter(PetContext.home, userXp: 0);
        expect(message, isNull);
      },
    );

    test(
      'offers nothing right at a level-up boundary (progress resets to 0)',
      () {
        final message = behavior.pageEnter(PetContext.home, userXp: 50);
        expect(message, isNull);
      },
    );

    test(
      'falls back to the review-due nudge when no level-up is imminent but a review is',
      () {
        final message = behavior.pageEnter(
          PetContext.home,
          userXp: 0,
          data: {'reviewDueCount': '3'},
        );

        expect(message, isNotNull);
        expect(message!.id, 'academy_review_due');
        expect(message.params, {'count': '3'});
      },
    );

    test(
      'falls back to the continue-lesson nudge when no review is due either',
      () {
        final message = behavior.pageEnter(
          PetContext.home,
          userXp: 0,
          data: {'lessonTitle': 'Renda Fixa Básica'},
        );

        expect(message, isNotNull);
        expect(message!.id, 'academy_continue_lesson');
        expect(message.params, {'lessonTitle': 'Renda Fixa Básica'});
      },
    );

    test(
      'prioritizes the imminent level-up over the continue/review fallback',
      () {
        final message = behavior.pageEnter(
          PetContext.home,
          userXp: 30,
          data: {'reviewDueCount': '3'},
        );

        expect(message!.id, 'home_xp_to_next_level');
      },
    );

    test(
      'offers nothing when neither a level-up nor review/continue data is available',
      () {
        final message = behavior.pageEnter(
          PetContext.home,
          userXp: 0,
          data: const {},
        );
        expect(message, isNull);
      },
    );

    test(
      'offers the mission-almost-done nudge when a missionTitle is supplied',
      () {
        final message = behavior.pageEnter(
          PetContext.home,
          userXp: 0,
          data: {'missionTitle': 'Aula do Dia'},
        );

        expect(message, isNotNull);
        expect(message!.id, 'home_mission_almost_done');
        expect(message.textKey, AppStrings.companionHomeMissionAlmostDone);
        expect(message.params, {'missionTitle': 'Aula do Dia'});
        expect(message.priority, PetMessagePriority.normal);
      },
    );

    test(
      'the mission-almost-done nudge outranks the imminent level-up nudge',
      () {
        final message = behavior.pageEnter(
          PetContext.home,
          userXp: 30,
          data: {'missionTitle': 'Aula do Dia'},
        );

        expect(message!.id, 'home_mission_almost_done');
      },
    );

    test(
      'offers a return-after-inactivity greeting once the gap reaches the sleep threshold',
      () {
        final message = behavior.pageEnter(
          PetContext.home,
          userXp: 0,
          data: {'daysSinceLastSession': '3'},
        );

        expect(message, isNotNull);
        expect(message!.id, startsWith('home_return_greeting_'));
        expect(
          message.textKey,
          anyOf(
            AppStrings.companionHomeReturnGreeting1,
            AppStrings.companionHomeReturnGreeting2,
          ),
        );
      },
    );

    test(
      'the return greeting outranks the mission-almost-done and level-up nudges',
      () {
        final message = behavior.pageEnter(
          PetContext.home,
          userXp: 30,
          data: {'missionTitle': 'Aula do Dia', 'daysSinceLastSession': '4'},
        );

        expect(message!.id, startsWith('home_return_greeting_'));
      },
    );

    test(
      'a gap shorter than the sleep threshold does not trigger the return greeting',
      () {
        final message = behavior.pageEnter(
          PetContext.home,
          userXp: 0,
          data: {'daysSinceLastSession': '2'},
        );

        expect(message, isNull);
      },
    );
  });

  group('AcademyPetBehavior.ambientFallback', () {
    const motivationalIds = {
      'home_motivation_1',
      'home_motivation_2',
      'home_motivation_3',
      'home_motivation_4',
      'home_motivation_5',
    };

    test(
      'is always one of the known pool entries, low priority, and content-free',
      () {
        final message = behavior.ambientFallback();

        expect(motivationalIds, contains(message.id));
        expect(message.context, PetContext.home);
        expect(message.priority, PetMessagePriority.low);
        expect(message.params, isNull);
        expect(message.action, isNull);
      },
    );
  });

  group('AcademyPetBehavior.pageEnter — academy', () {
    test(
      'offers a review-due nudge when reviewDueCount > 0, taking priority over a continue nudge',
      () {
        final message = behavior.pageEnter(
          PetContext.academy,
          userXp: 0,
          data: {'reviewDueCount': '3', 'lessonTitle': 'Renda Fixa'},
        );

        expect(message, isNotNull);
        expect(message!.id, 'academy_review_due');
        expect(message.textKey, AppStrings.companionAcademyReviewDue);
        expect(message.params, {'count': '3'});
      },
    );

    test(
      'offers a continue-lesson nudge when there is a lesson title and no review due',
      () {
        final message = behavior.pageEnter(
          PetContext.academy,
          userXp: 0,
          data: {'lessonTitle': 'Renda Fixa'},
        );

        expect(message, isNotNull);
        expect(message!.id, 'academy_continue_lesson');
        expect(message.textKey, AppStrings.companionAcademyContinueLesson);
        expect(message.params, {'lessonTitle': 'Renda Fixa'});
        expect(message.action?.destination, PetContext.academy);
      },
    );

    test('offers nothing when there is no review due and no lesson title', () {
      final message = behavior.pageEnter(PetContext.academy, userXp: 0);
      expect(message, isNull);
    });

    test('offers nothing when lessonTitle is an empty string', () {
      final message = behavior.pageEnter(
        PetContext.academy,
        userXp: 0,
        data: {'lessonTitle': ''},
      );
      expect(message, isNull);
    });
  });

  group('AcademyPetBehavior.pageEnter — contexts it does not own', () {
    test('offers nothing for portfolio/mentor/profile', () {
      for (final context in [
        PetContext.portfolio,
        PetContext.mentor,
        PetContext.profile,
      ]) {
        expect(behavior.pageEnter(context, userXp: 0), isNull);
      }
    });
  });

  group('AcademyPetBehavior — event-triggered reactions', () {
    test('lessonCompleted has a per-lesson id and high priority', () {
      final message = behavior.onEvent(const LessonCompletedEvent('lesson_1'));
      expect(message!.id, 'event_lesson_completed_lesson_1');
      expect(message.priority, PetMessagePriority.high);
      expect(message.mood, PetAnimationState.victory);
      expect(message.context, PetContext.academy);
    });

    test('difficultyDetected is per-school and normal priority', () {
      final message = behavior.onEvent(
        const DifficultyDetectedEvent('Renda Fixa'),
      );
      expect(message!.id, 'event_difficulty_detected_Renda Fixa');
      expect(message.params, {'school': 'Renda Fixa'});
      expect(message.priority, PetMessagePriority.normal);
      expect(message.mood, PetAnimationState.think);
    });

    test('schoolMastered is per-school and high priority', () {
      final message = behavior.onEvent(const SchoolMasteredEvent('Renda Fixa'));
      expect(message!.id, 'event_school_mastered_Renda Fixa');
      expect(message.params, {'school': 'Renda Fixa'});
      expect(message.priority, PetMessagePriority.high);
    });

    test('labSimulatorCompleted is per-simulator and high priority', () {
      final message = behavior.onEvent(
        const FinancialLabSimulatorCompletedEvent('Juros Compostos'),
      );
      expect(message!.id, 'event_lab_simulator_completed_Juros Compostos');
      expect(message.params, {'simulator': 'Juros Compostos'});
      expect(message.priority, PetMessagePriority.high);
      expect(message.mood, PetAnimationState.victory);
    });

    test('offers nothing for events it does not own', () {
      expect(behavior.onEvent(const FirstInvestmentAddedEvent()), isNull);
      expect(behavior.onEvent(const UserLeveledUpEvent(2)), isNull);
    });
  });

  group('AcademyPetBehavior.questionFeedbackTitle', () {
    test('picks a deterministic title from the correct/incorrect pool', () {
      final correct = AcademyPetBehavior.questionFeedbackTitle(
        correct: true,
        seed: 0,
      );
      final incorrect = AcademyPetBehavior.questionFeedbackTitle(
        correct: false,
        seed: 0,
      );
      expect(correct, isNot(incorrect));
    });
  });
}
