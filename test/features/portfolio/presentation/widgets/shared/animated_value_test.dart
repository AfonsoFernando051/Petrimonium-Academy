import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/animated_value.dart';

void main() {
  Widget buildTestableWidget(double value) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: AnimatedValue(
          value: value,
          builder: (context, animatedValue) => Text(animatedValue.toStringAsFixed(2)),
        ),
      ),
    );
  }

  group('AnimatedValue', () {
    testWidgets('animates from 0 towards the target value and settles on it', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(100));

      // Immediately after the first frame the tween has just started.
      await tester.pump();
      expect(find.text('100.00'), findsNothing);

      // Let the animation fully complete.
      await tester.pumpAndSettle();
      expect(find.text('100.00'), findsOneWidget);
    });

    testWidgets('re-animates towards a new value when value changes', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(50));
      await tester.pumpAndSettle();
      expect(find.text('50.00'), findsOneWidget);

      await tester.pumpWidget(buildTestableWidget(200));
      await tester.pumpAndSettle();
      expect(find.text('200.00'), findsOneWidget);
    });
  });
}
