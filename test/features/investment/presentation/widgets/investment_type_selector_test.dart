import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/investment/presentation/widgets/investment_type_selector.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_type_display.dart';

void main() {
  Widget buildTestableWidget({InvestmentTypeEnum? selected, required ValueChanged<InvestmentTypeEnum> onChanged}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: InvestmentTypeSelector(selected: selected, onChanged: onChanged)),
    );
  }

  group('InvestmentTypeSelector', () {
    testWidgets('renders one card per investment type and no tip when nothing is selected', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(selected: null, onChanged: (_) {}));
      await tester.pump();

      for (final type in InvestmentTypeEnum.values) {
        expect(find.text(type.shortLabel), findsWidgets);
      }
      expect(find.textContaining('Maior potencial de crescimento'), findsNothing);
    });

    testWidgets('shows the matching contextual tip once a type is selected', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(selected: InvestmentTypeEnum.STOCKS, onChanged: (_) {}));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Maior potencial de crescimento'), findsOneWidget);
    });

    testWidgets('tapping a type card calls onChanged with that type', (WidgetTester tester) async {
      InvestmentTypeEnum? tapped;
      await tester.pumpWidget(buildTestableWidget(selected: null, onChanged: (t) => tapped = t));
      await tester.pump();

      await tester.tap(find.text(InvestmentTypeEnum.CRYPTO.shortLabel));
      await tester.pump();

      expect(tapped, InvestmentTypeEnum.CRYPTO);
    });

    testWidgets('shows a different tip after switching selection', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(selected: InvestmentTypeEnum.STOCKS, onChanged: (_) {}));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('Maior potencial de crescimento'), findsOneWidget);

      await tester.pumpWidget(buildTestableWidget(selected: InvestmentTypeEnum.CRYPTO, onChanged: (_) {}));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Alto potencial, alta volatilidade'), findsOneWidget);
      expect(find.textContaining('Maior potencial de crescimento'), findsNothing);
    });
  });
}
