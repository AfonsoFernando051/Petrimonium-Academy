import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/data/datasources/academy_remote_datasource.dart';
import 'package:petrimonium/features/auth/data/repositories/auth_repository.dart';
import 'package:petrimonium/features/academy/data/models/academy_catalog_snapshot.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_catalog_repository.dart';
import 'package:petrimonium/features/game/data/datasources/gamification_remote_datasource.dart';
import 'package:petrimonium/features/game/data/repositories/gamification_repository.dart';
import 'package:petrimonium/features/game/domain/entities/gamification_summary.dart';
import 'package:petrimonium/features/home/presentation/screens/home_screen.dart';
import 'package:petrimonium/features/home/presentation/widgets/next_action_card.dart';
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
import 'package:petrimonium/features/portfolio/domain/entities/mission_status.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:petrimonium/features/portfolio/domain/enums/history_range.dart';
import 'package:petrimonium/features/portfolio/presentation/controllers/portfolio_controller.dart';

import '../../../academy/academy_test_fixtures.dart';

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
  GamificationSummary summaryToReturn = GamificationSummary.empty;

  @override
  Future<GamificationSummary> fetchSummary() async => summaryToReturn;

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

class MockAuthRepository extends Mock implements AuthRepository {}

const _emptySnapshot = AcademyCatalogSnapshot(domains: [], schools: [], modules: [], lessons: []);

void main() {
  late FakePortfolioRepository portfolioRepository;
  late FakeMissionsRepository missionsRepository;
  late FakeGamificationRepository gamificationRepository;
  late PortfolioController portfolioController;
  late FakeMascotRepository mascotRepository;
  late MascotController mascotController;
  late PetCompanionController companionController;
  late MockAcademyCatalogRepository mockCatalogRepository;
  late MockAcademyRemoteDataSource mockRemoteDataSource;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    Translator.currentLanguage = 'pt';
    SharedPreferences.setMockInitialValues({});

    portfolioRepository = FakePortfolioRepository();
    missionsRepository = FakeMissionsRepository();
    gamificationRepository = FakeGamificationRepository();
    portfolioController = PortfolioController(
      repository: portfolioRepository,
      achievementsLocalRepository: FakeAchievementsLocalRepository(),
      achievementsRepository: FakeAchievementsRepository(),
      gamificationRepository: gamificationRepository,
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

    mockAuthRepository = MockAuthRepository();
    when(() => mockAuthRepository.getSavedUserName()).thenAnswer((_) async => null);
    when(() => mockAuthRepository.refreshUserName()).thenAnswer((_) async => null);
    DI.authRepository = mockAuthRepository;
  });

  tearDown(() {
    portfolioController.dispose();
    companionController.dispose();
    mascotController.dispose();
  });

  Widget buildTestableWidget({
    VoidCallback? onOpenAcademyTab,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: HomeScreen(
          portfolioController: portfolioController,
          mascotController: mascotController,
          onOpenAcademyTab: onOpenAcademyTab ?? () {},
          companionController: companionController,
          heroAnchor: PetSpeechBubbleAnchor(),
        ),
      ),
    );
  }

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

  group('HomeScreen — greeting, streak and Mentor insight', () {
    testWidgets('shows the real name once resolved and the streak badge from the real gamification summary', (tester) async {
      when(() => mockAuthRepository.getSavedUserName()).thenAnswer((_) async => 'Camila');
      when(() => mockAuthRepository.refreshUserName()).thenAnswer((_) async => 'Camila');
      gamificationRepository.summaryToReturn = const GamificationSummary(
        totalXp: 100,
        level: 2,
        xpIntoLevel: 10,
        xpForNextLevel: 50,
        currentStreak: 3,
        longestStreak: 5,
      );
      await portfolioController.loadAll();

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.text('Bem-vindo de volta, Camila'), findsOneWidget);
      expect(find.text('3 dias'), findsOneWidget);
    });

    testWidgets('shows the Mentor insight card naming the real next lesson when one exists', (tester) async {
      when(() => mockCatalogRepository.fetchAndCache(any())).thenAnswer((_) async => buildAcademyCatalogSnapshot());
      await portfolioController.loadAll();

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Você estava progredindo em "${testLesson1.title}". Continuar de onde parou?'),
        findsOneWidget,
      );
      expect(find.text('Por que estou vendo isto?'), findsOneWidget);

      // The real next-lesson data also triggers PetCompanionController's own
      // nudge (a separate, transient mechanism — see HomeMentorCard's doc
      // comment), which starts a real auto-hide Timer (up to 9s). Flush it
      // so it doesn't outlive this test as a pending timer (mirrors
      // main_test.dart's own comment on the same mechanism).
      await tester.pump(const Duration(seconds: 10));
    });

    testWidgets('omits the Mentor insight card when no real signal applies', (tester) async {
      await portfolioController.loadAll();

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.text('Por que estou vendo isto?'), findsNothing);
    });
  });
}
