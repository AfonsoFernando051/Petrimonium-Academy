import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_indicator.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/indicator_education_sheet.dart';

void main() {
  Widget buildTestableWidget(AssetIndicator indicator) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: IndicatorEducationSheet(indicator: indicator)),
    );
  }

  group('IndicatorEducationSheet', () {
    testWidgets('renders the indicator label/value header and the three-part explanation for a known indicator', (WidgetTester tester) async {
      const indicator = AssetIndicator(id: 'pe', label: 'P/L', value: '5.20', rawValue: 5.2, unit: 'x');

      await tester.pumpWidget(buildTestableWidget(indicator));
      await tester.pump();

      expect(find.text('P/L'), findsOneWidget);
      expect(find.text('5.20'), findsOneWidget);
      expect(find.text('O que é P/L (Preço/Lucro)?'), findsOneWidget);

      // The sheet only fills 55% of the screen initially — scroll its
      // internal ListView to reach content further down.
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pump();

      expect(find.text('Por que importa?'), findsOneWidget);
      expect(find.text('Importante'), findsOneWidget);
      expect(find.byIcon(Icons.school_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    });

    testWidgets('shows the pet dialogue when the explanation has one', (WidgetTester tester) async {
      const indicator = AssetIndicator(id: 'pe', label: 'P/L', value: '5.20');

      await tester.pumpWidget(buildTestableWidget(indicator));
      await tester.pump();
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pump();

      expect(find.byIcon(Icons.pets), findsOneWidget);
      expect(find.textContaining('Vamos entender o P/L!'), findsOneWidget);
    });

    testWidgets('shows a "coming soon" fallback for an indicator with no catalog explanation', (WidgetTester tester) async {
      const indicator = AssetIndicator(id: 'unknown_indicator', label: 'Mistério', value: '--');

      await tester.pumpWidget(buildTestableWidget(indicator));
      await tester.pump();

      expect(find.text('Explicação educacional em breve.'), findsOneWidget);
      expect(find.text('Por que importa?'), findsNothing);
    });

    testWidgets('shows a "--" placeholder when the indicator value is null', (WidgetTester tester) async {
      const indicator = AssetIndicator(id: 'pe', label: 'P/L', value: null);

      await tester.pumpWidget(buildTestableWidget(indicator));
      await tester.pump();

      expect(find.text('--'), findsOneWidget);
    });
  });
}
