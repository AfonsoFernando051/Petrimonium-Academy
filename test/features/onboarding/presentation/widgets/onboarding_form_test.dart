import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/app_loading_indicator.dart';
import 'package:petrimonium/features/onboarding/data/models/option_model.dart';
import 'package:petrimonium/features/onboarding/data/models/question_model.dart';
import 'package:petrimonium/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/onboarding_form.dart';
import 'package:petrimonium/features/pet/domain/repositories/pet_repository.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/pet_configuration_screen.dart';

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

class MockPetRepository extends Mock implements PetRepository {}

const _questions = [
  QuestionModel(
    id: 'q1',
    text: 'Qual seu objetivo principal?',
    options: [
      OptionModel(id: 'q1_a', text: 'Crescer patrimônio'),
      OptionModel(id: 'q1_b', text: 'Renda passiva'),
    ],
  ),
  QuestionModel(
    id: 'q2',
    text: 'Qual seu horizonte de tempo?',
    options: [
      OptionModel(id: 'q2_a', text: 'Curto prazo'),
      OptionModel(id: 'q2_b', text: 'Longo prazo'),
    ],
  ),
];

void main() {
  late MockOnboardingRepository mockOnboardingRepository;
  late MockPetRepository mockPetRepository;

  setUp(() {
    Translator.currentLanguage = 'pt';
    mockOnboardingRepository = MockOnboardingRepository();
    DI.onboardingRepository = mockOnboardingRepository;
    mockPetRepository = MockPetRepository();
    DI.petRepository = mockPetRepository;
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: const Scaffold(body: OnboardingForm()),
    );
  }

  group('OnboardingForm — loading/error/empty states', () {
    testWidgets('shows a loading indicator while questions are being fetched', (tester) async {
      final completer = Completer<List<QuestionModel>>();
      when(() => mockOnboardingRepository.getQuestions()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.byType(AppLoadingIndicator), findsOneWidget);

      // Resolve the pending future so it doesn't leak past the test.
      completer.complete(_questions);
      await tester.pump();
      await tester.pump();
    });

    testWidgets('shows an error message when fetching questions fails', (tester) async {
      when(() => mockOnboardingRepository.getQuestions()).thenAnswer((_) async => throw Exception('network down'));

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Falha ao carregar perguntas'), findsOneWidget);
    });

    testWidgets('shows the "no questions" message when the list is empty', (tester) async {
      when(() => mockOnboardingRepository.getQuestions()).thenAnswer((_) async => const []);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      expect(find.text('Nenhuma pergunta disponível.'), findsOneWidget);
    });
  });

  group('OnboardingForm — answering and submitting', () {
    setUp(() {
      when(() => mockOnboardingRepository.getQuestions()).thenAnswer((_) async => _questions);
    });

    testWidgets('renders one QuestionCard per question and the submit button', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      expect(find.text('Qual seu objetivo principal?'), findsOneWidget);
      expect(find.text('Qual seu horizonte de tempo?'), findsOneWidget);
      expect(find.text('Enviar Respostas'), findsOneWidget);
    });

    testWidgets('shows a validation error and does not submit when a question is unanswered', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      // Answer only the first question.
      await tester.tap(find.text('Crescer patrimônio'));
      await tester.pump();

      await tester.tap(find.text('Enviar Respostas'), warnIfMissed: false);
      await tester.pump();
      await tester.pump();

      expect(find.text('Responda todas as perguntas'), findsOneWidget);
      verifyNever(() => mockOnboardingRepository.submitAssessment(any()));
    });

    testWidgets('submits the selected option ids and navigates to PetConfigurationScreen when the user has no pet', (tester) async {
      when(() => mockOnboardingRepository.submitAssessment(any())).thenAnswer((_) async => 'moderate');
      when(() => mockPetRepository.getPetStatus()).thenAnswer((_) async => false);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Crescer patrimônio'));
      await tester.pump();
      await tester.tap(find.text('Longo prazo'));
      await tester.pump();

      await tester.tap(find.text('Enviar Respostas'), warnIfMissed: false);
      await tester.pump(); // loading state
      await tester.pump(); // submit resolves
      await tester.pump(); // getPetStatus resolves
      await tester.pump(const Duration(milliseconds: 400)); // route transition

      verify(() => mockOnboardingRepository.submitAssessment(['q1_a', 'q2_b'])).called(1);
      expect(find.byType(PetConfigurationScreen), findsOneWidget);
    });

    // Note: the "user already has a pet" branch (pushReplacement to
    // DashboardScreen) is intentionally not exercised here — DashboardScreen
    // wires up several controllers that hit the real network in initState,
    // and letting that build for real in a widget test risks flaky
    // post-test failures from unmocked in-flight requests. The routing
    // conditional itself (`if (!hasPet) ... else ...`) is trivial; the
    // PetConfigurationScreen branch above already exercises the surrounding
    // submit/getPetStatus/navigate logic.

    testWidgets('shows a friendly error snackbar when submission fails', (tester) async {
      when(() => mockOnboardingRepository.submitAssessment(any())).thenThrow(Exception('boom'));

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Crescer patrimônio'));
      await tester.pump();
      await tester.tap(find.text('Longo prazo'));
      await tester.pump();

      await tester.tap(find.text('Enviar Respostas'), warnIfMissed: false);
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Falha ao enviar respostas'), findsOneWidget);
    });
  });
}
