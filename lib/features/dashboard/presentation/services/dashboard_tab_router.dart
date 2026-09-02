import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';

/// Pure tab-index → behavior mappings for [DashboardScreen]'s 4 bottom-nav
/// tabs (Home/Academy/Wallet/Mentor). The `dashboard` feature has no domain
/// layer of its own, so this small but real business logic (which background
/// mood and which persistent-companion voice each tab gets) previously lived
/// inline in the screen; pulled out here so it's independently testable and
/// the screen only orchestrates widgets.
///
/// No Proventos (passive income) tab exists — it was removed along with the
/// real-portfolio dividend radar it depended on (Stage 7 of the ecosystem
/// split plan): Academy has no real holdings to report dividends on, so the
/// tab could never actually show anything.
class DashboardTabRouter {
  DashboardTabRouter._();

  static const int homeTab = 0;
  static const int academyTab = 1;
  static const int walletTab = 2;
  static const int mentorTab = 3;

  /// (`docs/PROJECT_CONTEXT.md`'s Pet Companion section, `PetContext`'s doc
  /// comment on why this mirrors the real tabs + Profile rather than a
  /// generic missions/goals set that doesn't exist in this app.)
  static PetContext petContextFor(int tabIndex) => switch (tabIndex) {
        homeTab => PetContext.home,
        academyTab => PetContext.academy,
        walletTab => PetContext.portfolio,
        _ => PetContext.mentor,
      };

  /// Whether [tabIndex] is the portfolio-flavored tab — used to decide
  /// whether the companion greeting needs the holdings count.
  static bool showsHoldingsCount(int tabIndex) => tabIndex == walletTab;
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
