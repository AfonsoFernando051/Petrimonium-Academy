import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_tokens.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/translator.dart';
import '../../../../core/widgets/confirm_logout_dialog.dart';
import '../../../../core/widgets/cosmic_background.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/events/app_event.dart';
import '../../../../core/events/app_event_bus.dart';
import '../../../academy/presentation/screens/academy_home_screen.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../game/domain/services/level_calculator.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../pet/presentation/mascot/controllers/mascot_controller.dart';
import '../../../portfolio/domain/entities/achievement.dart';
import '../../../portfolio/presentation/controllers/portfolio_controller.dart';
import '../../../portfolio/presentation/screens/passive_income_screen.dart';
import '../../../portfolio/presentation/widgets/achievement_celebration_overlay.dart';
import '../../../portfolio/presentation/widgets/dividend_notifications_sheet.dart';
import '../../../mentor/presentation/screens/mentor_screen.dart';
import '../../../pet/presentation/celebration/level_up_celebration_overlay.dart';
import '../../../pet/presentation/companion/pet_companion_controller.dart';
import '../../../pet/presentation/companion/pet_context.dart';
import '../../../pet/presentation/companion/widgets/pet_companion_header.dart';
import '../../../pet/presentation/companion/widgets/pet_speech_bubble.dart';
import '../../../pet/presentation/companion/widgets/pet_speech_bubble_anchor.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../simulated_wallet/presentation/controllers/simulated_wallet_controller.dart';
import '../../../simulated_wallet/presentation/screens/simulated_wallet_screen.dart';
import '../services/dashboard_tab_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Shared across the Início (Home) and Carteira (Portfolio) tabs so both
  // reflect the same real holdings/summary/allocation data and a single
  // in-flight load — no duplicate fetches, no drift between tabs.
  late final MascotController _mascotController;
  late final PortfolioController _portfolioController;

  // Academy's fictitious wallet — entirely separate from
  // `_portfolioController` above, which still owns real-portfolio-flavored
  // gamification orchestration (see PortfolioController's class doc) until
  // that's untangled in a later pass. Never fed real holdings/summary data.
  late final SimulatedWalletController _simulatedWalletController;

  // The persistent pet companion's speech-bubble/interaction state — one
  // instance shared by every tab and by `ProfileScreen` (pushed with it),
  // so there is a single message queue/cooldown ledger for the whole
  // authenticated session (see `PetCompanionController` class doc).
  late final PetCompanionController _companionController;

  // Where the Pet actually renders on screen, for `PetSpeechBubbleOverlay`
  // to glue its bubble to (see `PetSpeechBubbleAnchor`'s doc comment).
  // `_heroAnchor` is Home's big, more expressive pet (`LearningHeroCard`)
  // and takes priority whenever Home is the visible tab; `_headerAnchor` is
  // the always-present AppBar avatar every other tab falls back to.
  final PetSpeechBubbleAnchor _heroAnchor = PetSpeechBubbleAnchor();
  final PetSpeechBubbleAnchor _headerAnchor = PetSpeechBubbleAnchor();

  PetSpeechBubbleAnchor get _activeCompanionAnchor =>
      _selectedIndex == 0 ? _heroAnchor : _headerAnchor;

  // Newly-unlocked achievements awaiting their celebration overlay (see
  // `PortfolioController.newlyUnlocked`) — previously these unlocked
  // completely silently, with no on-screen reward moment at all.
  List<Achievement> _celebrating = [];

  // The level just reached, awaiting `LevelUpCelebrationOverlay` — `null`
  // when there's no level-up celebration to show. Replaces the old plain
  // `GameSnack` toast with a real reward moment that doubles as a
  // social-share prompt.
  int? _celebratingLevel;

  // Whether the pet should nudge the user about the (skipped) portfolio
  // step this session, and whether the risk-assessment questionnaire is
  // still unanswered — both feed the "what to do now" placeholder content
  // shown when there's no live portfolio yet.
  bool _showPortfolioReminder = false;
  bool _investorProfileUnanswered = false;

  // First real consumer of `AppEventBus`: reacts to game-progression events
  // (currently just level-ups) without the emitter (`MascotController`)
  // knowing this screen exists.
  StreamSubscription<AppEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _mascotController = MascotController(repository: DI.mascotRepository);
    _companionController = PetCompanionController(
      mascotController: _mascotController,
      preferencesRepository: DI.petCompanionPreferencesRepository,
    );
    _portfolioController = PortfolioController(
      repository: DI.portfolioRepository,
      achievementsLocalRepository: DI.achievementsLocalRepository,
      achievementsRepository: DI.achievementsRepository,
      gamificationRepository: DI.gamificationRepository,
      missionsRepository: DI.missionsRepository,
      mascotController: _mascotController,
    );
    _simulatedWalletController = SimulatedWalletController(
      repository: DI.simulatedWalletRepository,
    );
    _initCompanionGreeting();
    _portfolioController.addListener(_onPortfolioChanged);
    _portfolioController.loadAll();
    // Loaded here (not just on first Proventos-tab visit) so the
    // notification bell's badge reflects real upcoming payments as soon as
    // the dashboard opens, even if the user never taps into Proventos.
    _portfolioController.loadDividendRadarIfNeeded();
    _loadOnboardingSignals();
    _eventSubscription = AppEventBus.instance.stream.listen(_onAppEvent);
  }

  void _onAppEvent(AppEvent event) {
    if (!mounted) return;
    if (event is UserLeveledUpEvent) {
      setState(() => _celebratingLevel = event.newLevel);
    }
  }

  Future<void> _initCompanionGreeting() async {
    await _mascotController.loadProfile();
    if (!mounted) return;
    _companionController.enterContext(PetContext.home);
  }

  Future<void> _loadOnboardingSignals() async {
    final showReminder = await DI.onboardingStateRepository
        .shouldShowPortfolioReminder();
    if (showReminder) {
      // Recorded the moment we decide to show it, not on dismiss — so a
      // user who just navigates away without tapping anything still gets
      // the cooldown, instead of seeing it again next session.
      final sessionCount = await DI.onboardingStateRepository
          .currentSessionCount();
      await DI.onboardingStateRepository.markReminderShown(sessionCount);
    }

    bool investorProfileUnanswered = false;
    try {
      final status = await DI.onboardingRepository.getStatus();
      investorProfileUnanswered = !status.hasAnswered;
    } catch (_) {
      // Non-critical suggestion — if the status check fails, just omit it.
    }
    if (!mounted) return;
    setState(() {
      _showPortfolioReminder = showReminder;
      _investorProfileUnanswered = investorProfileUnanswered;
    });
  }

  void _onPortfolioChanged() {
    setState(() {
      if (_portfolioController.newlyUnlocked.isNotEmpty) {
        _celebrating = _portfolioController.newlyUnlocked;
        _portfolioController.clearNewlyUnlocked();
      }
      // The Proventos tab can disappear if the holdings that justified it
      // (ações/FIIs/fundos) get sold off mid-session — bounce back to
      // Carteira rather than leaving the user stranded on a tab with no nav
      // item pointing at it.
      if (_selectedIndex == DashboardTabRouter.passiveIncomeTab &&
          !_visibleTabIndices.contains(_selectedIndex)) {
        _selectedIndex = DashboardTabRouter.walletTab;
      }
    });
  }

  // ── Proventos tab visibility ─────────────────────────────────────────────
  // Only shown when the wallet actually holds an asset type that pays out
  // dividends/proventos (ações, FIIs, ETFs/fundos) — see
  // `InvestmentTypePayout.paysDividends` and
  // `PortfolioController.hasDividendPayingHoldings`.
  List<int> get _visibleTabIndices => [
    DashboardTabRouter.homeTab,
    DashboardTabRouter.academyTab,
    DashboardTabRouter.walletTab,
    if (_portfolioController.hasDividendPayingHoldings)
      DashboardTabRouter.passiveIncomeTab,
    DashboardTabRouter.mentorTab,
  ];

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _portfolioController.removeListener(_onPortfolioChanged);
    _portfolioController.dispose();
    _simulatedWalletController.dispose();
    _companionController.dispose();
    _mascotController.dispose();
    super.dispose();
  }

  // Shared background instance for all tabs (the IndexedStack below keeps
  // every tab's state alive, so there's one CosmicBackground behind all of
  // them, not five) — see `DashboardTabRouter.backgroundIntensityFor` for
  // which mood each tab gets.
  Widget _buildBackground({required Widget child}) {
    return CosmicBackground(
      intensity: DashboardTabRouter.backgroundIntensityFor(_selectedIndex),
      child: child,
    );
  }

  // ── Page route helper ─────────────────────────────────────────────────────
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

  // ── Persistent pet companion: route-aware context + destination routing ──
  void _onTabSelected(int index) {
    HapticFeedback.selectionClick();
    setState(() => _selectedIndex = index);
    _companionController.enterContext(
      DashboardTabRouter.petContextFor(index),
      data: DashboardTabRouter.showsHoldingsCount(index)
          ? {'count': '${_portfolioController.holdings.length}'}
          : const {},
    );
  }

  /// Where "Learn" / "Portfolio" / "Progress" in [PetInteractionSheet], or a
  /// speech-bubble action, actually take the user.
  void _handleCompanionDestination(PetContext destination) {
    switch (destination) {
      case PetContext.academy:
        _onTabSelected(1);
      case PetContext.portfolio:
        _onTabSelected(2);
      case PetContext.mentor:
        _onTabSelected(4);
      case PetContext.home:
        _onTabSelected(0);
      case PetContext.profile:
        _openProfile();
    }
  }

  Future<void> _openProfile() async {
    _companionController.dismiss();
    _companionController.enterContext(PetContext.profile);
    await Navigator.of(context).push(
      _fadeRoute(ProfileScreen(companionController: _companionController)),
    );
    // Settings (reached via Profile) may have renamed the pet —
    // reload so the AppBar/greeting reflect it immediately.
    await _mascotController.loadProfile();
    if (mounted) setState(() {});
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> _confirmLogout() async {
    final confirmed = await ConfirmLogoutDialog.show(context);

    if (confirmed && mounted) {
      HapticFeedback.mediumImpact();
      await DI.authRepository.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(_fadeRoute(const LoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds the AppBar/bottom-nav chrome (and everything under it) when
    // the user switches language in Settings — matches the same explicit
    // per-screen listening pattern `SettingsScreen` and the Academy screens
    // already use, rather than relying on the top-level `MyApp` rebuild
    // alone (which resets `FutureBuilder`'s start-route resolution and would
    // otherwise flash the splash screen on every language switch).
    return ValueListenableBuilder<String>(
      valueListenable: Translator.languageNotifier,
      builder: (context, _, _) => _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final tokens = context.colors;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: _buildAppBarTitle(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          _buildNotificationsButton(),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: tokens.textSecondary),
            tooltip: Translator.translate(AppStrings.profileTooltip),
            onPressed: _openProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.neonPurple),
            tooltip: Translator.translate(AppStrings.logoutTooltip),
            onPressed: _confirmLogout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          _buildBackground(
            child: SafeArea(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildHomeContent(),
                  _buildAcademyContent(),
                  _buildWalletContent(),
                  _buildPassiveIncomeContent(),
                  _buildMentorContent(),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: PetSpeechBubbleOverlay(
              controller: _companionController,
              anchor: _activeCompanionAnchor,
              onActionSelected: (action) =>
                  _handleCompanionDestination(action.destination),
            ),
          ),
          if (_celebrating.isNotEmpty)
            AchievementCelebrationOverlay(
              achievements: _celebrating,
              onDismiss: () => setState(() => _celebrating = []),
            ),
          if (_celebratingLevel != null)
            LevelUpCelebrationOverlay(
              newLevel: _celebratingLevel!,
              mascotController: _mascotController,
              onDismiss: () => setState(() => _celebratingLevel = null),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── AppBar title — compact player HUD, anchored by the persistent pet
  // companion (`docs/PROJECT_CONTEXT.md`'s Pet Companion section) ─────────
  Widget _buildAppBarTitle() {
    // Real level derived from the same accumulated XP that drives pet
    // evolution (`MascotController.profile.xp`), not a hardcoded number.
    final level = LevelCalculator.fromXp(_mascotController.profile.xp).level;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PetCompanionHeader(
          controller: _companionController,
          onDestinationSelected: _handleCompanionDestination,
          anchor: _headerAnchor,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Invest Game',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyEmphasis.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _mascotController.profile.name?.isNotEmpty == true
                    ? Translator.translate(
                        AppStrings.appBarPlayerNamedGreeting,
                        params: {
                          'petName': _mascotController.profile.name!,
                          'level': '$level',
                        },
                      )
                    : Translator.translate(
                        AppStrings.appBarPlayerGenericGreeting,
                        params: {'level': '$level'},
                      ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: context.colors.primary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Notifications: upcoming dividends for the user's real holdings ──────
  // Badge count is real and provider-confirmed (`DividendRadar.upcoming`,
  // the same data `DividendRadarSection` renders on the Proventos tab) —
  // never a placeholder or simulated count.
  Widget _buildNotificationsButton() {
    final upcomingCount = _portfolioController.dividendRadar.upcoming.length;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: context.colors.textSecondary,
          ),
          tooltip: Translator.translate(AppStrings.notificationsTooltip),
          onPressed: _openNotifications,
        ),
        if (upcomingCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                decoration: BoxDecoration(
                  color: context.colors.error,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: Border.all(
                    color: context.colors.backgroundSecondary,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  DashboardFormatters.notificationBadgeLabel(upcomingCount),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _openNotifications() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AnimatedBuilder(
        animation: _portfolioController,
        builder: (context, _) => DividendNotificationsSheet(
          isLoading: _portfolioController.isDividendRadarLoading,
          error: _portfolioController.dividendRadarError,
          upcoming: _portfolioController.dividendRadar.upcoming,
          onRetry: _portfolioController.refreshDividendRadar,
        ),
      ),
    );
  }

  // ── Home: learning-first orchestration layer (docs/PRODUCT_VISION.md §8) ─
  // Detailed financial metrics, missions and achievements live on Carteira
  // (Portfolio) now — Home orients the user in their learning journey first.
  // Both tabs share `_portfolioController`/`_mascotController` so they
  // always agree.
  Widget _buildHomeContent() {
    return HomeScreen(
      portfolioController: _portfolioController,
      mascotController: _mascotController,
      onOpenAcademyTab: () => setState(() => _selectedIndex = 1),
      onOpenPortfolioTab: () => setState(() => _selectedIndex = 2),
      showPortfolioReminder: _showPortfolioReminder,
      onDismissPortfolioReminder: () =>
          setState(() => _showPortfolioReminder = false),
      investorProfileUnanswered: _investorProfileUnanswered,
      companionController: _companionController,
      heroAnchor: _heroAnchor,
    );
  }

  // ── Carteira (Simulada) ──────────────────────────────────────────────────
  // Academy's fictitious wallet (Petrimonium-Backend's simulated_portfolio
  // context) — replaces the real-portfolio `PortfolioScreen` that used to
  // live here. `PortfolioScreen`/`PortfolioController`'s real-holdings path
  // stays in the codebase for now (its gamification orchestration —
  // achievements/missions/XP — is still legitimately used, see
  // `_buildHomeContent`) but is no longer reachable from this tab.
  Widget _buildWalletContent() {
    return SimulatedWalletScreen(controller: _simulatedWalletController);
  }

  // ── Proventos / Passive Income ────────────────────────────────────────────
  Widget _buildPassiveIncomeContent() {
    return PassiveIncomeScreen(controller: _portfolioController);
  }

  // ── Academia: module/lesson progression (see docs/ACADEMY_ENGINE.md) ────
  Widget _buildAcademyContent() {
    return AcademyHomeScreen(
      mascotController: _mascotController,
      companionController: _companionController,
      // In-app stand-in for the §1.6 Wallet bridge CTA while Wallet's
      // screens still live in this repo (see `WalletBridgeCta`'s doc
      // comment) — opens the Carteira tab instead of an external app.
      onOpenPortfolioTab: () =>
          setState(() => _selectedIndex = DashboardTabRouter.walletTab),
    );
  }

  // ── Mentor: AI-powered chat with the pet acting as investment mentor ────
  Widget _buildMentorContent() {
    return const MentorScreen();
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  // Item content per logical tab (see `DashboardTabRouter`'s tab-index
  // constants) — kept separate from `_visibleTabIndices` so hiding/showing
  // Proventos doesn't duplicate icon/label definitions.
  BottomNavigationBarItem _navItemFor(int tabIndex) {
    return switch (tabIndex) {
      DashboardTabRouter.homeTab => BottomNavigationBarItem(
        icon: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Icon(Icons.rocket_launch_outlined),
        ),
        activeIcon: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Icon(Icons.rocket_launch),
        ),
        label: Translator.translate(AppStrings.navHome),
      ),
      DashboardTabRouter.academyTab => BottomNavigationBarItem(
        icon: const Icon(Icons.school_outlined),
        activeIcon: const Icon(Icons.school),
        label: Translator.translate(AppStrings.navAcademy),
      ),
      DashboardTabRouter.walletTab => BottomNavigationBarItem(
        icon: const Icon(Icons.diamond_outlined),
        activeIcon: const Icon(Icons.diamond),
        label: Translator.translate(AppStrings.navWallet),
      ),
      DashboardTabRouter.passiveIncomeTab => BottomNavigationBarItem(
        icon: const Icon(Icons.payments_outlined),
        activeIcon: const Icon(Icons.payments),
        label: Translator.translate(AppStrings.navPassiveIncome),
      ),
      _ => BottomNavigationBarItem(
        icon: const Icon(Icons.auto_awesome_outlined),
        activeIcon: const Icon(Icons.auto_awesome),
        label: Translator.translate(AppStrings.navMentor),
      ),
    };
  }

  Widget _buildBottomNav() {
    final tokens = context.colors;
    final visible = _visibleTabIndices;
    // _selectedIndex is a logical tab id (`DashboardTabRouter`'s constants),
    // not a position in the (possibly shorter) visible list — translate it
    // so BottomNavigationBar's currentIndex/onTap stay in range even while
    // Proventos is hidden.
    final currentPosition = visible.indexOf(_selectedIndex);
    return Container(
      decoration: BoxDecoration(
        color: tokens.backgroundSecondary,
        border: Border(
          top: BorderSide(
            color: tokens.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: tokens.primary.withValues(
              alpha: context.isDarkMode ? 0.12 : 0.08,
            ),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: tokens.primary,
        unselectedItemColor: tokens.textTertiary,
        selectedLabelStyle: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.caption,
        currentIndex: currentPosition == -1 ? 0 : currentPosition,
        onTap: (position) => _onTabSelected(visible[position]),
        items: [for (final tabIndex in visible) _navItemFor(tabIndex)],
      ),
    );
  }
}
