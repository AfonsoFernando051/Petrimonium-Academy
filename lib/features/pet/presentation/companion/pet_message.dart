import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';

/// How strongly a [PetMessage] should compete for the single visible speech
/// bubble slot. A [high] message (level-up, evolution) replaces whatever is
/// currently showing; [normal]/[low] never interrupt an equal-or-higher
/// priority message already on screen — see `PetCompanionController`.
enum PetMessagePriority { low, normal, high }

/// What caused a [PetMessage] to be offered. `pageEnter` messages are
/// subject to the cooldown/dismissed-memory rules in
/// `PetCompanionController` (so the same nudge doesn't reappear every visit);
/// event-triggered messages reflect something that genuinely just happened
/// and are not cooled down.
enum PetMessageTrigger {
  pageEnter,
  lessonCompleted,
  xpGained,
  levelUp,
  achievementUnlocked,
  evolved,
  difficultyDetected,
  schoolMastered,
  firstInvestment,
  highConcentration,
  missionCompleted,
  labSimulatorCompleted,
}

/// An optional call-to-action attached to a [PetMessage] — e.g. "Continue
/// Lesson" on an Academy nudge. [destination] is one of the app's real tabs
/// the interaction sheet/dashboard already knows how to open.
class PetMessageAction {
  const PetMessageAction({required this.labelKey, required this.destination});

  /// An `AppStrings` key (resolved via `Translator.translate`), not a raw
  /// label, to follow the app's existing i18n convention.
  final String labelKey;
  final PetContext destination;
}

/// A single thing the pet companion can say. Text is never stored
/// pre-resolved — [textKey] is an `AppStrings` key and [params] are the
/// `Translator.translate` placeholder values, resolved at render time so a
/// mid-session language switch is honored like everywhere else in the app.
///
/// [id] is stable across occurrences of conceptually-the-same message (e.g.
/// always `'home_xp_to_next_level'`, never including the actual XP number)
/// — it is the cooldown/dismissed-memory key, not a unique-per-instance id.
class PetMessage {
  const PetMessage({
    required this.id,
    required this.context,
    required this.priority,
    required this.trigger,
    required this.textKey,
    this.params,
    this.mood = PetAnimationState.idle,
    this.action,
  });

  final String id;
  final PetContext context;
  final PetMessagePriority priority;
  final PetMessageTrigger trigger;
  final String textKey;
  final Map<String, String>? params;

  /// The animation `MascotController.triggerEventAnimation` should play
  /// while this message is showing.
  final PetAnimationState mood;
  final PetMessageAction? action;
}
