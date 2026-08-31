import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/onboarding/data/models/question_model.dart';
import 'package:petrimonium/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/onboarding_form.dart';

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

void main() {
  late MockOnboardingRepository mockOnboardingRepository;

  setUp(() {
    Translator.currentLanguage = 'pt';
    mockOnboardingRepository = MockOnboardingRepository();
    DI.onboardingRepository = mockOnboardingRepository;
    when(() => mockOnboardingRepository.getQuestions()).thenAnswer((_) async => const <QuestionModel>[]);
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: const OnboardingScreen(),
    );
  }

  group('OnboardingScreen', () {
    testWidgets('renders the app bar title and embeds OnboardingForm', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      // Hosts CosmicBackground (repeating AnimationControllers) — never
      // call pumpAndSettle.
      await tester.pump();
      await tester.pump();

      expect(find.text('Perfil de Risco'), findsOneWidget);
      // Disambiguates this risk-tolerance questionnaire from the 7-step
      // wizard's FinancialGoalScreen, which used to read as "the same step
      // answered twice".
      expect(find.textContaining('Diferente do seu objetivo financeiro'), findsOneWidget);
      expect(find.byType(OnboardingForm), findsOneWidget);
    });

    testWidgets('the back button pops the screen when there is somewhere to go back to', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(OnboardingScreen), findsOneWidget);

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(OnboardingScreen), findsNothing);
    });
  });
}
