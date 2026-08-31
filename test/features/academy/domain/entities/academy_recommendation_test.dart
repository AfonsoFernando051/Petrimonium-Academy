import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_recommendation.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';

void main() {
  group('AcademyRecommendation', () {
    const lesson = Lesson(
      id: 'lesson_1',
      moduleId: 'module_1',
      title: 'What is a stock',
      order: 1,
      xpReward: 10,
      steps: [],
    );

    test('constructs with the given fields', () {
      const recommendation = AcademyRecommendation(
        type: RecommendationType.continueLearning,
        lesson: lesson,
        reasonKey: 'reason.continue',
        reasonParams: {'lessonTitle': 'What is a stock'},
      );

      expect(recommendation.type, RecommendationType.continueLearning);
      expect(recommendation.lesson, lesson);
      expect(recommendation.reasonKey, 'reason.continue');
      expect(recommendation.reasonParams, {'lessonTitle': 'What is a stock'});
    });

    test('reasonParams defaults to an empty map when omitted', () {
      const recommendation = AcademyRecommendation(
        type: RecommendationType.review,
        lesson: lesson,
        reasonKey: 'reason.review',
      );

      expect(recommendation.reasonParams, isEmpty);
    });

    test('RecommendationType has exactly the two expected values', () {
      expect(RecommendationType.values, [RecommendationType.continueLearning, RecommendationType.review]);
    });
  });
}
