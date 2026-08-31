import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/widgets/labeled_slider.dart';

void main() {
  Widget wrap(Widget child) =>
      MaterialApp(theme: AppTheme.dark, home: Scaffold(body: child));

  group('LabeledSlider', () {
    testWidgets('renders the label and value label', (tester) async {
      await tester.pumpWidget(
        wrap(
          LabeledSlider(
            label: 'Valor inicial',
            valueLabel: 'R\$ 1.000',
            value: 1000,
            min: 0,
            max: 10000,
            divisions: 10,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Valor inicial'), findsOneWidget);
      expect(find.text('R\$ 1.000'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('invokes onChanged when dragged', (tester) async {
      double? changedTo;
      await tester.pumpWidget(
        wrap(
          LabeledSlider(
            label: 'Anos',
            valueLabel: '10',
            value: 10,
            min: 1,
            max: 40,
            divisions: 39,
            onChanged: (v) => changedTo = v,
          ),
        ),
      );

      await tester.drag(find.byType(Slider), const Offset(200, 0));
      await tester.pump();

      expect(changedTo, isNotNull);
    });

    testWidgets('exposes the label via Semantics', (tester) async {
      await tester.pumpWidget(
        wrap(
          LabeledSlider(
            label: 'Retorno anual',
            valueLabel: '8.0%',
            value: 8,
            min: 0,
            max: 30,
            divisions: 60,
            onChanged: (_) {},
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Retorno anual',
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'announces semanticValue instead of valueLabel when provided',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            LabeledSlider(
              label: 'Inflação',
              valueLabel: '5%',
              semanticValue: '5 porcento ao ano',
              value: 5,
              min: 0,
              max: 20,
              divisions: 40,
              onChanged: (_) {},
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(Slider));
        expect(semantics.value, '5 porcento ao ano');
      },
    );
  });
}
