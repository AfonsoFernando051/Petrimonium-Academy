import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:petrimonium/features/auth/presentation/widgets/forgot_password_button.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: const Scaffold(
        body: ForgotPasswordButton(),
      ),
    );
  }

  group('ForgotPasswordButton', () {
    testWidgets('renders the translated label', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Esqueceu a senha?'), findsOneWidget);
    });

    testWidgets('navigates to ForgotPasswordScreen when tapped', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.tap(find.byType(GestureDetector));
      // Not pumpAndSettle(): ForgotPasswordScreen renders a CosmicBackground
      // whose drift/twinkle AnimationControllers repeat indefinitely, so
      // pumpAndSettle() would hang forever. Pump past the page route's own
      // transition instead.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    });
  });
}
