import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/features/auth/data/repositories/auth_repository.dart';
import 'package:petrimonium/features/onboarding/data/models/onboarding_status_model.dart';
import 'package:petrimonium/features/onboarding/data/models/question_model.dart';
import 'package:petrimonium/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:petrimonium/features/auth/presentation/screens/login_screen.dart';
import 'package:petrimonium/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:petrimonium/features/auth/presentation/widgets/login_background.dart';
import 'package:petrimonium/features/auth/presentation/widgets/login_button.dart';
import 'package:petrimonium/features/auth/presentation/widgets/login_card.dart';

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
      (_) async => const OnboardingStatusModel(
        hasAnswered: false,
        profile: null,
      ),
    );

    when(() => mockOnboardingRepository.getQuestions()).thenAnswer(
      (_) async => <QuestionModel>[],
    );
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: const LoginScreen(),
    );
  }

  group('LoginScreen', () {
    testWidgets('renders perfectly with all child components', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.byType(LoginCard), findsOneWidget);
      expect(find.byType(LoginBackground), findsOneWidget);
      expect(find.byType(CustomTextField), findsNWidgets(2));
      expect(find.byType(LoginButton), findsOneWidget);

      expect(find.text('PETRIMONIUM'), findsOneWidget);
      expect(find.text('E-mail ou Usuário'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Entrar'), findsWidgets);
    });

    testWidgets('updates UI text when Translator language changes', (WidgetTester tester) async {
      Translator.currentLanguage = 'en';
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Email or Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsWidgets);

      expect(find.text('E-mail ou Usuário'), findsNothing);
    });

    testWidgets('TextFields accept text input properly and attempt login', (WidgetTester tester) async {
      when(() => mockAuthRepository.login(any(), any())).thenAnswer((_) async {});
      
      await tester.pumpWidget(buildTestableWidget());

      final emailField = find.descendant(
        of: find.byType(CustomTextField),
        matching: find.byType(TextField),
      ).first;
      
      final passwordField = find.descendant(
        of: find.byType(CustomTextField),
        matching: find.byType(TextField),
      ).last;

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);

      final loginBtn = find.byType(LoginButton);
      await tester.tap(loginBtn);
      await tester.pump(); // Start loading
      await tester.pump(); // Finish loading

      verify(() => mockAuthRepository.login('test@example.com', 'password123')).called(1);
    });
  });
}
