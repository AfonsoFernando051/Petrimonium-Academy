import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/portfolio_summary_card.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/mini_sparkline.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/performance_badge.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: child),
    );
  }

  group('PortfolioSummaryCard', () {
    testWidgets('renders title and subtitle when no percent is given', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PortfolioSummaryCard(
        title: 'Capital Investido',
        icon: Icons.savings_outlined,
        value: 1000,
        subtitle: '3 ativos',
      )));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Capital Investido'), findsOneWidget);
      expect(find.text('3 ativos'), findsOneWidget);
      expect(find.byType(PerformanceBadge), findsNothing);
    });

    testWidgets('renders a PerformanceBadge instead of subtitle when percent is given', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PortfolioSummaryCard(
        title: 'Lucro Total',
        icon: Icons.trending_up,
        value: 200,
        percent: 20,
        subtitle: 'ignored',
      )));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(PerformanceBadge), findsOneWidget);
      expect(find.text('ignored'), findsNothing);
    });

    testWidgets('renders a sparkline only when at least 2 points are given', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PortfolioSummaryCard(
        title: 'Valor Total',
        icon: Icons.account_balance_wallet,
        value: 1200,
        sparkline: [100, 110, 120],
      )));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(MiniSparkline), findsOneWidget);
    });

    testWidgets('does not render a sparkline with fewer than 2 points', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PortfolioSummaryCard(
        title: 'Valor Total',
        icon: Icons.account_balance_wallet,
        value: 1200,
        sparkline: [100],
      )));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(MiniSparkline), findsNothing);
    });

    testWidgets('does not render a sparkline when null', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PortfolioSummaryCard(
        title: 'Valor Total',
        icon: Icons.account_balance_wallet,
        value: 1200,
      )));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(MiniSparkline), findsNothing);
    });
  });
}
