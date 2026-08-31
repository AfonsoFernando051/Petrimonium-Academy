import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/investment/presentation/widgets/ticker_suggestion_tile.dart';

void main() {
  Widget buildTestableWidget({
    required String symbol,
    required String name,
    double? price,
    required VoidCallback onTap,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: TickerSuggestionTile(symbol: symbol, name: name, price: price, onTap: onTap)),
    );
  }

  group('TickerSuggestionTile', () {
    testWidgets('renders uppercased symbol, name, formatted price and 2-letter avatar initials', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(symbol: 'petr4', name: 'Petrobras', price: 32.5, onTap: () {}));
      await tester.pump();

      expect(find.text('PETR4'), findsOneWidget);
      expect(find.text('Petrobras'), findsOneWidget);
      expect(find.text('PE'), findsOneWidget); // avatar initials
      expect(find.textContaining('R\$'), findsOneWidget);
    });

    testWidgets('omits the price text when price is null', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(symbol: 'petr4', name: 'Petrobras', price: null, onTap: () {}));
      await tester.pump();

      expect(find.textContaining('R\$'), findsNothing);
    });

    testWidgets('omits the name line when name is empty', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(symbol: 'petr4', name: '', price: null, onTap: () {}));
      await tester.pump();

      expect(find.text('PETR4'), findsOneWidget);
      expect(find.text(''), findsNothing);
    });

    testWidgets('fires onTap when tapped', (WidgetTester tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestableWidget(symbol: 'petr4', name: 'Petrobras', price: 32.5, onTap: () => tapped = true));
      await tester.pump();

      await tester.tap(find.byType(TickerSuggestionTile));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('uses the full symbol as initials when the symbol is a single character', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(symbol: 'x', name: 'X Corp', price: 1, onTap: () {}));
      await tester.pump();

      expect(find.text('X'), findsWidgets); // avatar initials + uppercased symbol line
    });
  });
}
