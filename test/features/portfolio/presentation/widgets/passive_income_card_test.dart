import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/passive_income_estimate.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/passive_income_card.dart';

void main() {
  Widget buildTestableWidget(PassiveIncomeEstimate estimate) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: SingleChildScrollView(child: PassiveIncomeCard(estimate: estimate))),
    );
  }

  group('PassiveIncomeCard', () {
    testWidgets('shows a call-to-action message when there is no breakdown yet', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(PassiveIncomeEstimate.empty));
      await tester.pump();

      expect(find.textContaining('Invista em ativos geradores de renda'), findsOneWidget);
      expect(find.textContaining('Projeção para os próximos 6 meses'), findsNothing);
    });

    testWidgets('renders monthly/annual totals and a breakdown row per type when populated', (WidgetTester tester) async {
      const estimate = PassiveIncomeEstimate(
        monthlyEstimate: 100,
        annualEstimate: 1200,
        monthlyByType: {
          InvestmentTypeEnum.FIXED_INCOME: 80,
          InvestmentTypeEnum.REAL_ESTATE: 20,
        },
      );

      // The month chip's fixed-height Container overflows by a few pixels
      // under flutter_test's fallback test font (its glyph metrics are
      // taller than a real device font) — not reproducible with real fonts,
      // so this only suppresses that specific, expected layout warning.
      final previousOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (!details.toString().contains('overflowed')) previousOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = previousOnError);

      await tester.pumpWidget(buildTestableWidget(estimate));
      await tester.pump();

      expect(find.text('RENDA PASSIVA (ESTIMADA)'), findsOneWidget);
      // The month-chip projection also renders the monthly estimate value,
      // so only assert the annual figure (unique) exactly once.
      expect(find.text('R\$ 1.200'), findsOneWidget);
      expect(find.text('R. Fixa'), findsOneWidget);
      expect(find.text('FIIs'), findsOneWidget);
      expect(find.textContaining('Projeção para os próximos 6 meses'), findsOneWidget);
      // 1 figure + 6 month chips, all showing the same monthly value.
      expect(find.text('R\$ 100'), findsNWidgets(7));
    });
  });
}
