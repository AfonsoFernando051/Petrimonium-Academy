import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/data/datasources/academy_remote_datasource.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_catalog_repository.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_progress_local_repository.dart';
import 'package:petrimonium/features/auth/data/repositories/auth_repository.dart';
import 'package:petrimonium/features/auth/presentation/screens/login_screen.dart';
import 'package:petrimonium/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:petrimonium/features/game/data/datasources/gamification_remote_datasource.dart';
import 'package:petrimonium/features/game/data/repositories/gamification_repository.dart';
import 'package:petrimonium/features/game/domain/entities/gamification_summary.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/portfolio_choice_screen.dart';
import 'package:petrimonium/features/onboarding/data/repositories/onboarding_state_repository.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/journey_ready_screen.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/domain/repositories/pet_repository.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/financial_goal_screen.dart';
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

import 'features/academy/academy_test_fixtures.dart';
import 'package:petrimonium/main.dart';

// ── Doubles ──────────────────────────────────────────────────────────────
// Note: `_SplashScreen` (lib/main.dart) is a private class, so it can't be
// referenced by type from this test file — it's exercised indirectly
// through `MyApp` while `StartRouteResolver().resolve()` is still pending,
// asserting on its rendered content instead.

class MockAuthRepository extends Mock implements AuthRepository {}

class MockPetRepository extends Mock implements PetRepository {}

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

class FakePortfolioRepository implements PortfolioRepository {
  @override
  Future<List<Holding>> fetchHoldings() async => const [];

  @override
  Future<PortfolioSummary> fetchSummary() async => PortfolioSummary.empty;

  @override
  Future<List<AllocationSlice>> fetchAllocation() async => const [];

  @override
  Future<List<HistoryPoint>> fetchHistory(HistoryRange range) async => const [];

  @override
  Future<DividendRadar> fetchDividendRadar() async => DividendRadar.empty;

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
  @override
  Future<MissionEvaluationResult> evaluate() async => MissionEvaluationResult.empty;

  @override
  MissionsRemoteDataSource get remoteDataSource => throw UnimplementedError();
}

class MockAcademyCatalogRepository extends Mock implements AcademyCatalogRepository {}

class MockAcademyRemoteDataSource extends Mock implements AcademyRemoteDataSource {}

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
    SharedPreferences.setMockInitialValues({});

    DI.mascotRepository = FakeMascotRepository();
    DI.onboardingStateRepository = OnboardingStateRepository();
  });

  Widget buildTestable() => const MyApp();

  group('MyApp splash', () {
    testWidgets('shows the branded splash while the start route is resolving', (tester) async {
      final authRepository = MockAuthRepository();
      // Never resolves within this test — keeps the FutureBuilder in its
      // "waiting" state so _SplashScreen's content can be asserted on. A
      // bare Completer (never a Timer-backed Future.delayed) so nothing is
      // left pending when the test ends.
      when(() => authRepository.isLoggedIn()).thenAnswer((_) => Completer<bool>().future);
      DI.authRepository = authRepository;

      await tester.pumpWidget(buildTestable());
      await tester.pump();

      expect(find.text('Inicializando Módulo de Comandante...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('MyApp route resolution', () {
    testWidgets('routes to LoginScreen when not logged in', (tester) async {
      final authRepository = MockAuthRepository();
      when(() => authRepository.isLoggedIn()).thenAnswer((_) async => false);
      DI.authRepository = authRepository;

      await tester.pumpWidget(buildTestable());
      await tester.pump();
      await tester.pump();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('routes to WelcomeScreen (meetPet) when the pet has no name yet', (tester) async {
      final authRepository = MockAuthRepository();
      when(() => authRepository.isLoggedIn()).thenAnswer((_) async => true);
      DI.authRepository = authRepository;

      final petRepository = MockPetRepository();
      when(() => petRepository.getPetStatus()).thenAnswer((_) async => false);
      DI.petRepository = petRepository;

      await tester.pumpWidget(buildTestable());
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(WelcomeScreen), findsOneWidget);

      // WelcomeScreen's floating icon starts its own repeating-adjacent
      // Timer (1.2s) — flush it now so it doesn't outlive this test as a
      // pending timer.
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('routes to FinancialGoalScreen when the pet is configured but no goal is set', (tester) async {
      final authRepository = MockAuthRepository();
      when(() => authRepository.isLoggedIn()).thenAnswer((_) async => true);
      DI.authRepository = authRepository;

      final petRepository = MockPetRepository();
      when(() => petRepository.getPetStatus()).thenAnswer((_) async => true);
      DI.petRepository = petRepository;

      DI.mascotRepository = _NamedFakeMascotRepository();
      // hasSetGoal() defaults to false against the real, SharedPreferences-
      // backed OnboardingStateRepository set up in setUp().

      await tester.pumpWidget(buildTestable());
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(FinancialGoalScreen), findsOneWidget);
    });

    testWidgets('routes to JourneyReadyScreen (tutorial) once a goal is set but the tutorial is unfinished', (tester) async {
      final authRepository = MockAuthRepository();
      when(() => authRepository.isLoggedIn()).thenAnswer((_) async => true);
      DI.authRepository = authRepository;

      final petRepository = MockPetRepository();
      when(() => petRepository.getPetStatus()).thenAnswer((_) async => true);
      DI.petRepository = petRepository;

      DI.mascotRepository = _NamedFakeMascotRepository();
      final onboardingState = OnboardingStateRepository();
      await onboardingState.setGoalChosen();
      DI.onboardingStateRepository = onboardingState;

      await tester.pumpWidget(buildTestable());
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(JourneyReadyScreen), findsOneWidget);
    });

    testWidgets('routes to PortfolioChoiceScreen once tutorial is done but the portfolio step is unresolved', (tester) async {
      final authRepository = MockAuthRepository();
      when(() => authRepository.isLoggedIn()).thenAnswer((_) async => true);
      DI.authRepository = authRepository;

      final petRepository = MockPetRepository();
      when(() => petRepository.getPetStatus()).thenAnswer((_) async => true);
      DI.petRepository = petRepository;

      DI.mascotRepository = _NamedFakeMascotRepository();
      final onboardingState = OnboardingStateRepository();
      await onboardingState.setGoalChosen();
      await onboardingState.completeTutorial();
      DI.onboardingStateRepository = onboardingState;

      await tester.pumpWidget(buildTestable());
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(PortfolioChoiceScreen), findsOneWidget);
    });

    testWidgets('routes to DashboardScreen once every onboarding step is resolved', (tester) async {
      final authRepository = MockAuthRepository();
      when(() => authRepository.isLoggedIn()).thenAnswer((_) async => true);
      DI.authRepository = authRepository;

      final petRepository = MockPetRepository();
      when(() => petRepository.getPetStatus()).thenAnswer((_) async => true);
      DI.petRepository = petRepository;

      DI.mascotRepository = _NamedFakeMascotRepository();
      final onboardingState = OnboardingStateRepository();
      await onboardingState.setGoalChosen();
      await onboardingState.completeTutorial();
      await onboardingState.markPortfolioSkipped();
      DI.onboardingStateRepository = onboardingState;

      // DashboardScreen's IndexedStack mounts all 5 tabs at once (Home,
      // Academy, Wallet, Passive Income, Mentor) — every dependency any of
      // them touch on init needs a working double, or an unmocked real
      // repository would attempt a real network call from this test.
      DI.portfolioRepository = FakePortfolioRepository();
      DI.achievementsLocalRepository = FakeAchievementsLocalRepository();
      DI.achievementsRepository = FakeAchievementsRepository();
      DI.gamificationRepository = FakeGamificationRepository();
      DI.missionsRepository = FakeMissionsRepository();
      DI.academyProgressRepository = AcademyProgressLocalRepository();

      final mockCatalogRepository = MockAcademyCatalogRepository();
      when(() => mockCatalogRepository.loadCached(any())).thenAnswer((_) async => buildAcademyCatalogSnapshot());
      when(() => mockCatalogRepository.fetchAndCache(any())).thenAnswer((_) async => buildAcademyCatalogSnapshot());
      DI.academyCatalogRepository = mockCatalogRepository;

      final mockRemoteDataSource = MockAcademyRemoteDataSource();
      when(() => mockRemoteDataSource.getCompletedLessonIds()).thenAnswer((_) async => {});
      DI.academyRemoteDataSource = mockRemoteDataSource;
      when(() => petRepository.getMyPet()).thenAnswer((_) async => null);

      await tester.pumpWidget(buildTestable());
      for (var i = 0; i < 10; i++) {
        await tester.pump();
      }
      // Flushes the persistent companion's greeting Timer (up to 9s) so it
      // doesn't outlive this test as a pending timer.
      await tester.pump(const Duration(seconds: 10));

      expect(find.byType(DashboardScreen), findsOneWidget);
    });
  });
}

/// A pet profile with a name set — routes past `StartRoute.meetPet` so
/// later tests in this file can reach the onboarding steps beyond it. CAT
/// rather than the default DOG for the same reason as [FakeMascotRepository]
/// above — DOG's bundled `dog.riv` isn't safely loadable under
/// `flutter_tester` on this toolchain.
class _NamedFakeMascotRepository implements MascotRepository {
  @override
  Future<PetProfile> loadProfile() async => PetProfile(name: 'Rex', specie: PetSpecieEnum.CAT);

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
