import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/widgets/layer_chip.dart';

void main() {
  group('LayerChip', () {
    testWidgets('renders the given label in the given color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: LayerChip(label: 'CONTEÚDO EDUCATIVO', color: Colors.cyan)),
        ),
      );

      final text = tester.widget<Text>(find.text('CONTEÚDO EDUCATIVO'));
      expect(text.style?.color, Colors.cyan);
    });
  });
}
