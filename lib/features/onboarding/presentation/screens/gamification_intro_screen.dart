import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/xp_bar.dart';
import 'package:petrimonium/features/onboarding/presentation/onboarding_constants.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/mission_reward_card.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/onboarding_scaffold.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/pet_hero_capsule.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:petrimonium/features/pet/presentation/mascot/widgets/pet_mascot_widget.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/financial_goal_screen.dart';

/// Onboarding's "don't explain the loop, show it" beat — the Learn → Play →
/// Evolve mechanic demonstrated on the player's own just-configured pet
/// (species/name are real by this point), with an illustrative level/XP bar
/// (a worked example of *what progression looks like*, not the player's real
/// 0 XP yet — that honest number is shown on the Journey Ready screen) and a
/// mission/XP reward matching [kStandardLessonXpReward], the real per-lesson
/// value every lesson in the Academy catalog awards today.
class GamificationIntroScreen extends StatefulWidget {
  const GamificationIntroScreen({super.key});

  @override
  State<GamificationIntroScreen> createState() =>
      _GamificationIntroScreenState();
}

class _GamificationIntroScreenState extends State<GamificationIntroScreen> {
  static const _demoLevel = 3;
  static const _demoXpIntoLevel = 820;
  static const _demoXpForNextLevel = 1000;

  late final MascotController _mascotController = MascotController(
    repository: DI.mascotRepository,
  );

  @override
  void initState() {
    super.initState();
    _mascotController.loadProfile();
  }

  @override
  void dispose() {
    _mascotController.dispose();
    super.dispose();
  }

  void _goNext(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const FinancialGoalScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 4,
      totalSteps: 7,
      showSkip: true,
      onSkip: () => _goNext(context),
      title: Translator.translate(AppStrings.gamificationIntroTitle),
      subtitle: Translator.translate(AppStrings.gamificationIntroSubtitle),
      ctaLabel: Translator.translate(AppStrings.onboardingNext),
      onCta: () => _goNext(context),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                AnimatedBuilder(
                  animation: _mascotController,
                  builder: (context, _) => PetHeroCapsule(
                    size: 170,
                    auraColor: AppColors.neonViolet,
                    child: PetMascotWidget(
                      controller: _mascotController,
                      size: 130,
                    ),
                  ),
                ),
                Positioned(
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.brandGradient,
                      ),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonPink.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Text(
                      Translator.translate(
                        AppStrings.onboardingLevelBadge,
                        params: {'level': '$_demoLevel'},
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          XpBar(
            progress: _demoXpIntoLevel / _demoXpForNextLevel,
            color: AppColors.neonCyan,
            label: '$_demoXpIntoLevel / $_demoXpForNextLevel XP',
          ),
          const SizedBox(height: 24),
          MissionRewardCard(
            title: Translator.translate(
              AppStrings.missionCompoundInterestTitle,
            ),
            xp: kStandardLessonXpReward,
          ),
        ],
      ),
    );
  }
}
