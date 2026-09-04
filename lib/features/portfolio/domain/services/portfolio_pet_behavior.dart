import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/features/pet/domain/behavior/pet_behavior.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_message.dart';

/// The real-portfolio Pet reaction script — holdings, dividends,
/// concentration risk, missions/achievements, and the Mentor chat nudge.
/// `petrimonium-wallet` is its own repo now and keeps its own copy of this
/// class for the real-money holdings screens it owns. This copy stays wired
/// into Academy's `_kPetBehaviors` only because `DashboardScreen` still runs
/// `PortfolioController.loadAll()` here for its own achievements/missions
/// gamification evaluation — Academy no longer has any real-holdings screen
/// (`features/asset_details` and the investment-configuration flow were
/// removed as dead code; see `docs/BACKEND_MODULE_PLAN.md`/`ECOSYSTEM.md`
/// for the split history). Implements the same [PetBehavior] contract so the
/// two scripts stay swappable without either needing to know the other
/// exists (`PetCompanionController` composes both).
class PortfolioPetBehavior extends PetBehavior {
  const PortfolioPetBehavior();

  @override
  PetMessage? pageEnter(
    PetContext context, {
    required int userXp,
    Map<String, String> data = const {},
  }) {
    return switch (context) {
      PetContext.portfolio => _portfolioNudge(data),
      PetContext.mentor => _mentorNudge(),
      _ => null,
    };
  }

  PetMessage? _portfolioNudge(Map<String, String> data) {
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
  /// "you haven't started yet" state, as opposed to [onEvent]'s celebration
  /// of the real 0→N transition. Deliberately non-pressuring (no "invest
  /// now"/urgency framing) — "Companion, Not Protagonist" tone.
  PetMessage _portfolioActivationNudge() {
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
  /// [PetMessage] — a direct reaction to a UI tap with nothing to suppress
  /// or cool down, so it's rendered inline by the screen instead of going
  /// through `PetCompanionController`.
  static String investorStatusReaction({required bool alreadyInvests}) =>
      alreadyInvests
      ? AppStrings.companionInvestorStatusYes
      : AppStrings.companionInvestorStatusNo;

  PetMessage _mentorNudge() {
    return const PetMessage(
      id: 'mentor_nudge',
      context: PetContext.mentor,
      priority: PetMessagePriority.low,
      trigger: PetMessageTrigger.pageEnter,
      textKey: AppStrings.companionMentorNudge,
      mood: PetAnimationState.idle,
    );
  }

  @override
  PetMessage? onEvent(AppEvent event) {
    return switch (event) {
      FirstInvestmentAddedEvent() => const PetMessage(
        id: 'event_first_investment',
        context: PetContext.portfolio,
        priority: PetMessagePriority.high,
        trigger: PetMessageTrigger.firstInvestment,
        textKey: AppStrings.companionEventFirstInvestment,
        // Neutral, never celebrate/victory — see AppEvent.isFinancial. An
        // aporte is acknowledged and bridged into learning, not rewarded with
        // the animation a finished lesson gets.
        mood: PetAnimationState.idle,
        action: PetMessageAction(
          labelKey: AppStrings.companionActionUnderstand,
          destination: PetContext.academy,
        ),
      ),
      HighConcentrationDetectedEvent(:final ticker, :final percent) => PetMessage(
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
      ),
      MissionCompletedEvent(:final missionTitle) => PetMessage(
        id: 'event_mission_completed_$missionTitle',
        context: PetContext.portfolio,
        priority: PetMessagePriority.high,
        trigger: PetMessageTrigger.missionCompleted,
        textKey: AppStrings.companionEventMissionCompleted,
        params: {'title': missionTitle},
        mood: PetAnimationState.celebrate,
      ),
      AchievementUnlockedEvent(:final achievement) => PetMessage(
        id: 'event_achievement_unlocked_${achievement.title}',
        context: PetContext.portfolio,
        priority: PetMessagePriority.high,
        trigger: PetMessageTrigger.achievementUnlocked,
        textKey: AppStrings.companionEventAchievementUnlocked,
        params: {'title': achievement.title},
        mood: PetAnimationState.celebrate,
      ),
      _ => null,
    };
  }
}
