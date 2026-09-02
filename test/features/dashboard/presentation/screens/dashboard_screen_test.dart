import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/data/datasources/academy_remote_datasource.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_catalog_repository.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_progress_local_repository.dart';
import 'package:petrimonium/features/auth/data/repositories/auth_repository.dart';
import 'package:petrimonium/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:petrimonium/features/game/data/datasources/gamification_remote_datasource.dart';
import 'package:petrimonium/features/game/data/repositories/gamification_repository.dart';
import 'package:petrimonium/features/game/domain/entities/gamification_summary.dart';
import 'package:petrimonium/features/onboarding/data/models/onboarding_status_model.dart';
import 'package:petrimonium/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:petrimonium/features/onboarding/data/repositories/onboarding_state_repository.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/domain/repositories/pet_repository.dart';
import 'package:petrimonium/features/pet/data/repositories/pet_companion_preferences_repository.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

import '../../../academy/academy_test_fixtures.dart';

// ── Fakes/mocks mirroring test/features/portfolio/presentation/controllers/
// portfolio_controller_test.dart's doubles, plus the academy/mascot ones
// used across the Academy screen tests — DashboardScreen's IndexedStack
// mounts every tab at once, so all of their dependencies need doubles here,
// not just the ones DashboardScreen touches directly.

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
  Map<String, DateTime> _unlocked = {};

  @override
  Future<Map<String, DateTime>> loadUnlocked() async => _unlocked;

  @override
  Future<void> cacheUnlocked(Map<String, DateTime> unlockedAt) async {
    _unlocked = unlockedAt;
  }
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
  @override
  Future<MissionEvaluationResult> evaluate() async => MissionEvaluationResult.empty;

  @override
  MissionsRemoteDataSource get remoteDataSource => throw UnimplementedError();
}

class FakeMascotRepository implements MascotRepository {
  // CAT rather than the default DOG: DOG now ships a real `dog.riv`, and
  // this project's pinned `rive`/`rive_common` versions hit a native-symbol
  // lookup failure once `flutter_tester` actually parses `.riv` bytes on
  // this toolchain (see `pet_rive_companion_test.dart`). CAT has no bundled
  // asset, so DashboardScreen's embedded PetCompanionHeader keeps exercising
  // the real, always-reachable fallback path deterministically.
  @override
  Future<PetProfile> loadProfile() async => PetProfile(specie: PetSpecieEnum.CAT);

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

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

class MockPetRepository extends Mock implements PetRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
    SharedPreferences.setMockInitialValues({});

    DI.mascotRepository = FakeMascotRepository();
    DI.portfolioRepository = FakePortfolioRepository();
    DI.achievementsLocalRepository = FakeAchievementsLocalRepository();
    DI.achievementsRepository = FakeAchievementsRepository();
    DI.gamificationRepository = FakeGamificationRepository();
    DI.missionsRepository = FakeMissionsRepository();
    DI.petCompanionPreferencesRepository = PetCompanionPreferencesRepository();
    DI.onboardingStateRepository = OnboardingStateRepository();
    DI.academyProgressRepository = AcademyProgressLocalRepository();

    final mockCatalogRepository = MockAcademyCatalogRepository();
    when(() => mockCatalogRepository.loadCached(any())).thenAnswer((_) async => buildAcademyCatalogSnapshot());
    when(() => mockCatalogRepository.fetchAndCache(any())).thenAnswer((_) async => buildAcademyCatalogSnapshot());
    DI.academyCatalogRepository = mockCatalogRepository;

    final mockRemoteDataSource = MockAcademyRemoteDataSource();
    when(() => mockRemoteDataSource.getCompletedLessonIds()).thenAnswer((_) async => {});
    DI.academyRemoteDataSource = mockRemoteDataSource;

    final mockOnboardingRepository = MockOnboardingRepository();
    when(() => mockOnboardingRepository.getStatus()).thenAnswer(
      (_) async => const OnboardingStatusModel(hasAnswered: true, profile: null),
    );
    DI.onboardingRepository = mockOnboardingRepository;

    final mockPetRepository = MockPetRepository();
    when(() => mockPetRepository.getMyPet()).thenAnswer((_) async => null);
    DI.petRepository = mockPetRepository;

    final mockAuthRepository = MockAuthRepository();
    when(() => mockAuthRepository.getSavedUserName()).thenAnswer((_) async => null);
    when(() => mockAuthRepository.refreshUserName()).thenAnswer((_) async => null);
    DI.authRepository = mockAuthRepository;
  });

  Widget buildTestable() {
    return MaterialApp(theme: AppTheme.dark, home: const DashboardScreen());
  }

  Future<void> pumpUntilLoaded(WidgetTester tester) async {
    // DashboardScreen mounts a CosmicBackground and several GameButton
    // pulse:true CTAs across its tabs — never pumpAndSettle. Several plain
    // pumps flush the various controllers' async load() chains, plus a
    // longer flush for the persistent companion's greeting Timer (up to 9s).
    for (var i = 0; i < 10; i++) {
      await tester.pump();
    }
    await tester.pump(const Duration(seconds: 10));
  }

  // Several icons used in the bottom nav (school, diamond, ...) also appear
  // elsewhere in the tab content itself (e.g. HomeScreen's Knowledge Map
  // reuses Icons.school for the fixture domain's icon) — every lookup below
  // is scoped to the BottomNavigationBar so it can't collide with those.
  Finder navIcon(IconData icon) => find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.byIcon(icon),
      );

  group('DashboardScreen', () {
    testWidgets('renders the Home tab by default without crashing', (tester) async {
      await tester.pumpWidget(buildTestable());
      await pumpUntilLoaded(tester);

      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('Invest Game'), findsOneWidget);
      expect(navIcon(Icons.rocket_launch), findsOneWidget); // active Home nav icon
    });

    testWidgets('switching to the Academy tab shows Academy nav as active', (tester) async {
      await tester.pumpWidget(buildTestable());
      await pumpUntilLoaded(tester);

      await tester.tap(navIcon(Icons.school_outlined));
      await pumpUntilLoaded(tester);

      expect(navIcon(Icons.school), findsOneWidget); // active Academy nav icon
    });

    testWidgets('switching to the Wallet tab shows Wallet nav as active', (tester) async {
      await tester.pumpWidget(buildTestable());
      await pumpUntilLoaded(tester);

      await tester.tap(navIcon(Icons.diamond_outlined));
      await pumpUntilLoaded(tester);

      expect(navIcon(Icons.diamond), findsOneWidget); // active Wallet nav icon
    });

    testWidgets('switching to the Mentor tab shows Mentor nav as active', (tester) async {
      await tester.pumpWidget(buildTestable());
      await pumpUntilLoaded(tester);

      await tester.tap(navIcon(Icons.auto_awesome_outlined));
      await pumpUntilLoaded(tester);

      expect(navIcon(Icons.auto_awesome), findsOneWidget); // active Mentor nav icon
    });
  });
}
