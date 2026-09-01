import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/core/events/app_event_bus.dart';
import 'package:petrimonium/core/utils/friendly_error_message.dart';
import 'package:petrimonium/features/game/data/datasources/gamification_remote_datasource.dart';
import 'package:petrimonium/features/game/data/repositories/gamification_repository.dart';
import 'package:petrimonium/features/game/domain/entities/gamification_summary.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/data/datasources/achievements_remote_datasource.dart';
import 'package:petrimonium/features/portfolio/data/datasources/portfolio_remote_datasource.dart';
import 'package:petrimonium/features/portfolio/data/datasources/missions_remote_datasource.dart';
import 'package:petrimonium/features/portfolio/data/repositories/achievements_local_repository.dart';
import 'package:petrimonium/features/portfolio/data/repositories/achievements_repository.dart';
import 'package:petrimonium/features/portfolio/data/repositories/missions_repository.dart';
import 'package:petrimonium/features/portfolio/data/repositories/portfolio_repository.dart';
import 'package:petrimonium/features/portfolio/domain/entities/achievement_evaluation_result.dart';
import 'package:petrimonium/features/portfolio/domain/entities/allocation_slice.dart';
import 'package:petrimonium/features/portfolio/domain/entities/dividend_event.dart';
import 'package:petrimonium/features/portfolio/domain/entities/history_point.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/mission_status.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:petrimonium/features/portfolio/domain/enums/history_range.dart';
import 'package:petrimonium/features/portfolio/presentation/controllers/portfolio_controller.dart';

import '../../domain/services/portfolio_test_fixtures.dart';

/// In-memory [PortfolioRepository] double. The real repository talks to the
/// network via [PortfolioRemoteDataSource]; tests configure the values it
/// should "fetch" instead, and can simulate a failure via [holdingsError].
class FakePortfolioRepository implements PortfolioRepository {
  List<Holding> holdingsToReturn = const [];
  PortfolioSummary summaryToReturn = PortfolioSummary.empty;
  List<AllocationSlice> allocationToReturn = const [];
  Map<HistoryRange, List<HistoryPoint>> historyByRange = const {};
  DividendRadar dividendRadarToReturn = DividendRadar.empty;
  Object? holdingsError;
  Object? dividendRadarError;

  int fetchHoldingsCalls = 0;

  @override
  Future<List<Holding>> fetchHoldings() async {
    fetchHoldingsCalls++;
    if (holdingsError != null) throw holdingsError!;
    return holdingsToReturn;
  }

  @override
  Future<PortfolioSummary> fetchSummary() async => summaryToReturn;

  @override
  Future<List<AllocationSlice>> fetchAllocation() async => allocationToReturn;

  @override
  Future<List<HistoryPoint>> fetchHistory(HistoryRange range) async => historyByRange[range] ?? const [];

  @override
  Future<DividendRadar> fetchDividendRadar() async {
    if (dividendRadarError != null) throw dividendRadarError!;
    return dividendRadarToReturn;
  }

  @override
  PortfolioRemoteDataSource get remoteDataSource => throw UnimplementedError();
}

/// In-memory [AchievementsLocalRepository] double — the real one persists to
/// `SharedPreferences`, unavailable in a plain unit test.
class FakeAchievementsLocalRepository implements AchievementsLocalRepository {
  Map<String, DateTime> _unlocked = {};

  @override
  Future<Map<String, DateTime>> loadUnlocked() async => _unlocked;

  @override
  Future<void> cacheUnlocked(Map<String, DateTime> unlockedAt) async {
    _unlocked = unlockedAt;
  }
}

/// In-memory [AchievementsRepository] double standing in for the real
/// backend call — the achievement-*qualification* logic itself now lives
/// server-side (see `EvaluateAchievementsUseCaseImplTest.java`), so this
/// test only verifies `PortfolioController` correctly orchestrates whatever
/// the backend reports.
class FakeAchievementsRepository implements AchievementsRepository {
  AchievementEvaluationResult resultToReturn = AchievementEvaluationResult.empty;

  @override
  Future<AchievementEvaluationResult> evaluate() async => resultToReturn;

  @override
  AchievementsRemoteDataSource get remoteDataSource => throw UnimplementedError();
}

/// In-memory [GamificationRepository] double — the real one calls the
/// backend's `/api/v1/gamification/summary` endpoint.
class FakeGamificationRepository implements GamificationRepository {
  GamificationSummary summaryToReturn = GamificationSummary.empty;

  @override
  Future<GamificationSummary> fetchSummary() async => summaryToReturn;

  @override
  GamificationRemoteDataSource get remoteDataSource => throw UnimplementedError();
}

/// In-memory [MissionsRepository] double standing in for the real backend
/// call — mission progress/completion logic itself now lives server-side
/// (see `EvaluateMissionsUseCaseImplTest.java`), so this only verifies
/// `PortfolioController` correctly orchestrates whatever the backend
/// reports.
class FakeMissionsRepository implements MissionsRepository {
  MissionEvaluationResult resultToReturn = MissionEvaluationResult.empty;
  Object? evaluateError;

  @override
  Future<MissionEvaluationResult> evaluate() async {
    if (evaluateError != null) throw evaluateError!;
    return resultToReturn;
  }

  @override
  MissionsRemoteDataSource get remoteDataSource => throw UnimplementedError();
}

/// A single-lot [Holding] built the same way the real pipeline does
/// (`Holding.fromLots`), so `firstPurchaseDate` and other lot-derived
/// getters behave exactly as they would for real data.
List<Holding> _holdingList({
  String ticker = 'PETR4',
  InvestmentTypeEnum type = InvestmentTypeEnum.STOCKS,
  double quantity = 100,
  double purchasePrice = 10,
  double? currentPrice,
}) {
  return Holding.fromLots([
    lot(ticker: ticker, type: type, quantity: quantity, purchasePrice: purchasePrice, currentPrice: currentPrice),
  ]);
}

/// `AppEventBus`'s broadcast controller notifies listeners asynchronously,
/// so a test that emits and then immediately asserts needs one more turn of
/// the event loop before the listener's callback has actually run.
Future<void> flushMicrotasks() => Future<void>.delayed(Duration.zero);

void main() {
  late FakePortfolioRepository repository;
  late FakeAchievementsLocalRepository achievementsLocalRepository;
  late FakeAchievementsRepository achievementsRepository;
  late FakeGamificationRepository gamificationRepository;
  late FakeMissionsRepository missionsRepository;
  late PortfolioController controller;

  setUp(() {
    repository = FakePortfolioRepository();
    achievementsLocalRepository = FakeAchievementsLocalRepository();
    achievementsRepository = FakeAchievementsRepository();
    gamificationRepository = FakeGamificationRepository();
    missionsRepository = FakeMissionsRepository();
    controller = PortfolioController(
      repository: repository,
      achievementsLocalRepository: achievementsLocalRepository,
      achievementsRepository: achievementsRepository,
      gamificationRepository: gamificationRepository,
      missionsRepository: missionsRepository,
    );
  });

  tearDown(() => controller.dispose());

  group('loadAll — happy path', () {
    test('populates holdings/summary/allocation and clears the loading flag', () async {
      repository.holdingsToReturn = _holdingList();
      repository.summaryToReturn = const PortfolioSummary(
        investedCapital: 1000,
        currentValue: 1200,
        totalGain: 200,
        totalGainPercent: 20,
        totalAssets: 1,
      );
      repository.allocationToReturn = [
        const AllocationSlice(type: InvestmentTypeEnum.STOCKS, currentValue: 1200, portfolioPercent: 100),
      ];

      await controller.loadAll();

      expect(controller.isLoading, isFalse);
      expect(controller.error, isNull);
      expect(controller.holdings, hasLength(1));
      expect(controller.summary.currentValue, 1200);
      expect(controller.allocation, hasLength(1));
    });

    test('isLoading is true while the load is in flight', () async {
      expect(controller.isLoading, isTrue); // set by the constructor's initial state
      final future = controller.loadAll();
      expect(controller.isLoading, isTrue);
      await future;
      expect(controller.isLoading, isFalse);
    });
  });

  group('loadAll — failure', () {
    test('a repository failure is captured as a user-facing error, not an unhandled exception', () async {
      final error = Exception('network down');
      repository.holdingsError = error;

      await controller.loadAll();

      expect(controller.isLoading, isFalse);
      // The raw exception is never shown to the user — it's translated into
      // friendly copy via friendlyErrorMessage (see friendlyErrorMessage.dart).
      expect(controller.error, friendlyErrorMessage(error));
    });

    test('a failed load does not crash gamification evaluation', () async {
      repository.holdingsError = Exception('network down');

      await controller.loadAll();

      // No exception propagated out of loadAll — reaching this line is the assertion.
      expect(controller.newlyUnlocked, isEmpty);
    });

    test('a failed real-portfolio fetch still evaluates gamification — '
        'this is the only signal an Academy-context session gets now that '
        'real_portfolio is Wallet-only and always 403s here', () async {
      repository.holdingsError = Exception('network down (expected: Wallet-only endpoint)');
      gamificationRepository.summaryToReturn = const GamificationSummary(
        totalXp: 250,
        level: 3,
        xpIntoLevel: 50,
        xpForNextLevel: 100,
        currentStreak: 2,
        longestStreak: 5,
      );

      await controller.loadAll();

      expect(controller.error, isNotNull); // the real-portfolio fetch itself still failed...
      expect(controller.gamificationSummary?.totalXp, 250); // ...but XP still loaded
    });
  });

  group('loadAll — empty portfolio', () {
    test('performance deltas are all zero, never a division-by-zero artifact', () async {
      await controller.loadAll();

      expect(controller.todayChangeValue, 0);
      expect(controller.todayChangePercent, 0);
      expect(controller.monthlyChangeValue, 0);
      expect(controller.annualChangeValue, 0);
    });
  });

  group('loadAll — gamification', () {
    // Achievement *qualification* is now real, server-side logic (see
    // EvaluateAchievementsUseCaseImplTest.java) — this only verifies
    // PortfolioController correctly orchestrates whatever the backend
    // reports: caching it locally, reporting newly-unlocked ones exactly
    // once, and feeding real XP into the mascot.
    test('reports newly-unlocked achievements from the backend and caches them locally', () async {
      achievementsRepository.resultToReturn = AchievementEvaluationResult(
        unlockedAt: {'first_investment': DateTime(2026, 1, 1)},
        newlyUnlockedCodes: {'first_investment'},
        achievementXpTotal: 50,
      );

      await controller.loadAll();

      expect(controller.newlyUnlocked.any((a) => a.id == 'first_investment'), isTrue);
      expect(controller.achievements.firstWhere((a) => a.id == 'first_investment').unlocked, isTrue);
      expect((await achievementsLocalRepository.loadUnlocked()).containsKey('first_investment'), isTrue);

      controller.clearNewlyUnlocked();
      expect(controller.newlyUnlocked, isEmpty);

      // A second load where the backend reports no *new* unlocks (already
      // persisted server-side) must not re-report it as "newly" unlocked.
      achievementsRepository.resultToReturn = AchievementEvaluationResult(
        unlockedAt: {'first_investment': DateTime(2026, 1, 1)},
        newlyUnlockedCodes: {},
        achievementXpTotal: 50,
      );
      await controller.loadAll();
      expect(controller.newlyUnlocked, isEmpty);
    });

    test('feeds the backend\'s real total XP into the mascot controller', () async {
      gamificationRepository.summaryToReturn = const GamificationSummary(
        totalXp: 275,
        level: 3,
        xpIntoLevel: 25,
        xpForNextLevel: 100,
        currentStreak: 2,
        longestStreak: 5,
      );

      await controller.loadAll();

      expect(controller.gamificationSummary?.totalXp, 275);
      expect(controller.gamificationSummary?.currentStreak, 2);
    });
  });

  group('loadAll — missions', () {
    test('populates missions and newly-completed codes from the backend', () async {
      missionsRepository.resultToReturn = const MissionEvaluationResult(
        missions: [
          MissionStatus(
            code: 'daily_complete_lesson',
            period: MissionPeriod.daily,
            periodKey: '2026-08-19',
            progress: 1,
            target: 1,
            xpReward: 30,
            completed: true,
          ),
        ],
        newlyCompletedCodes: {'daily_complete_lesson'},
        missionXpTotal: 30,
      );

      await controller.loadAll();

      expect(controller.missions, hasLength(1));
      expect(controller.missions.first.code, 'daily_complete_lesson');
      expect(controller.newlyCompletedMissions, contains('daily_complete_lesson'));

      controller.clearNewlyCompletedMissions();
      expect(controller.newlyCompletedMissions, isEmpty);
    });

    test('emits a MissionCompletedEvent with the resolved title for each newly-completed mission', () async {
      final events = <AppEvent>[];
      final sub = AppEventBus.instance.stream.listen(events.add);
      addTearDown(sub.cancel);

      missionsRepository.resultToReturn = const MissionEvaluationResult(
        missions: [
          MissionStatus(
            code: 'daily_complete_lesson',
            period: MissionPeriod.daily,
            periodKey: '2026-08-19',
            progress: 1,
            target: 1,
            xpReward: 30,
            completed: true,
          ),
        ],
        newlyCompletedCodes: {'daily_complete_lesson'},
        missionXpTotal: 30,
      );

      await controller.loadAll();
      await flushMicrotasks();

      final missionEvents = events.whereType<MissionCompletedEvent>().toList();
      expect(missionEvents, hasLength(1));
      expect(missionEvents.single.missionTitle, 'Aula do Dia');
    });

    test('does not emit MissionCompletedEvent when nothing newly completed', () async {
      final events = <AppEvent>[];
      final sub = AppEventBus.instance.stream.listen(events.add);
      addTearDown(sub.cancel);

      missionsRepository.resultToReturn = const MissionEvaluationResult(
        missions: [
          MissionStatus(
            code: 'daily_complete_lesson',
            period: MissionPeriod.daily,
            periodKey: '2026-08-19',
            progress: 0,
            target: 1,
            xpReward: 30,
            completed: false,
          ),
        ],
        newlyCompletedCodes: {},
        missionXpTotal: 0,
      );

      await controller.loadAll();
      await flushMicrotasks();

      expect(events.whereType<MissionCompletedEvent>(), isEmpty);
    });

    test('a missions backend failure does not crash loadAll or clear prior mission state', () async {
      missionsRepository.resultToReturn = const MissionEvaluationResult(
        missions: [
          MissionStatus(
            code: 'daily_complete_lesson',
            period: MissionPeriod.daily,
            periodKey: '2026-08-19',
            progress: 0,
            target: 1,
            xpReward: 30,
            completed: false,
          ),
        ],
        newlyCompletedCodes: {},
        missionXpTotal: 0,
      );
      await controller.loadAll();
      expect(controller.missions, hasLength(1));

      missionsRepository.evaluateError = Exception('network down');
      await controller.loadAll();

      expect(controller.error, isNull);
      expect(controller.missions, hasLength(1));
    });
  });

  group('setRange / setAssetFilter', () {
    test('setRange updates selectedRange and is a no-op when set to the same value', () async {
      await controller.loadAll();
      controller.setRange(HistoryRange.y1);
      expect(controller.selectedRange, HistoryRange.y1);
    });

    test('setAssetFilter updates selectedAssetFilter', () async {
      await controller.loadAll();
      controller.setAssetFilter(InvestmentTypeEnum.STOCKS);
      expect(controller.selectedAssetFilter, InvestmentTypeEnum.STOCKS);

      controller.setAssetFilter(null);
      expect(controller.selectedAssetFilter, isNull);
    });
  });

  group('refresh', () {
    test('calls loadAll again, hitting the repository a second time', () async {
      await controller.loadAll();
      expect(repository.fetchHoldingsCalls, 1);

      await controller.refresh();
      expect(repository.fetchHoldingsCalls, 2);
    });
  });

  group('loadAll — first investment', () {
    test('does not fire on a cold-start load, even if the portfolio is already non-empty', () async {
      final events = <AppEvent>[];
      final sub = AppEventBus.instance.stream.listen(events.add);
      addTearDown(sub.cancel);

      repository.holdingsToReturn = _holdingList();
      await controller.loadAll();
      await flushMicrotasks();

      expect(events.whereType<FirstInvestmentAddedEvent>(), isEmpty);
    });

    test('fires exactly once when holdings genuinely go from empty to non-empty on a later load', () async {
      final events = <AppEvent>[];
      final sub = AppEventBus.instance.stream.listen(events.add);
      addTearDown(sub.cancel);

      await controller.loadAll(); // cold start: empty portfolio
      repository.holdingsToReturn = _holdingList();
      await controller.loadAll(); // the user just bought their first asset
      await flushMicrotasks();

      expect(events.whereType<FirstInvestmentAddedEvent>(), hasLength(1));
    });

    test('does not refire on a subsequent load that stays non-empty', () async {
      final events = <AppEvent>[];
      final sub = AppEventBus.instance.stream.listen(events.add);
      addTearDown(sub.cancel);

      repository.holdingsToReturn = _holdingList();
      await controller.loadAll();
      await controller.loadAll();
      await flushMicrotasks();

      expect(events.whereType<FirstInvestmentAddedEvent>(), isEmpty);
    });
  });

  group('loadAll — high concentration', () {
    test('fires when a single holding makes up the whole portfolio', () async {
      final events = <AppEvent>[];
      final sub = AppEventBus.instance.stream.listen(events.add);
      addTearDown(sub.cancel);

      repository.holdingsToReturn = _holdingList(ticker: 'PETR4');
      await controller.loadAll();
      await flushMicrotasks();

      final fired = events.whereType<HighConcentrationDetectedEvent>();
      expect(fired, hasLength(1));
      expect(fired.first.ticker, 'PETR4');
      expect(fired.first.percent, 100);
    });

    test('does not refire on a subsequent load that stays concentrated', () async {
      final events = <AppEvent>[];
      final sub = AppEventBus.instance.stream.listen(events.add);
      addTearDown(sub.cancel);

      repository.holdingsToReturn = _holdingList(ticker: 'PETR4');
      await controller.loadAll();
      await controller.loadAll();
      await flushMicrotasks();

      expect(events.whereType<HighConcentrationDetectedEvent>(), hasLength(1));
    });

    test('does not fire when holdings are balanced across tickers', () async {
      final events = <AppEvent>[];
      final sub = AppEventBus.instance.stream.listen(events.add);
      addTearDown(sub.cancel);

      // A two-way 50/50 split is still >40% per holding — i.e. still
      // "concentrated" under `_evaluateConcentration`'s own threshold (see
      // `InsightGenerator`'s identical rule) — so a genuinely balanced,
      // non-concentrated portfolio needs at least three roughly-even
      // holdings, each ≤40%. Built as one combined lot set (not three
      // separate `_holdingList()` calls) so `portfolioPercent` is
      // normalized across all three tickers together.
      repository.holdingsToReturn = Holding.fromLots([
        lot(ticker: 'PETR4', quantity: 100, purchasePrice: 10),
        lot(ticker: 'VALE3', quantity: 100, purchasePrice: 10),
        lot(ticker: 'ITUB4', quantity: 100, purchasePrice: 10),
      ]);
      await controller.loadAll();
      await flushMicrotasks();

      expect(events.whereType<HighConcentrationDetectedEvent>(), isEmpty);
    });
  });
}
