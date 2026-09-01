import 'package:flutter/foundation.dart';
import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/core/events/app_event_bus.dart';
import 'package:petrimonium/core/utils/friendly_error_message.dart';
import 'package:petrimonium/features/game/data/repositories/gamification_repository.dart';
import 'package:petrimonium/features/game/domain/entities/gamification_summary.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:petrimonium/features/portfolio/data/repositories/achievements_local_repository.dart';
import 'package:petrimonium/features/portfolio/data/repositories/achievements_repository.dart';
import 'package:petrimonium/features/portfolio/data/repositories/missions_repository.dart';
import 'package:petrimonium/features/portfolio/data/repositories/portfolio_repository.dart';
import 'package:petrimonium/features/portfolio/domain/entities/achievement.dart';
import 'package:petrimonium/features/portfolio/domain/entities/allocation_slice.dart';
import 'package:petrimonium/features/portfolio/domain/entities/history_point.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_lot.dart';
import 'package:petrimonium/features/portfolio/domain/entities/mission_status.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_health.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_stats.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:petrimonium/features/portfolio/domain/enums/history_range.dart';
import 'package:petrimonium/features/portfolio/domain/services/achievement_catalog.dart';
import 'package:petrimonium/features/portfolio/domain/services/mission_display_catalog.dart';
import 'package:petrimonium/features/portfolio/domain/services/portfolio_health_calculator.dart';
import 'package:petrimonium/features/portfolio/domain/services/wealth_history_calculator.dart';

/// Owns all state for the redesigned Portfolio screen: real holdings/
/// summary/allocation/history from the backend, plus everything derived
/// client-side from that real data (health score, insights, estimated
/// passive income) and everything the backend now owns authoritatively
/// (achievement unlocks, total XP/level, engagement streak — see
/// [_evaluateGamification]). When [mascotController] is supplied, every
/// successful load feeds the user's real net worth and real backend-granted
/// XP into `MascotController.evaluateEvolution`.
class PortfolioController extends ChangeNotifier {
  PortfolioController({
    required PortfolioRepository repository,
    required AchievementsLocalRepository achievementsLocalRepository,
    required AchievementsRepository achievementsRepository,
    required GamificationRepository gamificationRepository,
    required MissionsRepository missionsRepository,
    MascotController? mascotController,
    AppEventBus? eventBus,
  })  : _repository = repository,
        _achievementsLocalRepository = achievementsLocalRepository,
        _achievementsRepository = achievementsRepository,
        _gamificationRepository = gamificationRepository,
        _missionsRepository = missionsRepository,
        _mascotController = mascotController,
        _eventBus = eventBus ?? AppEventBus.instance;

  final PortfolioRepository _repository;
  final AchievementsLocalRepository _achievementsLocalRepository;
  final AchievementsRepository _achievementsRepository;
  final GamificationRepository _gamificationRepository;
  final MissionsRepository _missionsRepository;
  final MascotController? _mascotController;
  final AppEventBus _eventBus;

  /// Whether a `loadAll()` has ever completed successfully this session —
  /// gates [FirstInvestmentAddedEvent] so a cold-start load of an
  /// already-invested user's real holdings is never mistaken for a fresh
  /// purchase (see `loadAll`).
  bool _hasLoadedOnce = false;

  /// Whether the most recently loaded portfolio was above
  /// `_evaluateConcentration`'s high-concentration threshold — tracked so
  /// [HighConcentrationDetectedEvent] only fires on the low→high crossing,
  /// not on every subsequent load while it stays high.
  bool _wasHighlyConcentrated = false;

  bool isLoading = true;
  String? error;

  List<Holding> holdings = [];
  PortfolioSummary summary = PortfolioSummary.empty;
  List<AllocationSlice> allocation = [];
  Map<String, DateTime> _unlockedAchievements = {};

  /// The backend's real XP/level/streak, refreshed on every [loadAll] (see
  /// [_evaluateGamification]). Null until the first successful fetch —
  /// callers must not fabricate a placeholder value while it's null.
  GamificationSummary? gamificationSummary;

  /// Achievements that became unlocked on the *most recent* `loadAll()` call
  /// — i.e. genuinely new this session, not just "unlocked at some point in
  /// the past" (see `_evaluateGamification`, which diffs against what was
  /// already persisted before recomputing). The UI shows a celebration for
  /// these, then calls [clearNewlyUnlocked].
  List<Achievement> newlyUnlocked = [];

  void clearNewlyUnlocked() {
    newlyUnlocked = [];
  }

  /// The current period's real status for every mission
  /// (`GET /api/v1/missions`), refreshed on every [loadAll] — see
  /// [_evaluateGamification]. Empty until the first successful fetch.
  List<MissionStatus> missions = [];

  /// Mission codes newly completed on the *most recent* `loadAll()` call —
  /// same "genuinely new this session" contract as [newlyUnlocked].
  Set<String> newlyCompletedMissions = {};

  void clearNewlyCompletedMissions() {
    newlyCompletedMissions = {};
  }

  HistoryRange selectedRange = HistoryRange.m3;
  InvestmentTypeEnum? selectedAssetFilter;
  List<HistoryPoint> chartPoints = [];

  double todayChangeValue = 0;
  double todayChangePercent = 0;
  double monthlyChangeValue = 0;
  double monthlyChangePercent = 0;
  double annualChangeValue = 0;
  double annualChangePercent = 0;

  final Map<HistoryRange, List<HistoryPoint>> _backendHistoryCache = {};

  PortfolioStats get stats => PortfolioStats(summary: summary, holdings: holdings, allocation: allocation);

  PortfolioHealth get health => PortfolioHealthCalculator.calculate(stats);

  List<Achievement> get achievements => AchievementCatalog.resolve(_unlockedAchievements);

  List<InvestmentLot> get _allLots => holdings.expand((h) => h.lots).toList();

  Future<void> loadAll() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.fetchHoldings(),
        _repository.fetchAllocation(),
        _repository.fetchSummary(),
      ]);
      // Captured before overwriting `holdings` below, and gated on
      // `_hasLoadedOnce` so this session's very first successful load (which
      // may simply be reading an already-invested user's real portfolio)
      // never reads as "just went from 0 to N holdings".
      final hadNoHoldingsBefore = _hasLoadedOnce && holdings.isEmpty;
      holdings = results[0] as List<Holding>;
      allocation = results[1] as List<AllocationSlice>;
      summary = results[2] as PortfolioSummary;
      _hasLoadedOnce = true;

      await _loadPerformanceDeltas();
      _recomputeChart();

      if (hadNoHoldingsBefore && holdings.isNotEmpty) {
        _eventBus.emit(const FirstInvestmentAddedEvent());
      }
      _evaluateConcentration();
    } catch (e) {
      error = friendlyErrorMessage(e);
    }

    // Deliberately outside the try/catch above and always run: XP/
    // achievements/missions are gamification.* endpoints, unrestricted by
    // app_context (see backend SecurityConfig), so they must keep working
    // even when the real-portfolio fetch above fails — as it now always
    // does for an Academy-context session (real_portfolio is Wallet-only).
    // Before this was split out, a failed real-portfolio fetch silently
    // skipped gamification evaluation too.
    await _evaluateGamification();

    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => loadAll();

  void setRange(HistoryRange range) {
    if (range == selectedRange) return;
    selectedRange = range;
    _recomputeChart();
    notifyListeners();
  }

  void setAssetFilter(InvestmentTypeEnum? type) {
    if (type == selectedAssetFilter) return;
    selectedAssetFilter = type;
    _recomputeChart();
    notifyListeners();
  }

  Future<void> _loadPerformanceDeltas() async {
    if (holdings.isEmpty) {
      todayChangeValue = 0;
      todayChangePercent = 0;
      monthlyChangeValue = 0;
      monthlyChangePercent = 0;
      annualChangeValue = 0;
      annualChangePercent = 0;
      return;
    }

    final thirtyDay = await _cachedBackendHistory(HistoryRange.d30);
    final oneYear = await _cachedBackendHistory(HistoryRange.y1);

    final today = _delta(thirtyDay, fromEnd: true);
    todayChangeValue = today.$1;
    todayChangePercent = today.$2;

    final monthly = _delta(thirtyDay, fromEnd: false);
    monthlyChangeValue = monthly.$1;
    monthlyChangePercent = monthly.$2;

    final annual = _delta(oneYear, fromEnd: false);
    annualChangeValue = annual.$1;
    annualChangePercent = annual.$2;
  }

  /// [fromEnd] compares the last two samples (≈ "today"); otherwise compares
  /// the first and last sample of the series (≈ full-range change).
  (double, double) _delta(List<HistoryPoint> series, {required bool fromEnd}) {
    if (series.length < 2) return (0, 0);
    final from = fromEnd ? series[series.length - 2] : series.first;
    final to = series.last;
    final value = to.portfolioValue - from.portfolioValue;
    final percent = from.portfolioValue == 0 ? 0.0 : (value / from.portfolioValue) * 100;
    return (value, percent);
  }

  Future<List<HistoryPoint>> _cachedBackendHistory(HistoryRange range) async {
    final cached = _backendHistoryCache[range];
    if (cached != null) return cached;
    final points = await _repository.fetchHistory(range);
    _backendHistoryCache[range] = points;
    return points;
  }

  void _recomputeChart() {
    if (selectedAssetFilter != null) {
      final filteredLots = _allLots.where((l) => l.type == selectedAssetFilter).toList();
      chartPoints = WealthHistoryCalculator.compute(filteredLots, selectedRange);
      return;
    }

    final cached = _backendHistoryCache[selectedRange];
    if (cached != null) {
      chartPoints = cached;
      return;
    }

    // Not yet fetched from the backend for this range — compute locally from
    // already-loaded lots so the UI responds instantly, then fetch+replace.
    chartPoints = WealthHistoryCalculator.compute(_allLots, selectedRange);
    _repository.fetchHistory(selectedRange).then((points) {
      _backendHistoryCache[selectedRange] = points;
      if (selectedAssetFilter == null) {
        chartPoints = points;
        notifyListeners();
      }
    }).catchError((_) {
      // Keep the locally-computed series if the backend call fails.
    });
  }

  /// The backend is the sole authority on achievement unlocks, mission
  /// progress, and XP. [AchievementsRepository.evaluate] re-checks every
  /// achievement condition against the user's real, server-side portfolio
  /// and persists any new unlock; [MissionsRepository.evaluate] does the
  /// same for every mission's current daily/weekly period, purely from real
  /// lesson/module completion history; [GamificationRepository.fetchSummary]
  /// returns the real total XP (learning + achievements + missions) and
  /// level. All three calls are independently best-effort — offline, the
  /// achievement path falls back to the last-known-real cache rather than
  /// fabricating a number; missions have no such cache (each period resets
  /// anyway) and simply keep whatever was last successfully fetched.
  Future<void> _evaluateGamification() async {
    try {
      final result = await _achievementsRepository.evaluate();
      _unlockedAchievements = result.unlockedAt;
      await _achievementsLocalRepository.cacheUnlocked(result.unlockedAt);

      if (result.newlyUnlockedCodes.isNotEmpty) {
        newlyUnlocked = AchievementCatalog.resolve(_unlockedAchievements)
            .where((a) => result.newlyUnlockedCodes.contains(a.id))
            .toList();
        // The in-screen celebration overlay (`newlyUnlocked` above) already
        // shows these; the bus emission is for other, decoupled listeners
        // (e.g. a future Character Engine reaction) rather than a second UI.
        for (final achievement in newlyUnlocked) {
          _eventBus.emit(AchievementUnlockedEvent(achievement));
        }
      }
    } catch (_) {
      // Offline or backend unavailable — fall back to the last-known-real
      // cached unlock state rather than showing nothing or fabricating one.
      _unlockedAchievements = await _achievementsLocalRepository.loadUnlocked();
    }

    try {
      final result = await _missionsRepository.evaluate();
      missions = result.missions;
      newlyCompletedMissions = result.newlyCompletedCodes;
      // Mirrors the achievement-unlock loop above: the in-screen celebration
      // (`newlyCompletedMissions`) already shows these on the Portfolio tab;
      // the bus emission is for decoupled listeners like the pet companion.
      for (final code in result.newlyCompletedCodes) {
        _eventBus.emit(MissionCompletedEvent(MissionDisplayCatalog.forCode(code).title));
      }
    } catch (_) {
      // Offline or backend unavailable — keep whatever mission state was
      // last successfully fetched rather than showing nothing.
    }

    try {
      gamificationSummary = await _gamificationRepository.fetchSummary();
      await _mascotController?.evaluateEvolution(summary.currentValue, gamificationSummary!.totalXp);
    } catch (_) {
      // Offline or backend unavailable — keep whatever XP/level the mascot
      // already had rather than overwriting it with a guess.
    }
  }

  /// Mirrors `InsightGenerator`'s existing "Concentração elevada" rule
  /// (>40% of the portfolio in one holding) so the pet's alert and the
  /// Insights card agree on what counts as concentrated. Only emits on the
  /// low→high transition — see [_wasHighlyConcentrated].
  void _evaluateConcentration() {
    final isConcentrated = stats.largestHoldingPercent > 40;
    if (isConcentrated && !_wasHighlyConcentrated) {
      final biggest = holdings.first;
      _eventBus.emit(HighConcentrationDetectedEvent(
        ticker: biggest.ticker,
        percent: biggest.portfolioPercent,
      ));
    }
    _wasHighlyConcentrated = isConcentrated;
  }
}
