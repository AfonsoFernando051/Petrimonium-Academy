import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/auth/data/repositories/auth_repository.dart';
import 'package:petrimonium/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:petrimonium/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:petrimonium/features/auth/presentation/widgets/custom_text_field.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    Translator.currentLanguage = 'pt';
    mockAuthRepository = MockAuthRepository();
    DI.authRepository = mockAuthRepository;
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: const ForgotPasswordScreen(),
    );
  }

  group('ForgotPasswordScreen', () {
    testWidgets('renders title, subtitle, email field, and send button', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Recuperar senha'), findsOneWidget);
      expect(
        find.text('Digite seu e-mail e enviaremos um link para redefinir sua senha.'),
        findsOneWidget,
      );
      expect(find.byType(CustomTextField), findsOneWidget);
      expect(find.text('Enviar link'), findsOneWidget);
      expect(find.text('Já tenho um código de redefinição'), findsOneWidget);
    });

    testWidgets('does not submit when email is empty', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.tap(find.text('Enviar link'));
      await tester.pump();

      verifyNever(() => mockAuthRepository.requestPasswordReset(any()));
      expect(find.text('Enviar link'), findsOneWidget);
    });

    testWidgets('submits email and shows confirmation message on success', (tester) async {
      when(() => mockAuthRepository.requestPasswordReset(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestableWidget());

      await tester.enterText(find.byType(TextField), 'user@example.com');
      await tester.tap(find.text('Enviar link'));
      await tester.pump(); // loading
      await tester.pump(); // settle

      verify(() => mockAuthRepository.requestPasswordReset('user@example.com')).called(1);
      expect(
        find.text('Se existir uma conta com esse e-mail, você receberá instruções em instantes.'),
        findsOneWidget,
      );
      expect(find.byType(CustomTextField), findsNothing);
    });

    testWidgets('shows friendly error snackbar when request fails', (tester) async {
      when(() => mockAuthRepository.requestPasswordReset(any())).thenThrow(Exception('server down'));

      await tester.pumpWidget(buildTestableWidget());

      await tester.enterText(find.byType(TextField), 'user@example.com');
      await tester.tap(find.text('Enviar link'));
      await tester.pump();
      await tester.pump();

      expect(find.text('server down'), findsOneWidget);
    });

    testWidgets('navigates to ResetPasswordScreen via the code link', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.tap(find.text('Já tenho um código de redefinição'));
      // Not pumpAndSettle(): both screens render a CosmicBackground whose
      // drift/twinkle AnimationControllers repeat indefinitely.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ResetPasswordScreen), findsOneWidget);
    });

    testWidgets('back button pops the screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

      // Not pumpAndSettle() anywhere here: ForgotPasswordScreen's
      // CosmicBackground repeats its drift/twinkle animations forever.
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();
      // A touch over the 300ms default MaterialPageRoute transition, plus a
      // trailing zero-duration pump, so the pop animation fully completes
      // and the route is actually removed (landing exactly on the boundary
      // can leave it one frame short of that).
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      expect(find.byType(ForgotPasswordScreen), findsNothing);
    });
  });
}
