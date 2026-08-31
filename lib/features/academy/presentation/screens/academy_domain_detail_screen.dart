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
import 'package:petrimonium/features/academy/domain/entities/academy_domain.dart';
import 'package:petrimonium/features/academy/domain/entities/school.dart';
import 'package:petrimonium/features/academy/presentation/controllers/academy_controller.dart';
import 'package:petrimonium/features/academy/presentation/screens/school_detail_screen.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_catalog_error_state.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_progress_bar.dart';
import 'package:petrimonium/features/academy/presentation/widgets/school_card.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// Lists the schools of one [AcademyDomain] — the new top step of the
/// Domain → School → Module → Lesson journey, pushed from
/// `AcademyHomeScreen`'s domain list. Mirrors `SchoolDetailScreen`'s shape
/// exactly (own `Scaffold`/`AppBar`/`CosmicBackground`, same fade-route push
/// into the **existing, unmodified** `SchoolDetailScreen`).
class AcademyDomainDetailScreen extends StatefulWidget {
  const AcademyDomainDetailScreen({
    super.key,
    required this.domain,
    required this.mascotController,
  });

  final AcademyDomain domain;
  final MascotController mascotController;

  @override
  State<AcademyDomainDetailScreen> createState() =>
      _AcademyDomainDetailScreenState();
}

class _AcademyDomainDetailScreenState extends State<AcademyDomainDetailScreen> {
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

  Future<void> _openSchool(School school) async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push(
      _fadeRoute(
        SchoolDetailScreen(
          school: school,
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
    final schools = _controller.schoolsForDomain(widget.domain);
    final masteryPercent = _controller.domainMasteryFor(widget.domain);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.domain.title,
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
                                    widget.domain.icon,
                                    color: AppColors.neonCyan,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      widget.domain.description,
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
                              AcademyProgressBar(progress: masteryPercent),
                              const SizedBox(height: 6),
                              Text(
                                Translator.translate(
                                  AppStrings.academyMasteryPercentLabel,
                                  params: {
                                    'percent':
                                        '${(masteryPercent * 100).round()}',
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
                          AppStrings.academySchoolsSectionLabel,
                        ),
                        style: TextStyle(
                          color: tokens.primary.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final school in schools) ...[
                        SchoolCard(
                          school: school,
                          status: _controller.schoolStatusFor(school),
                          masteryPercent: _controller.masteryFor(school),
                          onTap: () => _openSchool(school),
                          missingPrerequisites: _controller.missingSchoolPrerequisitesFor(school),
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
