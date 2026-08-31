import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/widgets/chart_legend.dart';

void main() {
  Widget buildTestableWidget(List<ChartLegendItem> items) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: ChartLegend(items: items)),
    );
  }

  group('ChartLegend', () {
    testWidgets('renders a label for each item', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const [
        ChartLegendItem(color: Colors.red, label: 'Patrimônio'),
        ChartLegendItem(color: Colors.blue, label: 'Investido'),
      ]));

      expect(find.text('Patrimônio'), findsOneWidget);
      expect(find.text('Investido'), findsOneWidget);
    });

    testWidgets('renders one dot Container per item', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const [
        ChartLegendItem(color: Colors.red, label: 'A'),
        ChartLegendItem(color: Colors.blue, label: 'B'),
        ChartLegendItem(color: Colors.green, label: 'C'),
      ]));

      final dots = tester.widgetList<Container>(find.byType(Container));
      final circles = dots.where((c) {
        final decoration = c.decoration;
        return decoration is BoxDecoration && decoration.shape == BoxShape.circle;
      });
      expect(circles.length, 3);
    });

    testWidgets('renders nothing but stays valid with an empty list', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const []));

      expect(find.byType(Text), findsNothing);
    });
  });
}
