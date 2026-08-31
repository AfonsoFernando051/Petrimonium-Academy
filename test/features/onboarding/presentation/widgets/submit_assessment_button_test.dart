import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/submit_assessment_button.dart';

void main() {
  Widget buildTestableWidget({required bool isSubmitting, VoidCallback? onPressed}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: SubmitAssessmentButton(isSubmitting: isSubmitting, onPressed: onPressed),
      ),
    );
  }

  group('SubmitAssessmentButton', () {
    testWidgets('renders the submit label', (tester) async {
      await tester.pumpWidget(buildTestableWidget(isSubmitting: false, onPressed: () {}));
      // GameButton uses pulse:true (repeating AnimationController) — never
      // call pumpAndSettle here, a bounded pump is enough to lay out.
      await tester.pump();

      expect(find.text('Enviar Respostas'), findsOneWidget);
    });

    testWidgets('tapping invokes onPressed when not submitting', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestableWidget(isSubmitting: false, onPressed: () => tapped = true));
      await tester.pump();

      await tester.tap(find.byType(GameButton), warnIfMissed: false);
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows a loading state and is not tappable while submitting', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestableWidget(isSubmitting: true, onPressed: () => tapped = true));
      await tester.pump();

      final button = tester.widget<GameButton>(find.byType(GameButton));
      expect(button.isLoading, isTrue);

      await tester.tap(find.byType(GameButton), warnIfMissed: false);
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('does nothing when onPressed is null', (tester) async {
      await tester.pumpWidget(buildTestableWidget(isSubmitting: false, onPressed: null));
      await tester.pump();

      final button = tester.widget<GameButton>(find.byType(GameButton));
      expect(button.onPressed, isNull);
    });
  });
}
