import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/auth/data/repositories/auth_repository.dart';
import 'package:petrimonium/features/auth/presentation/widgets/login_card.dart';
import 'package:petrimonium/features/auth/presentation/widgets/login_form.dart';
import 'package:petrimonium/features/auth/presentation/widgets/signup_form.dart';
import 'package:petrimonium/features/onboarding/data/repositories/onboarding_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
    DI.authRepository = MockAuthRepository();
    DI.onboardingRepository = MockOnboardingRepository();
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: const Scaffold(
        body: LoginCard(),
      ),
    );
  }

  group('LoginCard', () {
    testWidgets('renders the fox mascot, brand title and LoginForm by default', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('PETRIMONIUM'), findsOneWidget);
      expect(find.byType(LoginForm), findsOneWidget);
      expect(find.byType(SignupForm), findsNothing);
    });

    testWidgets('switches to SignupForm when Criar conta is tapped', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.tap(find.text('Criar Conta'));
      await tester.pump();

      expect(find.byType(SignupForm), findsOneWidget);
      expect(find.byType(LoginForm), findsNothing);
    });
  });
}
