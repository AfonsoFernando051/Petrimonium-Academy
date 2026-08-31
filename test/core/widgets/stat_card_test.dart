import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/widgets/stat_card.dart';

void main() {
  Widget wrap(Widget child) =>
      MaterialApp(theme: AppTheme.dark, home: Scaffold(body: child));

  group('StatCard', () {
    testWidgets('renders the label and value', (tester) async {
      await tester.pumpWidget(
        wrap(
          const StatCard(
            label: 'Valor final',
            value: 'R\$ 15.2K',
            accent: Colors.cyan,
          ),
        ),
      );

      expect(find.text('Valor final'), findsOneWidget);
      expect(find.text('R\$ 15.2K'), findsOneWidget);
    });

    testWidgets('applies the accent color to the value text', (tester) async {
      await tester.pumpWidget(
        wrap(
          const StatCard(
            label: 'Total investido',
            value: 'R\$ 1.0K',
            accent: Colors.amber,
          ),
        ),
      );

      final valueText = tester.widget<Text>(find.text('R\$ 1.0K'));
      expect(valueText.style?.color, Colors.amber);
    });
  });
}
