import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';
import 'package:petrimonium/features/academy/presentation/widgets/steps/example_step_view.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  group('ExampleStepView', () {
    testWidgets('renders the example label, title and body', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: ExampleStepView(step: ExampleStep(title: 'A Worked Example', body: 'Here is the math.')),
          ),
        ),
      );

      expect(find.text('EXEMPLO'), findsOneWidget);
      expect(find.text('A Worked Example'), findsOneWidget);
      expect(find.text('Here is the math.'), findsOneWidget);
    });

    testWidgets('renders the breadcrumb when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: ExampleStepView(
              step: ExampleStep(title: 'A Worked Example', body: 'Here is the math.'),
              breadcrumb: 'Fundamentos · Aula 1 de 4',
            ),
          ),
        ),
      );

      expect(find.text('Fundamentos · Aula 1 de 4'), findsOneWidget);
    });
  });
}
