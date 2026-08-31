import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/widgets/app_loading_indicator.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_module.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_recommendation.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/academy/domain/services/academy_progress_calculator.dart';
import 'package:petrimonium/features/academy/presentation/controllers/academy_controller.dart';
import 'package:petrimonium/features/academy/presentation/screens/lesson_screen.dart';
import 'package:petrimonium/features/academy/presentation/screens/module_detail_screen.dart';
import 'package:petrimonium/features/academy/presentation/widgets/recommended_for_you_section.dart';
import 'package:petrimonium/features/home/domain/entities/next_action.dart';
import 'package:petrimonium/features/home/domain/services/next_action_resolver.dart';
import 'package:petrimonium/features/home/presentation/widgets/knowledge_map_strip.dart';
import 'package:petrimonium/features/home/presentation/widgets/next_action_card.dart';
import 'package:petrimonium/features/home/presentation/widgets/learning_hero_card.dart';
import 'package:petrimonium/features/home/presentation/widgets/portfolio_bridge_card.dart';
import 'package:petrimonium/features/home/presentation/widgets/portfolio_not_connected_card.dart';
import 'package:petrimonium/features/home/presentation/widgets/portfolio_reminder_banner.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_companion_controller.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/pet_speech_bubble_anchor.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:petrimonium/features/portfolio/domain/services/mission_display_catalog.dart';
import 'package:petrimonium/features/portfolio/presentation/controllers/portfolio_controller.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/error_banner.dart';

/// Home — the app's learning-first orchestration layer
/// (`docs/PRODUCT_VISION.md` §8): where the user is in their learning
/// journey, what to learn next, XP progress, knowledge development, and a
/// compact bridge into their real portfolio. Detailed financial metrics
/// (charts, allocation, holdings, the full missions/achievements list) live
/// on the Portfolio tab, not here — the one exception is `NextActionCard`
/// (see `_nextAction`/`NextActionResolver`), which surfaces a single mission
/// on Home only when it's one lesson away from completing, since that's a
/// genuine, time-bound signal that would otherwise stay invisible.
///
/// No own `Scaffold`/`AppBar`/background — embedded directly in
/// `DashboardScreen`'s shared chrome, mirroring `AcademyHomeScreen` and
/// `PortfolioScreen`.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.portfolioController,
    required this.mascotController,
    required this.onOpenAcademyTab,
    required this.onOpenPortfolioTab,
    required this.showPortfolioReminder,
    required this.onDismissPortfolioReminder,
    required this.investorProfileUnanswered,
    required this.companionController,
    required this.heroAnchor,
  });

  final PortfolioController portfolioController;
  final MascotController mascotController;
  final VoidCallback onOpenAcademyTab;
  final VoidCallback onOpenPortfolioTab;
  final bool showPortfolioReminder;
  final VoidCallback onDismissPortfolioReminder;
  final bool investorProfileUnanswered;

  /// Offers Home's own "what should I do next" companion nudge once the
  /// review/continue-lesson data is known — see
  /// `PetMessageCatalog._homeNudge`. Same contract as
  /// `AcademyHomeScreen.companionController`.
  final PetCompanionController companionController;

  /// Where Home's big, animated pet (`LearningHeroCard`) renders, for
  /// `PetSpeechBubbleOverlay` to glue its bubble to — see
  /// `PetSpeechBubbleAnchor`. Owned by `DashboardScreen` so it stays the
  /// same instance across rebuilds.
  final PetSpeechBubbleAnchor heroAnchor;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AcademyController _academyController;
  bool _companionNotified = false;

  @override
  void initState() {
    super.initState();
    _academyController = AcademyController(
      repository: DI.academyProgressRepository,
      catalogRepository: DI.academyCatalogRepository,
      remoteDataSource: DI.academyRemoteDataSource,
    );
    _academyController.addListener(_onAcademyChanged);
    _academyController.load();
  }

  void _onAcademyChanged() {
    if (mounted) setState(() {});
    _notifyCompanionOnce();
  }

  // Mirrors `AcademyHomeScreen._notifyCompanionOnce` exactly — only offered
  // once per screen lifetime, and only once real review/continue-lesson data
  // is known, so Home isn't silent just because no level-up is imminent
  // (`PetMessageCatalog._homeNudge`'s fallback).
  void _notifyCompanionOnce() {
    if (_companionNotified ||
        _academyController.isLoading ||
        _academyController.isCatalogLoading) {
      return;
    }
    final reviewCount = _academyController.reviewQueue.length;
    final nextLesson = _academyController.nextLesson;
    final daysAway = widget.mascotController.daysSinceLastSession;
    // Genuinely nothing known (offline, or an empty catalog fetch) — stay
    // silent rather than force the ambient fallback in over real absence of
    // data; the common "already showed the real nudge, now cooling down"
    // case is what the fallback is for (see `enterContext` below).
    if (reviewCount == 0 && nextLesson == null && daysAway == null) return;
    _companionNotified = true;
    // Same signal driving `NextActionCard` below (`_nextAction`) — so the
    // pet's words and the headline CTA agree (brief §18 "Home + Pet
    // Integration": the pet explains, the card executes).
    final nextAction = _nextAction;
    widget.companionController.enterContext(
      PetContext.home,
      data: {
        if (nextLesson != null) 'lessonTitle': nextLesson.title,
        if (reviewCount > 0) 'reviewDueCount': '$reviewCount',
        if (nextAction is CompleteMissionAction)
          'missionTitle': MissionDisplayCatalog.forCode(nextAction.mission.code).title,
        if (daysAway != null) 'daysSinceLastSession': '$daysAway',
      },
      // Once real Academy data is in, Home always has *something* worth
      // saying — either a concrete nudge or, when that's cooling down /
      // there's nothing to recommend, the ambient motivational fallback
      // (`PetMessageCatalog._homeNudge`). The early, low-info greeting from
      // `DashboardScreen._initCompanionGreeting` deliberately doesn't set
      // this, so it can't "claim" the slot with filler before this call.
      allowAmbientFallback: true,
    );
  }

  /// Home's single ranked "what should I do now" — see `NextActionResolver`.
  /// Read both by [build] (to render `NextActionCard`) and by
  /// [_notifyCompanionOnce] (so the pet's nudge agrees with it) — computed
  /// once per rebuild rather than twice, so the two can never disagree.
  NextAction get _nextAction => NextActionResolver.resolve(
        nextLesson: _academyController.nextLesson,
        moduleTitle: _academyController.nextLesson == null
            ? null
            : _academyController.snapshot?.moduleById(_academyController.nextLesson!.moduleId)?.title,
        missions: widget.portfolioController.missions,
      );

  @override
  void dispose() {
    _academyController.removeListener(_onAcademyChanged);
    _academyController.dispose();
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
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  Future<void> _startLesson(Lesson lesson) async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push(
      _fadeRoute(
        LessonScreen(
          lesson: lesson,
          catalog: _academyController.snapshot!,
          mascotController: widget.mascotController,
        ),
      ),
    );
    _academyController.load();
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
    _academyController.load();
  }

  /// Only the `review` recommendation, if any — `continueLearning` is
  /// already this screen's `NextActionCard` (when nothing more urgent
  /// outranks it), so showing it again here would be redundant (brief's own
  /// "one primary action per screen" principle).
  List<AcademyRecommendation> get _reviewRecommendations => _academyController
      .recommendations
      .where((r) => r.type == RecommendationType.review)
      .toList();

  void _tapModuleChip(AcademyModule module) {
    final status = _academyController.statusFor(module);
    if (status == ModuleStatus.comingSoon || status == ModuleStatus.locked) {
      return;
    }
    _openModule(module);
  }

  @override
  Widget build(BuildContext context) {
    final portfolioController = widget.portfolioController;

    if (portfolioController.isLoading &&
        portfolioController.holdings.isEmpty &&
        portfolioController.error == null) {
      return const AppLoadingIndicator();
    }

    final hasPortfolio = portfolioController.holdings.isNotEmpty;

    return RefreshIndicator(
      color: context.colors.primary,
      backgroundColor: context.colors.surfaceElevated,
      onRefresh: () => Future.wait([
        portfolioController.refresh(),
        _academyController.load(),
      ]),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (portfolioController.error != null) ...[
              ErrorBanner(onRetry: portfolioController.refresh),
              const SizedBox(height: 12),
            ],

            // Only when the catalog truly never loaded (no cache either) —
            // otherwise a `nextLesson == null` reads as "every lesson
            // complete" below, which would be misleading during a transient
            // fetch failure that still has cached content to show.
            if (_academyController.catalogError != null &&
                _academyController.snapshot == null) ...[
              ErrorBanner(onRetry: _academyController.load),
              const SizedBox(height: 12),
            ],

            NextActionCard(
              action: _nextAction,
              onStartLesson: () {
                final lesson = _academyController.nextLesson;
                if (lesson != null) _startLesson(lesson);
              },
              onOpenAcademy: widget.onOpenAcademyTab,
            ),
            const SizedBox(height: 16),

            LearningHeroCard(
              mascotController: widget.mascotController,
              anchor: widget.heroAnchor,
            ),
            const SizedBox(height: 16),

            if (widget.showPortfolioReminder) ...[
              PortfolioReminderBanner(
                onDismiss: widget.onDismissPortfolioReminder,
              ),
              const SizedBox(height: 16),
            ],

            if (!_academyController.isLoading &&
                !_academyController.isCatalogLoading) ...[
              KnowledgeMapStrip(
                modules: _academyController.modules,
                statusFor: _academyController.statusFor,
                completedLessonCountFor:
                    _academyController.completedLessonCountFor,
                onTapModule: _tapModuleChip,
                onViewAll: widget.onOpenAcademyTab,
              ),
              const SizedBox(height: 16),
            ],

            if (_reviewRecommendations.isNotEmpty) ...[
              RecommendedForYouSection(
                recommendations: _reviewRecommendations,
                onTapLesson: _startLesson,
              ),
              const SizedBox(height: 16),
            ],

            if (hasPortfolio)
              PortfolioBridgeCard(
                summary: portfolioController.summary,
                completedLessonCount:
                    _academyController.completedLessonIds.length,
                onViewPortfolio: widget.onOpenPortfolioTab,
              )
            else
              PortfolioNotConnectedCard(
                showInvestorProfileAction: widget.investorProfileUnanswered,
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
