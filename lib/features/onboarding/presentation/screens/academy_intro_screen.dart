import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/pet_assets.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_module.dart';
import 'package:petrimonium/features/academy/domain/services/academy_progress_calculator.dart';
import 'package:petrimonium/features/academy/presentation/controllers/academy_controller.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/gamification_intro_screen.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/onboarding_scaffold.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/financial_goal_screen.dart';

/// Onboarding's "here's your track" beat — a vertical, locked/unlocked
/// sequence of the first real Academy modules (matching the Notion
/// mockup's "Sua trilha começa aqui"), not a generic preview grid. Modules
/// and their locked state are read live from the same `AcademyController`/
/// `AcademyProgressCalculator` the real Academy screen uses, so onboarding
/// never drifts from what the user will actually see once they get there —
/// no fabricated lesson counts or "starts now" claims. If the catalog is
/// still loading or unreachable, the track is simply omitted rather than
/// blocking onboarding — this screen's own progress never depends on it.
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
    final previewModules = [..._controller.modules.where((m) => m.order <= 4)]
      ..sort((a, b) => a.order.compareTo(b.order));

    return OnboardingScaffold(
      step: 3,
      totalSteps: 8,
      showSkip: true,
      onSkip: () => _skip(context),
      title: Translator.translate(AppStrings.academyIntroTitle),
      subtitle: Translator.translate(AppStrings.academyIntroSubtitle),
      ctaLabel: Translator.translate(AppStrings.onboardingNext),
      onCta: () => _goNext(context),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < previewModules.length; i++)
            _TrackStep(
              index: i + 1,
              module: previewModules[i],
              status: _controller.statusFor(previewModules[i]),
              isLast: i == previewModules.length - 1,
            ),
          if (previewModules.isNotEmpty) ...[
            const SizedBox(height: 20),
            _MentorIntroCard(module: previewModules.first),
          ],
        ],
      ),
    );
  }
}

String _lessonCountLabel(AcademyModule module) {
  final count = module.lessonIds.length;
  final unit = Translator.translate(
    count == 1 ? AppStrings.academyIntroLessonSingular : AppStrings.academyIntroLessonPlural,
  );
  return '$count $unit';
}

class _TrackStep extends StatelessWidget {
  const _TrackStep({required this.index, required this.module, required this.status, required this.isLast});

  final int index;
  final AcademyModule module;
  final ModuleStatus status;
  final bool isLast;

  bool get _isActive => status == ModuleStatus.available || status == ModuleStatus.inProgress;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final subtitle = _isActive
        ? '${_lessonCountLabel(module)} · ${Translator.translate(AppStrings.academyIntroStartsNow)}'
        : _lessonCountLabel(module);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _isActive ? const LinearGradient(colors: AppColors.brandGradient) : null,
                  color: _isActive ? null : tokens.textPrimary.withValues(alpha: 0.08),
                ),
                child: Text(
                  '$index',
                  style: TextStyle(
                    color: _isActive ? Colors.white : tokens.textTertiary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 1.5, color: tokens.textPrimary.withValues(alpha: 0.12)),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.title,
                    style: TextStyle(
                      color: _isActive ? tokens.textPrimary : tokens.textTertiary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: tokens.textTertiary, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MentorIntroCard extends StatelessWidget {
  const _MentorIntroCard({required this.module});

  final AcademyModule module;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: Image.asset(
            PetAssets.imageFor(null),
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.pets, size: 20, color: tokens.mentor),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: tokens.textPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: tokens.textPrimary.withValues(alpha: 0.1)),
            ),
            child: Text(
              Translator.translate(
                AppStrings.academyIntroMentorIntro,
                params: {'module': module.title, 'count': _lessonCountLabel(module)},
              ),
              style: TextStyle(color: tokens.textSecondary, fontSize: 13, height: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}
