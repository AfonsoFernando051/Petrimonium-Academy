import 'dart:math';

import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';

/// Creates a session-specific presentation of a lesson's choice questions.
///
/// The Academy catalog is cached verbatim so it remains a stable content
/// source. This shuffler is deliberately applied only when a lesson session
/// starts: option order stays fixed while that session is on screen, but an
/// authored `correctIndex` does not become a predictable answer position.
class LessonQuestionShuffler {
  const LessonQuestionShuffler._();

  /// Returns a copy of [lesson] with each valid choice question's options in
  /// a new order and its [ChoiceQuestionStep.correctIndex] remapped to match.
  ///
  /// Supplying [random] keeps callers and tests in control of the sequence.
  /// Production callers can omit it to use a fresh random source per lesson
  /// session.
  static Lesson shuffle(Lesson lesson, {Random? random}) {
    final optionRandom = random ?? Random();

    return Lesson(
      id: lesson.id,
      moduleId: lesson.moduleId,
      title: lesson.title,
      order: lesson.order,
      xpReward: lesson.xpReward,
      portfolioConcepts: lesson.portfolioConcepts,
      steps: [
        for (final step in lesson.steps)
          switch (step) {
            ChoiceQuestionStep() => _shuffleChoiceQuestion(step, optionRandom),
            _ => step,
          },
      ],
    );
  }

  static ChoiceQuestionStep _shuffleChoiceQuestion(
    ChoiceQuestionStep step,
    Random random,
  ) {
    // Invalid catalog data is already unusable as a question. Leaving it
    // untouched preserves the API payload for the existing validation/error
    // paths instead of silently associating a different option as correct.
    if (step.correctIndex < 0 || step.correctIndex >= step.options.length) {
      return step;
    }

    final indexedOptions = step.options.indexed.toList();
    _fisherYatesShuffle(indexedOptions, random);
    final correctIndex = indexedOptions.indexWhere(
      (option) => option.$1 == step.correctIndex,
    );

    return ChoiceQuestionStep(
      framing: step.framing,
      prompt: step.prompt,
      options: [for (final option in indexedOptions) option.$2],
      correctIndex: correctIndex,
      explanation: step.explanation,
    );
  }

  /// The unbiased in-place shuffle used for answer positions. Keeping the
  /// algorithm here (rather than hiding it in `List.shuffle`) also makes the
  /// injected random source straightforward to exercise in unit tests.
  static void _fisherYatesShuffle(List<(int, String)> options, Random random) {
    for (var lastIndex = options.length - 1; lastIndex > 0; lastIndex--) {
      final swapIndex = random.nextInt(lastIndex + 1);
      final option = options[lastIndex];
      options[lastIndex] = options[swapIndex];
      options[swapIndex] = option;
    }
  }
}
