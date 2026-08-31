import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/background_presets.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/onboarding_scaffold.dart';
import 'package:petrimonium/features/pet/data/models/pet_goal_enum.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/time_horizon_screen.dart';

/// Onboarding's "Choose Your Financial Goal" step — framed as the player's
/// first mission (per the redesign) rather than a risk/strategy question, so
/// it reads as personal, not a financial form. Time horizon used to live on
/// this same screen behind a bottom-sheet picker; it's now its own
/// deliberate step (`TimeHorizonScreen`) right after this one. Selection
/// personalizes future missions/recommendations; nothing here is mandatory
/// data like a portfolio, so there is no skip affordance — picking a goal
/// costs nothing.
class FinancialGoalScreen extends StatefulWidget {
  const FinancialGoalScreen({super.key});

  @override
  State<FinancialGoalScreen> createState() => _FinancialGoalScreenState();
}

class _FinancialGoalScreenState extends State<FinancialGoalScreen> {
  PetGoalEnum _selectedGoal = PetGoalEnum.buildWealth;
  bool _isSaving = false;

  void _selectGoal(PetGoalEnum goal) {
    HapticFeedback.selectionClick();
    setState(() => _selectedGoal = goal);
  }

  Future<void> _handleContinue() async {
    setState(() => _isSaving = true);
    try {
      await DI.petPreferencesRepository.saveGoal(_selectedGoal);
      if (mounted) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const TimeHorizonScreen()));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      intensity: BackgroundIntensity.subtle,
      step: 5,
      totalSteps: 7,
      maxContentWidth: 760,
      title: Translator.translate(AppStrings.financialGoalTitle),
      subtitle: Translator.translate(AppStrings.financialGoalSubtitle),
      ctaLabel: Translator.translate(AppStrings.financialGoalContinue),
      isCtaLoading: _isSaving,
      onCta: _handleContinue,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 560 ? 2 : 1;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: columns == 2 ? 1.5 : 2.4,
                children: [
                  for (final goal in PetGoalEnum.values)
                    _GoalCard(
                      goal: goal,
                      isSelected: goal == _selectedGoal,
                      onTap: () => _selectGoal(goal),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.isSelected,
    required this.onTap,
  });

  final PetGoalEnum goal;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedScale(
          scale: isSelected ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.neonCyan.withValues(alpha: 0.14)
                  : tokens.textPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppColors.neonCyan
                    : tokens.textPrimary.withValues(alpha: 0.12),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.neonCyan.withValues(alpha: 0.22),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            (isSelected
                                    ? AppColors.neonCyan
                                    : tokens.textPrimary)
                                .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        goal.icon,
                        color: isSelected
                            ? AppColors.neonCyan
                            : tokens.textSecondary,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    AnimatedOpacity(
                      opacity: isSelected ? 1 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppColors.neonCyan,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  goal.label,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 14.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  goal.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 11.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
