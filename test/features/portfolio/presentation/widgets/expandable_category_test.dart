import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_lot.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/asset_row.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/expandable_category.dart';

void main() {
  Widget buildTestableWidget(List<Holding> holdings, {bool initiallyExpanded = false}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: ExpandableCategory(
          type: InvestmentTypeEnum.STOCKS,
          holdings: holdings,
          totalPortfolioValue: 10000,
          initiallyExpanded: initiallyExpanded,
        ),
      ),
    );
  }

  List<Holding> buildHoldings() {
    return Holding.fromLots([
      InvestmentLot(
        id: 1,
        ticker: 'PETR4',
        type: InvestmentTypeEnum.STOCKS,
        quantity: 100,
        purchasePrice: 10,
        purchaseDate: DateTime(2024, 1, 1),
        currentPrice: 12,
        investedValue: 1000,
        currentValue: 1200,
      ),
    ]);
  }

  group('ExpandableCategory', () {
    testWidgets('renders category label and asset count in the header', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(buildHoldings()));

      expect(find.text('Ações'), findsOneWidget);
      expect(find.textContaining('1 ativo(s)'), findsOneWidget);
    });

    // AnimatedCrossFade always builds both firstChild and secondChild (it
    // needs both mounted to animate between them), so AssetRow is present
    // in the tree regardless of expansion — find.byType(AssetRow) can't
    // distinguish collapsed from expanded. Assert on the AnimatedCrossFade's
    // own crossFadeState instead, which is what actually drives visibility.
    CrossFadeState crossFadeState(WidgetTester tester) =>
        tester.widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade)).crossFadeState;

    testWidgets('does not show AssetRow children when collapsed by default', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(buildHoldings()));

      expect(crossFadeState(tester), CrossFadeState.showSecond);
    });

    testWidgets('shows AssetRow children when initiallyExpanded is true', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(buildHoldings(), initiallyExpanded: true));

      expect(find.byType(AssetRow), findsOneWidget);
      expect(crossFadeState(tester), CrossFadeState.showFirst);
    });

    testWidgets('toggles expansion when the header is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(buildHoldings()));

      expect(crossFadeState(tester), CrossFadeState.showSecond);

      // Not pumpAndSettle(): a sibling test elsewhere in this suite renders
      // widgets with indefinitely-repeating animations; pump past this
      // widget's own 250ms cross-fade explicitly to stay robust to that.
      // .first: the header's own InkWell is built before AssetRow's (which
      // is present in the tree even while collapsed, per the comment
      // above), so byType(InkWell) alone matches both ambiguously.
      await tester.tap(find.byType(InkWell).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(crossFadeState(tester), CrossFadeState.showFirst);

      // .first: the header's own InkWell is built before AssetRow's (which
      // is present in the tree even while collapsed, per the comment
      // above), so byType(InkWell) alone matches both ambiguously.
      await tester.tap(find.byType(InkWell).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(crossFadeState(tester), CrossFadeState.showSecond);
    });
  });
}
