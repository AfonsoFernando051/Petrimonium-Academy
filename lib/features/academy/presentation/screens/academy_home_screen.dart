import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_spacing.dart';
import 'package:petrimonium/core/theme/app_text_styles.dart';
import 'package:petrimonium/core/utils/fade_route.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/app_loading_indicator.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_domain.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/academy/presentation/controllers/academy_controller.dart';
import 'package:petrimonium/features/academy/presentation/screens/academy_domain_detail_screen.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/financial_lab_home_screen.dart';
import 'package:petrimonium/features/academy/presentation/screens/lesson_screen.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_catalog_error_state.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_continue_card.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_domain_card.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_level_header.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_mastery_section.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_review_card.dart';
import 'package:petrimonium/features/academy/presentation/widgets/financial_lab_entry_card.dart';
import 'package:petrimonium/features/game/domain/services/level_calculator.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_companion_controller.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// The "Academia" tab: current level, an unmissable "what's next" CTA, and
/// the module list — the answer to "what should I learn next?" is always on
/// screen (see `docs/ACADEMY_ENGINE.md` §5).
///
/// No own `Scaffold`/`AppBar`/background — like `PortfolioScreen` and
/// `MentorScreen`, this is embedded directly in `DashboardScreen`'s shared
/// `Scaffold`/`AppBar`/`CosmicBackground`/`IndexedStack`. Module detail and
/// individual lessons remain separately pushed screens (they need their own
/// back navigation); only the top-level tab content lives here.
class AcademyHomeScreen extends StatefulWidget {
  const AcademyHomeScreen({
    super.key,
    required this.mascotController,
    required this.companionController,
  });

  final MascotController mascotController;

  /// Offers the "continue where you left off" companion nudge once the
  /// next lesson is known — see `PetMessageCatalog._academyNudge`.
  final PetCompanionController companionController;

  @override
  State<AcademyHomeScreen> createState() => _AcademyHomeScreenState();
}

class _AcademyHomeScreenState extends State<AcademyHomeScreen> {
  late final AcademyController _controller;
  bool _companionNotified = false;

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
    _notifyCompanionOnce();
  }

  // Only offered once per screen lifetime — `PetCompanionController`'s own
  // cooldown/priority rules decide whether it's actually shown; this just
  // avoids re-evaluating on every rebuild the ChangeNotifier triggers.
  void _notifyCompanionOnce() {
    if (_companionNotified ||
        _controller.isLoading ||
        _controller.isCatalogLoading) {
      return;
    }
    final reviewCount = _controller.reviewQueue.length;
    final nextLesson = _controller.nextLesson;
    if (reviewCount == 0 && nextLesson == null) return;
    _companionNotified = true;
    widget.companionController.enterContext(
      PetContext.academy,
      data: {
        if (nextLesson != null) 'lessonTitle': nextLesson.title,
        if (reviewCount > 0) 'reviewDueCount': '$reviewCount',
      },
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openLesson(Lesson lesson) async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push(
      fadeRoute(
        LessonScreen(
          lesson: lesson,
          catalog: _controller.snapshot!,
          mascotController: widget.mascotController,
        ),
      ),
    );
    _controller.load();
  }

  Future<void> _openDomain(AcademyDomain domain) async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push(
      fadeRoute(
        AcademyDomainDetailScreen(
          domain: domain,
          mascotController: widget.mascotController,
        ),
      ),
    );
    _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds when the user switches language in Settings — this screen's
    // chrome keys off `Translator.currentLanguage` directly, while the
    // curriculum content itself is re-fetched by `_controller`'s own
    // language listener (see `AcademyController._onLanguageChanged`).
    return ValueListenableBuilder<String>(
      valueListenable: Translator.languageNotifier,
      builder: (context, _, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final tokens = context.colors;
    final level = LevelCalculator.fromXp(widget.mascotController.profile.xp);

    if (_controller.isLoading || _controller.isCatalogLoading) {
      return const AppLoadingIndicator();
    }

    if (_controller.snapshot == null) {
      return AcademyCatalogErrorState(onRetry: _controller.load);
    }

    // Mastery rows are only shown for schools with real content — an empty
    // 0% row for a `comingSoon` school isn't informative, same reasoning as
    // `PetMessageCatalog._portfolioNudge` only firing once there's something
    // real to say.
    final masterySchools = _controller.schools
        .where((s) => s.contentAvailable)
        .toList();

    return RefreshIndicator(
      color: tokens.primary,
      backgroundColor: tokens.surfaceElevated,
      onRefresh: _controller.load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AcademyLevelHeader(
              level: level.level,
              totalXpEarned: _controller.totalXpEarned,
              knowledgeLevel: _controller.knowledgeLevel,
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (_controller.nextLesson != null) ...[
              AcademyContinueCard(
                lesson: _controller.nextLesson!,
                onStart: () => _openLesson(_controller.nextLesson!),
              ),
              const SizedBox(height: AppSpacing.xxl + 4),
            ],
            if (masterySchools.isNotEmpty) ...[
              AcademyMasterySection(
                schools: masterySchools,
                masteryFor: _controller.masteryFor,
                realMasteryFor: _controller.realMasteryFor,
                masteryTierFor: _controller.masteryTierFor,
              ),
              const SizedBox(height: AppSpacing.xxl + 4),
            ],
            if (_controller.reviewQueue.isNotEmpty) ...[
              AcademyReviewCard(
                lessonCount: _controller.reviewQueue.length,
                estimatedMinutes: _controller.reviewEstimatedMinutes,
                onStart: () => _openLesson(_controller.reviewQueue.first),
              ),
              const SizedBox(height: AppSpacing.xxl + 4),
            ],
            FinancialLabEntryCard(
              onTap: () => Navigator.of(context).push(
                fadeRoute(
                  FinancialLabHomeScreen(
                    mascotController: widget.mascotController,
                    companionController: widget.companionController,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl + 4),
            Text(
              Translator.translate(AppStrings.academyDomainsSectionLabel),
              style: AppTextStyles.caption.copyWith(
                color: tokens.primary.withValues(alpha: 0.6),
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm + 2),
            for (final domain in _controller.domains) ...[
              AcademyDomainCard(
                domain: domain,
                status: _controller.domainStatusFor(domain),
                masteryPercent: _controller.domainMasteryFor(domain),
                onTap: () => _openDomain(domain),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
