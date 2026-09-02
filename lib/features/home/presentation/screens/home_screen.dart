import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/widgets/app_loading_indicator.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_module.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_recommendation.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/academy/domain/services/academy_progress_calculator.dart';
import 'package:petrimonium/features/academy/presentation/controllers/academy_controller.dart';
import 'package:petrimonium/features/academy/presentation/screens/all_modules_screen.dart';
import 'package:petrimonium/features/academy/presentation/screens/lesson_screen.dart';
import 'package:petrimonium/features/academy/presentation/screens/module_detail_screen.dart';
import 'package:petrimonium/features/academy/presentation/widgets/recommended_for_you_section.dart';
import 'package:petrimonium/features/home/domain/entities/next_action.dart';
import 'package:petrimonium/features/home/domain/services/next_action_resolver.dart';
import 'package:petrimonium/features/home/presentation/widgets/home_greeting_row.dart';
import 'package:petrimonium/features/home/presentation/widgets/home_mentor_card.dart';
import 'package:petrimonium/features/home/presentation/widgets/knowledge_map_strip.dart';
import 'package:petrimonium/features/home/presentation/widgets/next_action_card.dart';
import 'package:petrimonium/features/home/presentation/widgets/learning_hero_card.dart';
import 'package:petrimonium/features/pet/data/models/pet_goal_enum.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_companion_controller.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/pet_speech_bubble_anchor.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:petrimonium/features/portfolio/domain/services/mission_display_catalog.dart';
import 'package:petrimonium/features/portfolio/presentation/controllers/portfolio_controller.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/error_banner.dart';

/// Home — the app's learning-first orchestration layer
/// (`docs/PRODUCT_VISION.md` §8): where the user is in their learning
/// journey, what to learn next, XP progress, and knowledge development.
/// `NextActionCard` (see `_nextAction`/`NextActionResolver`) surfaces a
/// single mission on Home only when it's one lesson away from completing,
/// since that's a genuine, time-bound signal that would otherwise stay
/// invisible. No real-portfolio content here or anywhere in this app — Home
/// used to bridge into the real portfolio, but that concept was removed
/// (Stage 7 of the ecosystem split plan) since Academy has no real holdings
/// to bridge into; `portfolioController` is kept only for the
/// achievements/missions/XP gamification it still orchestrates (see
/// `DashboardScreen._buildHomeContent`'s doc comment).
///
/// No own `Scaffold`/`AppBar`/background — embedded directly in
/// `DashboardScreen`'s shared chrome, mirroring `AcademyHomeScreen`.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.portfolioController,
    required this.mascotController,
    required this.onOpenAcademyTab,
    required this.companionController,
    required this.heroAnchor,
  });

  final PortfolioController portfolioController;
  final MascotController mascotController;
  final VoidCallback onOpenAcademyTab;

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

  /// The user's own onboarding goal, resolved to display text — loaded once
  /// (it's local-only, see `PetPreferencesRepository`'s doc comment) rather
  /// than re-read every rebuild.
  PetGoalEnum? _goal;

  /// The account's registered display name. Set first from the local cache
  /// (instant, may be stale/absent), then refreshed from `GET
  /// /api/users/me` (real backend value) — see `AuthRepository`'s doc
  /// comments on why login alone can't supply this.
  String? _userName;

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
    DI.petPreferencesRepository.loadGoal().then((goal) {
      if (mounted) setState(() => _goal = goal);
    });
    DI.authRepository.getSavedUserName().then((name) {
      if (mounted && name != null) setState(() => _userName = name);
    });
    DI.authRepository.refreshUserName().then((name) {
      if (mounted && name != null) setState(() => _userName = name);
    });
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
  NextAction get _nextAction {
    final nextLesson = _academyController.nextLesson;
    final module = nextLesson == null ? null : _academyController.snapshot?.moduleById(nextLesson.moduleId);
    return NextActionResolver.resolve(
      nextLesson: nextLesson,
      moduleTitle: module?.title,
      missions: widget.portfolioController.missions,
      moduleLessonCount: module?.lessonIds.length,
      moduleCompletedCount: module == null ? null : _academyController.completedLessonCountFor(module),
      goalLabel: _goal?.label,
    );
  }

  /// Real signals, checked in the same priority order as
  /// `AcademyPetBehavior._homeNudge` (returning-user greeting outranks
  /// review-due, which outranks the default continue-lesson nudge) — kept
  /// independent of `PetCompanionController`'s transient, auto-hiding
  /// speech bubble, since this card is meant to stay visible in the feed
  /// rather than disappear after a few seconds. `null` when no real signal
  /// applies, in which case the card is simply omitted.
  ({String textKey, Map<String, String> params, HomeMentorReason reason})? get _mentorInsight {
    final daysAway = widget.mascotController.daysSinceLastSession;
    if (daysAway != null && daysAway >= kSleepAfterInactiveDays) {
      final pool = [AppStrings.companionHomeReturnGreeting1, AppStrings.companionHomeReturnGreeting2];
      return (textKey: pool[daysAway % pool.length], params: const {}, reason: HomeMentorReason.returning);
    }

    final reviewCount = _reviewRecommendations.length;
    if (reviewCount > 0) {
      return (
        textKey: AppStrings.companionAcademyReviewDue,
        params: {'count': '$reviewCount'},
        reason: HomeMentorReason.reviewDue,
      );
    }

    final nextLesson = _academyController.nextLesson;
    if (nextLesson != null) {
      return (
        textKey: AppStrings.companionAcademyContinueLesson,
        params: {'lessonTitle': nextLesson.title},
        reason: HomeMentorReason.continueLesson,
      );
    }

    return null;
  }

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

  Future<void> _openAllModules() async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push(
      _fadeRoute(AllModulesScreen(mascotController: widget.mascotController)),
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
            HomeGreetingRow(
              userName: _userName,
              streakDays: portfolioController.gamificationSummary?.currentStreak,
            ),
            const SizedBox(height: 16),

            if (_mentorInsight != null) ...[
              HomeMentorCard(
                mascotController: widget.mascotController,
                petName: widget.mascotController.profile.name ?? widget.mascotController.profile.specie.name,
                message: Translator.translate(_mentorInsight!.textKey, params: _mentorInsight!.params),
                reason: _mentorInsight!.reason,
              ),
              const SizedBox(height: 16),
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

            if (!_academyController.isLoading &&
                !_academyController.isCatalogLoading) ...[
              KnowledgeMapStrip(
                modules: _academyController.modules,
                statusFor: _academyController.statusFor,
                completedLessonCountFor:
                    _academyController.completedLessonCountFor,
                onTapModule: _tapModuleChip,
                onViewAll: _openAllModules,
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

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
