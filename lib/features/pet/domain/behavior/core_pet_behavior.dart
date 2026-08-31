import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/features/game/domain/services/level_calculator.dart';
import 'package:petrimonium/features/game/domain/services/level_title.dart';
import 'package:petrimonium/features/pet/domain/behavior/pet_behavior.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_message.dart';

/// Reactions to the Pet's own identity/gamification state — XP, level,
/// evolution — which the backend `pet` module owns and both apps share (see
/// `AGENT_CONTEXT`'s pet-state-schema proposal). Neither Academy- nor
/// Wallet-specific, so it isn't part of either app's [PetBehavior]
/// implementation.
class CorePetBehavior extends PetBehavior {
  const CorePetBehavior();

  @override
  PetMessage? pageEnter(
    PetContext context, {
    required int userXp,
    Map<String, String> data = const {},
  }) {
    if (context != PetContext.profile) return null;
    final level = LevelCalculator.fromXp(userXp);
    return PetMessage(
      id: 'profile_summary',
      context: PetContext.profile,
      priority: PetMessagePriority.low,
      trigger: PetMessageTrigger.pageEnter,
      textKey: AppStrings.companionProfileSummary,
      params: {
        'level': '${level.level}',
        'stage': LevelTitle.forLevel(level.level),
      },
      mood: PetAnimationState.idle,
    );
  }

  @override
  PetMessage? onEvent(AppEvent event) {
    return switch (event) {
      XpGainedEvent(:final amount) => PetMessage(
        id: 'event_xp_gained',
        context: PetContext.home,
        priority: PetMessagePriority.normal,
        trigger: PetMessageTrigger.xpGained,
        textKey: AppStrings.companionEventXpGained,
        params: {'xp': '$amount'},
        mood: PetAnimationState.happy,
      ),
      UserLeveledUpEvent(:final newLevel) => PetMessage(
        id: 'event_level_up',
        context: PetContext.home,
        priority: PetMessagePriority.high,
        trigger: PetMessageTrigger.levelUp,
        textKey: AppStrings.companionEventLevelUp,
        params: {'level': '$newLevel'},
        mood: PetAnimationState.celebrate,
      ),
      PetEvolvedEvent(:final newStage) => PetMessage(
        id: 'event_evolved',
        context: PetContext.home,
        priority: PetMessagePriority.high,
        trigger: PetMessageTrigger.evolved,
        textKey: AppStrings.companionEventEvolved,
        params: {'stage': newStage.label},
        mood: PetAnimationState.victory,
      ),
      _ => null,
    };
  }
}
