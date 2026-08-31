import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_recommendation.dart';
import 'package:petrimonium/features/academy/domain/services/academy_recommendation_service.dart';

import '../../academy_test_fixtures.dart';

void main() {
  final catalog = buildAcademyCatalogSnapshot();
  final lessons = catalog.lessonsForModule(testModule.id);

  group('recommendationsFor', () {
    test('with nothing completed, only continueLearning is recommended', () {
      final recommendations = AcademyRecommendationService.recommendationsFor(catalog: catalog, completedIds: {}, perfectIds: {});
      expect(recommendations, hasLength(1));
      expect(recommendations.single.type, RecommendationType.continueLearning);
    });

    test('a completed-but-imperfect lesson adds a review recommendation', () {
      final recommendations = AcademyRecommendationService.recommendationsFor(
        catalog: catalog,
        completedIds: {lessons.first.id},
        perfectIds: {},
      );
      expect(recommendations.map((r) => r.type), contains(RecommendationType.review));
      final review = recommendations.firstWhere((r) => r.type == RecommendationType.review);
      expect(review.lesson.id, lessons.first.id);
    });

    test('a perfectly-answered completed lesson does not trigger a review recommendation', () {
      final recommendations = AcademyRecommendationService.recommendationsFor(
        catalog: catalog,
        completedIds: {lessons.first.id},
        perfectIds: {lessons.first.id},
      );
      expect(recommendations.map((r) => r.type), isNot(contains(RecommendationType.review)));
    });

    test('continueLearning is always first when both are present', () {
      final recommendations = AcademyRecommendationService.recommendationsFor(
        catalog: catalog,
        completedIds: {lessons.first.id},
        perfectIds: {},
      );
      expect(recommendations.first.type, RecommendationType.continueLearning);
    });
  });

  group('reviewQueue', () {
    test('empty when nothing is completed', () {
      expect(AcademyRecommendationService.reviewQueue(catalog: catalog, completedIds: {}, perfectIds: {}), isEmpty);
    });

    test('empty when every completed lesson was perfect', () {
      final ids = {lessons.first.id, lessons[1].id};
      expect(AcademyRecommendationService.reviewQueue(catalog: catalog, completedIds: ids, perfectIds: ids), isEmpty);
    });

    test('contains completed-but-imperfect lessons in curriculum order', () {
      final queue = AcademyRecommendationService.reviewQueue(
        catalog: catalog,
        completedIds: {lessons.first.id, lessons[1].id},
        perfectIds: {lessons[1].id},
      );
      expect(queue.map((l) => l.id), [lessons.first.id]);
    });
  });

  group('reviewEstimatedMinutes', () {
    test('zero when the review queue is empty', () {
      expect(AcademyRecommendationService.reviewEstimatedMinutes(catalog: catalog, completedIds: {}, perfectIds: {}), 0);
    });

    test('at least 1 minute once the queue is non-empty', () {
      final minutes = AcademyRecommendationService.reviewEstimatedMinutes(
        catalog: catalog,
        completedIds: {lessons.first.id},
        perfectIds: {},
      );
      expect(minutes, greaterThanOrEqualTo(1));
    });
  });
}
