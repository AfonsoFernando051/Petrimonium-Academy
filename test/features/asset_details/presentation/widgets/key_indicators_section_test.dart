import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/indicator_education_sheet.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/key_indicators_section.dart';

void main() {
  Widget buildTestableWidget(AssetDetails asset) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: KeyIndicatorsSection(asset: asset)),
    );
  }

  const emptyAsset = AssetDetails(ticker: 'XXXX11', assetType: 'stock');
  const populatedAsset = AssetDetails(
    ticker: 'PETR4',
    shortName: 'Petrobras',
    assetType: 'stock',
    priceToEarnings: 5.2,
    priceToBook: 1.1,
    dividendYield: 12.5,
  );

  group('KeyIndicatorsSection', () {
    testWidgets('shows an unavailable message when no indicators can be built', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(emptyAsset));

      expect(find.text('INDICADORES'), findsOneWidget);
      expect(find.text('Indicadores não disponíveis para este ativo.'), findsOneWidget);
    });

    testWidgets('renders a chip per available indicator with its formatted value', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(populatedAsset));

      expect(find.text('P/L'), findsOneWidget);
      expect(find.text('5.20'), findsOneWidget);
      expect(find.text('P/VP'), findsOneWidget);
      expect(find.text('1.10'), findsOneWidget);
      expect(find.text('DY 12M'), findsOneWidget);
      expect(find.text('12.50%'), findsOneWidget);
      expect(find.text('Toque para entender'), findsOneWidget);
    });

    testWidgets('tapping an indicator with an explanation opens the education sheet', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(populatedAsset));

      await tester.tap(find.text('P/L'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(IndicatorEducationSheet), findsOneWidget);
    });
  });
}
