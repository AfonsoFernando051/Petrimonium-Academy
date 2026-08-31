import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_message.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_message_catalog.dart';

void main() {
  group('PetMessageCatalog.pageEnter — home', () {
    test(
      'offers the XP-to-next-level nudge once past halfway to the next level',
      () {
        // Level 1->2 needs 50 total XP; 30 is 60% of the way there.
        final message = PetMessageCatalog.pageEnter(
          PetContext.home,
          userXp: 30,
        );

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
        final message = PetMessageCatalog.pageEnter(PetContext.home, userXp: 0);
        expect(message, isNull);
      },
    );

    test(
      'offers nothing right at a level-up boundary (progress resets to 0)',
      () {
        // Level 1->2 needs 50 total XP; landing exactly on it resets progress
        // toward level 2->3, which is also below half.
        final message = PetMessageCatalog.pageEnter(
          PetContext.home,
          userXp: 50,
        );
        expect(message, isNull);
      },
    );

    test(
      'falls back to the review-due nudge when no level-up is imminent but a review is',
      () {
        final message = PetMessageCatalog.pageEnter(
          PetContext.home,
          userXp: 0,
          data: {'reviewDueCount': '3'},
        );

        expect(message, isNotNull);
        // Same id/copy as Academy's own review nudge — the two tabs share one
        // cooldown entry so the user isn't told twice.
        expect(message!.id, 'academy_review_due');
        expect(message.params, {'count': '3'});
      },
    );

    test(
      'falls back to the continue-lesson nudge when no review is due either',
      () {
        final message = PetMessageCatalog.pageEnter(
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
        final message = PetMessageCatalog.pageEnter(
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
        final message = PetMessageCatalog.pageEnter(
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
        final message = PetMessageCatalog.pageEnter(
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
        final message = PetMessageCatalog.pageEnter(
          PetContext.home,
          userXp: 30, // past halfway to the next level, per the test above.
          data: {'missionTitle': 'Aula do Dia'},
        );

        expect(message!.id, 'home_mission_almost_done');
      },
    );

    test(
      'offers a return-after-inactivity greeting once the gap reaches the sleep threshold',
      () {
        final message = PetMessageCatalog.pageEnter(
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
        final message = PetMessageCatalog.pageEnter(
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
        final message = PetMessageCatalog.pageEnter(
          PetContext.home,
          userXp: 0,
          data: {'daysSinceLastSession': '2'},
        );

        expect(message, isNull);
      },
    );
  });

  group('PetMessageCatalog.homeMotivationalFallback', () {
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
        final message = PetMessageCatalog.homeMotivationalFallback();

        expect(motivationalIds, contains(message.id));
        expect(message.context, PetContext.home);
        expect(message.priority, PetMessagePriority.low);
        expect(message.params, isNull);
        expect(message.action, isNull);
      },
    );
  });

  group('PetMessageCatalog.pageEnter — academy', () {
    test(
      'offers a review-due nudge when reviewDueCount > 0, taking priority over a continue nudge',
      () {
        final message = PetMessageCatalog.pageEnter(
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
        final message = PetMessageCatalog.pageEnter(
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
      final message = PetMessageCatalog.pageEnter(
        PetContext.academy,
        userXp: 0,
      );
      expect(message, isNull);
    });

    test('offers nothing when lessonTitle is an empty string', () {
      final message = PetMessageCatalog.pageEnter(
        PetContext.academy,
        userXp: 0,
        data: {'lessonTitle': ''},
      );
      expect(message, isNull);
    });
  });

  group('PetMessageCatalog.pageEnter — portfolio', () {
    test(
      'offers a diversification nudge when spread across more than 1 asset',
      () {
        final message = PetMessageCatalog.pageEnter(
          PetContext.portfolio,
          userXp: 0,
          data: {'count': '3'},
        );

        expect(message, isNotNull);
        expect(message!.id, 'portfolio_diversified');
        expect(message.priority, PetMessagePriority.low);
        expect(message.params, {'count': '3'});
      },
    );

    test(
      'offers nothing at exactly 1 holding — celebrated separately by firstInvestment()',
      () {
        expect(
          PetMessageCatalog.pageEnter(
            PetContext.portfolio,
            userXp: 0,
            data: {'count': '1'},
          ),
          isNull,
        );
      },
    );

    test('offers the activation nudge at 0 holdings (missing count)', () {
      final message = PetMessageCatalog.pageEnter(
        PetContext.portfolio,
        userXp: 0,
      );

      expect(message, isNotNull);
      expect(message!.id, 'portfolio_activation_nudge');
      expect(message.priority, PetMessagePriority.low);
      expect(message.textKey, AppStrings.companionPortfolioActivationNudge);
    });

    test('treats an unparseable count as 0, offering the activation nudge', () {
      final message = PetMessageCatalog.pageEnter(
        PetContext.portfolio,
        userXp: 0,
        data: {'count': 'not-a-number'},
      );
      expect(message, isNotNull);
      expect(message!.id, 'portfolio_activation_nudge');
    });
  });

  group('PetMessageCatalog.investorStatusReaction', () {
    test('returns the already-invests key when true', () {
      expect(
        PetMessageCatalog.investorStatusReaction(alreadyInvests: true),
        AppStrings.companionInvestorStatusYes,
      );
    });

    test('returns the not-yet key when false', () {
      expect(
        PetMessageCatalog.investorStatusReaction(alreadyInvests: false),
        AppStrings.companionInvestorStatusNo,
      );
    });
  });

  group('PetMessageCatalog.pageEnter — mentor and profile', () {
    test('mentor always offers the mentor nudge', () {
      final message = PetMessageCatalog.pageEnter(PetContext.mentor, userXp: 0);
      expect(message, isNotNull);
      expect(message!.id, 'mentor_nudge');
      expect(message.textKey, AppStrings.companionMentorNudge);
    });

    test('profile always offers a level/stage summary', () {
      final message = PetMessageCatalog.pageEnter(
        PetContext.profile,
        userXp: 60,
      );
      expect(message, isNotNull);
      expect(message!.id, 'profile_summary');
      expect(message.textKey, AppStrings.companionProfileSummary);
      expect(message.params?['level'], '2');
    });
  });

  group('PetMessageCatalog — event-triggered reactions', () {
    test('lessonCompleted has a per-lesson id and high priority', () {
      final message = PetMessageCatalog.lessonCompleted('lesson_1');
      expect(message.id, 'event_lesson_completed_lesson_1');
      expect(message.priority, PetMessagePriority.high);
      expect(message.mood, PetAnimationState.victory);
      expect(message.context, PetContext.academy);
    });

    test('xpGained carries the amount', () {
      final message = PetMessageCatalog.xpGained(15);
      expect(message.id, 'event_xp_gained');
      expect(message.params, {'xp': '15'});
      expect(message.priority, PetMessagePriority.normal);
    });

    test('levelUp carries the new level and is high priority', () {
      final message = PetMessageCatalog.levelUp(5);
      expect(message.id, 'event_level_up');
      expect(message.params, {'level': '5'});
      expect(message.priority, PetMessagePriority.high);
      expect(message.mood, PetAnimationState.celebrate);
    });

    test('achievementUnlocked is per-title and high priority', () {
      final message = PetMessageCatalog.achievementUnlocked('Primeira Compra');
      expect(message.id, 'event_achievement_unlocked_Primeira Compra');
      expect(message.params, {'title': 'Primeira Compra'});
      expect(message.context, PetContext.portfolio);
    });

    test('difficultyDetected is per-school and normal priority', () {
      final message = PetMessageCatalog.difficultyDetected('Renda Fixa');
      expect(message.id, 'event_difficulty_detected_Renda Fixa');
      expect(message.params, {'school': 'Renda Fixa'});
      expect(message.priority, PetMessagePriority.normal);
      expect(message.mood, PetAnimationState.think);
    });

    test('schoolMastered is per-school and high priority', () {
      final message = PetMessageCatalog.schoolMastered('Renda Fixa');
      expect(message.id, 'event_school_mastered_Renda Fixa');
      expect(message.params, {'school': 'Renda Fixa'});
      expect(message.priority, PetMessagePriority.high);
    });

    test('evolved carries the new stage\'s label', () {
      final message = PetMessageCatalog.evolved(PetEvolutionStage.royalDog);
      expect(message.id, 'event_evolved');
      expect(message.params, {'stage': 'Real'});
      expect(message.priority, PetMessagePriority.high);
      expect(message.context, PetContext.home);
    });

    test(
      'firstInvestment is high priority with an Academy CTA and no fabricated ticker',
      () {
        final message = PetMessageCatalog.firstInvestment();
        expect(message.id, 'event_first_investment');
        expect(message.priority, PetMessagePriority.high);
        expect(message.mood, PetAnimationState.celebrate);
        expect(message.params, isNull);
        expect(message.action?.destination, PetContext.academy);
      },
    );

    test(
      'highConcentration carries the ticker/percent and bridges to Mentor',
      () {
        final message = PetMessageCatalog.highConcentration('PETR4', 55.4);
        expect(message.id, 'event_high_concentration_PETR4');
        expect(message.priority, PetMessagePriority.normal);
        expect(message.mood, PetAnimationState.think);
        expect(message.params, {'ticker': 'PETR4', 'percent': '55'});
        expect(message.action?.destination, PetContext.mentor);
      },
    );

    test(
      'missionCompleted is per-title, high priority, and mirrors achievementUnlocked\'s shape',
      () {
        final message = PetMessageCatalog.missionCompleted('Aula do Dia');
        expect(message.id, 'event_mission_completed_Aula do Dia');
        expect(message.params, {'title': 'Aula do Dia'});
        expect(message.priority, PetMessagePriority.high);
        expect(message.mood, PetAnimationState.celebrate);
        expect(message.context, PetContext.portfolio);
      },
    );
  });
}
