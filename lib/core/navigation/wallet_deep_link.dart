import 'package:petrimonium/features/academy/domain/entities/lab_simulator.dart';

/// Academy → Wallet cross-app deep-link scheme — **a proposal, not yet a
/// working link** (see the cross-repo contract proposal doc). This repo has
/// no deep-linking infrastructure and Wallet is not yet a separate
/// installed app (its screens — `features/portfolio`, `features/investment`,
/// `features/asset_details` — still live in this repo per the "leave in
/// place, build alongside" decision), so nothing here calls `url_launcher`
/// or attempts an OS-level launch yet.
///
/// Kept as a pure, testable URI builder so the shape is settled now — once
/// Wallet exists as a separate installed app and the scheme is confirmed
/// across repos, only `WalletBridgeCta`'s launch strategy needs to change,
/// not this shape.
class WalletDeepLink {
  const WalletDeepLink._();

  /// `petrimonium://wallet/portfolio?highlight=<concept>` — opens Wallet's
  /// portfolio view with [highlight] pre-selected, mirroring how
  /// `PortfolioLearningBridge` already surfaces a completed lesson's
  /// concept against real indicator data on `AssetDetailsScreen`. [highlight]
  /// is a stable concept id — a `LabSimulatorId.sourceId` for Financial Lab
  /// completions today; any other stable, backend-agnostic string is valid
  /// for future callers (e.g. a `Lesson.portfolioConcepts` indicator id).
  static Uri portfolioHighlight(String highlight) => Uri(
    scheme: 'petrimonium',
    host: 'wallet',
    path: '/portfolio',
    queryParameters: {'highlight': highlight},
  );

  /// Convenience overload for a completed Financial Lab simulator.
  static Uri forSimulator(LabSimulatorId id) => portfolioHighlight(id.sourceId);
}
