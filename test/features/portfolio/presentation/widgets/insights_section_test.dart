import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/portfolio/domain/entities/insight.dart';
import 'package:petrimonium/features/portfolio/domain/enums/insight_priority.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/insight_card_widget.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/insights_section.dart';

void main() {
  Widget buildTestableWidget(List<Insight> insights) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: InsightsSection(insights: insights)),
    );
  }

  const insight1 = Insight(
    title: 'A',
    description: 'desc a',
    icon: Icons.info,
    priority: InsightPriority.high,
    color: Colors.red,
  );
  const insight2 = Insight(
    title: 'B',
    description: 'desc b',
    icon: Icons.info,
    priority: InsightPriority.low,
    color: Colors.blue,
  );

  group('InsightsSection', () {
    testWidgets('renders a header and one card per insight', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget([insight1, insight2]));

      expect(find.textContaining('INSIGHTS'), findsOneWidget);
      expect(find.byType(InsightCardWidget), findsNWidgets(2));
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('renders nothing (SizedBox.shrink) for an empty insight list', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget([]));

      expect(find.byType(InsightCardWidget), findsNothing);
      expect(find.textContaining('INSIGHTS'), findsNothing);
    });
  });
}
