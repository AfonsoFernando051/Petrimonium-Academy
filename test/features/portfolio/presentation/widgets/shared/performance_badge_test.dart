import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/performance_badge.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: child),
    );
  }

  group('PerformanceBadge', () {
    testWidgets('shows an up arrow and formatted percent for a positive value', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PerformanceBadge(percent: 5.5)));

      expect(find.text('+5.50%'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_up), findsOneWidget);
    });

    testWidgets('shows a down arrow and formatted percent for a negative value', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PerformanceBadge(percent: -3.2)));

      expect(find.text('-3.20%'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });

    testWidgets('treats zero as positive (up arrow)', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PerformanceBadge(percent: 0)));

      expect(find.byIcon(Icons.arrow_drop_up), findsOneWidget);
    });

    testWidgets('renders smaller icon size when compact is true', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PerformanceBadge(percent: 1, compact: true)));

      final icon = tester.widget<Icon>(find.byIcon(Icons.arrow_drop_up));
      expect(icon.size, 14);
    });
  });
}
