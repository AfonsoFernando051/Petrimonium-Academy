import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_narrative_card.dart';

void main() {
  Widget wrap(Widget child) =>
      MaterialApp(theme: AppTheme.dark, home: Scaffold(body: child));

  group('LabNarrativeCard', () {
    testWidgets('renders its text', (tester) async {
      await tester.pumpWidget(
        wrap(
          const LabNarrativeCard(
            text: 'Ajuste os valores para ver o resultado.',
            variant: LabNarrativeVariant.introduction,
          ),
        ),
      );

      expect(
        find.text('Ajuste os valores para ver o resultado.'),
        findsOneWidget,
      );
    });

    testWidgets('renders a distinct icon per variant', (tester) async {
      for (final variant in LabNarrativeVariant.values) {
        await tester.pumpWidget(
          wrap(LabNarrativeCard(text: 'texto', variant: variant)),
        );
        expect(find.byType(Icon), findsOneWidget);
      }
    });
  });
}
