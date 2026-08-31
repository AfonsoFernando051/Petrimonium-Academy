import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/portfolio/domain/entities/achievement.dart';

/// Something the Financial Engine or Game Engine did that other systems
/// (character reactions, notifications, a future AI Mentor) may want to
/// react to, without being called directly by whatever emitted it.
///
/// Kept intentionally small: only the events this codebase can honestly emit
/// today. Add a case when a real trigger exists for it, not in advance of one.
sealed class AppEvent {
  const AppEvent();
}

/// Fired the moment a permanent achievement is unlocked (see
/// `AchievementCatalog` — achievements never re-lock).
class AchievementUnlockedEvent extends AppEvent {
  final Achievement achievement;
  const AchievementUnlockedEvent(this.achievement);
}

/// Fired when the pet's evolution tier advances (see
/// `MascotController.evaluateEvolution`).
class PetEvolvedEvent extends AppEvent {
  final PetEvolutionStage newStage;
  const PetEvolvedEvent(this.newStage);
}

/// Fired when the player's computed level (see `LevelCalculator`) increases.
class UserLeveledUpEvent extends AppEvent {
  final int newLevel;
  const UserLeveledUpEvent(this.newLevel);
}

/// Fired the moment a lesson is marked complete locally (see
/// `LessonSessionController._completeLesson`) — independent of whether the
/// backend XP sync that follows it succeeds.
class LessonCompletedEvent extends AppEvent {
  final String lessonId;
  const LessonCompletedEvent(this.lessonId);
}

/// Fired whenever the user's persisted total XP increases (see
/// `MascotController.evaluateEvolution`, the single choke point XP changes
/// flow through from both lesson completion and portfolio/gamification
/// sync).
class XpGainedEvent extends AppEvent {
  final int amount;
  final int newTotalXp;
  const XpGainedEvent({required this.amount, required this.newTotalXp});
}

/// Fired when the learner has recently missed enough questions in one
/// Academy school to be worth a gentle "let's review" nudge (see
/// `AcademyProgressLocalRepository.recordMiss`). Carries the school's
/// already-resolved, current-language title — not its id — so the pet
/// feature stays decoupled from the Academy's school/module id scheme,
/// matching how `AchievementUnlockedEvent` carries a resolved title.
class DifficultyDetectedEvent extends AppEvent {
  final String schoolTitle;
  const DifficultyDetectedEvent(this.schoolTitle);
}

/// Fired the moment completing a lesson brings every currently-available
/// module of its school to 100% (see
/// `LessonSessionController._completeLesson`). Same "carry the resolved
/// title" reasoning as [DifficultyDetectedEvent].
class SchoolMasteredEvent extends AppEvent {
  final String schoolTitle;
  const SchoolMasteredEvent(this.schoolTitle);
}

/// Fired the moment the user's real, backend-confirmed portfolio holds an
/// investment for the first time (see `PortfolioController.loadAll`, which
/// diffs the previous in-session holdings count against the freshly loaded
/// one — deliberately never fires on the very first `loadAll()` of a
/// session, since an already-invested user's cold-start load must not read
/// as "just invested").
class FirstInvestmentAddedEvent extends AppEvent {
  const FirstInvestmentAddedEvent();
}

/// Fired when a single holding's share of the portfolio newly crosses the
/// "high concentration" threshold `InsightGenerator` already uses (>40%,
/// see `PortfolioStats.largestHoldingPercent`) — only on the low→high
/// transition, not on every load while it stays high, so the pet doesn't
/// repeat itself every time the Portfolio tab is revisited.
class HighConcentrationDetectedEvent extends AppEvent {
  final String ticker;
  final double percent;
  const HighConcentrationDetectedEvent({required this.ticker, required this.percent});
}

/// Fired the moment a mission (daily/weekly, see `MissionStatus`) is newly
/// completed this period (see `PortfolioController._evaluateGamification`,
/// which diffs `MissionEvaluationResult.newlyCompletedCodes` the same way
/// [AchievementUnlockedEvent] diffs newly-unlocked achievements). Carries the
/// resolved title (via `MissionDisplayCatalog`), not the raw code — same
/// "stay decoupled from the domain's id scheme" reasoning as
/// [DifficultyDetectedEvent]/[SchoolMasteredEvent].
class MissionCompletedEvent extends AppEvent {
  final String missionTitle;
  const MissionCompletedEvent(this.missionTitle);
}

/// Fired by [ApiClient] the moment a 401 response's automatic refresh
/// attempt definitively fails (no refresh token stored, or the backend
/// rejects it as invalid/expired/revoked) — the session is no longer
/// salvageable and every stored token has already been cleared by the time
/// this fires. `main.dart`'s root listener reacts by clearing the
/// navigation stack back to `LoginScreen`, the same "one global reaction,
/// not every screen handling it individually" shape as the other events
/// here. `ApiClient` lives in `core/`, below every feature, so this event
/// deliberately carries no feature-specific data — just the fact itself.
class SessionExpiredEvent extends AppEvent {
  const SessionExpiredEvent();
}

/// Fired the moment a Financial Lab simulator's full flow is completed —
/// including its comprehension check — independent of whether the backend
/// XP sync that follows succeeds (`LabCompletionController.completeSimulator`
/// fires this before attempting the sync, matching every other event's
/// local-first ordering). One event for all five simulators, not one per
/// simulator — they have no behavioral difference, only the resolved title
/// differs (see `docs/DECISIONS.md` DECISION-037). Carries the resolved,
/// current-language title (not the raw simulator id), same reasoning as
/// [SchoolMasteredEvent]/[MissionCompletedEvent].
class FinancialLabSimulatorCompletedEvent extends AppEvent {
  final String simulatorTitle;
  const FinancialLabSimulatorCompletedEvent(this.simulatorTitle);
}
