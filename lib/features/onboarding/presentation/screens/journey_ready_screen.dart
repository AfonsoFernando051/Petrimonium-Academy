import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/game/domain/services/level_calculator.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/portfolio_choice_screen.dart';
import 'package:petrimonium/features/onboarding/presentation/onboarding_constants.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/mission_reward_card.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/onboarding_scaffold.dart';
import 'package:petrimonium/features/pet/data/models/pet_goal_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';

/// Onboarding's closing beat — a summary of the choices just made plus the
/// actual first mission, so the flow ends on an action rather than more
/// information. Replaces `TutorialScreen` as the step that flips
/// `completeTutorial()` before handing off to `PortfolioChoiceScreen`.
class JourneyReadyScreen extends StatefulWidget {
  const JourneyReadyScreen({super.key});

  @override
  State<JourneyReadyScreen> createState() => _JourneyReadyScreenState();
}

class _JourneyReadyScreenState extends State<JourneyReadyScreen> {
  PetGoalEnum? _goal;
  PetProfile? _profile;
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      DI.petPreferencesRepository.loadGoal(),
      DI.mascotRepository.loadProfile(),
    ]);
    if (!mounted) return;
    setState(() {
      _goal = results[0] as PetGoalEnum;
      _profile = results[1] as PetProfile;
    });
  }

  Future<void> _handleStart() async {
    setState(() => _isStarting = true);
    try {
      await DI.onboardingStateRepository.completeTutorial();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PortfolioChoiceScreen()),
        );
      }
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final goal = _goal;
    final profile = _profile;

    return OnboardingScaffold(
      step: 8,
      totalSteps: 8,
      title: Translator.translate(AppStrings.journeyReadyTitle),
      subtitle: Translator.translate(AppStrings.journeyReadySubtitle),
      ctaLabel: Translator.translate(AppStrings.journeyReadyCta),
      isCtaLoading: _isStarting,
      onCta: (goal == null || profile == null) ? null : _handleStart,
      body: (goal == null || profile == null)
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.neonCyan),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(
                        icon: goal.icon,
                        color: AppColors.neonPink,
                        label: Translator.translate(
                          AppStrings.journeyReadyGoalLabel,
                        ),
                        value: goal.label,
                      ),
                      const _SummaryDivider(),
                      _SummaryRow(
                        icon: Icons.school_outlined,
                        color: AppColors.neonCyan,
                        label: Translator.translate(
                          AppStrings.journeyReadyPathLabel,
                        ),
                        value: Translator.translate(
                          AppStrings.journeyReadyPathValue,
                        ),
                      ),
                      const _SummaryDivider(),
                      _SummaryRow(
                        icon: Icons.pets,
                        color: AppColors.neonPurple,
                        label: Translator.translate(
                          AppStrings.journeyReadyCompanionLabel,
                        ),
                        value:
                            '${profile.name ?? ''} · ${Translator.translate(AppStrings.onboardingLevelBadge, params: {'level': '${LevelCalculator.fromXp(profile.xp).level}'})}',
                      ),
                      const _SummaryDivider(),
                      _SummaryRow(
                        icon: Icons.star_rounded,
                        color: AppColors.goldenBorder,
                        label: Translator.translate(
                          AppStrings.journeyReadyProgressLabel,
                        ),
                        value: Translator.translate(
                          AppStrings.academyXpPill,
                          params: {'xp': '${profile.xp}'},
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                MissionRewardCard(
                  eyebrow: Translator.translate(
                    AppStrings.journeyReadyFirstMissionLabel,
                  ),
                  title: Translator.translate(
                    AppStrings.missionCompoundInterestTitle,
                  ),
                  xp: kStandardLessonXpReward,
                  completed: false,
                ),
              ],
            ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: tokens.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, color: context.colors.divider),
    );
  }
}
