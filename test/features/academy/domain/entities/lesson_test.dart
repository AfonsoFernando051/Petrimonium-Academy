import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';

void main() {
  group('Lesson', () {
    test('constructs with the given fields', () {
      const steps = [
        ExplanationStep(title: 'What is a stock', body: 'A share of a company.'),
        SummaryStep(title: 'Recap', takeaways: ['Stocks represent ownership']),
      ];
      const lesson = Lesson(
        id: 'lesson_1',
        moduleId: 'module_1',
        title: 'What is a stock',
        order: 1,
        xpReward: 10,
        steps: steps,
      );

      expect(lesson.id, 'lesson_1');
      expect(lesson.moduleId, 'module_1');
      expect(lesson.title, 'What is a stock');
      expect(lesson.order, 1);
      expect(lesson.xpReward, 10);
      expect(lesson.steps, steps);
    });
  });
}
