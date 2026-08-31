import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/features/academy/domain/entities/lab_simulator.dart';
import 'package:petrimonium/features/academy/presentation/controllers/lab_completion_controller.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/compound_interest_lab_screen.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/diversification_lab_screen.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/fixed_income_lab_screen.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/inflation_lab_screen.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/portfolio_lab_screen.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_companion_controller.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// One tile in [FinancialLabHomeScreen] and the screen it opens when
/// available. Replaces five hardcoded `_LabTile` widgets — enabling a lab
/// is now flipping [available] to `true` and swapping [build] for the real
/// screen, not editing the home screen's layout.
class LabSimulatorEntry {
  const LabSimulatorEntry({
    required this.id,
    required this.icon,
    required this.titleKey,
    this.subtitleKey,
    required this.available,
    required this.build,
  });

  final LabSimulatorId id;
  final IconData icon;
  final String titleKey;

  /// `null` for a simulator with no subtitle copy yet — matches the app's
  /// existing `UnavailableBadge`-driven "coming soon" tiles, none of which
  /// have ever shown a subtitle.
  final String? subtitleKey;
  final bool available;

  /// Never invoked while [available] is `false` — the home screen disables
  /// the tile's tap target for unavailable entries.
  final Widget Function(
    MascotController mascotController,
    PetCompanionController companionController,
    LabCompletionController completionController,
    VoidCallback onOpenWallet,
  )
  build;
}

class LabSimulatorCatalog {
  const LabSimulatorCatalog._();

  static List<LabSimulatorEntry> get entries => [
    LabSimulatorEntry(
      id: LabSimulatorId.compoundInterest,
      icon: Icons.trending_up_rounded,
      titleKey: AppStrings.labCompoundInterestTitle,
      subtitleKey: AppStrings.labCompoundInterestSubtitle,
      available: true,
      build:
          (
            mascotController,
            companionController,
            completionController,
            onOpenWallet,
          ) => CompoundInterestLabScreen(
            mascotController: mascotController,
            companionController: companionController,
            completionController: completionController,
            onOpenWallet: onOpenWallet,
          ),
    ),
    LabSimulatorEntry(
      id: LabSimulatorId.inflation,
      icon: Icons.shopping_basket_outlined,
      titleKey: AppStrings.labInflationTitle,
      subtitleKey: AppStrings.labInflationSubtitle,
      available: true,
      build:
          (
            mascotController,
            companionController,
            completionController,
            onOpenWallet,
          ) => InflationLabScreen(
            mascotController: mascotController,
            companionController: companionController,
            completionController: completionController,
            onOpenWallet: onOpenWallet,
          ),
    ),
    LabSimulatorEntry(
      id: LabSimulatorId.fixedIncome,
      icon: Icons.account_balance_outlined,
      titleKey: AppStrings.labFixedIncomeTitle,
      subtitleKey: AppStrings.labFixedIncomeSubtitle,
      available: true,
      build:
          (
            mascotController,
            companionController,
            completionController,
            onOpenWallet,
          ) => FixedIncomeLabScreen(
            mascotController: mascotController,
            companionController: companionController,
            completionController: completionController,
            onOpenWallet: onOpenWallet,
          ),
    ),
    LabSimulatorEntry(
      id: LabSimulatorId.diversification,
      icon: Icons.hub_outlined,
      titleKey: AppStrings.labDiversificationTitle,
      subtitleKey: AppStrings.labDiversificationSubtitle,
      available: true,
      build:
          (
            mascotController,
            companionController,
            completionController,
            onOpenWallet,
          ) => DiversificationLabScreen(
            mascotController: mascotController,
            companionController: companionController,
            completionController: completionController,
            onOpenWallet: onOpenWallet,
          ),
    ),
    LabSimulatorEntry(
      id: LabSimulatorId.portfolio,
      icon: Icons.pie_chart_outline_rounded,
      titleKey: AppStrings.labPortfolioTitle,
      subtitleKey: AppStrings.labPortfolioSubtitle,
      available: true,
      build:
          (
            mascotController,
            companionController,
            completionController,
            onOpenWallet,
          ) => PortfolioLabScreen(
            mascotController: mascotController,
            companionController: companionController,
            completionController: completionController,
            onOpenWallet: onOpenWallet,
          ),
    ),
  ];
}
