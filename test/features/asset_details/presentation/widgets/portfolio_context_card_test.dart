import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/asset_details/domain/entities/user_position.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/portfolio_context_card.dart';

void main() {
  Widget buildTestableWidget(AssetDetails asset) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: PortfolioContextCard(asset: asset)),
    );
  }

  const position = UserPosition(
    quantity: 100,
    averagePrice: 20,
    investedValue: 2000,
    currentValue: 2500,
    unrealizedGain: 500,
    unrealizedGainPercent: 25,
    portfolioWeight: 12.34,
  );

  group('PortfolioContextCard', () {
    testWidgets('renders nothing when the asset has no user position', (tester) async {
      const asset = AssetDetails(ticker: 'PETR4');

      await tester.pumpWidget(buildTestableWidget(asset));

      expect(find.text('NA SUA CARTEIRA'), findsNothing);
    });

    testWidgets('renders portfolio weight and category for a stock', (tester) async {
      const asset = AssetDetails(
        ticker: 'PETR4',
        shortName: 'Petrobras',
        assetType: 'stock',
        userPosition: position,
      );

      await tester.pumpWidget(buildTestableWidget(asset));

      expect(find.text('NA SUA CARTEIRA'), findsOneWidget);
      expect(
        find.text('Petrobras representa 12.3% do seu portfólio total.'),
        findsOneWidget,
      );
      expect(find.text('Categoria: ações.'), findsOneWidget);
      expect(find.textContaining('Setor:'), findsNothing);
    });

    testWidgets('shows the sector line when sector is present', (tester) async {
      const asset = AssetDetails(
        ticker: 'HGLG11',
        assetType: 'fii',
        sector: 'Logística',
        userPosition: position,
      );

      await tester.pumpWidget(buildTestableWidget(asset));

      expect(find.text('Categoria: FIIs.'), findsOneWidget);
      expect(find.text('Setor: Logística.'), findsOneWidget);
    });

    testWidgets('maps etf and bdr and unknown types to the correct category label', (tester) async {
      const etf = AssetDetails(ticker: 'BOVA11', assetType: 'etf', userPosition: position);
      await tester.pumpWidget(buildTestableWidget(etf));
      expect(find.text('Categoria: ETFs.'), findsOneWidget);

      const bdr = AssetDetails(ticker: 'AAPL34', assetType: 'bdr', userPosition: position);
      await tester.pumpWidget(buildTestableWidget(bdr));
      expect(find.text('Categoria: BDRs.'), findsOneWidget);

      const unknown = AssetDetails(ticker: 'XXXX', assetType: 'unknown', userPosition: position);
      await tester.pumpWidget(buildTestableWidget(unknown));
      expect(find.text('Categoria: ativos.'), findsOneWidget);
    });
  });
}
