import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_stacked_bar_chart.dart';

void main() {
  Widget wrap(Widget child) =>
      MaterialApp(theme: AppTheme.dark, home: Scaffold(body: child));

  List<LabStackedBarPoint> points() => const [
    LabStackedBarPoint(xLabel: '0', base: 1000, total: 1000),
    LabStackedBarPoint(xLabel: '1', base: 1200, total: 1300),
    LabStackedBarPoint(xLabel: '2', base: 1400, total: 1700),
  ];

  group('LabStackedBarChart', () {
    testWidgets('renders the legend with both labels', (tester) async {
      await tester.pumpWidget(
        wrap(
          LabStackedBarChart(
            points: points(),
            baseColor: Colors.cyan,
            growthColor: Colors.amber,
            baseLegendLabel: 'Investido',
            growthLegendLabel: 'Rendimento',
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Investido'), findsOneWidget);
      expect(find.text('Rendimento'), findsOneWidget);
    });

    testWidgets('renders nothing chart-wise with fewer than 2 points', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const LabStackedBarChart(
            points: [LabStackedBarPoint(xLabel: '0', base: 1000, total: 1000)],
            baseColor: Colors.cyan,
            growthColor: Colors.amber,
            baseLegendLabel: 'Investido',
            growthLegendLabel: 'Rendimento',
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(BarChart), findsNothing);
    });
  });
}
