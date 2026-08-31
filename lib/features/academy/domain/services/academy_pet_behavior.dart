import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/features/game/domain/services/level_calculator.dart';
import 'package:petrimonium/features/pet/domain/behavior/pet_behavior.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_message.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart'
    show kSleepAfterInactiveDays;

/// Academy's Pet reaction script — lessons completed, quizzes passed, review
/// due, Financial Lab simulators finished, and Home's "what should I learn
/// next" nudge. Tone: playful, expressive, celebratory (brief §1.4). Owns
/// [PetContext.home] and [PetContext.academy] and implements the shared
/// [PetBehavior] contract so it stays isolated from — and swappable with —
/// Wallet's own implementation (`PortfolioPetBehavior`), which reacts to
/// real-portfolio events instead. `PetCompanionController` composes both
/// rather than either one hardcoding reactions inline.
class AcademyPetBehavior extends PetBehavior {
  const AcademyPetBehavior();

  @override
  PetMessage? pageEnter(
    PetContext context, {
    required int userXp,
    Map<String, String> data = const {},
  }) {
    return switch (context) {
      PetContext.home => _homeNudge(userXp, data),
      PetContext.academy => _academyNudge(data),
      _ => null,
    };
  }

  /// Home's own "what should I do next" answer, checked in order of how
  /// contextually relevant each real signal is right now:
  /// 1. a return-after-inactivity greeting (`data['daysSinceLastSession']`)
  ///    — restoring context for a returning user outranks everything else;
  /// 2. a mission one lesson away from completion (`data['missionTitle']`)
  ///    — matches whichever `NextAction` `NextActionResolver` picked as
  ///    Home's headline CTA, so the pet's words and the card agree (this can
  ///    currently be a real-portfolio mission title supplied by Home — see
  ///    the cross-repo contract note on `NextActionResolver`);
  /// 3. a near-level-up nudge;
  /// 4. otherwise, the exact same review/continue-lesson nudge Academy
  ///    offers, so the two tabs share one cooldown/dedup entry.
  PetMessage? _homeNudge(int userXp, Map<String, String> data) {
    final returnGreeting = _returnGreeting(data);
    if (returnGreeting != null) return returnGreeting;

    final missionTitle = data['missionTitle'];
    if (missionTitle != null && missionTitle.isNotEmpty) {
      return PetMessage(
        id: 'home_mission_almost_done',
        context: PetContext.home,
        priority: PetMessagePriority.normal,
        trigger: PetMessageTrigger.pageEnter,
        textKey: AppStrings.companionHomeMissionAlmostDone,
        params: {'missionTitle': missionTitle},
        mood: PetAnimationState.think,
        action: const PetMessageAction(
          labelKey: AppStrings.companionActionContinue,
          destination: PetContext.home,
        ),
      );
    }

    final level = LevelCalculator.fromXp(userXp);
    if (level.progress >= 0.5) {
      final remaining = level.xpForNextLevel - level.xpIntoLevel;
      if (remaining > 0) {
        return PetMessage(
          id: 'home_xp_to_next_level',
          context: PetContext.home,
          priority: PetMessagePriority.normal,
          trigger: PetMessageTrigger.pageEnter,
          textKey: AppStrings.companionHomeXpToNextLevel,
          params: {'xp': '$remaining'},
          mood: PetAnimationState.happy,
          action: const PetMessageAction(
            labelKey: AppStrings.companionActionViewProgress,
            destination: PetContext.profile,
          ),
        );
      }
    }

    return _academyNudge(data);
  }

  /// A returning-user greeting for whenever the pet was resting long enough
  /// to have gone to sleep — never guilt-based, just a warm restoration of
  /// context. A small rotating pool, picked by the exact gap length so it's
  /// deterministic and testable.
  PetMessage? _returnGreeting(Map<String, String> data) {
    final days = int.tryParse(data['daysSinceLastSession'] ?? '');
    if (days == null || days < kSleepAfterInactiveDays) return null;

    const pool = [
      ('home_return_greeting_1', AppStrings.companionHomeReturnGreeting1),
      ('home_return_greeting_2', AppStrings.companionHomeReturnGreeting2),
    ];
    final (id, textKey) = pool[days % pool.length];
    return PetMessage(
      id: id,
      context: PetContext.home,
      priority: PetMessagePriority.normal,
      trigger: PetMessageTrigger.pageEnter,
      textKey: textKey,
      mood: PetAnimationState.happy,
    );
  }

  PetMessage? _academyNudge(Map<String, String> data) {
    final reviewDueCount = int.tryParse(data['reviewDueCount'] ?? '') ?? 0;
    if (reviewDueCount > 0) return _reviewDueNudge(reviewDueCount);

    final lessonTitle = data['lessonTitle'];
    if (lessonTitle == null || lessonTitle.isEmpty) return null;

    return PetMessage(
      id: 'academy_continue_lesson',
      context: PetContext.academy,
      priority: PetMessagePriority.normal,
      trigger: PetMessageTrigger.pageEnter,
      textKey: AppStrings.companionAcademyContinueLesson,
      params: {'lessonTitle': lessonTitle},
      mood: PetAnimationState.think,
      action: const PetMessageAction(
        labelKey: AppStrings.companionActionContinue,
        destination: PetContext.academy,
      ),
    );
  }

  /// Offered instead of the plain continue nudge once lessons are due for
  /// review — never punitive, just a gentle reminder.
  PetMessage _reviewDueNudge(int count) {
    return PetMessage(
      id: 'academy_review_due',
      context: PetContext.academy,
      priority: PetMessagePriority.normal,
      trigger: PetMessageTrigger.pageEnter,
      textKey: AppStrings.companionAcademyReviewDue,
      params: {'count': '$count'},
      mood: PetAnimationState.think,
      action: const PetMessageAction(
        labelKey: AppStrings.companionActionContinue,
        destination: PetContext.academy,
      ),
    );
  }

  /// A small, rotating pool of genuinely content-free encouragement — no XP,
  /// lesson, or portfolio figure is referenced. Tried by
  /// `PetCompanionController` both when [pageEnter] returns nothing *and*
  /// when it returns a real nudge that's still cooling down.
  static const List<(String id, String textKey)> _motivationalMessages = [
    ('home_motivation_1', AppStrings.companionHomeMotivation1),
    ('home_motivation_2', AppStrings.companionHomeMotivation2),
    ('home_motivation_3', AppStrings.companionHomeMotivation3),
    ('home_motivation_4', AppStrings.companionHomeMotivation4),
    ('home_motivation_5', AppStrings.companionHomeMotivation5),
  ];

  @override
  PetMessage ambientFallback() {
    final (id, textKey) =
        _motivationalMessages[DateTime.now().day %
            _motivationalMessages.length];
    return PetMessage(
      id: id,
      context: PetContext.home,
      priority: PetMessagePriority.low,
      trigger: PetMessageTrigger.pageEnter,
      textKey: textKey,
      mood: PetAnimationState.idle,
    );
  }

  // ── In-lesson question feedback ─────────────────────────────────────────
  //
  // Not a [PetMessage] — this is local, immediate, per-question feedback
  // rendered inline by `ChoiceQuestionStepView`'s existing feedback card, not
  // routed through `PetCompanionController`. There's nothing to suppress
  // here (a wrong answer is never penalized), so the cooldown/priority
  // machinery a real `PetMessage` needs doesn't apply. [seed] (the step
  // index) varies the pick so a multi-question lesson doesn't repeat the
  // exact same line every time.

  static const List<String> _correctAnswerTitles = [
    AppStrings.academyCorrectFeedbackTitle,
    AppStrings.academyCorrectFeedbackTitle2,
    AppStrings.academyCorrectFeedbackTitle3,
  ];

  static const List<String> _incorrectAnswerTitles = [
    AppStrings.academyIncorrectFeedbackTitle,
    AppStrings.academyIncorrectFeedbackTitle2,
    AppStrings.academyIncorrectFeedbackTitle3,
  ];

  static String questionFeedbackTitle({
    required bool correct,
    required int seed,
  }) {
    final pool = correct ? _correctAnswerTitles : _incorrectAnswerTitles;
    return pool[seed % pool.length];
  }

  @override
  PetMessage? onEvent(AppEvent event) {
    return switch (event) {
      LessonCompletedEvent() => PetMessage(
        id: 'event_lesson_completed_${event.lessonId}',
        context: PetContext.academy,
        priority: PetMessagePriority.high,
        trigger: PetMessageTrigger.lessonCompleted,
        textKey: AppStrings.companionEventLessonCompleted,
        mood: PetAnimationState.victory,
      ),
      DifficultyDetectedEvent(:final schoolTitle) => PetMessage(
        id: 'event_difficulty_detected_$schoolTitle',
        context: PetContext.academy,
        priority: PetMessagePriority.normal,
        trigger: PetMessageTrigger.difficultyDetected,
        textKey: AppStrings.companionEventDifficultyDetected,
        params: {'school': schoolTitle},
        mood: PetAnimationState.think,
      ),
      SchoolMasteredEvent(:final schoolTitle) => PetMessage(
        id: 'event_school_mastered_$schoolTitle',
        context: PetContext.academy,
        priority: PetMessagePriority.high,
        trigger: PetMessageTrigger.schoolMastered,
        textKey: AppStrings.companionEventSchoolMastered,
        params: {'school': schoolTitle},
        mood: PetAnimationState.victory,
      ),
      FinancialLabSimulatorCompletedEvent(:final simulatorTitle) => PetMessage(
        id: 'event_lab_simulator_completed_$simulatorTitle',
        context: PetContext.academy,
        priority: PetMessagePriority.high,
        trigger: PetMessageTrigger.labSimulatorCompleted,
        textKey: AppStrings.companionEventLabSimulatorCompleted,
        params: {'simulator': simulatorTitle},
        mood: PetAnimationState.victory,
      ),
      _ => null,
    };
  }
}
