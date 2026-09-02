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
  InvestmentHorizonEnum _selected = InvestmentHorizonEnum.mediumTerm;
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
      step: 6,
      totalSteps: 7,
      maxContentWidth: 760,
      title: Translator.translate(AppStrings.timeHorizonTitle),
      subtitle: Translator.translate(AppStrings.timeHorizonSubtitle),
      ctaLabel: Translator.translate(AppStrings.onboardingNext),
      isCtaLoading: _isSaving,
      onCta: _handleContinue,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 620;
              final cards = [
                for (final horizon in InvestmentHorizonEnum.values)
                  _HorizonCard(
                    horizon: horizon,
                    isSelected: horizon == _selected,
                    onTap: () => _select(horizon),
                    expand: isWide,
                  ),
              ];
              if (!isWide) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final c in cards)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: c,
                      ),
                  ],
                );
              }
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 1.5,
                    margin: const EdgeInsets.symmetric(horizontal: 48),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.neonCyan.withValues(alpha: 0.05),
                          AppColors.neonCyan.withValues(alpha: 0.35),
                          AppColors.neonPink.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final c in cards)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: c,
                            ),
                          ),
                      ],
                    ),
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

class _HorizonCard extends StatelessWidget {
  const _HorizonCard({
    required this.horizon,
    required this.isSelected,
    required this.onTap,
    required this.expand,
  });

  final InvestmentHorizonEnum horizon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedScale(
          scale: isSelected ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
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
                        color: AppColors.neonCyan.withValues(alpha: 0.25),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      horizon.icon,
                      color: isSelected
                          ? AppColors.neonCyan
                          : tokens.textSecondary,
                      size: 34,
                    ),
                    if (isSelected)
                      const Positioned(
                        right: -6,
                        top: -6,
                        child: Icon(
                          Icons.check_circle,
                          color: AppColors.neonCyan,
                          size: 18,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  horizon.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  horizon.description,
                  textAlign: TextAlign.center,
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
