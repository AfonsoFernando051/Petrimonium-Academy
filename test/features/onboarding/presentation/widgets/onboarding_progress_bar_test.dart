import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/onboarding_progress_bar.dart';

void main() {
  Widget buildTestable(int step, int total) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: OnboardingProgressBar(step: step, total: total)),
    );
  }

  group('OnboardingProgressBar', () {
    testWidgets('renders the step/total fraction label', (tester) async {
      await tester.pumpWidget(buildTestable(3, 9));
      await tester.pump();

      expect(find.text('3/9'), findsOneWidget);
    });

    testWidgets('fills the track proportionally to step/total', (tester) async {
      await tester.pumpWidget(buildTestable(3, 9));
      await tester.pump();

      final fill = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      expect(fill.widthFactor, closeTo(3 / 9, 0.001));
    });
  });
}
