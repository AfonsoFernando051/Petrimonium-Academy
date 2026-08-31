import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/presentation/widgets/financial_lab_entry_card.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestable(VoidCallback onTap) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: FinancialLabEntryCard(onTap: onTap)),
    );
  }

  group('FinancialLabEntryCard', () {
    testWidgets('renders the lab icon and chevron', (tester) async {
      await tester.pumpWidget(buildTestable(() {}));

      expect(find.byIcon(Icons.science_outlined), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('invokes onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestable(() => tapped = true));

      await tester.tap(find.byType(FinancialLabEntryCard));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
