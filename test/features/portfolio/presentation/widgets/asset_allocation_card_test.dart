import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/allocation_slice.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/asset_allocation_card.dart';

void main() {
  Widget buildTestableWidget(List<AllocationSlice> allocation, double totalValue) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: AssetAllocationCard(allocation: allocation, totalValue: totalValue),
      ),
    );
  }

  const slices = [
    AllocationSlice(type: InvestmentTypeEnum.STOCKS, currentValue: 7000, portfolioPercent: 70),
    AllocationSlice(type: InvestmentTypeEnum.FIXED_INCOME, currentValue: 3000, portfolioPercent: 30),
  ];

  group('AssetAllocationCard', () {
    testWidgets('renders the section title, pie chart and a legend row per slice', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(slices, 10000));

      expect(find.text('ALOCAÇÃO DE ATIVOS'), findsOneWidget);
      expect(find.byType(PieChart), findsOneWidget);
      expect(find.text('Ações'), findsOneWidget);
      expect(find.text('R. Fixa'), findsOneWidget);
      expect(find.text('70%'), findsOneWidget);
      expect(find.text('30%'), findsOneWidget);
    });

    testWidgets('shows the empty state message and no chart when allocation is empty', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const [], 0));

      expect(find.byType(PieChart), findsNothing);
      expect(find.textContaining('ativo'), findsOneWidget);
    });
  });
}
