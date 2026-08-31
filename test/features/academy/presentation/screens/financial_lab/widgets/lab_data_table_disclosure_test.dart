import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_data_table_disclosure.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget wrap(Widget child) =>
      MaterialApp(theme: AppTheme.dark, home: Scaffold(body: child));

  group('LabDataTableDisclosure', () {
    testWidgets('is collapsed by default, hiding row content', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const LabDataTableDisclosure(
            columnLabels: ['Ano', 'Investido', 'Rendimento'],
            rows: [
              LabDataTableRow(
                label: '1',
                values: ['R\$ 1.000', 'R\$ 50'],
              ),
            ],
          ),
        ),
      );

      expect(find.text('R\$ 1.000'), findsNothing);
    });

    testWidgets('reveals rows once expanded', (tester) async {
      await tester.pumpWidget(
        wrap(
          const LabDataTableDisclosure(
            columnLabels: ['Ano', 'Investido', 'Rendimento'],
            rows: [
              LabDataTableRow(
                label: '1',
                values: ['R\$ 1.000', 'R\$ 50'],
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      expect(find.text('R\$ 1.000'), findsOneWidget);
      expect(find.text('R\$ 50'), findsOneWidget);
    });
  });
}
