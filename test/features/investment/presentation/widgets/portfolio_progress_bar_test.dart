import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/investment/presentation/widgets/portfolio_progress_bar.dart';

void main() {
  Widget buildTestableWidget(int assetCount, {int target = 3}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: PortfolioProgressBar(assetCount: assetCount, target: target)),
    );
  }

  group('PortfolioProgressBar', () {
    testWidgets('shows 0% and the in-progress label when no assets are added', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('0%'), findsOneWidget);
      expect(find.text('Progresso do Portfólio Inicial'), findsOneWidget);
      expect(find.textContaining('Completo'), findsNothing);
    });

    testWidgets('shows the intermediate percent for partial progress', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(1, target: 3));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('33%'), findsOneWidget);
    });

    testWidgets('shows 100% and the completed label once the target is reached', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(3, target: 3));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('100%'), findsOneWidget);
      expect(find.text('Portfólio Inicial Completo ✓'), findsOneWidget);
    });

    testWidgets('clamps to 100% and stays "complete" when the count exceeds the target', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(5, target: 3));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('100%'), findsOneWidget);
      expect(find.text('Portfólio Inicial Completo ✓'), findsOneWidget);
    });
  });
}
