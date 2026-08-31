import 'package:petrimonium/core/theme/background_presets.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';

/// Pure tab-index → behavior mappings for [DashboardScreen]'s 5 bottom-nav
/// tabs (Home/Academy/Wallet/Passive Income/Mentor). The `dashboard` feature
/// has no domain layer of its own, so this small but real business logic
/// (which background mood and which persistent-companion voice each tab
/// gets) previously lived inline in the screen; pulled out here so it's
/// independently testable and the screen only orchestrates widgets.
class DashboardTabRouter {
  DashboardTabRouter._();

  static const int homeTab = 0;
  static const int academyTab = 1;
  static const int walletTab = 2;
  static const int passiveIncomeTab = 3;
  static const int mentorTab = 4;

  // Content-hierarchy comes from swapping intensity per selected tab: full
  // cosmic expression on Home, progressively quieter as the screen gets more
  // cognitively demanding, down to Academy. Lesson/quiz screens go one step
  // further with their own `focus`-level CosmicBackground pushed as a
  // separate route (see LessonScreen).
  static const List<BackgroundIntensity> _tabIntensities = [
    BackgroundIntensity.immersive, // Home
    BackgroundIntensity.subtle, // Academia
    BackgroundIntensity.balanced, // Carteira / Portfolio
    BackgroundIntensity.balanced, // Proventos / Passive income
    BackgroundIntensity.mentor, // Mentor
  ];

  static BackgroundIntensity backgroundIntensityFor(int tabIndex) => _tabIntensities[tabIndex];

  /// (`docs/PROJECT_CONTEXT.md`'s Pet Companion section, `PetContext`'s doc
  /// comment on why this mirrors the 5 real tabs + Profile rather than a
  /// generic missions/goals set that doesn't exist in this app.)
  static PetContext petContextFor(int tabIndex) => switch (tabIndex) {
        homeTab => PetContext.home,
        academyTab => PetContext.academy,
        walletTab || passiveIncomeTab =>
          PetContext.portfolio, // Carteira / Proventos share the same companion voice
        _ => PetContext.mentor,
      };

  /// Whether [tabIndex] is one of the two portfolio-flavored tabs — used to
  /// decide whether the companion greeting needs the holdings count.
  static bool showsHoldingsCount(int tabIndex) => tabIndex == walletTab || tabIndex == passiveIncomeTab;
}

/// Small display-formatting helpers for the Dashboard chrome — kept
/// alongside [DashboardTabRouter] rather than inline in the screen for the
/// same "no domain layer to hold this" reason.
class DashboardFormatters {
  DashboardFormatters._();

  /// Notification-bell badge count: caps the visible digits at "9+" instead
  /// of letting a busy user's badge grow unbounded and break the pill layout.
  static String notificationBadgeLabel(int count) => count > 9 ? '9+' : '$count';
}
