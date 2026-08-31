import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';
import 'package:petrimonium/features/academy/domain/services/lesson_question_shuffler.dart';

class _SequenceRandom implements Random {
  _SequenceRandom(this._values);

  final List<int> _values;
  var _nextValueIndex = 0;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;

  @override
  int nextInt(int max) {
    final value = _values[_nextValueIndex++];
    if (value < 0 || value >= max) {
      throw StateError('Test random value $value is outside [0, $max).');
    }
    return value;
  }
}

void main() {
  const lesson = Lesson(
    id: 'quiz_lesson',
    moduleId: 'module',
    title: 'Quiz lesson',
    order: 3,
    xpReward: 15,
    portfolioConcepts: ['inflation'],
    steps: [
      ExplanationStep(title: 'Intro', body: 'Body'),
      ChoiceQuestionStep(
        framing: ChoiceStepFraming.microExercise,
        prompt: 'Question one',
        options: ['A1', 'B1', 'C1'],
        correctIndex: 1,
        explanation: 'Explanation one',
      ),
      ChoiceQuestionStep(
        framing: ChoiceStepFraming.apply,
        prompt: 'Question two',
        options: ['A2', 'B2', 'C2'],
        correctIndex: 1,
        explanation: 'Explanation two',
      ),
      ChoiceQuestionStep(
        framing: ChoiceStepFraming.microExercise,
        prompt: 'Question three',
        options: ['A3', 'B3', 'C3'],
        correctIndex: 1,
        explanation: 'Explanation three',
      ),
      SummaryStep(title: 'Summary', takeaways: ['Takeaway']),
    ],
  );

  group('LessonQuestionShuffler', () {
    test('shuffles each question and keeps its correct answer associated', () {
      // Fisher-Yates consumes two values for each three-option question.
      // These values keep the first answer in position 1, then move the
      // second to 2 and the third to 0: no authored index becomes a pattern.
      final shuffled = LessonQuestionShuffler.shuffle(
        lesson,
        random: _SequenceRandom([2, 1, 1, 1, 0, 0]),
      );
      final questions = shuffled.steps.whereType<ChoiceQuestionStep>().toList();

      expect(shuffled.id, lesson.id);
      expect(shuffled.moduleId, lesson.moduleId);
      expect(shuffled.portfolioConcepts, lesson.portfolioConcepts);
      expect(shuffled.steps.first, same(lesson.steps.first));
      expect(shuffled.steps.last, same(lesson.steps.last));

      expect(questions.map((question) => question.correctIndex), [1, 2, 0]);
      expect(
        questions.map((question) => question.options[question.correctIndex]),
        ['B1', 'B2', 'B3'],
      );
      expect(questions[1].options, ['A2', 'C2', 'B2']);

      // The cached/source lesson itself is never mutated.
      final originalSecondQuestion = lesson.steps[2] as ChoiceQuestionStep;
      expect(originalSecondQuestion.options, ['A2', 'B2', 'C2']);
      expect(originalSecondQuestion.correctIndex, 1);
    });

    test('reproduces the same presentation when given the same seed', () {
      final first = LessonQuestionShuffler.shuffle(lesson, random: Random(42));
      final second = LessonQuestionShuffler.shuffle(lesson, random: Random(42));
      final firstQuestions = first.steps
          .whereType<ChoiceQuestionStep>()
          .toList();
      final secondQuestions = second.steps
          .whereType<ChoiceQuestionStep>()
          .toList();

      expect(
        firstQuestions.map((question) => question.options),
        secondQuestions.map((question) => question.options),
      );
      expect(
        firstQuestions.map((question) => question.correctIndex),
        secondQuestions.map((question) => question.correctIndex),
      );
    });

    test(
      'leaves an invalid question untouched instead of remapping its answer',
      () {
        const invalidLesson = Lesson(
          id: 'invalid',
          moduleId: 'module',
          title: 'Invalid question',
          order: 1,
          xpReward: 0,
          steps: [
            ChoiceQuestionStep(
              framing: ChoiceStepFraming.microExercise,
              prompt: 'Question',
              options: ['A', 'B'],
              correctIndex: 2,
              explanation: 'Explanation',
            ),
          ],
        );

        final shuffled = LessonQuestionShuffler.shuffle(
          invalidLesson,
          random: _SequenceRandom([]),
        );

        expect(shuffled.steps.single, same(invalidLesson.steps.single));
      },
    );
  });
}
