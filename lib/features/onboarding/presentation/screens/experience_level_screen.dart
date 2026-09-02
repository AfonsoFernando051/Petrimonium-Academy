import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/journey_ready_screen.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/onboarding_scaffold.dart';
import 'package:petrimonium/features/pet/data/models/experience_level_enum.dart';

/// Onboarding's "Como está sua experiência hoje?" step — lets the Academy
/// skip content the user already knows instead of a one-size-fits-all
/// track. Sits between Time Horizon and Journey Ready; not individually
/// tracked by `OnboardingStateRepository` (same as Academy Intro/
/// Gamification Intro) since `TimeHorizonScreen` already marks the "goal"
/// milestone done before pushing here — closing the app mid-screen just
/// resumes at Journey Ready, which matches how the other untracked
/// intermediate onboarding screens already behave.
class ExperienceLevelScreen extends StatefulWidget {
  const ExperienceLevelScreen({super.key});

  @override
  State<ExperienceLevelScreen> createState() => _ExperienceLevelScreenState();
}

class _ExperienceLevelScreenState extends State<ExperienceLevelScreen> {
  ExperienceLevelEnum _selected = ExperienceLevelEnum.novice;
  bool _isSaving = false;

  void _select(ExperienceLevelEnum level) {
    HapticFeedback.selectionClick();
    setState(() => _selected = level);
  }

  Future<void> _handleContinue() async {
    setState(() => _isSaving = true);
    try {
      await DI.petPreferencesRepository.saveExperienceLevel(_selected);
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
      step: 7,
      totalSteps: 8,
      title: Translator.translate(AppStrings.experienceLevelTitle),
      subtitle: Translator.translate(AppStrings.experienceLevelSubtitle),
      ctaLabel: Translator.translate(AppStrings.onboardingNext),
      isCtaLoading: _isSaving,
      onCta: _handleContinue,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final level in ExperienceLevelEnum.values)
            _ExperienceLevelRow(
              level: level,
              isSelected: level == _selected,
              onTap: () => _select(level),
            ),
        ],
      ),
    );
  }
}

class _ExperienceLevelRow extends StatelessWidget {
  const _ExperienceLevelRow({required this.level, required this.isSelected, required this.onTap});

  final ExperienceLevelEnum level;
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
                  child: Text(level.emoji, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.label,
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        level.description,
                        style: TextStyle(color: tokens.textSecondary, fontSize: 12),
                      ),
                    ],
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
