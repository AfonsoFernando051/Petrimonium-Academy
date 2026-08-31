import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/data/datasources/academy_remote_datasource.dart';
import 'package:petrimonium/features/academy/data/models/academy_catalog_snapshot.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_catalog_repository.dart';
import 'package:petrimonium/features/game/data/datasources/gamification_remote_datasource.dart';
import 'package:petrimonium/features/game/data/repositories/gamification_repository.dart';
import 'package:petrimonium/features/game/domain/entities/gamification_summary.dart';
import 'package:petrimonium/features/home/presentation/screens/home_screen.dart';
import 'package:petrimonium/features/home/presentation/widgets/next_action_card.dart';
import 'package:petrimonium/features/home/presentation/widgets/portfolio_bridge_card.dart';
import 'package:petrimonium/features/home/presentation/widgets/portfolio_not_connected_card.dart';
import 'package:petrimonium/features/home/presentation/widgets/portfolio_reminder_banner.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_companion_controller.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/pet_speech_bubble_anchor.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:petrimonium/features/portfolio/data/datasources/achievements_remote_datasource.dart';
import 'package:petrimonium/features/portfolio/data/datasources/missions_remote_datasource.dart';
import 'package:petrimonium/features/portfolio/data/datasources/portfolio_remote_datasource.dart';
import 'package:petrimonium/features/portfolio/data/repositories/achievements_local_repository.dart';
import 'package:petrimonium/features/portfolio/data/repositories/achievements_repository.dart';
import 'package:petrimonium/features/portfolio/data/repositories/missions_repository.dart';
import 'package:petrimonium/features/portfolio/data/repositories/portfolio_repository.dart';
import 'package:petrimonium/features/portfolio/domain/entities/achievement_evaluation_result.dart';
import 'package:petrimonium/features/portfolio/domain/entities/allocation_slice.dart';
import 'package:petrimonium/features/portfolio/domain/entities/dividend_event.dart';
import 'package:petrimonium/features/portfolio/domain/entities/history_point.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_lot.dart';
import 'package:petrimonium/features/portfolio/domain/entities/mission_status.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:petrimonium/features/portfolio/domain/enums/history_range.dart';
import 'package:petrimonium/features/portfolio/presentation/controllers/portfolio_controller.dart';

/// In-memory [PortfolioRepository] double — mirrors the one in
/// `portfolio_controller_test.dart`; tests configure what it "fetches".
class FakePortfolioRepository implements PortfolioRepository {
  List<Holding> holdingsToReturn = const [];
  PortfolioSummary summaryToReturn = PortfolioSummary.empty;
  List<AllocationSlice> allocationToReturn = const [];
  Map<HistoryRange, List<HistoryPoint>> historyByRange = const {};
  DividendRadar dividendRadarToReturn = DividendRadar.empty;

  @override
  Future<List<Holding>> fetchHoldings() async => holdingsToReturn;

  @override
  Future<PortfolioSummary> fetchSummary() async => summaryToReturn;

  @override
  Future<List<AllocationSlice>> fetchAllocation() async => allocationToReturn;

  @override
  Future<List<HistoryPoint>> fetchHistory(HistoryRange range) async => historyByRange[range] ?? const [];

  @override
  Future<DividendRadar> fetchDividendRadar() async => dividendRadarToReturn;

  @override
  PortfolioRemoteDataSource get remoteDataSource => throw UnimplementedError();
}

class FakeAchievementsLocalRepository implements AchievementsLocalRepository {
  @override
  Future<Map<String, DateTime>> loadUnlocked() async => {};

  @override
  Future<void> cacheUnlocked(Map<String, DateTime> unlockedAt) async {}
}

class FakeAchievementsRepository implements AchievementsRepository {
  @override
  Future<AchievementEvaluationResult> evaluate() async => AchievementEvaluationResult.empty;

  @override
  AchievementsRemoteDataSource get remoteDataSource => throw UnimplementedError();
}

class FakeGamificationRepository implements GamificationRepository {
  @override
  Future<GamificationSummary> fetchSummary() async => GamificationSummary.empty;

  @override
  GamificationRemoteDataSource get remoteDataSource => throw UnimplementedError();
}

class FakeMissionsRepository implements MissionsRepository {
  MissionEvaluationResult resultToReturn = MissionEvaluationResult.empty;

  @override
  Future<MissionEvaluationResult> evaluate() async => resultToReturn;

  @override
  MissionsRemoteDataSource get remoteDataSource => throw UnimplementedError();
}

/// Minimal in-memory MascotRepository double, mirrors the one used in
/// `mascot_controller_test.dart` — only `loadProfile` matters here.
class FakeMascotRepository implements MascotRepository {
  PetProfile profileToReturn = PetProfile();

  @override
  Future<PetProfile> loadProfile() async => profileToReturn;
  @override
  Future<void> saveName(String name) async {}
  @override
  Future<void> saveStage(PetEvolutionStage stage) async {}
  @override
  Future<void> saveXp(int xp) async {}
  @override
  Future<void> saveSpecie(PetSpecieEnum specie) async {}
  @override
  Future<void> saveNetWorth(double netWorth) async {}
  @override
  Future<void> saveEquippedAccessories(Map<AccessoryType, PetAccessoryId> equipped) async {}
  @override
  Future<void> saveUnlockedAccessories(Set<PetAccessoryId> unlocked) async {}
  @override
  Future<void> saveLastActiveAt(DateTime lastActiveAt) async {}
}

class MockAcademyCatalogRepository extends Mock implements AcademyCatalogRepository {}

class MockAcademyRemoteDataSource extends Mock implements AcademyRemoteDataSource {}

/// A single-lot [Holding], built the same way the real pipeline does.
Holding _holding({String ticker = 'PETR4', double quantity = 100, double purchasePrice = 10}) {
  final lot = InvestmentLot(
    id: 1,
    ticker: ticker,
    type: InvestmentTypeEnum.STOCKS,
    quantity: quantity,
    purchasePrice: purchasePrice,
    purchaseDate: DateTime(2024, 1, 1),
    currentPrice: purchasePrice,
    investedValue: quantity * purchasePrice,
    currentValue: quantity * purchasePrice,
  );
  return Holding.fromLots([lot]).single;
}

const _emptySnapshot = AcademyCatalogSnapshot(domains: [], schools: [], modules: [], lessons: []);

void main() {
  late FakePortfolioRepository portfolioRepository;
  late FakeMissionsRepository missionsRepository;
  late PortfolioController portfolioController;
  late FakeMascotRepository mascotRepository;
  late MascotController mascotController;
  late PetCompanionController companionController;
  late MockAcademyCatalogRepository mockCatalogRepository;
  late MockAcademyRemoteDataSource mockRemoteDataSource;

  setUp(() {
    Translator.currentLanguage = 'pt';
    SharedPreferences.setMockInitialValues({});

    portfolioRepository = FakePortfolioRepository();
    missionsRepository = FakeMissionsRepository();
    portfolioController = PortfolioController(
      repository: portfolioRepository,
      achievementsLocalRepository: FakeAchievementsLocalRepository(),
      achievementsRepository: FakeAchievementsRepository(),
      gamificationRepository: FakeGamificationRepository(),
      missionsRepository: missionsRepository,
    );

    mascotRepository = FakeMascotRepository();
    mascotController = MascotController(repository: mascotRepository);
    companionController = PetCompanionController(mascotController: mascotController);

    mockCatalogRepository = MockAcademyCatalogRepository();
    DI.academyCatalogRepository = mockCatalogRepository;
    when(() => mockCatalogRepository.loadCached(any())).thenAnswer((_) async => null);
    when(() => mockCatalogRepository.fetchAndCache(any())).thenAnswer((_) async => _emptySnapshot);

    mockRemoteDataSource = MockAcademyRemoteDataSource();
    DI.academyRemoteDataSource = mockRemoteDataSource;
    when(() => mockRemoteDataSource.getCompletedLessonIds()).thenThrow(Exception('offline'));
  });

  tearDown(() {
    portfolioController.dispose();
    companionController.dispose();
    mascotController.dispose();
  });

  Widget buildTestableWidget({
    bool showPortfolioReminder = false,
    bool investorProfileUnanswered = false,
    VoidCallback? onOpenAcademyTab,
    VoidCallback? onOpenPortfolioTab,
    VoidCallback? onDismissPortfolioReminder,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: HomeScreen(
          portfolioController: portfolioController,
          mascotController: mascotController,
          onOpenAcademyTab: onOpenAcademyTab ?? () {},
          onOpenPortfolioTab: onOpenPortfolioTab ?? () {},
          showPortfolioReminder: showPortfolioReminder,
          onDismissPortfolioReminder: onDismissPortfolioReminder ?? () {},
          investorProfileUnanswered: investorProfileUnanswered,
          companionController: companionController,
          heroAnchor: PetSpeechBubbleAnchor(),
        ),
      ),
    );
  }

  group('HomeScreen — no portfolio connected', () {
    testWidgets('renders PortfolioNotConnectedCard when there are no holdings', (tester) async {
      await portfolioController.loadAll();

      await tester.pumpWidget(buildTestableWidget());
      // Hosts several repeating AnimationControllers (LearningHeroCard,
      // GameButton) — never call pumpAndSettle.
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.byType(PortfolioNotConnectedCard), findsOneWidget);
      expect(find.byType(PortfolioBridgeCard), findsNothing);
    });

    testWidgets('shows the portfolio reminder banner when asked to', (tester) async {
      await portfolioController.loadAll();

      await tester.pumpWidget(buildTestableWidget(showPortfolioReminder: true));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.byType(PortfolioReminderBanner), findsOneWidget);
    });

    testWidgets('omits the portfolio reminder banner by default', (tester) async {
      await portfolioController.loadAll();

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.byType(PortfolioReminderBanner), findsNothing);
    });
  });

  group('HomeScreen — Next Action engine', () {
    testWidgets('renders the mission-almost-done NextAction when a mission is one lesson away', (tester) async {
      missionsRepository.resultToReturn = const MissionEvaluationResult(
        missions: [
          MissionStatus(
            code: 'daily_complete_lesson',
            period: MissionPeriod.daily,
            periodKey: '2026-08-25',
            progress: 1,
            target: 2,
            xpReward: 15,
            completed: false,
          ),
        ],
        newlyCompletedCodes: {},
        missionXpTotal: 0,
      );
      await portfolioController.loadAll();

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.byType(NextActionCard), findsOneWidget);
      expect(find.text('Aula do Dia'), findsOneWidget);
    });
  });

  group('HomeScreen — portfolio connected', () {
    testWidgets('renders PortfolioBridgeCard when holdings exist', (tester) async {
      portfolioRepository.holdingsToReturn = [_holding()];
      portfolioRepository.summaryToReturn = const PortfolioSummary(
        investedCapital: 1000,
        currentValue: 1200,
        totalGain: 200,
        totalGainPercent: 20,
        totalAssets: 1,
      );
      await portfolioController.loadAll();

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.byType(PortfolioBridgeCard), findsOneWidget);
      expect(find.byType(PortfolioNotConnectedCard), findsNothing);
    });
  });

  group('HomeScreen — loading state', () {
    testWidgets('shows a loading indicator before the first load completes', (tester) async {
      // portfolioController.isLoading starts true and holdings empty by
      // default — HomeScreen shows a full-screen loader in that state,
      // before loadAll() is ever called.
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
