import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/onboarding_scaffold.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/financial_goal_screen.dart';

/// Onboarding's "how the loop actually works" beat — three ground rules the
/// Notion mockup states plainly (XP only from learning, no streak
/// punishment, no comparison between people) rather than a demo mechanic
/// with an illustrative level/XP number, which risked reading as a promise
/// about the player's own progress before they've earned any.
class GamificationIntroScreen extends StatelessWidget {
  const GamificationIntroScreen({super.key});

  void _goNext(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const FinancialGoalScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 4,
      totalSteps: 8,
      showSkip: true,
      onSkip: () => _goNext(context),
      title: Translator.translate(AppStrings.gamificationIntroTitle),
      ctaLabel: Translator.translate(AppStrings.onboardingNext),
      onCta: () => _goNext(context),
      body: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RuleRow(
              icon: Icons.auto_awesome,
              iconColor: AppColors.neonCyan,
              title: Translator.translate(AppStrings.gamificationIntroXpRuleTitle),
              body: Translator.translate(AppStrings.gamificationIntroXpRuleBody),
            ),
            const SizedBox(height: 18),
            _RuleRow(
              icon: Icons.local_fire_department,
              iconColor: AppColors.warningAmber,
              title: Translator.translate(AppStrings.gamificationIntroStreakRuleTitle),
              body: Translator.translate(AppStrings.gamificationIntroStreakRuleBody),
            ),
            const SizedBox(height: 18),
            _RuleRow(
              icon: Icons.diamond_outlined,
              iconColor: AppColors.neonViolet,
              title: Translator.translate(AppStrings.gamificationIntroCompareRuleTitle),
              body: Translator.translate(AppStrings.gamificationIntroCompareRuleBody),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: TextStyle(
                  color: tokens.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
