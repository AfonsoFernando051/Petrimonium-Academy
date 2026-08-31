import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_message.dart';

void main() {
  group('PetMessage', () {
    test('defaults mood to idle and action to null when not provided', () {
      const message = PetMessage(
        id: 'test_id',
        context: PetContext.home,
        priority: PetMessagePriority.normal,
        trigger: PetMessageTrigger.pageEnter,
        textKey: AppStrings.companionMentorNudge,
      );

      expect(message.mood, PetAnimationState.idle);
      expect(message.action, isNull);
      expect(message.params, isNull);
    });

    test('carries through every explicitly provided field', () {
      const action = PetMessageAction(
        labelKey: AppStrings.companionActionContinue,
        destination: PetContext.academy,
      );
      const message = PetMessage(
        id: 'event_xp_gained',
        context: PetContext.home,
        priority: PetMessagePriority.high,
        trigger: PetMessageTrigger.xpGained,
        textKey: AppStrings.companionEventXpGained,
        params: {'xp': '10'},
        mood: PetAnimationState.celebrate,
        action: action,
      );

      expect(message.id, 'event_xp_gained');
      expect(message.context, PetContext.home);
      expect(message.priority, PetMessagePriority.high);
      expect(message.trigger, PetMessageTrigger.xpGained);
      expect(message.textKey, AppStrings.companionEventXpGained);
      expect(message.params, {'xp': '10'});
      expect(message.mood, PetAnimationState.celebrate);
      expect(message.action, same(action));
    });
  });

  test('PetMessagePriority is ordered low < normal < high', () {
    expect(PetMessagePriority.low.index, lessThan(PetMessagePriority.normal.index));
    expect(PetMessagePriority.normal.index, lessThan(PetMessagePriority.high.index));
  });

  test('PetMessageAction exposes labelKey and destination', () {
    const action = PetMessageAction(
      labelKey: AppStrings.companionActionViewProgress,
      destination: PetContext.profile,
    );

    expect(action.labelKey, AppStrings.companionActionViewProgress);
    expect(action.destination, PetContext.profile);
  });
}
