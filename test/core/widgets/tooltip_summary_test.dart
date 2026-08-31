import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/widgets/tooltip_summary.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(theme: AppTheme.dark, home: Scaffold(body: child));

  group('TooltipSummary', () {
    testWidgets('renders its children in a Row', (tester) async {
      await tester.pumpWidget(wrap(const TooltipSummary(
        accentColor: Colors.cyan,
        children: [Text('Left'), Text('Right')],
      )));

      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('applies the accent color to the container border', (tester) async {
      await tester.pumpWidget(wrap(const TooltipSummary(
        accentColor: Colors.cyan,
        children: [Text('A')],
      )));

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });
  });
}
