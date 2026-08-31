import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/expandable_category.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/holdings_section.dart';

import '../../domain/services/portfolio_test_fixtures.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestableWidget(List<Holding> holdings, double totalPortfolioValue) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: HoldingsSection(holdings: holdings, totalPortfolioValue: totalPortfolioValue)),
    );
  }

  group('HoldingsSection', () {
    testWidgets('shows an empty-state message when there are no holdings', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const [], 0));
      await tester.pump();

      expect(find.text('MEUS ATIVOS'), findsOneWidget);
      expect(find.byType(ExpandableCategory), findsNothing);
      expect(find.text('Nenhum ativo registrado ainda.'), findsOneWidget);
    });

    testWidgets('groups holdings by category into one ExpandableCategory per type', (WidgetTester tester) async {
      final holdings = Holding.fromLots([
        lot(ticker: 'PETR4', type: InvestmentTypeEnum.STOCKS, quantity: 10, purchasePrice: 10, currentPrice: 12),
        lot(ticker: 'HGLG11', type: InvestmentTypeEnum.REAL_ESTATE, quantity: 5, purchasePrice: 100, currentPrice: 110),
      ]);

      await tester.pumpWidget(buildTestableWidget(holdings, 100 * 1.2 + 5 * 110));
      await tester.pump();

      expect(find.byType(ExpandableCategory), findsNWidgets(2));
    });

    testWidgets('the first (largest) category starts expanded', (WidgetTester tester) async {
      final holdings = Holding.fromLots([
        lot(ticker: 'BIG', type: InvestmentTypeEnum.STOCKS, quantity: 100, purchasePrice: 10, currentPrice: 10),
        lot(ticker: 'SMALL', type: InvestmentTypeEnum.REAL_ESTATE, quantity: 1, purchasePrice: 1, currentPrice: 1),
      ]);

      await tester.pumpWidget(buildTestableWidget(holdings, 1001));
      await tester.pump();

      final categories = tester.widgetList<ExpandableCategory>(find.byType(ExpandableCategory)).toList();
      expect(categories.first.initiallyExpanded, isTrue);
      expect(categories.last.initiallyExpanded, isFalse);
      // Largest current-value category (STOCKS, 1000) sorts first.
      expect(categories.first.type, InvestmentTypeEnum.STOCKS);
    });
  });
}
