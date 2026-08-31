import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/asset_details/domain/entities/user_position.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/pet_teacher_widget.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestableWidget(AssetDetails asset) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: PetTeacherWidget(asset: asset)),
    );
  }

  const notOwnedStock = AssetDetails(ticker: 'PETR4', shortName: 'Petrobras', assetType: 'stock');
  const ownedStock = AssetDetails(
    ticker: 'PETR4',
    shortName: 'Petrobras',
    assetType: 'stock',
    userPosition: UserPosition(
      quantity: 10,
      averagePrice: 20,
      investedValue: 200,
      currentValue: 220,
      unrealizedGain: 20,
      unrealizedGainPercent: 10,
      portfolioWeight: 50,
    ),
  );
  const fii = AssetDetails(ticker: 'HGLG11', shortName: 'CSHG Logística', assetType: 'fii');

  group('PetTeacherWidget', () {
    testWidgets('shows the not-owned greeting when the user has no position', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(notOwnedStock));

      expect(find.text('Seu Companheiro'), findsOneWidget);
      expect(find.text('Quer saber mais sobre Petrobras?'), findsOneWidget);
    });

    testWidgets('shows the owned greeting when the user holds a position', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(ownedStock));

      expect(find.text('Vamos entender melhor Petrobras!'), findsOneWidget);
    });

    testWidgets('shows up to 5 stock-specific suggested questions as chips', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(notOwnedStock));

      expect(find.text('Pergunte ao mentor:'), findsOneWidget);
      expect(find.text('O que é Petrobras?'), findsOneWidget);
      expect(find.text('O que o P/L desse ativo significa?'), findsOneWidget);
      // 3 generic + 3 stock-specific + 1 trailing = 7 total questions, capped at 5 chips.
      expect(find.text('Explique como se eu fosse iniciante.'), findsNothing);
    });

    testWidgets('shows FII-specific suggested questions for a FII', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(fii));

      expect(find.text('O que é P/VP em fundos imobiliários?'), findsOneWidget);
    });

    testWidgets('tapping a question chip shows a snackbar confirming it was sent to the mentor', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(notOwnedStock));

      await tester.tap(find.text('O que é Petrobras?'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Pergunta enviada ao mentor'), findsOneWidget);
    });
  });
}
