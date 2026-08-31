import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/asset_details/domain/services/portfolio_learning_bridge.dart';

const _peLesson = Lesson(
  id: 'fundamental_analysis_pl_pvp',
  moduleId: 'fundamental_analysis_module',
  title: 'P/L e P/VP',
  order: 1,
  xpReward: 20,
  portfolioConcepts: ['pe', 'pvp'],
  steps: [ExplanationStep(title: 'x', body: 'y')],
);

const _roeLesson = Lesson(
  id: 'fundamental_analysis_roe',
  moduleId: 'fundamental_analysis_module',
  title: 'ROE',
  order: 2,
  xpReward: 20,
  portfolioConcepts: ['roe'],
  steps: [ExplanationStep(title: 'x', body: 'y')],
);

const _unrelatedLesson = Lesson(
  id: 'unrelated_lesson',
  moduleId: 'other_module',
  title: 'Something else entirely',
  order: 1,
  xpReward: 20,
  steps: [ExplanationStep(title: 'x', body: 'y')],
);

void main() {
  group('PortfolioLearningBridge.resolve', () {
    test('returns nothing when no lesson has been completed', () {
      const asset = AssetDetails(ticker: 'PETR4', assetType: 'stock', priceToEarnings: 8.5);

      final result = PortfolioLearningBridge.resolve(
        lessons: const [_peLesson, _roeLesson],
        completedLessonIds: const {},
        asset: asset,
      );

      expect(result, isEmpty);
    });

    test('returns nothing when the completed lesson teaches no portfolio concept', () {
      const asset = AssetDetails(ticker: 'PETR4', assetType: 'stock', priceToEarnings: 8.5);

      final result = PortfolioLearningBridge.resolve(
        lessons: const [_unrelatedLesson],
        completedLessonIds: const {'unrelated_lesson'},
        asset: asset,
      );

      expect(result, isEmpty);
    });

    test('returns nothing when the asset has no real value for the taught concept', () {
      // priceToEarnings is null -- P/E is genuinely unavailable for this asset, so even
      // though the user learned about it, there is nothing real to show.
      const asset = AssetDetails(ticker: 'PETR4', assetType: 'stock');

      final result = PortfolioLearningBridge.resolve(
        lessons: const [_peLesson],
        completedLessonIds: const {'fundamental_analysis_pl_pvp'},
        asset: asset,
      );

      expect(result, isEmpty);
    });

    test('surfaces a concept once the lesson is completed and the asset has a real value', () {
      const asset = AssetDetails(ticker: 'PETR4', assetType: 'stock', priceToEarnings: 8.5);

      final result = PortfolioLearningBridge.resolve(
        lessons: const [_peLesson],
        completedLessonIds: const {'fundamental_analysis_pl_pvp'},
        asset: asset,
      );

      expect(result, hasLength(1));
      expect(result.single.indicator.id, 'pe');
      expect(result.single.indicator.value, isNotNull);
      expect(result.single.lessonId, 'fundamental_analysis_pl_pvp');
      expect(result.single.lessonTitle, 'P/L e P/VP');
    });

    test('surfaces every applicable concept across multiple completed lessons', () {
      const asset = AssetDetails(
        ticker: 'PETR4',
        assetType: 'stock',
        priceToEarnings: 8.5,
        returnOnEquity: 0.22,
      );

      final result = PortfolioLearningBridge.resolve(
        lessons: const [_peLesson, _roeLesson],
        completedLessonIds: const {'fundamental_analysis_pl_pvp', 'fundamental_analysis_roe'},
        asset: asset,
      );

      final conceptIds = result.map((c) => c.indicator.id).toSet();
      expect(conceptIds, {'pe', 'roe'});
    });

    test('a lesson tagged with a concept the asset type never builds an indicator for is silently skipped', () {
      // pvp is tagged on the lesson, but IndicatorEducationCatalog only builds a "pvp"
      // indicator for stocks when priceToBook is present -- here it's absent, so pvp must
      // not appear even though pe (also taught by the same lesson) does.
      const asset = AssetDetails(ticker: 'PETR4', assetType: 'stock', priceToEarnings: 8.5);

      final result = PortfolioLearningBridge.resolve(
        lessons: const [_peLesson],
        completedLessonIds: const {'fundamental_analysis_pl_pvp'},
        asset: asset,
      );

      expect(result.map((c) => c.indicator.id), ['pe']);
    });

    test('never fabricates a concept for an asset the user has not completed a lesson for', () {
      const asset = AssetDetails(
        ticker: 'PETR4',
        assetType: 'stock',
        priceToEarnings: 8.5,
        returnOnEquity: 0.22,
      );

      // Only the P/E lesson was completed -- ROE must not appear even though the asset
      // has a real ROE value and a ROE lesson exists in the catalog.
      final result = PortfolioLearningBridge.resolve(
        lessons: const [_peLesson, _roeLesson],
        completedLessonIds: const {'fundamental_analysis_pl_pvp'},
        asset: asset,
      );

      expect(result.map((c) => c.indicator.id), ['pe']);
    });
  });
}
