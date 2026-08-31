import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/onboarding/data/models/option_model.dart';
import 'package:petrimonium/features/onboarding/data/models/question_model.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/question_card.dart';

const _question = QuestionModel(
  id: 'q1',
  text: 'Qual seu objetivo principal?',
  options: [
    OptionModel(id: 'a', text: 'Crescer patrimônio'),
    OptionModel(id: 'b', text: 'Renda passiva'),
  ],
);

void main() {
  Widget buildTestableWidget({
    QuestionModel question = _question,
    String? selectedOptionId,
    ValueChanged<String>? onSelected,
    bool isFirst = false,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: QuestionCard(
          question: question,
          selectedOptionId: selectedOptionId,
          onSelected: onSelected ?? (_) {},
          isFirst: isFirst,
        ),
      ),
    );
  }

  group('QuestionCard', () {
    testWidgets('renders the question text and every option', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Qual seu objetivo principal?'), findsOneWidget);
      expect(find.text('Crescer patrimônio'), findsOneWidget);
      expect(find.text('Renda passiva'), findsOneWidget);
    });

    testWidgets('shows the compass/paw icon only when isFirst is true', (tester) async {
      await tester.pumpWidget(buildTestableWidget(isFirst: true));
      expect(find.byIcon(Icons.explore), findsOneWidget);

      await tester.pumpWidget(buildTestableWidget(isFirst: false));
      expect(find.byIcon(Icons.explore), findsNothing);
    });

    testWidgets('tapping an option invokes onSelected with its id', (tester) async {
      String? selected;
      await tester.pumpWidget(buildTestableWidget(onSelected: (id) => selected = id));

      await tester.tap(find.text('Renda passiva'));
      await tester.pump();

      expect(selected, 'b');
    });

    testWidgets('shows a paw check mark on the selected option', (tester) async {
      await tester.pumpWidget(buildTestableWidget(selectedOptionId: 'a'));
      await tester.pump();

      expect(find.byIcon(Icons.pets), findsOneWidget);
    });

    testWidgets('shows no paw check mark when nothing is selected', (tester) async {
      await tester.pumpWidget(buildTestableWidget(selectedOptionId: null));
      await tester.pump();

      expect(find.byIcon(Icons.pets), findsNothing);
    });
  });
}
