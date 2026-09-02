import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/journey_ready_screen.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/onboarding_scaffold.dart';
import 'package:petrimonium/features/pet/data/models/investment_horizon_enum.dart';

/// Onboarding's Time Horizon step — split out of the old `FinancialGoalScreen`
/// (which buried this behind a bottom-sheet picker) into its own deliberate
/// decision, framed as a timeline rather than a form field.
class TimeHorizonScreen extends StatefulWidget {
  const TimeHorizonScreen({super.key});

  @override
  State<TimeHorizonScreen> createState() => _TimeHorizonScreenState();
}

class _TimeHorizonScreenState extends State<TimeHorizonScreen> {
  InvestmentHorizonEnum _selected = InvestmentHorizonEnum.oneToFiveYears;
  bool _isSaving = false;

  void _select(InvestmentHorizonEnum horizon) {
    HapticFeedback.selectionClick();
    setState(() => _selected = horizon);
  }

  Future<void> _handleContinue() async {
    setState(() => _isSaving = true);
    try {
      await DI.petPreferencesRepository.saveHorizon(_selected);
      await DI.onboardingStateRepository.setGoalChosen();
      if (mounted) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const JourneyReadyScreen()));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 2,
      totalSteps: 9,
      title: Translator.translate(AppStrings.timeHorizonTitle),
      subtitle: Translator.translate(AppStrings.timeHorizonSubtitle),
      ctaLabel: Translator.translate(AppStrings.onboardingNext),
      isCtaLoading: _isSaving,
      onCta: _handleContinue,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final horizon in InvestmentHorizonEnum.values)
            _HorizonRow(
              horizon: horizon,
              isSelected: horizon == _selected,
              onTap: () => _select(horizon),
            ),
        ],
      ),
    );
  }
}

class _HorizonRow extends StatelessWidget {
  const _HorizonRow({required this.horizon, required this.isSelected, required this.onTap});

  final InvestmentHorizonEnum horizon;
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                Expanded(
                  child: Text(
                    horizon.label,
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
