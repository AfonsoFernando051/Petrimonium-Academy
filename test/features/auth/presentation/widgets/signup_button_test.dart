import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/auth/presentation/widgets/signup_button.dart';
import 'package:petrimonium/features/auth/presentation/widgets/signup_card.dart';

void main() {
  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: const Scaffold(
        body: SignupButton(),
      ),
    );
  }

  group('SignupButton', () {
    testWidgets('renders the signup prompt text', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      // The prompt is a RichText with two TextSpans ("Não tem conta? " +
      // "Cadastre-se"), not a single Text — find.text() only matches
      // Text/Text.rich widgets, so match on the RichText's plain text
      // instead (every plain Text also renders via its own RichText
      // internally, so byType(RichText) alone would be ambiguous here).
      expect(
        find.byWidgetPredicate(
          (widget) => widget is RichText && widget.text.toPlainText() == 'Não tem conta? Cadastre-se',
        ),
        findsOneWidget,
      );
    });

    testWidgets('opens the SignupCard dialog when tapped', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.tap(find.byType(GestureDetector));
      // Not pumpAndSettle(): the dialog's content (SignupForm) contains a
      // GameButton with pulse:true, whose AnimationController.repeat()
      // never finishes, so pumpAndSettle() would hang forever. Pump past
      // the dialog's own 300ms fade/scale transition instead.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SignupCard), findsOneWidget);
    });
  });
}
