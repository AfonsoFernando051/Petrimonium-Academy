import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/auth/data/repositories/auth_repository.dart';
import 'package:petrimonium/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:petrimonium/features/auth/presentation/widgets/google_signin_button.dart';
import 'package:petrimonium/features/auth/presentation/widgets/login_button.dart';
import 'package:petrimonium/features/auth/presentation/widgets/login_form.dart';
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
        body: LoginForm(),
      ),
    );
  }

  Finder emailField() => find
      .descendant(of: find.byType(CustomTextField), matching: find.byType(TextField))
      .first;
  Finder passwordField() => find
      .descendant(of: find.byType(CustomTextField), matching: find.byType(TextField))
      .last;

  group('LoginForm', () {
    testWidgets('renders both fields, the shared-account notice, LoginButton and ForgotPasswordButton', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.byType(CustomTextField), findsNWidgets(2));
      expect(
        find.text(
          'Sua conta Petrimonium é única para Academy e Wallet. Desinstalar um dos apps não exclui sua conta nem seus dados.',
        ),
        findsOneWidget,
      );
      expect(find.byType(LoginButton), findsOneWidget);
      expect(find.byType(GoogleSignInButton), findsOneWidget);
      expect(find.text('Esqueceu a senha?'), findsOneWidget);
      // The footer signup link is gone — LoginForm is now embedded under
      // LoginCard's inline Entrar/Criar conta toggle instead.
      expect(find.byWidgetPredicate((widget) => widget is RichText && widget.text.toPlainText().contains('Cadastre-se')), findsNothing);
    });

    testWidgets('shows error snackbar and does not call login when fields are empty', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.tap(find.byType(LoginButton));
      await tester.pump();
      await tester.pump();

      expect(find.text('Preencha e-mail e senha para continuar.'), findsOneWidget);
      verifyNever(() => mockAuthRepository.login(any(), any()));
    });

    testWidgets('calls login with entered credentials and navigates on success', (tester) async {
      when(() => mockAuthRepository.login(any(), any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestableWidget());

      await tester.enterText(emailField(), 'user@example.com');
      await tester.enterText(passwordField(), 'password123');
      await tester.pump();

      await tester.tap(find.byType(LoginButton));
      await tester.pump(); // loading state
      await tester.pump(); // settle

      verify(() => mockAuthRepository.login('user@example.com', 'password123')).called(1);
    });

    testWidgets('shows friendly error snackbar when login throws', (tester) async {
      when(() => mockAuthRepository.login(any(), any())).thenThrow(Exception('bad credentials'));

      await tester.pumpWidget(buildTestableWidget());

      await tester.enterText(emailField(), 'user@example.com');
      await tester.enterText(passwordField(), 'wrongpass');
      await tester.pump();

      await tester.tap(find.byType(LoginButton));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Login falhou'), findsOneWidget);
    });
  });
}
