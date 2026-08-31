import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/onboarding_progress_dots.dart';

void main() {
  Widget buildTestableWidget({required int step, required int total}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: OnboardingProgressDots(step: step, total: total),
      ),
    );
  }

  group('OnboardingProgressDots', () {
    testWidgets('renders one dot per total step', (tester) async {
      await tester.pumpWidget(buildTestableWidget(step: 2, total: 5));
      await tester.pump();

      expect(find.byType(AnimatedContainer), findsNWidgets(5));
    });

    testWidgets('the active dot is wider than the inactive ones', (tester) async {
      await tester.pumpWidget(buildTestableWidget(step: 3, total: 4));
      await tester.pump();

      final containers = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .toList();

      expect(containers.length, 4);
      // step is 1-based; index 2 (the 3rd dot) is active.
      for (var i = 0; i < containers.length; i++) {
        final decoration = containers[i].decoration as BoxDecoration;
        if (i == 2) {
          expect(decoration.boxShadow, isNotNull);
        } else {
          expect(decoration.boxShadow, isNull);
        }
      }
    });

    testWidgets('renders with step 1 without throwing', (tester) async {
      await tester.pumpWidget(buildTestableWidget(step: 1, total: 1));
      await tester.pump();

      expect(find.byType(AnimatedContainer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
