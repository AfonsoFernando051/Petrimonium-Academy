import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/module_chip.dart';
import 'package:petrimonium/features/academy/presentation/controllers/academy_controller.dart';
import 'package:petrimonium/features/onboarding/presentation/onboarding_constants.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/gamification_intro_screen.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/onboarding_scaffold.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/financial_goal_screen.dart';

/// Onboarding's "there is a real investment school inside this app" beat.
/// Modules/icons/titles are read live from the Academy catalog — the same
/// data the real Academy screen shows — so onboarding never drifts from
/// what the user will actually see once they get there. Owns its own
/// `AcademyController` (same pattern as every other Academy screen) purely
/// to fetch that catalog; if it's still loading or unreachable, the module
/// preview grid is simply omitted rather than blocking onboarding — this
/// screen's own progress never depends on the catalog.
class AcademyIntroScreen extends StatefulWidget {
  const AcademyIntroScreen({super.key});

  @override
  State<AcademyIntroScreen> createState() => _AcademyIntroScreenState();
}

class _AcademyIntroScreenState extends State<AcademyIntroScreen> {
  late final AcademyController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AcademyController(
      repository: DI.academyProgressRepository,
      catalogRepository: DI.academyCatalogRepository,
      remoteDataSource: DI.academyRemoteDataSource,
    );
    _controller.addListener(_onChanged);
    _controller.load();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _goNext(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const GamificationIntroScreen()));
  }

  void _skip(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const FinancialGoalScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final previewModules = [..._controller.modules.where((m) => m.order <= 4)]
      ..sort((a, b) => a.order.compareTo(b.order));

    return OnboardingScaffold(
      step: 3,
      totalSteps: 7,
      showSkip: true,
      onSkip: () => _skip(context),
      title: Translator.translate(AppStrings.academyIntroTitle),
      subtitle: Translator.translate(AppStrings.academyIntroSubtitle),
      ctaLabel: Translator.translate(AppStrings.onboardingNext),
      onCta: () => _goNext(context),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            Translator.translate(AppStrings.academyIntroBody),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          if (previewModules.isNotEmpty)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.7,
              children: [
                for (final module in previewModules) ModuleChip(module: module),
              ],
            ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.goldenBorder.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.goldenBorder.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.goldenBorder,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  Translator.translate(
                    AppStrings.academyIntroXpBadge,
                    params: {'xp': '$kStandardLessonXpReward'},
                  ),
                  style: const TextStyle(
                    color: AppColors.goldenBorder,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
