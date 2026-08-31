/// A single interactive block inside a [Lesson]. Kept as a small, closed set
/// of step types (a real "lesson engine", not one hardcoded widget per
/// lesson) — adding a new question type (matching, ordering, numeric input)
/// is a new subclass + one new step-view widget, nothing else changes, since
/// `LessonScreen` switches on step type generically.
sealed class LessonStep {
  const LessonStep();
}

/// The "discover + explain" beat: introduces the concept in plain language.
class ExplanationStep extends LessonStep {
  final String title;
  final String body;
  const ExplanationStep({required this.title, required this.body});
}

/// A concrete worked example grounding the explanation in real numbers.
class ExampleStep extends LessonStep {
  final String title;
  final String body;
  const ExampleStep({required this.title, required this.body});
}

/// Whether a [ChoiceQuestionStep] is testing recall of what was just taught
/// ([microExercise]) or asking the learner to reason about it in a new
/// situation ([apply]) — same data shape, different framing copy/visual tone.
enum ChoiceStepFraming { microExercise, apply }

/// Covers multiple-choice, true/false (as a 2-option question) and applied
/// scenario questions with one shared shape. Answering never removes a life
/// or blocks progress — a wrong answer shows [explanation] and lets the
/// learner continue, per this app's no-punishment design principle.
class ChoiceQuestionStep extends LessonStep {
  final ChoiceStepFraming framing;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const ChoiceQuestionStep({
    required this.framing,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

/// The closing recap before the lesson's reward moment.
class SummaryStep extends LessonStep {
  final String title;
  final List<String> takeaways;
  const SummaryStep({required this.title, required this.takeaways});
}
