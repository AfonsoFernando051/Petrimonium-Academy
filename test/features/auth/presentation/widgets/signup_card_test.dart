import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/features/auth/data/repositories/auth_repository.dart';
import 'package:petrimonium/features/auth/presentation/widgets/signup_card.dart';
import 'package:petrimonium/features/auth/presentation/widgets/custom_text_field.dart';
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
      home: const Scaffold(
        body: SignupCard(),
      ),
    );
  }

  group('SignupCard', () {
    testWidgets('renders all fields and attempts registration on tap', (WidgetTester tester) async {
      when(() => mockAuthRepository.register(any(), any(), any())).thenAnswer((_) async {});
      when(() => mockAuthRepository.login(any(), any())).thenAnswer((_) async {});
      
      await tester.pumpWidget(buildTestableWidget());

      // Fields: Name, Email, Password, Confirm Password
      expect(find.byType(CustomTextField), findsNWidgets(4));

      // `CustomTextField` wraps a `TextField`, so we target the underlying `TextField`s in order.
      final textFields = find.descendant(
        of: find.byType(CustomTextField),
        matching: find.byType(TextField),
      );

      final nameField = textFields.at(0);
      final emailField = textFields.at(1);
      final passwordField = textFields.at(2);
      final confirmPasswordField = textFields.at(3);

      // Fill in the form
      await tester.enterText(nameField, 'Test User');
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'Str0ngPass1');
      await tester.enterText(confirmPasswordField, 'Str0ngPass1');
      await tester.pump();

      // Tap the signup button — a `GameButton` (premium gradient/glow CTA)
      // since the plain `ElevatedButton` it used to wrap was retired in
      // favor of the shared button component used across the app.
      // The live password-requirements checklist below the password field
      // pushes it past the fold once a password is entered, so scroll it
      // into view first — same as a real user would on a small screen.
      final signupBtn = find.byType(GameButton).first;
      await tester.ensureVisible(signupBtn);
      await tester.pump();
      await tester.tap(signupBtn);
      
      await tester.pump(); // UI updates with loading state
      await tester.pump(); // UI updates with success snackbar

      verify(() => mockAuthRepository.register('Test User', 'test@example.com', 'Str0ngPass1')).called(1);
    });
  });
}
