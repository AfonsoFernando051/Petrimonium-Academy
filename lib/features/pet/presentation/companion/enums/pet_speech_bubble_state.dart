import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_message.dart';

/// Semantic visual states for the Investor Companion speech bubble, as required
/// by the Investor Companion Art Direction specification (§9).
enum PetSpeechBubbleState {
  /// Normal conversational speech, greetings, ambient nudges.
  idle,

  /// The pet is guiding or helping the user navigate next steps.
  guidance,

  /// The pet is celebrating a completed lesson, XP gain, or achievement.
  success,

  /// The pet offers motivation after a mistake or difficult moment.
  encouragement,

  /// The pet celebrates a major level up, evolution, or milestone.
  milestone,

  /// Contextual alerts, mission updates, or concentration warnings.
  attention,
}

/// Helper extension to map a [PetMessage] to its visual [PetSpeechBubbleState].
extension PetMessageStateResolver on PetMessage {
  PetSpeechBubbleState resolveState() {
    switch (trigger) {
      case PetMessageTrigger.lessonCompleted:
      case PetMessageTrigger.xpGained:
      case PetMessageTrigger.schoolMastered:
      case PetMessageTrigger.achievementUnlocked:
      case PetMessageTrigger.labSimulatorCompleted:
        return PetSpeechBubbleState.success;

      case PetMessageTrigger.levelUp:
      case PetMessageTrigger.evolved:
        return PetSpeechBubbleState.milestone;

      case PetMessageTrigger.difficultyDetected:
        return PetSpeechBubbleState.encouragement;

      case PetMessageTrigger.highConcentration:
      case PetMessageTrigger.missionCompleted:
        return PetSpeechBubbleState.attention;

      case PetMessageTrigger.firstInvestment:
      case PetMessageTrigger.pageEnter:
        if (mood == PetAnimationState.happy ||
            mood == PetAnimationState.celebrate ||
            mood == PetAnimationState.victory) {
          return PetSpeechBubbleState.success;
        } else if (mood == PetAnimationState.think) {
          return PetSpeechBubbleState.guidance;
        }
        return PetSpeechBubbleState.idle;
    }
  }
}
