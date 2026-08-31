import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/portfolio_choice_screen.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/onboarding_screen.dart';

/// Home's placeholder when the user skipped (or hasn't yet reached) the
/// portfolio step — the app must stay fully usable without a portfolio, so
/// this replaces the portfolio-bridge card instead of blocking Home.
class PortfolioNotConnectedCard extends StatelessWidget {
  const PortfolioNotConnectedCard({super.key, this.showInvestorProfileAction = false});

  /// Whether the risk-assessment questionnaire is still unanswered — mirrors
  /// `DashboardScreen._investorProfileUnanswered`.
  final bool showInvestorProfileAction;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      backgroundColor: context.colors.surface.withValues(alpha: context.isDarkMode ? 0.5 : 0.94),
      borderColor: AppColors.neonCyan.withValues(alpha: 0.3),
      borderRadius: 24,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.neonCyan.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.diamond_outlined, color: AppColors.neonCyan),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Translator.translate(AppStrings.portfolioNotConnectedTitle),
                        style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Translator.translate(AppStrings.portfolioNotConnectedBody),
                        style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GameButton(
              label: Translator.translate(AppStrings.connectInvestmentsButton),
              icon: Icons.arrow_forward,
              iconTrailing: true,
              height: 48,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PortfolioChoiceScreen()),
                );
              },
            ),
            if (showInvestorProfileAction) ...[
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                    );
                  },
                  child: Text(
                    Translator.translate(AppStrings.homeAnswerInvestorProfileLink),
                    style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
