import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
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
  PetGoalEnum _selectedGoal = PetGoalEnum.investWithConfidence;
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
      step: 5,
      totalSteps: 7,
      title: Translator.translate(AppStrings.financialGoalTitle),
      subtitle: Translator.translate(AppStrings.financialGoalSubtitle),
      ctaLabel: Translator.translate(AppStrings.financialGoalContinue),
      isCtaLoading: _isSaving,
      onCta: _handleContinue,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final goal in PetGoalEnum.values)
            _GoalRow(
              goal: goal,
              isSelected: goal == _selectedGoal,
              onTap: () => _selectGoal(goal),
            ),
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.goal, required this.isSelected, required this.onTap});

  final PetGoalEnum goal;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.neonCyan.withValues(alpha: 0.14) : tokens.textPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.neonCyan : tokens.textPrimary.withValues(alpha: 0.12),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tokens.textPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Text(goal.emoji, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    goal.label,
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ),
                if (isSelected) const Icon(Icons.check_circle, color: AppColors.neonCyan, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
