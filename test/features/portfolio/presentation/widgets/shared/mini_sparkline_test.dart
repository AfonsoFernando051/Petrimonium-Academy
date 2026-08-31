import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/mini_sparkline.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: child),
    );
  }

  group('MiniSparkline', () {
    testWidgets('renders a LineChart when given at least two values', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const MiniSparkline(values: [1, 2, 3, 2, 4], color: Colors.green),
      ));

      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('renders an empty sized box when given fewer than two values', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const MiniSparkline(values: [1], color: Colors.green),
      ));

      expect(find.byType(LineChart), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('renders an empty sized box when given no values', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const MiniSparkline(values: [], color: Colors.green),
      ));

      expect(find.byType(LineChart), findsNothing);
    });

    testWidgets('respects the custom height', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const MiniSparkline(values: [1, 5], color: Colors.green, height: 60),
      ));

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(of: find.byType(LineChart), matching: find.byType(SizedBox)).first,
      );
      expect(sizedBox.height, 60);
    });
  });
}
