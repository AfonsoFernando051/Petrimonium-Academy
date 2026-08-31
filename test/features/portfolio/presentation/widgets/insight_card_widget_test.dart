import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/portfolio/domain/entities/insight.dart';
import 'package:petrimonium/features/portfolio/domain/enums/insight_priority.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/insight_card_widget.dart';

void main() {
  Widget buildTestableWidget(Insight insight) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: InsightCardWidget(insight: insight)),
    );
  }

  group('InsightCardWidget', () {
    testWidgets('renders title, description and icon', (WidgetTester tester) async {
      const insight = Insight(
        title: 'Diversifique',
        description: 'Sua carteira está concentrada.',
        icon: Icons.warning,
        priority: InsightPriority.medium,
        color: Colors.orange,
      );

      await tester.pumpWidget(buildTestableWidget(insight));

      expect(find.text('Diversifique'), findsOneWidget);
      expect(find.text('Sua carteira está concentrada.'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('does not render an action link when actionLabel/onAction are absent', (WidgetTester tester) async {
      const insight = Insight(
        title: 'Diversifique',
        description: 'desc',
        icon: Icons.warning,
        priority: InsightPriority.low,
        color: Colors.orange,
      );

      await tester.pumpWidget(buildTestableWidget(insight));

      expect(find.textContaining('→'), findsNothing);
    });

    testWidgets('renders and fires the action link when provided', (WidgetTester tester) async {
      var tapped = false;
      final insight = Insight(
        title: 'Complete seu perfil',
        description: 'desc',
        icon: Icons.info,
        priority: InsightPriority.medium,
        color: Colors.blue,
        actionLabel: 'Adicionar',
        onAction: () => tapped = true,
      );

      await tester.pumpWidget(buildTestableWidget(insight));

      expect(find.text('Adicionar →'), findsOneWidget);
      await tester.tap(find.text('Adicionar →'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows a priority dot only for high-priority insights', (WidgetTester tester) async {
      const highInsight = Insight(
        title: 'Urgente',
        description: 'desc',
        icon: Icons.warning,
        priority: InsightPriority.high,
        color: Colors.red,
      );
      const lowInsight = Insight(
        title: 'Info',
        description: 'desc',
        icon: Icons.info,
        priority: InsightPriority.low,
        color: Colors.blue,
      );

      await tester.pumpWidget(buildTestableWidget(highInsight));
      // The dot is an unlabeled Container/BoxShape.circle — assert by
      // rendering successfully with the high-priority insight, then compare
      // widget counts against the low-priority case below.
      final highContainerCount = find.byType(Container).evaluate().length;

      await tester.pumpWidget(buildTestableWidget(lowInsight));
      final lowContainerCount = find.byType(Container).evaluate().length;

      expect(highContainerCount, greaterThan(lowContainerCount));
    });
  });
}
