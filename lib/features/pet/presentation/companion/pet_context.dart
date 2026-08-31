/// Which major screen the persistent pet companion is currently presented
/// in — drives which contextual message a screen may offer via
/// `PetCompanionController.showContextMessage` (see
/// `PetMessageCatalog`). Deliberately mirrors the app's real top-level
/// destinations (`DashboardScreen`'s 5 tabs + the separately-routed Profile
/// screen) rather than the generic "missions"/"goals" screens described in
/// early product exploration, which don't exist in this app — see
/// `docs/ARCHITECTURE.md` and `docs/FEATURES.md`.
enum PetContext { home, academy, portfolio, mentor, profile }
