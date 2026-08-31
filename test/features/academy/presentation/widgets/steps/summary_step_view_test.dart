import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';
import 'package:petrimonium/features/academy/presentation/widgets/steps/summary_step_view.dart';

void main() {
  group('SummaryStepView', () {
    testWidgets('renders the step title and every takeaway', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: SummaryStepView(
              step: SummaryStep(title: 'Wrap Up', takeaways: ['First point', 'Second point']),
            ),
          ),
        ),
      );

      expect(find.text('Wrap Up'), findsOneWidget);
      expect(find.text('First point'), findsOneWidget);
      expect(find.text('Second point'), findsOneWidget);
      expect(find.byIcon(Icons.fact_check_outlined), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
    });
  });
}
