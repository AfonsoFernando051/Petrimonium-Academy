import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/asset_education_section.dart';

void main() {
  Widget buildTestableWidget(AssetDetails asset) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: SingleChildScrollView(child: AssetEducationSection(asset: asset))),
    );
  }

  const stock = AssetDetails(ticker: 'PETR4', shortName: 'Petrobras', assetType: 'stock', sector: 'Energia');
  const fii = AssetDetails(ticker: 'HGLG11', shortName: 'CSHG Logística', assetType: 'fii', sector: 'Logística');
  const etf = AssetDetails(ticker: 'BOVA11', shortName: 'iShares Bovespa', assetType: 'etf');
  const bdr = AssetDetails(ticker: 'AAPL34', shortName: 'Apple', assetType: 'bdr');

  group('AssetEducationSection', () {
    testWidgets('collapsed by default: shows only "what is it" and a "saiba mais" expander', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(stock));

      expect(find.text('GUIA EDUCACIONAL'), findsOneWidget);
      expect(find.text('O que é Petrobras?'), findsOneWidget);
      expect(find.text('Saiba mais →'), findsOneWidget);
      expect(find.text('Como gera renda?'), findsNothing);
      expect(find.text('O que observar?'), findsNothing);
    });

    testWidgets('expanding reveals "how it makes money" and "what to watch"', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(stock));

      await tester.tap(find.text('Saiba mais →'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Como gera renda?'), findsOneWidget);
      expect(find.text('O que observar?'), findsOneWidget);
      expect(find.text('Saiba mais →'), findsNothing);
    });

    testWidgets('tapping the chevron also toggles expansion', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(stock));

      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Como gera renda?'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Como gera renda?'), findsNothing);
      expect(find.text('Saiba mais →'), findsOneWidget);
    });

    testWidgets('describes a stock with the equity-specific copy', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(stock));

      expect(find.textContaining('ação negociada na bolsa brasileira'), findsOneWidget);
      expect(find.textContaining('setor de Energia'), findsOneWidget);
    });

    testWidgets('describes a FII with the real-estate-fund-specific copy', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(fii));

      expect(find.textContaining('Fundo de Investimento Imobiliário'), findsOneWidget);
      expect(find.textContaining('segmento de Logística'), findsOneWidget);
    });

    testWidgets('describes an ETF with the index-fund-specific copy', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(etf));

      expect(find.textContaining('ETF (fundo de índice)'), findsOneWidget);
    });

    testWidgets('describes a BDR with the depositary-receipt-specific copy', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(bdr));

      expect(find.textContaining('BDR (Brazilian Depositary Receipt)'), findsOneWidget);
    });
  });
}
