import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/asset_header.dart';

void main() {
  Widget buildTestableWidget(AssetDetails asset) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: AssetHeader(asset: asset)),
    );
  }

  group('AssetHeader', () {
    testWidgets('renders the display name, price, and positive change', (tester) async {
      const asset = AssetDetails(
        ticker: 'PETR4',
        shortName: 'Petrobras',
        assetType: 'stock',
        sector: 'Energia',
        currentPrice: 35.5,
        dailyChangePercent: 2.5,
      );

      await tester.pumpWidget(buildTestableWidget(asset));

      expect(find.text('Petrobras'), findsOneWidget);
      expect(find.text('Ação'), findsOneWidget);
      expect(find.text('· Energia'), findsOneWidget);
      expect(find.text('R\$ 35,50'), findsOneWidget);
      expect(find.text('+2.50%'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_up), findsOneWidget);
    });

    testWidgets('falls back to the ticker as the display name and shows price unavailable', (tester) async {
      const asset = AssetDetails(ticker: 'PETR4', assetType: 'fii');

      await tester.pumpWidget(buildTestableWidget(asset));

      expect(find.text('PETR4'), findsOneWidget);
      expect(find.text('FII'), findsOneWidget);
      expect(find.text('Preço indisponível'), findsOneWidget);
      // No change badge without dailyChangePercent.
      expect(find.byIcon(Icons.arrow_drop_up), findsNothing);
      expect(find.byIcon(Icons.arrow_drop_down), findsNothing);
    });

    testWidgets('renders a negative change with the down arrow', (tester) async {
      const asset = AssetDetails(
        ticker: 'PETR4',
        currentPrice: 10,
        dailyChangePercent: -1.25,
      );

      await tester.pumpWidget(buildTestableWidget(asset));

      expect(find.text('-1.25%'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });

    testWidgets('renders the 52-week range when both bounds are present', (tester) async {
      const asset = AssetDetails(
        ticker: 'PETR4',
        currentPrice: 15,
        fiftyTwoWeekLow: 10,
        fiftyTwoWeekHigh: 20,
      );

      await tester.pumpWidget(buildTestableWidget(asset));

      expect(find.textContaining('52 sem:'), findsOneWidget);
    });

    testWidgets('does not render the 52-week range when a bound is missing', (tester) async {
      const asset = AssetDetails(ticker: 'PETR4', fiftyTwoWeekLow: 10);

      await tester.pumpWidget(buildTestableWidget(asset));

      expect(find.textContaining('52 sem:'), findsNothing);
    });

    testWidgets('shows "Atualizado agora" for a lastUpdated timestamp from just now', (tester) async {
      final asset = AssetDetails(
        ticker: 'PETR4',
        lastUpdated: DateTime.now().toIso8601String(),
      );

      await tester.pumpWidget(buildTestableWidget(asset));

      expect(find.text('Atualizado agora'), findsOneWidget);
    });

    testWidgets('shows nothing for an unparsable lastUpdated string', (tester) async {
      const asset = AssetDetails(ticker: 'PETR4', lastUpdated: 'not-a-date');

      await tester.pumpWidget(buildTestableWidget(asset));

      expect(find.text(''), findsOneWidget);
    });

    testWidgets('badges unknown asset types as "Ativo"', (tester) async {
      const asset = AssetDetails(ticker: 'XXXX', assetType: 'unknown');

      await tester.pumpWidget(buildTestableWidget(asset));

      expect(find.text('Ativo'), findsOneWidget);
    });
  });
}
