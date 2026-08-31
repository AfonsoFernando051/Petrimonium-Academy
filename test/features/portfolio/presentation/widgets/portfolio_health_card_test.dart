import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_health.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/portfolio_health_card.dart';

void main() {
  Widget buildTestableWidget(PortfolioHealth health) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: PortfolioHealthCard(health: health)),
    );
  }

  group('PortfolioHealthCard', () {
    testWidgets('shows an empty-state message and no radar/bars when there are no metrics', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(PortfolioHealth.empty));
      await tester.pump();

      expect(find.text('SAÚDE DO PORTFÓLIO'), findsOneWidget);
      expect(find.textContaining('Invista em ao menos um ativo'), findsOneWidget);
      expect(find.text('D'), findsOneWidget); // grade for score 0
    });

    testWidgets('renders the score badge grade and each metric name/score', (WidgetTester tester) async {
      // fl_chart's RadarChart requires >= 3 entries (see
      // PortfolioHealthCalculator, which always emits 6 in production), so
      // this uses 3 metrics to match a realistic call site.
      const health = PortfolioHealth(
        overallScore: 82,
        metrics: [
          HealthMetric(name: 'Diversificação', score: 90, icon: Icons.hub),
          HealthMetric(name: 'Liquidez', score: 60, icon: Icons.water_drop),
          HealthMetric(name: 'Risco', score: 70, icon: Icons.warning),
        ],
      );

      await tester.pumpWidget(buildTestableWidget(health));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800)); // let the TweenAnimationBuilder bars settle

      expect(find.text('A'), findsOneWidget); // grade for score 82
      expect(find.text('82'), findsOneWidget);
      expect(find.text('Diversificação'), findsOneWidget);
      expect(find.text('Liquidez'), findsOneWidget);
      expect(find.text('90'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
    });

    testWidgets('truncates a metric name longer than 10 characters with an ellipsis in the radar title', (WidgetTester tester) async {
      const health = PortfolioHealth(
        overallScore: 50,
        metrics: [
          HealthMetric(name: 'Concentração de Ativos', score: 50, icon: Icons.pie_chart),
          HealthMetric(name: 'Liquidez', score: 50, icon: Icons.water_drop),
          HealthMetric(name: 'Risco', score: 50, icon: Icons.warning),
        ],
      );

      await tester.pumpWidget(buildTestableWidget(health));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      // The full name is still shown in the per-facet bar row.
      expect(find.text('Concentração de Ativos'), findsOneWidget);
    });
  });
}
