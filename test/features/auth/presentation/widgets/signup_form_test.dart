import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/auth/data/repositories/auth_repository.dart';
import 'package:petrimonium/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:petrimonium/features/auth/presentation/widgets/google_signin_button.dart';
import 'package:petrimonium/features/auth/presentation/widgets/signup_action_button.dart';
import 'package:petrimonium/features/auth/presentation/widgets/signup_form.dart';
import 'package:petrimonium/features/onboarding/data/models/onboarding_status_model.dart';
import 'package:petrimonium/features/onboarding/data/models/question_model.dart';
import 'package:petrimonium/features/onboarding/data/repositories/onboarding_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockOnboardingRepository mockOnboardingRepository;

  setUp(() {
    Translator.currentLanguage = 'pt';
    mockAuthRepository = MockAuthRepository();
    DI.authRepository = mockAuthRepository;

    mockOnboardingRepository = MockOnboardingRepository();
    DI.onboardingRepository = mockOnboardingRepository;
    when(() => mockOnboardingRepository.getStatus()).thenAnswer(
      (_) async => const OnboardingStatusModel(hasAnswered: false, profile: null),
    );
    when(() => mockOnboardingRepository.getQuestions()).thenAnswer(
      (_) async => <QuestionModel>[],
    );
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: const Scaffold(
        body: SingleChildScrollView(
          child: SignupForm(),
        ),
      ),
    );
  }

  Finder fieldAt(int index) => find
      .descendant(of: find.byType(CustomTextField), matching: find.byType(TextField))
      .at(index);

  group('SignupForm', () {
    testWidgets('renders all four fields and action buttons, no footer link', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.byType(CustomTextField), findsNWidgets(4));
      expect(find.byType(SignupActionButton), findsOneWidget);
      expect(find.byType(GoogleSignInButton), findsOneWidget);
      // The footer login link is gone — SignupForm is now embedded under
      // LoginCard's inline Entrar/Criar conta toggle instead.
      expect(find.text('Já tem conta? Entrar'), findsNothing);
    });

    testWidgets('shows a live name error once at least one char is typed but under minimum', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.enterText(fieldAt(0), 'ab');
      await tester.pump();

      expect(find.text('Mínimo de 3 caracteres.'), findsOneWidget);
    });

    testWidgets('shows a live email error for an invalid email', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.enterText(fieldAt(1), 'not-an-email');
      await tester.pump();

      expect(find.text('Digite um e-mail válido.'), findsOneWidget);
    });

    testWidgets('shows password requirements checklist once password is non-empty', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Mínimo de 8 caracteres'), findsNothing);

      await tester.enterText(fieldAt(2), 'abc');
      await tester.pump();

      expect(find.text('Mínimo de 8 caracteres'), findsOneWidget);
      expect(find.text('Uma letra maiúscula'), findsOneWidget);
      expect(find.text('Uma letra minúscula'), findsOneWidget);
      expect(find.text('Um número'), findsOneWidget);
    });

    testWidgets('shows a live mismatch error when confirm password differs', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.enterText(fieldAt(2), 'Str0ngPass1');
      await tester.enterText(fieldAt(3), 'different');
      await tester.pump();

      expect(find.text('As senhas não coincidem.'), findsOneWidget);
    });

    testWidgets('shows snackbar and does not register when fields are empty', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.tap(find.byType(SignupActionButton));
      await tester.pump();
      await tester.pump();

      expect(find.text('Preencha todos os campos obrigatórios.'), findsOneWidget);
      verifyNever(() => mockAuthRepository.register(any(), any(), any()));
    });

    testWidgets('registers, logs in, and navigates on success with valid data', (tester) async {
      when(() => mockAuthRepository.register(any(), any(), any())).thenAnswer((_) async {});
      when(() => mockAuthRepository.login(any(), any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestableWidget());

      await tester.enterText(fieldAt(0), 'Test User');
      await tester.enterText(fieldAt(1), 'test@example.com');
      await tester.enterText(fieldAt(2), 'Str0ngPass1');
      await tester.enterText(fieldAt(3), 'Str0ngPass1');
      await tester.pump();

      final signupBtn = find.byType(SignupActionButton);
      await tester.ensureVisible(signupBtn);
      await tester.pump();
      await tester.tap(signupBtn);
      await tester.pump(); // loading
      await tester.pump(); // settle

      verify(() => mockAuthRepository.register('Test User', 'test@example.com', 'Str0ngPass1')).called(1);
      verify(() => mockAuthRepository.login('test@example.com', 'Str0ngPass1')).called(1);
    });

    testWidgets('shows friendly error snackbar when register throws', (tester) async {
      when(() => mockAuthRepository.register(any(), any(), any())).thenThrow(Exception('email taken'));

      await tester.pumpWidget(buildTestableWidget());

      await tester.enterText(fieldAt(0), 'Test User');
      await tester.enterText(fieldAt(1), 'test@example.com');
      await tester.enterText(fieldAt(2), 'Str0ngPass1');
      await tester.enterText(fieldAt(3), 'Str0ngPass1');
      await tester.pump();

      final signupBtn = find.byType(SignupActionButton);
      await tester.ensureVisible(signupBtn);
      await tester.pump();
      await tester.tap(signupBtn);
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Cadastro falhou'), findsOneWidget);
    });
  });
}
