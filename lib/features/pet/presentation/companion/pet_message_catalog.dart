import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/features/game/domain/services/level_calculator.dart';
import 'package:petrimonium/features/game/domain/services/level_title.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart'
    show kSleepAfterInactiveDays;
import 'package:petrimonium/features/pet/presentation/companion/pet_message.dart';

/// The single source of truth for what the pet companion says. Nothing
/// outside this file constructs a [PetMessage] with literal copy — screens
/// only supply the real data (XP, next lesson title, holdings count...) and
/// get back a fully-formed message or `null` when there's nothing worth
/// saying yet. Two deliberate exceptions: [homeMotivationalFallback] —
/// genuinely content-free encouragement, never a stand-in for real data; see
/// its own doc comment for why it's a separate entry point rather than a
/// branch inside [pageEnter] — and [questionFeedbackTitle], which returns a
/// raw `AppStrings` key rather than a [PetMessage] because in-lesson answer
/// feedback never goes through `PetCompanionController` at all (see its own
/// doc comment).
class PetMessageCatalog {
  const PetMessageCatalog._();

  /// A nudge offered when the user lands on [context], subject to
  /// `PetCompanionController`'s cooldown/priority rules — never guaranteed
  /// to actually show.
  static PetMessage? pageEnter(
    PetContext context, {
    required int userXp,
    Map<String, String> data = const {},
  }) {
    switch (context) {
      case PetContext.home:
        return _homeNudge(userXp, data);
      case PetContext.academy:
        return _academyNudge(data);
      case PetContext.portfolio:
        return _portfolioNudge(data);
      case PetContext.mentor:
        return _mentorNudge();
      case PetContext.profile:
        return _profileSummary(userXp);
    }
  }

  /// Home's own "what should I do next" answer, checked in order of how
  /// contextually relevant each real signal is right now:
  /// 1. a return-after-inactivity greeting (`data['daysSinceLastSession']`,
  ///    supplied only once that's genuinely known — see
  ///    `MascotController.daysSinceLastSession`) — restoring context for a
  ///    returning user outranks everything else the first moment they're
  ///    back;
  /// 2. a mission one lesson away from completion
  ///    (`data['missionTitle']`) — matches whichever `NextAction`
  ///    `NextActionResolver` picked as Home's headline CTA, so the pet's
  ///    words and the card agree;
  /// 3. a near-level-up nudge — the most exciting *generic* thing to lead
  ///    with when it's true;
  /// 4. otherwise, the exact same review/continue-lesson nudge Academy
  ///    offers (`_academyNudge`) rather than a separate, duplicated notion
  ///    of "what's next" — reusing it also means the two tabs share one
  ///    cooldown/dedup entry, so seeing it on Home suppresses the identical
  ///    nudge on Academy shortly after, and vice versa (see
  ///    `_HomeScreenState._notifyCompanionOnce`, which supplies [data] once
  ///    its own `AcademyController`/`PortfolioController` data has loaded).
  static PetMessage? _homeNudge(int userXp, Map<String, String> data) {
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
    // Only worth mentioning when the next level is genuinely close —
    // "12000 XP to go" right after leveling up isn't an encouraging nudge.
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
  /// to have gone to sleep (`data['daysSinceLastSession']` >=
  /// `kSleepAfterInactiveDays`, set by `_HomeScreenState._notifyCompanionOnce`
  /// from `MascotController.daysSinceLastSession`) — never guilt-based
  /// (brief §10/§22 "Inactivity: do not guilt the user"), just a warm
  /// restoration of context. A small rotating pool, picked by the exact gap
  /// length so it's deterministic and testable, same discipline as
  /// [homeMotivationalFallback].
  static PetMessage? _returnGreeting(Map<String, String> data) {
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

  /// A small, rotating pool of genuinely content-free encouragement — no XP,
  /// lesson, or portfolio figure is referenced. This is a separate entry
  /// point rather than a branch inside [_homeNudge] because it needs to be
  /// tried *both* when [pageEnter] returns nothing *and* when it returns a
  /// real nudge that's still cooling down (e.g. `academy_continue_lesson`
  /// shown an hour ago) — a distinction only `PetCompanionController` can
  /// make, since it alone holds the per-message cooldown ledger. See
  /// `PetCompanionController.enterContext`'s `allowAmbientFallback`.
  ///
  /// Picked by day-of-month rather than randomly so it's still deterministic
  /// (and testable) while varying across visits on different days; each
  /// entry keeps its own stable id so the per-message cooldown still applies
  /// to it individually.
  static const List<(String id, String textKey)> _motivationalMessages = [
    ('home_motivation_1', AppStrings.companionHomeMotivation1),
    ('home_motivation_2', AppStrings.companionHomeMotivation2),
    ('home_motivation_3', AppStrings.companionHomeMotivation3),
    ('home_motivation_4', AppStrings.companionHomeMotivation4),
    ('home_motivation_5', AppStrings.companionHomeMotivation5),
  ];

  static PetMessage homeMotivationalFallback() {
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
  // here (a wrong answer is never penalized, and the lesson screen is
  // deliberately quiet otherwise — see `LessonScreen`'s doc comment), so the
  // cooldown/priority machinery a real `PetMessage` needs doesn't apply.
  // [seed] (the step index) varies the pick so a multi-question lesson
  // doesn't repeat the exact same line every time.

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

  static PetMessage? _academyNudge(Map<String, String> data) {
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
  /// review (`AcademyController.reviewQueue`) — never punitive, just a
  /// gentle reminder, same encouraging tone as every other pet nudge.
  static PetMessage _reviewDueNudge(int count) {
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

  static PetMessage? _portfolioNudge(Map<String, String> data) {
    final countStr = data['count'];
    final count = countStr == null ? 0 : int.tryParse(countStr) ?? 0;
    if (count == 0) return _portfolioActivationNudge();
    if (count <= 1) return null;

    return PetMessage(
      id: 'portfolio_diversified',
      context: PetContext.portfolio,
      priority: PetMessagePriority.low,
      trigger: PetMessageTrigger.pageEnter,
      textKey: AppStrings.companionPortfolioDiversified,
      params: {'count': '$count'},
      mood: PetAnimationState.happy,
    );
  }

  /// Offered on landing on the Portfolio tab with zero holdings — the static
  /// "you haven't started yet" state, as opposed to [firstInvestment]'s
  /// celebration of the real 0→N transition. Deliberately non-pressuring
  /// (no "invest now"/urgency framing) per `docs/DESIGN_SYSTEM.md`'s
  /// "Companion, Not Protagonist" tone.
  static PetMessage _portfolioActivationNudge() {
    return const PetMessage(
      id: 'portfolio_activation_nudge',
      context: PetContext.portfolio,
      priority: PetMessagePriority.low,
      trigger: PetMessageTrigger.pageEnter,
      textKey: AppStrings.companionPortfolioActivationNudge,
      mood: PetAnimationState.idle,
    );
  }

  /// The pet's immediate reaction to the "Você já investe?" choice inside
  /// `PortfolioActivationView`. Returns a raw `AppStrings` key rather than a
  /// [PetMessage] — same reasoning as [questionFeedbackTitle]: this is a
  /// direct reaction to a UI tap with nothing to suppress or cool down, so
  /// it's rendered inline by the screen instead of going through
  /// `PetCompanionController`.
  static String investorStatusReaction({required bool alreadyInvests}) =>
      alreadyInvests
      ? AppStrings.companionInvestorStatusYes
      : AppStrings.companionInvestorStatusNo;

  static PetMessage _mentorNudge() {
    return const PetMessage(
      id: 'mentor_nudge',
      context: PetContext.mentor,
      priority: PetMessagePriority.low,
      trigger: PetMessageTrigger.pageEnter,
      textKey: AppStrings.companionMentorNudge,
      mood: PetAnimationState.idle,
    );
  }

  static PetMessage _profileSummary(int userXp) {
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

  // ── Event-triggered reactions ─────────────────────────────────────────

  static PetMessage lessonCompleted(String lessonId) {
    return PetMessage(
      id: 'event_lesson_completed_$lessonId',
      context: PetContext.academy,
      priority: PetMessagePriority.high,
      trigger: PetMessageTrigger.lessonCompleted,
      textKey: AppStrings.companionEventLessonCompleted,
      mood: PetAnimationState.victory,
    );
  }

  static PetMessage xpGained(int amount) {
    return PetMessage(
      id: 'event_xp_gained',
      context: PetContext.home,
      priority: PetMessagePriority.normal,
      trigger: PetMessageTrigger.xpGained,
      textKey: AppStrings.companionEventXpGained,
      params: {'xp': '$amount'},
      mood: PetAnimationState.happy,
    );
  }

  static PetMessage levelUp(int newLevel) {
    return PetMessage(
      id: 'event_level_up',
      context: PetContext.home,
      priority: PetMessagePriority.high,
      trigger: PetMessageTrigger.levelUp,
      textKey: AppStrings.companionEventLevelUp,
      params: {'level': '$newLevel'},
      mood: PetAnimationState.celebrate,
    );
  }

  static PetMessage achievementUnlocked(String title) {
    return PetMessage(
      id: 'event_achievement_unlocked_$title',
      context: PetContext.portfolio,
      priority: PetMessagePriority.high,
      trigger: PetMessageTrigger.achievementUnlocked,
      textKey: AppStrings.companionEventAchievementUnlocked,
      params: {'title': title},
      mood: PetAnimationState.celebrate,
    );
  }

  /// Never punitive — same encouraging, "let's look at this together" tone
  /// as a wrong-answer explanation inside a lesson, just offered a level up:
  /// a pattern across recent answers, not a single mistake.
  static PetMessage difficultyDetected(String schoolTitle) {
    return PetMessage(
      id: 'event_difficulty_detected_$schoolTitle',
      context: PetContext.academy,
      priority: PetMessagePriority.normal,
      trigger: PetMessageTrigger.difficultyDetected,
      textKey: AppStrings.companionEventDifficultyDetected,
      params: {'school': schoolTitle},
      mood: PetAnimationState.think,
    );
  }

  static PetMessage schoolMastered(String schoolTitle) {
    return PetMessage(
      id: 'event_school_mastered_$schoolTitle',
      context: PetContext.academy,
      priority: PetMessagePriority.high,
      trigger: PetMessageTrigger.schoolMastered,
      textKey: AppStrings.companionEventSchoolMastered,
      params: {'school': schoolTitle},
      mood: PetAnimationState.victory,
    );
  }

  /// Offered once per genuine 0→N holdings transition (see
  /// `PortfolioController.loadAll`/`FirstInvestmentAddedEvent`) — a bridge
  /// into learning, not just a celebration: no specific ticker/type is named
  /// since the backend `/configure` call may add several at once and this
  /// catalog never fabricates which one is "the" first.
  static PetMessage firstInvestment() {
    return const PetMessage(
      id: 'event_first_investment',
      context: PetContext.portfolio,
      priority: PetMessagePriority.high,
      trigger: PetMessageTrigger.firstInvestment,
      textKey: AppStrings.companionEventFirstInvestment,
      mood: PetAnimationState.celebrate,
      action: PetMessageAction(
        labelKey: AppStrings.companionActionUnderstand,
        destination: PetContext.academy,
      ),
    );
  }

  /// Offered when a holding newly crosses `InsightGenerator`'s existing
  /// high-concentration threshold (`PortfolioController._evaluateConcentration`)
  /// — never punitive, mirrors `difficultyDetected`'s "let's look at this
  /// together" register. Bridges to the Mentor rather than Academy since
  /// this is about the user's own real risk, not a general concept.
  static PetMessage highConcentration(String ticker, double percent) {
    return PetMessage(
      id: 'event_high_concentration_$ticker',
      context: PetContext.portfolio,
      priority: PetMessagePriority.normal,
      trigger: PetMessageTrigger.highConcentration,
      textKey: AppStrings.companionEventHighConcentration,
      params: {'ticker': ticker, 'percent': percent.toStringAsFixed(0)},
      mood: PetAnimationState.think,
      action: const PetMessageAction(
        labelKey: AppStrings.companionActionUnderstand,
        destination: PetContext.mentor,
      ),
    );
  }

  /// Offered on `MissionCompletedEvent` — mirrors [achievementUnlocked]'s
  /// shape exactly (same `context: PetContext.portfolio`, since missions
  /// render on the Portfolio tab, and same "one celebration per unique
  /// title" id scheme).
  static PetMessage missionCompleted(String title) {
    return PetMessage(
      id: 'event_mission_completed_$title',
      context: PetContext.portfolio,
      priority: PetMessagePriority.high,
      trigger: PetMessageTrigger.missionCompleted,
      textKey: AppStrings.companionEventMissionCompleted,
      params: {'title': title},
      mood: PetAnimationState.celebrate,
    );
  }

  /// Offered on `FinancialLabSimulatorCompletedEvent` — one factory for all
  /// five simulators (the title param varies, the reaction doesn't). Uses
  /// `PetContext.academy` since there's no dedicated Lab context (see
  /// `pet_context.dart`'s doc comment) and the Lab is reached from Academy.
  static PetMessage labSimulatorCompleted(String simulatorTitle) {
    return PetMessage(
      id: 'event_lab_simulator_completed_$simulatorTitle',
      context: PetContext.academy,
      priority: PetMessagePriority.high,
      trigger: PetMessageTrigger.labSimulatorCompleted,
      textKey: AppStrings.companionEventLabSimulatorCompleted,
      params: {'simulator': simulatorTitle},
      mood: PetAnimationState.victory,
    );
  }

  static PetMessage evolved(PetEvolutionStage newStage) {
    return PetMessage(
      id: 'event_evolved',
      context: PetContext.home,
      priority: PetMessagePriority.high,
      trigger: PetMessageTrigger.evolved,
      textKey: AppStrings.companionEventEvolved,
      params: {'stage': newStage.label},
      mood: PetAnimationState.victory,
    );
  }
}
