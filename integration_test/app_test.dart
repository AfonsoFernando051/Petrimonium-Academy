import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/presentation/screens/academy_domain_detail_screen.dart';
import 'package:petrimonium/features/academy/presentation/screens/academy_home_screen.dart';
import 'package:petrimonium/features/academy/presentation/screens/lesson_screen.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_domain_card.dart';
import 'package:petrimonium/features/academy/presentation/widgets/school_card.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_completion_result.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_catalog_repository.dart';
import 'package:petrimonium/features/auth/data/repositories/auth_repository.dart';
import 'package:petrimonium/features/auth/presentation/screens/login_screen.dart';
import 'package:petrimonium/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:petrimonium/features/auth/presentation/widgets/login_button.dart';
import 'package:petrimonium/features/auth/presentation/widgets/signup_action_button.dart';
import 'package:petrimonium/features/auth/presentation/widgets/signup_form.dart';
import 'package:petrimonium/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:petrimonium/features/mentor/data/repositories/mentor_chat_repository.dart';
import 'package:petrimonium/features/mentor/presentation/screens/mentor_screen.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/portfolio_choice_screen.dart';
import 'package:petrimonium/features/onboarding/data/models/onboarding_status_model.dart';
import 'package:petrimonium/features/onboarding/data/models/question_model.dart';
import 'package:petrimonium/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:petrimonium/features/onboarding/data/repositories/onboarding_state_repository.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/data/repositories/pet_companion_preferences_repository.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/domain/repositories/pet_repository.dart';
import 'package:petrimonium/features/pet/presentation/celebration/module_completion_share_overlay.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/features/academy/academy_test_fixtures.dart';
import '../test/features/academy/presentation/screens/academy_home_screen_test.dart'
    show MockAcademyCatalogRepository, MockAcademyRemoteDataSource;
import '../test/features/portfolio/presentation/controllers/portfolio_controller_test.dart'
    show
        FakePortfolioRepository,
        FakeAchievementsLocalRepository,
        FakeAchievementsRepository,
        FakeGamificationRepository,
        FakeMissionsRepository;

class MockAuthRepository extends Mock implements AuthRepository {}

class MockPetRepository extends Mock implements PetRepository {}

class MockMascotRepository extends Mock implements MascotRepository {}

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

class MockOnboardingStateRepository extends Mock
    implements OnboardingStateRepository {}

class MockPetCompanionPreferencesRepository extends Mock
    implements PetCompanionPreferencesRepository {}

class MockMentorChatRepository extends Mock implements MentorChatRepository {}

class MockApiClient extends Mock implements ApiClient {}

/// The app's one real end-to-end flow: a returning, fully-onboarded user
/// logs in and lands on [DashboardScreen] — exercising `MyApp`'s real
/// `StartRouteResolver` routing (see `core/navigation/start_route_resolver.dart`)
/// and `LoginForm`'s real `pushAndRemoveUntil(MyApp())` re-mount, not just
/// the individual screens/controllers in isolation (already covered by
/// `test/`'s widget/unit tests).
///
/// Runs via `flutter test integration_test/app_test.dart` (see
/// `.github/workflows/mobile-ci.yml`) — this app has no native-plugin
/// behavior under test here, so the plain widget-tree-level `flutter test`
/// runner is sufficient; no device/emulator is required.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Mocktail needs a concrete enum value whenever `any()` is used for
    // MascotRepository.saveStage. Register it once for every integration
    // scenario that prepares the shared mascot mock below.
    registerFallbackValue(PetEvolutionStage.babyDog);
  });

  late MockAuthRepository mockAuthRepository;
  late MockPetRepository mockPetRepository;
  late MockMascotRepository mockMascotRepository;
  late MockOnboardingRepository mockOnboardingRepository;
  late MockOnboardingStateRepository mockOnboardingStateRepository;
  late MockPetCompanionPreferencesRepository
  mockPetCompanionPreferencesRepository;
  late MockMentorChatRepository mockMentorChatRepository;

  setUp(() {
    Translator.currentLanguage = 'pt';

    // Starts logged out (so MyApp's first resolve() lands on LoginScreen);
    // AuthRepository.login flips it to true, mirroring what a real login
    // does to persisted auth state before MyApp re-mounts and re-resolves.
    var loggedIn = false;

    mockAuthRepository = MockAuthRepository();
    DI.authRepository = mockAuthRepository;
    when(
      () => mockAuthRepository.isLoggedIn(),
    ).thenAnswer((_) async => loggedIn);
    when(() => mockAuthRepository.login(any(), any())).thenAnswer((_) async {
      loggedIn = true;
    });
    when(
      () => mockAuthRepository.register(any(), any(), any()),
    ).thenAnswer((_) async {});
    // HomeScreen.initState calls both on every mount; unstubbed, mocktail
    // returns null where a Future<String?> is awaited and the whole dashboard
    // fails to build. Null is the "no display name known" case, which these
    // flows don't assert on.
    when(() => mockAuthRepository.getSavedUserName()).thenAnswer((_) async => null);
    when(() => mockAuthRepository.refreshUserName()).thenAnswer((_) async => null);

    mockOnboardingRepository = MockOnboardingRepository();
    DI.onboardingRepository = mockOnboardingRepository;
    when(() => mockOnboardingRepository.getStatus()).thenAnswer(
      (_) async =>
          const OnboardingStatusModel(hasAnswered: true, profile: 'moderate'),
    );
    when(
      () => mockOnboardingRepository.getQuestions(),
    ).thenAnswer((_) async => <QuestionModel>[]);

    // Fully onboarded: every StartRouteResolver gate before StartRoute.home
    // resolves as already-done.
    mockPetRepository = MockPetRepository();
    DI.petRepository = mockPetRepository;
    when(() => mockPetRepository.getPetStatus()).thenAnswer((_) async => true);
    when(() => mockPetRepository.getMyPet()).thenAnswer((_) async => null);

    // The integration scenario below represents the Mentor API response.
    // Keeping it at the repository boundary makes the full screen flow
    // deterministic while the backend's randomized selection is covered by
    // its own service tests.
    mockMentorChatRepository = MockMentorChatRepository();
    DI.mentorChatRepository = mockMentorChatRepository;
    when(() => mockMentorChatRepository.loadSuggestedPrompts()).thenAnswer(
      (_) async => const [
        'Como montar minha reserva de emergência?',
        'Qual a diferença entre ETF e fundo imobiliário?',
        'Como funciona a diversificação?',
        'O que devo estudar antes de investir?',
        'Como analisar minha carteira?',
      ],
    );
    when(
      () => mockMentorChatRepository.purgeLegacyLocalHistory(),
    ).thenAnswer((_) async {});

    mockMascotRepository = MockMascotRepository();
    DI.mascotRepository = mockMascotRepository;
    when(() => mockMascotRepository.loadProfile()).thenAnswer(
      (_) async => PetProfile(
        specie: PetSpecieEnum.DOG,
        name: 'Rex',
        stage: PetEvolutionStage.babyDog,
      ),
    );
    when(
      () => mockMascotRepository.saveLastActiveAt(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockMascotRepository.saveNetWorth(any()),
    ).thenAnswer((_) async {});
    when(() => mockMascotRepository.saveXp(any())).thenAnswer((_) async {});
    when(() => mockMascotRepository.saveStage(any())).thenAnswer((_) async {});

    mockOnboardingStateRepository = MockOnboardingStateRepository();
    DI.onboardingStateRepository = mockOnboardingStateRepository;
    when(
      () => mockOnboardingStateRepository.hasSetGoal(),
    ).thenAnswer((_) async => true);
    when(
      () => mockOnboardingStateRepository.isTutorialCompleted(),
    ).thenAnswer((_) async => true);
    when(
      () => mockOnboardingStateRepository.isPortfolioStepDone(),
    ).thenAnswer((_) async => true);
    // Dashboard mounts the empty-portfolio activation view in these flows.
    // Stub its persisted state as well so the async initState path has the
    // same concrete return type it receives in production.
    when(
      () => mockOnboardingStateRepository.hasSeenPortfolioActivation(),
    ).thenAnswer((_) async => false);
    when(
      () => mockOnboardingStateRepository.markPortfolioActivationSeen(),
    ).thenAnswer((_) async {});
    when(
      () => mockOnboardingStateRepository.shouldShowPortfolioReminder(),
    ).thenAnswer((_) async => false);
    when(
      () => mockOnboardingStateRepository.currentSessionCount(),
    ).thenAnswer((_) async => 3);
    when(
      () => mockOnboardingStateRepository.markReminderShown(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockOnboardingStateRepository.markPortfolioSkipped(),
    ).thenAnswer((_) async {});

    // Academy catalog — a real (fake-backed) snapshot with one contentAvailable
    // school and one comingSoon school, so the "does a school still render
    // with zero investments / after skipping portfolio setup" flow below has
    // real content to assert on rather than an empty catalog.
    final mockAcademyCatalogRepository = MockAcademyCatalogRepository();
    when(
      () => mockAcademyCatalogRepository.loadCached(any()),
    ).thenAnswer((_) async => buildAcademyCatalogSnapshot());
    when(
      () => mockAcademyCatalogRepository.fetchAndCache(any()),
    ).thenAnswer((_) async => buildAcademyCatalogSnapshot());
    DI.academyCatalogRepository = mockAcademyCatalogRepository;

    final mockAcademyRemoteDataSource = MockAcademyRemoteDataSource();
    when(
      () => mockAcademyRemoteDataSource.getCompletedLessonIds(),
    ).thenAnswer((_) async => {});
    when(
      () => mockAcademyRemoteDataSource.completeLesson(
        any(),
        perfectFirstTry: any(named: 'perfectFirstTry'),
      ),
    ).thenAnswer(
      (_) async => const LessonCompletionResult(
        lessonId: 'test_lesson_3',
        alreadyCompleted: false,
        xpAwarded: 20,
        moduleCompleted: true,
        moduleXpAwarded: 0,
        totalXp: 60,
        level: 2,
        xpIntoLevel: 10,
        xpForNextLevel: 100,
      ),
    );
    DI.academyRemoteDataSource = mockAcademyRemoteDataSource;

    // DashboardScreen's own dependencies — an empty-but-valid portfolio so
    // the screen renders without error (its content is exercised in detail
    // by the feature-level widget tests, not this flow).
    DI.portfolioRepository = FakePortfolioRepository();
    DI.achievementsLocalRepository = FakeAchievementsLocalRepository();
    DI.achievementsRepository = FakeAchievementsRepository();
    DI.gamificationRepository = FakeGamificationRepository();
    DI.missionsRepository = FakeMissionsRepository();

    mockPetCompanionPreferencesRepository =
        MockPetCompanionPreferencesRepository();
    DI.petCompanionPreferencesRepository =
        mockPetCompanionPreferencesRepository;
    when(
      () => mockPetCompanionPreferencesRepository.loadLastShown(),
    ).thenAnswer((_) async => {});
    when(
      () => mockPetCompanionPreferencesRepository.recordShown(any(), any()),
    ).thenAnswer((_) async {});
  });

  testWidgets('login lands on the dashboard for a fully-onboarded user', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    // Let MyApp's FutureBuilder resolve StartRouteResolver().resolve().
    await tester.pump();
    await tester.pump();

    expect(find.byType(LoginScreen), findsOneWidget);

    final fields = find.descendant(
      of: find.byType(CustomTextField),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.first, 'investor@test.com');
    await tester.enterText(fields.last, 'Str0ngPass1');
    await tester.pump();

    // LoginScreen also has a GoogleSignInButton, which is GameButton-based
    // too — target LoginButton specifically so the tap isn't ambiguous.
    await tester.tap(find.byType(LoginButton));
    // Not pumpAndSettle() anywhere in this test: both LoginScreen (its
    // GameButton has pulse:true) and DashboardScreen (its CosmicBackground)
    // contain indefinitely-repeating animations. Pump bounded steps instead:
    // one to resolve login()'s future and start the loading state, one for
    // pushAndRemoveUntil's page transition, then several zero-duration
    // pumps to drain the chained async calls MyApp's re-resolve and
    // DashboardScreen.initState() both kick off (isLoggedIn, pet/mascot/
    // onboarding signals, portfolio loadAll, companion greeting).
    await tester
        .pump(); // login() resolves, loading state, pushAndRemoveUntil starts
    await tester.pump(const Duration(milliseconds: 300)); // page transition
    for (var i = 0; i < 6; i++) {
      await tester.pump();
    }

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets(
    'registration reaches the learn-first onboarding before any asset entry',
    (tester) async {
      // This account has already completed the earlier onboarding steps
      // (pet, goal and tutorial). Its first post-registration route must be
      // the learn-first guidance, rather than a forced asset-entry screen.
      when(
        () => mockOnboardingStateRepository.isPortfolioStepDone(),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(const MyApp());
      await tester.pump();
      await tester.pump();

      // Login/signup is now an inline Entrar/Criar conta toggle (no modal) —
      // switch to the signup side by its label.
      final signupToggle = find.text(Translator.translate(AppStrings.createAccount));
      await tester.ensureVisible(signupToggle);
      await tester.tap(signupToggle);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(SignupForm), findsOneWidget);

      final fields = find.descendant(
        of: find.byType(SignupForm),
        matching: find.byType(TextField),
      );
      expect(fields, findsNWidgets(4));
      await tester.enterText(fields.at(0), 'Novo Investidor');
      await tester.enterText(fields.at(1), 'novo.investidor@test.com');
      await tester.enterText(fields.at(2), 'Str0ngPass1');
      await tester.enterText(fields.at(3), 'Str0ngPass1');
      await tester.pump();

      final signupAction = find.byType(SignupActionButton);
      await tester.ensureVisible(signupAction);
      await tester.tap(signupAction);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      for (var i = 0; i < 6; i++) {
        await tester.pump();
      }

      expect(find.byType(PortfolioChoiceScreen), findsOneWidget);
      expect(find.byType(DashboardScreen), findsNothing);
      expect(
        find.text(
          Translator.translate(AppStrings.portfolioGuidanceContinueButton),
        ),
        findsOneWidget,
      );
      expect(
        find.text(Translator.translate(AppStrings.addManuallyButton)),
        findsNothing,
      );
      expect(
        find.text(Translator.translate(AppStrings.importPortfolioButton)),
        findsNothing,
      );

      // Continue the learn-first onboarding without ever asking the user to
      // register an asset — the portfolio stays optional and unconnected.
      await tester.tap(
        find.text(
          Translator.translate(AppStrings.portfolioGuidanceContinueButton),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      for (var i = 0; i < 6; i++) {
        await tester.pump();
      }

      verify(
        () => mockOnboardingStateRepository.markPortfolioSkipped(),
      ).called(1);
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(PortfolioChoiceScreen), findsNothing);

      // Switch to the Academy tab and let AcademyController's catalog load
      // (loadCached, then fetchAndCache) drain.
      await tester.tap(
        find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.byIcon(Icons.school_outlined),
        ),
      );
      for (var i = 0; i < 6; i++) {
        await tester.pump();
      }

      expect(find.byType(AcademyHomeScreen), findsOneWidget);

      // Drill into the one domain in the fake catalog to reach its schools —
      // AcademyHomeScreen itself lists domains, not schools directly.
      await tester.ensureVisible(find.byType(AcademyDomainCard).first);
      await tester.pump();
      await tester.tap(find.byType(AcademyDomainCard).first);
      await tester.pump(); // HapticFeedback + Navigator.push starts
      await tester.pump(
        const Duration(milliseconds: 300),
      ); // fade/slide page transition
      for (var i = 0; i < 6; i++) {
        await tester.pump();
      }

      expect(find.byType(AcademyDomainDetailScreen), findsOneWidget);
      expect(find.byType(SchoolCard), findsWidgets);
    },
  );

  testWidgets('mentor displays the suggestions returned by the backend', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump();

    final fields = find.descendant(
      of: find.byType(CustomTextField),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.first, 'investor@test.com');
    await tester.enterText(fields.last, 'Str0ngPass1');
    await tester.tap(find.byType(LoginButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    for (var i = 0; i < 6; i++) {
      await tester.pump();
    }

    await tester.tap(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.byIcon(Icons.auto_awesome_outlined),
      ),
    );
    for (var i = 0; i < 6; i++) {
      await tester.pump();
    }

    expect(find.byType(MentorScreen), findsOneWidget);
    expect(
      find.text('Como montar minha reserva de emergência?'),
      findsOneWidget,
    );
    expect(
      find.text('Qual a diferença entre ETF e fundo imobiliário?'),
      findsOneWidget,
    );
    expect(find.text('Como funciona a diversificação?'), findsOneWidget);
    expect(find.text('O que devo estudar antes de investir?'), findsOneWidget);
    expect(find.text('Como analisar minha carteira?'), findsOneWidget);
    verify(() => mockMentorChatRepository.loadSuggestedPrompts()).called(1);
  });

  testWidgets('finishing a module opens its social-share celebration', (
    tester,
  ) async {
    // Simulate a learner who already completed the first two lessons and is
    // now completing the module's final lesson through the real lesson UI.
    await DI.academyProgressRepository.markLessonCompleted(testLesson1.id);
    await DI.academyProgressRepository.markLessonCompleted(testLesson2.id);

    final mascotController = MascotController(repository: mockMascotRepository);
    await mascotController.loadProfile();
    addTearDown(mascotController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: LessonScreen(
          lesson: testLesson3,
          catalog: buildAcademyCatalogSnapshot(),
          mascotController: mascotController,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byType(GameButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.byType(ModuleCompletionShareOverlay), findsOneWidget);
    expect(find.text('Módulo concluído!'), findsOneWidget);
    expect(find.text(testModule.title), findsOneWidget);
    expect(find.text('Compartilhar'), findsOneWidget);
    expect(mascotController.profile.xp, 60);

    // Completion starts the mascot's four-second victory animation; drain
    // its delayed reset so this integration test leaves no pending timer.
    await tester.pump(const Duration(seconds: 5));
  });

  test('academy replaces the stale all-blocked catalog with available schools', () async {
    final staleCatalog = {
      'domains': [
        {
          'id': 'financial_education',
          'title': 'Educação Financeira',
          'description': '',
          'iconKey': 'savings_outlined',
          'order': 1,
          'schoolIds': ['financial_life'],
        },
      ],
      'schools': [
        {
          'id': 'financial_life',
          'title': 'Vida Financeira',
          'description': '',
          'iconKey': 'savings_outlined',
          'order': 1,
          'prerequisites': <String>[],
          'contentAvailable': false,
        },
      ],
      'modules': [
        {
          'id': 'money_fundamentals',
          'schoolId': 'financial_life',
          'title': 'Fundamentos do Dinheiro',
          'description': '',
          'iconKey': 'payments_outlined',
          'order': 1,
          'lessonIds': <String>[],
          'prerequisites': <String>[],
          'contentAvailable': true,
        },
      ],
      'lessons': <Map<String, dynamic>>[],
    };
    final currentCatalog = {
      ...staleCatalog,
      'schools': [
        {
          ...staleCatalog['schools']!.single,
          'contentAvailable': true,
        },
      ],
    };

    SharedPreferences.setMockInitialValues({
      'academy_catalog_cache_pt': jsonEncode(staleCatalog),
    });
    final apiClient = MockApiClient();
    when(() => apiClient.get(any())).thenAnswer(
      (_) async => http.Response(jsonEncode(currentCatalog), 200),
    );
    final repository = AcademyCatalogRepository(apiClient: apiClient);

    expect(await repository.loadCached('pt'), isNull);

    final refreshedCatalog = await repository.fetchAndCache('pt');

    expect(refreshedCatalog.schools.single.contentAvailable, isTrue);
    expect((await repository.loadCached('pt'))?.schools.single.contentAvailable, isTrue);
  });
}
