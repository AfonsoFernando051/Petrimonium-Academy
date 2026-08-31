import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_motion.dart';
import 'package:petrimonium/core/theme/background_presets.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/app_loading_indicator.dart';
import 'package:petrimonium/core/widgets/cosmic_background.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_module.dart';
import 'package:petrimonium/features/academy/domain/entities/school.dart';
import 'package:petrimonium/features/academy/presentation/controllers/academy_controller.dart';
import 'package:petrimonium/features/academy/presentation/screens/module_detail_screen.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_catalog_error_state.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_progress_bar.dart';
import 'package:petrimonium/features/academy/presentation/widgets/mastery_tier_presentation.dart';
import 'package:petrimonium/features/academy/presentation/widgets/module_card.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// Lists the modules of one [School] — the middle step of the
/// School → Module → Lesson journey, pushed from `AcademyHomeScreen`'s
/// journey list. Mirrors `ModuleDetailScreen`'s shape exactly (own
/// `Scaffold`/`AppBar`/`CosmicBackground`, same fade-route push into
/// `ModuleDetailScreen`).
class SchoolDetailScreen extends StatefulWidget {
  const SchoolDetailScreen({
    super.key,
    required this.school,
    required this.mascotController,
  });

  final School school;
  final MascotController mascotController;

  @override
  State<SchoolDetailScreen> createState() => _SchoolDetailScreenState();
}

class _SchoolDetailScreenState extends State<SchoolDetailScreen> {
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

  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.04), end: Offset.zero)
                  .animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: child,
            ),
          ),
      transitionDuration: AppMotion.pageTransition,
    );
  }

  Future<void> _openModule(AcademyModule module) async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push(
      _fadeRoute(
        ModuleDetailScreen(
          module: module,
          mascotController: widget.mascotController,
        ),
      ),
    );
    _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: Translator.languageNotifier,
      builder: (context, _, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final tokens = context.colors;
    final modules = _controller.modulesForSchool(widget.school);
    final progressPercent = _controller.masteryFor(widget.school);
    final realMasteryPercent = _controller.realMasteryFor(widget.school);
    final masteryTier = _controller.masteryTierFor(widget.school);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.school.title,
          style: TextStyle(
            color: tokens.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tokens.textPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
      ),
      body: CosmicBackground(
        intensity: BackgroundIntensity.subtle,
        child: SafeArea(
          child: _controller.isLoading || _controller.isCatalogLoading
              ? const AppLoadingIndicator()
              : _controller.snapshot == null
              ? AcademyCatalogErrorState(onRetry: _controller.load)
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GlassCard(
                        borderColor: AppColors.neonCyan.withValues(alpha: 0.3),
                        borderRadius: 20,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    widget.school.icon,
                                    color: AppColors.neonCyan,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      widget.school.description,
                                      style: TextStyle(
                                        color: tokens.textSecondary,
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                Translator.translate(
                                  AppStrings.academyProgressLabel,
                                ),
                                style: TextStyle(
                                  color: tokens.textTertiary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              AcademyProgressBar(progress: progressPercent),
                              const SizedBox(height: 6),
                              Text(
                                Translator.translate(
                                  AppStrings.academyMasteryPercentLabel,
                                  params: {
                                    'percent':
                                        '${(progressPercent * 100).round()}',
                                  },
                                ),
                                style: TextStyle(
                                  color: tokens.textTertiary,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                Translator.translate(
                                  AppStrings.academyRealMasteryLabel,
                                ),
                                style: TextStyle(
                                  color: tokens.textTertiary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: AcademyProgressBar(
                                      progress: realMasteryPercent,
                                      color: MasteryTierPresentation.color(
                                        masteryTier,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${(realMasteryPercent * 100).round()}%',
                                    style: TextStyle(
                                      color: tokens.textTertiary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                Translator.translate(
                                  MasteryTierPresentation.labelKey(masteryTier),
                                ),
                                style: TextStyle(
                                  color: MasteryTierPresentation.color(
                                    masteryTier,
                                  ),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        Translator.translate(
                          AppStrings.academyModulesSectionLabel,
                        ),
                        style: TextStyle(
                          color: tokens.primary.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final module in modules) ...[
                        ModuleCard(
                          module: module,
                          status: _controller.statusFor(module),
                          completedLessons: _controller.completedLessonCountFor(
                            module,
                          ),
                          onTap: () => _openModule(module),
                          missingPrerequisites: _controller.missingPrerequisitesFor(module),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
