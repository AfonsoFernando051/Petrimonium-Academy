import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/mentor/presentation/widgets/suggested_prompt_chip.dart';

void main() {
  Widget buildTestableWidget({required String label, required VoidCallback onTap}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: SuggestedPromptChip(label: label, onTap: onTap)),
    );
  }

  group('SuggestedPromptChip', () {
    testWidgets('renders the given label', (tester) async {
      await tester.pumpWidget(buildTestableWidget(label: 'O que são dividendos?', onTap: () {}));

      expect(find.text('O que são dividendos?'), findsOneWidget);
    });

    testWidgets('tapping invokes onTap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(buildTestableWidget(label: 'Analise minha carteira.', onTap: () => tapped = true));
      await tester.tap(find.byType(SuggestedPromptChip));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('meets the 44 logical-pixel minimum touch target height', (tester) async {
      await tester.pumpWidget(buildTestableWidget(label: 'Curto', onTap: () {}));

      final size = tester.getSize(find.byType(SuggestedPromptChip));
      expect(size.height, greaterThanOrEqualTo(44));
    });
  });
}
