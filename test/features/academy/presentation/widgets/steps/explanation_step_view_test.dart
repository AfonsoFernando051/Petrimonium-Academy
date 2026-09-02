import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';
import 'package:petrimonium/features/academy/presentation/widgets/steps/explanation_step_view.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  group('ExplanationStepView', () {
    testWidgets('renders the step title, body and content-layer chip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: ExplanationStepView(step: ExplanationStep(title: 'Explain This', body: 'The full body text.')),
          ),
        ),
      );

      expect(find.text('Explain This'), findsOneWidget);
      expect(find.text('The full body text.'), findsOneWidget);
      expect(find.text('CONTEÚDO EDUCATIVO'), findsOneWidget);
    });

    testWidgets('renders the breadcrumb when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: ExplanationStepView(
              step: ExplanationStep(title: 'Explain This', body: 'The full body text.'),
              breadcrumb: 'Fundamentos · Aula 1 de 4',
            ),
          ),
        ),
      );

      expect(find.text('Fundamentos · Aula 1 de 4'), findsOneWidget);
    });
  });
}
