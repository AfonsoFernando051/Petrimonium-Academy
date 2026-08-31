import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/investment/presentation/screens/investment_configuration_screen.dart';
import 'package:petrimonium/features/onboarding/data/repositories/onboarding_state_repository.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/portfolio_activation_view.dart';

/// Minimal in-memory [MascotRepository] double — mirrors the fake used by
/// `portfolio_screen_test.dart`; a fresh default profile is all these tests
/// need to drive `PetRiveCompanion`'s controller.
class FakeMascotRepository implements MascotRepository {
  @override
  Future<PetProfile> loadProfile() async => PetProfile();

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
  Future<void> saveEquippedAccessories(
    Map<AccessoryType, PetAccessoryId> equipped,
  ) async {}

  @override
  Future<void> saveUnlockedAccessories(Set<PetAccessoryId> unlocked) async {}

  @override
  Future<void> saveLastActiveAt(DateTime lastActiveAt) async {}
}

class MockOnboardingStateRepository extends Mock
    implements OnboardingStateRepository {}

void main() {
  late MascotController mascotController;
  late MockOnboardingStateRepository mockOnboardingStateRepository;
  late bool academyTabOpened;

  setUp(() {
    Translator.currentLanguage = 'pt';
    mascotController = MascotController(repository: FakeMascotRepository());
    mockOnboardingStateRepository = MockOnboardingStateRepository();
    when(
      () => mockOnboardingStateRepository.markPortfolioActivationSeen(),
    ).thenAnswer((_) async {});
    DI.onboardingStateRepository = mockOnboardingStateRepository;
    academyTabOpened = false;
  });

  tearDown(() {
    mascotController.dispose();
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: PortfolioActivationView(
          mascotController: mascotController,
          onOpenAcademyTab: () => academyTabOpened = true,
        ),
      ),
    );
  }

  group('PortfolioActivationView — first-time visit', () {
    setUp(() {
      when(
        () => mockOnboardingStateRepository.hasSeenPortfolioActivation(),
      ).thenAnswer((_) async => false);
    });

    testWidgets('shows the intro and marks activation seen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Sua carteira começa aqui.'), findsOneWidget);
      expect(find.text('Vamos começar'), findsOneWidget);
      verify(
        () => mockOnboardingStateRepository.markPortfolioActivationSeen(),
      ).called(1);
    });

    testWidgets('"Vamos começar" advances to the investor-status question', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Vamos começar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Você já investe?'), findsOneWidget);
      expect(find.text('Sim, já invisto'), findsOneWidget);
      expect(find.text('Ainda não'), findsOneWidget);
    });

    testWidgets(
      '"Sim, já invisto" leads to the add-first-asset step with Import marked unavailable',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestableWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(find.text('Vamos começar'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await tester.tap(find.text('Sim, já invisto'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(
          find.text('Vamos adicionar seu primeiro investimento.'),
          findsOneWidget,
        );
        expect(find.text('Adicionar meu primeiro ativo'), findsOneWidget);
        expect(find.text('EM BREVE'), findsOneWidget);

        // InvestmentConfigurationScreen embeds an ambient pet animation with an
        // indefinitely-repeating animation controller — never pumpAndSettle.
        await tester.tap(find.text('Adicionar meu primeiro ativo'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(InvestmentConfigurationScreen), findsOneWidget);
      },
    );

    testWidgets(
      '"Ainda não" leads to the learning path and opens Academy without financial pressure copy',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestableWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(find.text('Vamos começar'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await tester.tap(find.text('Ainda não'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(
          find.text('Tudo bem. Você pode começar aprendendo.'),
          findsOneWidget,
        );
        expect(find.textContaining('invista agora'), findsNothing);
        expect(find.textContaining('fique de fora'), findsNothing);

        await tester.tap(find.text('Começar pela Academia'));
        await tester.pump();

        expect(academyTabOpened, isTrue);
      },
    );
  });

  group('PortfolioActivationView — returning visit', () {
    setUp(() {
      when(
        () => mockOnboardingStateRepository.hasSeenPortfolioActivation(),
      ).thenAnswer((_) async => true);
    });

    testWidgets('skips straight to the compact nudge, not the full intro', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Sua carteira começa aqui.'), findsNothing);
      expect(find.text('Você já investe?'), findsNothing);
      expect(
        find.text(
          'Ainda não adicionou seu primeiro investimento. Quando estiver pronto, podemos começar.',
        ),
        findsOneWidget,
      );
      expect(find.text('Adicionar ativo'), findsOneWidget);
      expect(find.text('Ir para Academia'), findsOneWidget);
      verifyNever(
        () => mockOnboardingStateRepository.markPortfolioActivationSeen(),
      );
    });

    testWidgets('"Ir para Academia" invokes the tab-switch callback', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Ir para Academia'));
      await tester.pump();

      expect(academyTabOpened, isTrue);
    });
  });
}
