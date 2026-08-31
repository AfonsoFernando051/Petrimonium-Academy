import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/game_snack.dart';
import 'package:petrimonium/core/widgets/error_state_view.dart';
import 'package:petrimonium/features/investment/presentation/screens/investment_configuration_screen.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:petrimonium/features/portfolio/presentation/controllers/portfolio_controller.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/asset_allocation_card.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/hero_summary_section.dart';
import 'package:petrimonium/features/portfolio/domain/services/insight_generator.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/holdings_section.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/achievements_section.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/insights_section.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/missions_section.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/portfolio_activation_view.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/quick_actions_fab.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/rpg_integration_card.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/wealth_evolution_bar_card.dart';

/// The "Carteira" (Portfolio) tab — holdings (Investidor10-inspired: grouped
/// by category, collapsible, expandable to full asset detail) preceded by
/// the portfolio summary cards, wealth evolution chart and asset allocation
/// donut, so the full picture is visible before scrolling into individual
/// positions.
///
/// [controller] is owned and loaded by `DashboardScreen` and shared with the
/// Home tab, so both reflect the same data with a single fetch.
class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({
    super.key,
    required this.controller,
    required this.mascotController,
    required this.onOpenAcademyTab,
  });

  final PortfolioController controller;
  final MascotController mascotController;

  /// Lets the Portfolio Activation experience send a "not yet an investor"
  /// user to the Academy tab — mirrors `HomeScreen`'s `onOpenAcademyTab`
  /// callback rather than introducing a new navigation abstraction.
  final VoidCallback onOpenAcademyTab;

  void _openConfigure(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.of(
      context,
    ).push(_fadeRoute(const InvestmentConfigurationScreen()));
  }

  void _pointAtAllocation(BuildContext context) {
    GameSnack.showWithHaptic(
      context,
      'Veja a % da carteira e a meta de cada categoria nos cartões abaixo.',
    );
  }

  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.04), end: Offset.zero)
                  .animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: child,
            ),
          ),
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading &&
        controller.holdings.isEmpty &&
        controller.error == null) {
      return const _HoldingsSkeleton();
    }

    if (controller.error != null && controller.holdings.isEmpty) {
      return ErrorStateView(
        title: 'Falha de Comunicação',
        message: controller.error!,
        onRetry: controller.loadAll,
        style: ErrorStateStyle.card,
      );
    }

    if (controller.holdings.isEmpty) {
      return PortfolioActivationView(
        mascotController: mascotController,
        onOpenAcademyTab: onOpenAcademyTab,
      );
    }

    final insights = InsightGenerator.generate(
      controller.stats,
      onOpenAllocation: () => _pointAtAllocation(context),
      onOpenConfigure: () => _openConfigure(context),
    );

    return Stack(
      children: [
        RefreshIndicator(
          color: AppColors.neonCyan,
          backgroundColor: context.colors.surfaceElevated,
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HeroSummarySection(controller: controller),
                const SizedBox(height: 16),
                if (insights.isNotEmpty) ...[
                  InsightsSection(insights: insights),
                  const SizedBox(height: 16),
                ],
                WealthEvolutionBarCard(controller: controller),
                const SizedBox(height: 16),
                AssetAllocationCard(
                  allocation: controller.allocation,
                  totalValue: controller.summary.currentValue,
                ),
                const SizedBox(height: 16),
                HoldingsSection(
                  holdings: controller.holdings,
                  totalPortfolioValue: controller.summary.currentValue,
                ),
                const SizedBox(height: 16),
                RpgIntegrationCard(
                  controller: mascotController,
                  stats: controller.stats,
                  currentStreak:
                      controller.gamificationSummary?.currentStreak ?? 0,
                ),
                const SizedBox(height: 16),
                if (controller.missions.isNotEmpty) ...[
                  MissionsSection(missions: controller.missions),
                  const SizedBox(height: 16),
                ],
                AchievementsSection(achievements: controller.achievements),
              ],
            ),
          ),
        ),
        Positioned(
          right: 4,
          bottom: 8,
          child: QuickActionsFab(
            onBuy: () => _openConfigure(context),
            // Sell/Reports are marked `available: false` inside
            // QuickActionsFab, which disables their hit-testing entirely —
            // these callbacks are wired for API completeness but can never
            // actually fire, so there's nothing to show a snackbar for.
            onSell: () {},
            onRebalance: () => _pointAtAllocation(context),
            onReports: () {},
          ),
        ),
      ],
    );
  }
}

class _HoldingsSkeleton extends StatelessWidget {
  const _HoldingsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _bar(context, height: 64),
        const SizedBox(height: 16),
        _bar(context, height: 300),
      ],
    );
  }

  Widget _bar(BuildContext context, {required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(
          alpha: context.isDarkMode ? 0.5 : 0.94,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
      ),
    );
  }
}
