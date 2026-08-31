import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_message.dart';
import 'package:petrimonium/features/portfolio/domain/entities/achievement.dart';
import 'package:petrimonium/features/portfolio/domain/services/portfolio_pet_behavior.dart';

void main() {
  const behavior = PortfolioPetBehavior();

  group('PortfolioPetBehavior.pageEnter — portfolio', () {
    test(
      'offers a diversification nudge when spread across more than 1 asset',
      () {
        final message = behavior.pageEnter(
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
      'offers nothing at exactly 1 holding — celebrated separately by onEvent(FirstInvestmentAddedEvent)',
      () {
        expect(
          behavior.pageEnter(
            PetContext.portfolio,
            userXp: 0,
            data: {'count': '1'},
          ),
          isNull,
        );
      },
    );

    test('offers the activation nudge at 0 holdings (missing count)', () {
      final message = behavior.pageEnter(PetContext.portfolio, userXp: 0);

      expect(message, isNotNull);
      expect(message!.id, 'portfolio_activation_nudge');
      expect(message.priority, PetMessagePriority.low);
      expect(message.textKey, AppStrings.companionPortfolioActivationNudge);
    });

    test('treats an unparseable count as 0, offering the activation nudge', () {
      final message = behavior.pageEnter(
        PetContext.portfolio,
        userXp: 0,
        data: {'count': 'not-a-number'},
      );
      expect(message, isNotNull);
      expect(message!.id, 'portfolio_activation_nudge');
    });
  });

  group('PortfolioPetBehavior.investorStatusReaction', () {
    test('returns the already-invests key when true', () {
      expect(
        PortfolioPetBehavior.investorStatusReaction(alreadyInvests: true),
        AppStrings.companionInvestorStatusYes,
      );
    });

    test('returns the not-yet key when false', () {
      expect(
        PortfolioPetBehavior.investorStatusReaction(alreadyInvests: false),
        AppStrings.companionInvestorStatusNo,
      );
    });
  });

  group('PortfolioPetBehavior.pageEnter — mentor', () {
    test('always offers the mentor nudge', () {
      final message = behavior.pageEnter(PetContext.mentor, userXp: 0);
      expect(message, isNotNull);
      expect(message!.id, 'mentor_nudge');
      expect(message.textKey, AppStrings.companionMentorNudge);
    });
  });

  group('PortfolioPetBehavior.pageEnter — contexts it does not own', () {
    test('offers nothing for home/academy/profile', () {
      for (final context in [
        PetContext.home,
        PetContext.academy,
        PetContext.profile,
      ]) {
        expect(behavior.pageEnter(context, userXp: 0), isNull);
      }
    });
  });

  group('PortfolioPetBehavior — event-triggered reactions', () {
    test(
      'firstInvestment is high priority with an Academy CTA and no fabricated ticker',
      () {
        final message = behavior.onEvent(const FirstInvestmentAddedEvent());
        expect(message!.id, 'event_first_investment');
        expect(message.priority, PetMessagePriority.high);
        expect(message.mood, PetAnimationState.celebrate);
        expect(message.params, isNull);
        expect(message.action?.destination, PetContext.academy);
      },
    );

    test(
      'highConcentration carries the ticker/percent and bridges to Mentor',
      () {
        final message = behavior.onEvent(
          const HighConcentrationDetectedEvent(ticker: 'PETR4', percent: 55.4),
        );
        expect(message!.id, 'event_high_concentration_PETR4');
        expect(message.priority, PetMessagePriority.normal);
        expect(message.mood, PetAnimationState.think);
        expect(message.params, {'ticker': 'PETR4', 'percent': '55'});
        expect(message.action?.destination, PetContext.mentor);
      },
    );

    test(
      "missionCompleted is per-title, high priority, and mirrors achievementUnlocked's shape",
      () {
        final message = behavior.onEvent(
          const MissionCompletedEvent('Aula do Dia'),
        );
        expect(message!.id, 'event_mission_completed_Aula do Dia');
        expect(message.params, {'title': 'Aula do Dia'});
        expect(message.priority, PetMessagePriority.high);
        expect(message.mood, PetAnimationState.celebrate);
        expect(message.context, PetContext.portfolio);
      },
    );

    test('achievementUnlocked is per-title and high priority', () {
      final message = behavior.onEvent(
        const AchievementUnlockedEvent(
          Achievement(
            id: 'first_purchase',
            title: 'Primeira Compra',
            description: '',
            icon: Icons.star,
            xpReward: 10,
            unlocked: true,
          ),
        ),
      );
      expect(message!.id, 'event_achievement_unlocked_Primeira Compra');
      expect(message.params, {'title': 'Primeira Compra'});
      expect(message.context, PetContext.portfolio);
    });

    test('offers nothing for events it does not own', () {
      expect(behavior.onEvent(const LessonCompletedEvent('lesson_1')), isNull);
      expect(behavior.onEvent(const UserLeveledUpEvent(2)), isNull);
    });
  });
}
