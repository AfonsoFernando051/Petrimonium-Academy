import 'package:shared_preferences/shared_preferences.dart';

/// After this many app sessions with portfolio still unconnected, the pet
/// may gently nudge the user on Home (see `shouldShowPortfolioReminder`).
const int kPortfolioReminderAfterSessions = 3;

/// After a reminder is shown, the pet waits at least this many sessions
/// before mentioning it again — reminders should never feel intrusive.
const int kPortfolioReminderCooldownSessions = 3;

/// Local-only (SharedPreferences) flags for the redesigned onboarding flow:
/// whether the player has chosen a financial goal, finished the tutorial,
/// and how they left the (now fully optional) portfolio step. There is no
/// backend field for any of this — it only decides which screen the app
/// opens to and what Home shows, mirroring `PetPreferencesRepository`'s
/// "local-only, nothing else consumes it yet" pattern.
class OnboardingStateRepository {
  static const _hasSetGoalKey = 'onboarding_has_set_goal';
  static const _tutorialCompletedKey = 'onboarding_tutorial_completed';
  static const _portfolioStepDoneKey = 'onboarding_portfolio_step_done';
  static const _portfolioConnectedKey = 'onboarding_portfolio_connected';
  static const _portfolioSkippedAtKey = 'onboarding_portfolio_skipped_at';
  static const _sessionCountKey = 'onboarding_session_count';
  static const _reminderShownAtSessionKey =
      'onboarding_reminder_shown_at_session';
  static const _portfolioActivationSeenKey = 'portfolio_activation_seen';

  Future<bool> hasSetGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSetGoalKey) ?? false;
  }

  Future<void> setGoalChosen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSetGoalKey, true);
  }

  Future<bool> isTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialCompletedKey) ?? false;
  }

  Future<void> completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialCompletedKey, true);
  }

  Future<bool> isPortfolioStepDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_portfolioStepDoneKey) ?? false;
  }

  Future<bool> isPortfolioConnected() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_portfolioConnectedKey) ?? false;
  }

  /// Marks the portfolio step as resolved via import/manual entry — the
  /// user has real holdings now, so Home shows live data, not placeholders.
  Future<void> markPortfolioConnected() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_portfolioStepDoneKey, true);
    await prefs.setBool(_portfolioConnectedKey, true);
    await prefs.remove(_portfolioSkippedAtKey);
  }

  /// Marks the portfolio step as resolved via "Skip For Now" — Home shows
  /// placeholders, and the pet may nudge the user again later.
  Future<void> markPortfolioSkipped({DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_portfolioStepDoneKey, true);
    await prefs.setBool(_portfolioConnectedKey, false);
    await prefs.setString(
      _portfolioSkippedAtKey,
      (now ?? DateTime.now()).toIso8601String(),
    );
  }

  /// Increments and returns the number of app sessions (cold starts) so
  /// far — call once per app boot. Used to pace the reminder cooldown.
  Future<int> incrementSessionCount() async {
    final prefs = await SharedPreferences.getInstance();
    final next = (prefs.getInt(_sessionCountKey) ?? 0) + 1;
    await prefs.setInt(_sessionCountKey, next);
    return next;
  }

  /// The session count as of the most recent [incrementSessionCount] call
  /// (i.e. this session's count), without incrementing it again.
  Future<int> currentSessionCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_sessionCountKey) ?? 0;
  }

  Future<void> markReminderShown(int atSession) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_reminderShownAtSessionKey, atSession);
  }

  /// Whether the pet should nudge the user about connecting their portfolio
  /// this session: only if they explicitly skipped (never if they simply
  /// haven't reached that step yet), enough sessions have passed since the
  /// skip, and enough sessions have passed since the last reminder.
  Future<bool> shouldShowPortfolioReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final skipped =
        prefs.getBool(_portfolioConnectedKey) == false &&
        prefs.getString(_portfolioSkippedAtKey) != null;
    if (!skipped) return false;

    final sessionCount = prefs.getInt(_sessionCountKey) ?? 0;
    if (sessionCount < kPortfolioReminderAfterSessions) return false;

    final lastShown = prefs.getInt(_reminderShownAtSessionKey);
    if (lastShown != null &&
        sessionCount - lastShown < kPortfolioReminderCooldownSessions) {
      return false;
    }
    return true;
  }

  /// Whether the Portfolio tab's full activation intro (title + "do you
  /// already invest?" question) has already been shown once. Deliberately
  /// separate from [isPortfolioConnected]/[markPortfolioSkipped] — those
  /// resolve the *onboarding* step and `StartRouteResolver` explicitly never
  /// re-routes on zero holdings alone, whereas this flag only decides
  /// whether the Portfolio tab shows the full intro or a shorter, returning
  /// nudge while holdings stay at zero.
  Future<bool> hasSeenPortfolioActivation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_portfolioActivationSeenKey) ?? false;
  }

  Future<void> markPortfolioActivationSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_portfolioActivationSeenKey, true);
  }
}
