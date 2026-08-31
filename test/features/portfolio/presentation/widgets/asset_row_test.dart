import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/asset_details/data/repositories/asset_details_repository.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/asset_details/presentation/screens/asset_details_screen.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_lot.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/asset_row.dart';

class MockAssetDetailsRepository extends Mock implements AssetDetailsRepository {}

void main() {
  Widget buildTestableWidget(Holding holding) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: AssetRow(holding: holding)),
    );
  }

  Holding buildHolding() {
    final lots = [
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
    ];
    return Holding.fromLots(lots).first;
  }

  group('AssetRow', () {
    testWidgets('renders ticker, quantity/average price and current value', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(buildHolding()));

      expect(find.text('PETR4'), findsOneWidget);
      expect(find.textContaining('100 un'), findsOneWidget);
      expect(find.textContaining('R\$ 1.200'), findsOneWidget);
    });

    testWidgets('opens AssetDetailsScreen on tap', (WidgetTester tester) async {
      final mockRepository = MockAssetDetailsRepository();
      DI.assetDetailsRepository = mockRepository;
      when(() => mockRepository.fetchAssetDetails(any()))
          .thenAnswer((_) async => const AssetDetails(ticker: 'PETR4'));

      await tester.pumpWidget(buildTestableWidget(buildHolding()));

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.byType(AssetDetailsScreen), findsOneWidget);
    });
  });
}
