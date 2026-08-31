import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/portfolio_choice_screen.dart';
import 'package:petrimonium/features/onboarding/data/repositories/onboarding_state_repository.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';

class MockMascotRepository extends Mock implements MascotRepository {}

class MockOnboardingStateRepository extends Mock
    implements OnboardingStateRepository {}

void main() {
  late MockMascotRepository mockMascotRepository;
  late MockOnboardingStateRepository mockOnboardingStateRepository;

  setUp(() {
    Translator.currentLanguage = 'pt';
    mockMascotRepository = MockMascotRepository();
    mockOnboardingStateRepository = MockOnboardingStateRepository();
    when(
      () => mockMascotRepository.loadProfile(),
    ).thenAnswer((_) async => PetProfile());
    when(
      () => mockOnboardingStateRepository.markPortfolioSkipped(),
    ).thenAnswer((_) async {});
    DI.mascotRepository = mockMascotRepository;
    DI.onboardingStateRepository = mockOnboardingStateRepository;
  });

  group('PortfolioChoiceScreen', () {
    testWidgets('explains the learn-first journey without asking for assets', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark, home: const PortfolioChoiceScreen()),
      );
      // CosmicBackground has an indefinitely-repeating animation — never pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Comece pelo conhecimento.'), findsOneWidget);
      expect(find.text('Aprenda antes de investir'), findsOneWidget);
      expect(
        find.text('Sua carteira entra quando fizer sentido'),
        findsOneWidget,
      );
      expect(find.text('Conte com seu mentor'), findsOneWidget);
      expect(find.text('Começar a aprender'), findsOneWidget);
      expect(find.text('Adicionar Manualmente'), findsNothing);
      expect(find.text('Importar Portfólio'), findsNothing);
    });

    testWidgets(
      'shows the pet-name footnote once the mascot profile loads with a name',
      (WidgetTester tester) async {
        when(
          () => mockMascotRepository.loadProfile(),
        ).thenAnswer((_) async => PetProfile(name: 'Rex'));

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            home: const PortfolioChoiceScreen(),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.textContaining('Rex'), findsOneWidget);
      },
    );

    testWidgets('shows no footnote when the mascot has no name yet', (
      WidgetTester tester,
    ) async {
      when(
        () => mockMascotRepository.loadProfile(),
      ).thenAnswer((_) async => PetProfile(name: null));

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark, home: const PortfolioChoiceScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Sem pressa'), findsNothing);
    });

    testWidgets('continue action resolves the optional portfolio step', (
      WidgetTester tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark, home: const PortfolioChoiceScreen()),
      );
      await tester.pump();

      await tester.tap(find.text('Começar a aprender'));
      verify(
        () => mockOnboardingStateRepository.markPortfolioSkipped(),
      ).called(1);
    });
  });
}
