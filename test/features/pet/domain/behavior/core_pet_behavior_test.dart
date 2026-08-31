import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/features/pet/domain/behavior/core_pet_behavior.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_message.dart';

void main() {
  const behavior = CorePetBehavior();

  group('CorePetBehavior.pageEnter — profile', () {
    test('always offers a level/stage summary', () {
      final message = behavior.pageEnter(PetContext.profile, userXp: 60);
      expect(message, isNotNull);
      expect(message!.id, 'profile_summary');
      expect(message.textKey, AppStrings.companionProfileSummary);
      expect(message.params?['level'], '2');
    });
  });

  group('CorePetBehavior.pageEnter — contexts it does not own', () {
    test('offers nothing for home/academy/portfolio/mentor', () {
      for (final context in [
        PetContext.home,
        PetContext.academy,
        PetContext.portfolio,
        PetContext.mentor,
      ]) {
        expect(behavior.pageEnter(context, userXp: 0), isNull);
      }
    });
  });

  group('CorePetBehavior.onEvent', () {
    test('xpGained carries the amount', () {
      final message = behavior.onEvent(
        const XpGainedEvent(amount: 15, newTotalXp: 115),
      );
      expect(message!.id, 'event_xp_gained');
      expect(message.params, {'xp': '15'});
      expect(message.priority, PetMessagePriority.normal);
    });

    test('levelUp carries the new level and is high priority', () {
      final message = behavior.onEvent(const UserLeveledUpEvent(5));
      expect(message!.id, 'event_level_up');
      expect(message.params, {'level': '5'});
      expect(message.priority, PetMessagePriority.high);
      expect(message.mood, PetAnimationState.celebrate);
    });

    test("evolved carries the new stage's label", () {
      final message = behavior.onEvent(
        const PetEvolvedEvent(PetEvolutionStage.royalDog),
      );
      expect(message!.id, 'event_evolved');
      expect(message.params, {'stage': 'Real'});
      expect(message.priority, PetMessagePriority.high);
      expect(message.context, PetContext.home);
    });

    test('offers nothing for events it does not own', () {
      expect(behavior.onEvent(const LessonCompletedEvent('lesson_1')), isNull);
      expect(behavior.onEvent(const FirstInvestmentAddedEvent()), isNull);
    });
  });
}
