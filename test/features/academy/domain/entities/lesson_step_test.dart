import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';

void main() {
  group('LessonStep subclasses', () {
    test('ExplanationStep carries title and body', () {
      const step = ExplanationStep(title: 'Title', body: 'Body');
      expect(step.title, 'Title');
      expect(step.body, 'Body');
      expect(step, isA<LessonStep>());
    });

    test('ExampleStep carries title and body', () {
      const step = ExampleStep(title: 'Example', body: 'Some numbers');
      expect(step.title, 'Example');
      expect(step.body, 'Some numbers');
      expect(step, isA<LessonStep>());
    });

    test('ChoiceQuestionStep carries every field, including framing', () {
      const step = ChoiceQuestionStep(
        framing: ChoiceStepFraming.apply,
        prompt: 'What is a stock?',
        options: ['A share of a company', 'A type of bond'],
        correctIndex: 0,
        explanation: 'Stocks represent ownership.',
      );

      expect(step.framing, ChoiceStepFraming.apply);
      expect(step.prompt, 'What is a stock?');
      expect(step.options, ['A share of a company', 'A type of bond']);
      expect(step.correctIndex, 0);
      expect(step.explanation, 'Stocks represent ownership.');
      expect(step, isA<LessonStep>());
    });

    test('SummaryStep carries title and takeaways', () {
      const step = SummaryStep(title: 'Recap', takeaways: ['Point 1', 'Point 2']);
      expect(step.title, 'Recap');
      expect(step.takeaways, ['Point 1', 'Point 2']);
      expect(step, isA<LessonStep>());
    });

    test('ChoiceStepFraming has exactly the two expected values', () {
      expect(ChoiceStepFraming.values, [ChoiceStepFraming.microExercise, ChoiceStepFraming.apply]);
    });
  });
}
