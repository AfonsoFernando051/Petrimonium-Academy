import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/asset_details/domain/entities/user_position.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/concentration_warning.dart';

void main() {
  Widget buildTestableWidget(AssetDetails asset) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: ConcentrationWarning(asset: asset)),
    );
  }

  group('ConcentrationWarning', () {
    testWidgets('renders nothing when the asset has no user position', (tester) async {
      const asset = AssetDetails(ticker: 'PETR4');

      await tester.pumpWidget(buildTestableWidget(asset));

      expect(find.byType(ConcentrationWarning), findsOneWidget);
      expect(find.text('Concentração'), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('renders the concentration message with the asset name and weight', (tester) async {
      const asset = AssetDetails(
        ticker: 'PETR4',
        shortName: 'Petrobras',
        userPosition: UserPosition(
          quantity: 100,
          averagePrice: 20,
          investedValue: 2000,
          currentValue: 2500,
          unrealizedGain: 500,
          unrealizedGainPercent: 25,
          portfolioWeight: 34.567,
        ),
      );

      await tester.pumpWidget(buildTestableWidget(asset));

      expect(find.text('Concentração'), findsOneWidget);
      expect(
        find.text(
          'Petrobras representa 34.6% '
          'da sua carteira, o que é uma porção relativamente grande.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });
}
