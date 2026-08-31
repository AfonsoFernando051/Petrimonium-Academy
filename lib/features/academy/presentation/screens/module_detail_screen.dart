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
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/academy/domain/services/academy_progress_calculator.dart';
import 'package:petrimonium/features/academy/presentation/controllers/academy_controller.dart';
import 'package:petrimonium/features/academy/presentation/screens/lesson_screen.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_catalog_error_state.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_progress_bar.dart';
import 'package:petrimonium/features/academy/presentation/widgets/lesson_list_tile.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

class ModuleDetailScreen extends StatefulWidget {
  const ModuleDetailScreen({
    super.key,
    required this.module,
    required this.mascotController,
  });

  final AcademyModule module;
  final MascotController mascotController;

  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {
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

  Future<void> _openLesson(Lesson lesson) async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push(
      _fadeRoute(
        LessonScreen(
          lesson: lesson,
          catalog: _controller.snapshot!,
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
    final lessons =
        _controller.snapshot?.lessonsForModule(widget.module.id) ?? const [];
    final completed = _controller.completedLessonCountFor(widget.module);
    final progress = lessons.isEmpty ? 0.0 : completed / lessons.length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.module.title,
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
                                    widget.module.icon,
                                    color: AppColors.neonCyan,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      widget.module.description,
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
                              AcademyProgressBar(progress: progress),
                              const SizedBox(height: 6),
                              Text(
                                Translator.translate(
                                  AppStrings.academyLessonsProgressLabel,
                                  params: {
                                    'completed': '$completed',
                                    'total': '${lessons.length}',
                                  },
                                ),
                                style: TextStyle(
                                  color: tokens.textTertiary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        Translator.translate(
                          AppStrings.academyLessonsSectionLabel,
                        ),
                        style: TextStyle(
                          color: tokens.primary.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final lesson in lessons)
                        LessonListTile(
                          lesson: lesson,
                          status: AcademyProgressCalculator.lessonStatus(
                            catalog: _controller.snapshot!,
                            lesson: lesson,
                            completedIds: _controller.completedLessonIds,
                          ),
                          onTap: () => _openLesson(lesson),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
