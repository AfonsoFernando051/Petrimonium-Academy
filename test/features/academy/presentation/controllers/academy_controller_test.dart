import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/core/events/app_event_bus.dart';
import 'package:petrimonium/features/academy/data/datasources/academy_remote_datasource.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_catalog_repository.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_progress_local_repository.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_recommendation.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_completion_result.dart';
import 'package:petrimonium/features/academy/domain/entities/mastery_tier.dart';
import 'package:petrimonium/features/academy/presentation/controllers/academy_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../academy_test_fixtures.dart';

class MockAcademyRemoteDataSource extends Mock
    implements AcademyRemoteDataSource {}

class MockAcademyCatalogRepository extends Mock
    implements AcademyCatalogRepository {}

void main() {
  late AcademyProgressLocalRepository repository;
  late MockAcademyRemoteDataSource mockRemoteDataSource;
  late MockAcademyCatalogRepository mockCatalogRepository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = AcademyProgressLocalRepository();
    mockRemoteDataSource = MockAcademyRemoteDataSource();
    mockCatalogRepository = MockAcademyCatalogRepository();

    // Every test's catalog fetch resolves to the shared fixture snapshot,
    // mirroring the "already cached, no need to hit the network again"
    // steady state — individual tests override this when they need to
    // exercise the loading/offline paths instead.
    when(
      () => mockCatalogRepository.loadCached(any()),
    ).thenAnswer((_) async => buildAcademyCatalogSnapshot());
    when(
      () => mockCatalogRepository.fetchAndCache(any()),
    ).thenAnswer((_) async => buildAcademyCatalogSnapshot());
  });

  AcademyController buildController({
    AcademyRemoteDataSource? remoteDataSource,
  }) {
    final controller = AcademyController(
      repository: repository,
      catalogRepository: mockCatalogRepository,
      remoteDataSource: remoteDataSource,
    );
    addTearDown(controller.dispose);
    return controller;
  }

  test(
    'load() works with local progress alone when no remote datasource is provided',
    () async {
      await repository.markLessonCompleted('foundations_what_is_investing');
      final controller = buildController();

      await controller.load();

      expect(controller.completedLessonIds, {'foundations_what_is_investing'});
      expect(controller.isLoading, isFalse);
      expect(controller.isCatalogLoading, isFalse);
      expect(controller.snapshot, isNotNull);
    },
  );

  test(
    'load() merges server-reported completions into local progress',
    () async {
      await repository.markLessonCompleted('foundations_what_is_investing');
      when(() => mockRemoteDataSource.getCompletedLessonIds()).thenAnswer(
        (_) async => {'foundations_what_is_investing', 'foundations_inflation'},
      );
      final controller = buildController(
        remoteDataSource: mockRemoteDataSource,
      );

      await controller.load();

      expect(controller.completedLessonIds, {
        'foundations_what_is_investing',
        'foundations_inflation',
      });
      final persisted = await repository.loadCompletedLessonIds();
      expect(persisted, {
        'foundations_what_is_investing',
        'foundations_inflation',
      });
    },
  );

  test(
    'load() keeps local-only progress when the remote sync fails (offline)',
    () async {
      await repository.markLessonCompleted('foundations_what_is_investing');
      when(
        () => mockRemoteDataSource.getCompletedLessonIds(),
      ).thenThrow(Exception('offline'));
      final controller = buildController(
        remoteDataSource: mockRemoteDataSource,
      );

      await controller.load();

      expect(controller.completedLessonIds, {'foundations_what_is_investing'});
      expect(controller.isLoading, isFalse);
    },
  );

  test(
    'catalog falls back to the cached snapshot when the fetch fails',
    () async {
      when(
        () => mockCatalogRepository.fetchAndCache(any()),
      ).thenThrow(Exception('offline'));
      final controller = buildController();

      await controller.load();

      expect(controller.snapshot, isNotNull);
      expect(controller.catalogError, isNull);
    },
  );

  test(
    'catalogError is set when there is no cache and the fetch fails',
    () async {
      when(
        () => mockCatalogRepository.loadCached(any()),
      ).thenAnswer((_) async => null);
      when(
        () => mockCatalogRepository.fetchAndCache(any()),
      ).thenThrow(Exception('offline'));
      final controller = buildController();

      await controller.load();

      expect(controller.snapshot, isNull);
      expect(controller.catalogError, isNotNull);
    },
  );

  test(
    'a completed lesson answered imperfectly shows lower Mastery than Progress',
    () async {
      await repository.markLessonCompleted(testLesson1.id);
      final controller = buildController();

      await controller.load();

      expect(
        controller.realMasteryFor(testSchool),
        lessThan(controller.masteryFor(testSchool)),
      );
      expect(
        controller.masteryTierFor(testSchool),
        isNot(MasteryTier.mastering),
      );
    },
  );

  test('a lesson answered perfectly counts fully toward Mastery', () async {
    await repository.markLessonCompleted(testLesson1.id);
    await repository.markLessonPerfect(testLesson1.id);
    final controller = buildController();

    await controller.load();

    expect(
      controller.realMasteryFor(testSchool),
      controller.masteryFor(testSchool),
    );
  });

  test(
    'recommendations surface a review item once a lesson is completed but not perfect',
    () async {
      await repository.markLessonCompleted(testLesson1.id);
      final controller = buildController();

      await controller.load();

      expect(
        controller.recommendations.map((r) => r.type),
        contains(RecommendationType.review),
      );
      expect(controller.reviewQueue.map((l) => l.id), contains(testLesson1.id));
      expect(controller.reviewEstimatedMinutes, greaterThanOrEqualTo(1));
    },
  );

  test('review queue is empty when nothing has been completed', () async {
    final controller = buildController();

    await controller.load();

    expect(controller.reviewQueue, isEmpty);
    expect(controller.reviewEstimatedMinutes, 0);
  });

  test(
    'refreshes local progress when a lesson completion event is emitted',
    () async {
      final controller = buildController();
      await controller.load();

      final refreshed = Completer<void>();
      controller.addListener(() {
        if (controller.completedLessonIds.contains(testLesson1.id) &&
            controller.perfectLessonIds.contains(testLesson1.id) &&
            !refreshed.isCompleted) {
          refreshed.complete();
        }
      });

      await repository.markLessonCompleted(testLesson1.id);
      await repository.markLessonPerfect(testLesson1.id);
      AppEventBus.instance.emit(LessonCompletedEvent(testLesson1.id));

      await refreshed.future.timeout(const Duration(seconds: 1));

      expect(controller.masteryFor(testSchool), closeTo(1 / 3, 0.0001));
      expect(controller.realMasteryFor(testSchool), closeTo(1 / 3, 0.0001));
    },
  );

  group('pending-sync retry', () {
    LessonCompletionResult resultFor(String lessonId) => LessonCompletionResult(
      lessonId: lessonId,
      alreadyCompleted: true,
      xpAwarded: 0,
      moduleCompleted: false,
      moduleXpAwarded: 0,
      totalXp: 120,
      level: 2,
      xpIntoLevel: 20,
      xpForNextLevel: 50,
    );

    setUp(() {
      // Every retry test needs the initial merge call to resolve — none of them are
      // exercising that path, so it's stubbed to a no-op success here.
      when(
        () => mockRemoteDataSource.getCompletedLessonIds(),
      ).thenAnswer((_) async => {});
    });

    test(
      'load() retries a lesson left pending from a previous failed sync',
      () async {
        await repository.markLessonCompleted(testLesson1.id);
        await repository.markPendingSync(testLesson1.id);
        when(
          () => mockRemoteDataSource.completeLesson(
            testLesson1.id,
            perfectFirstTry: false,
          ),
        ).thenAnswer((_) async => resultFor(testLesson1.id));
        final controller = buildController(
          remoteDataSource: mockRemoteDataSource,
        );

        await controller.load();

        verify(
          () => mockRemoteDataSource.completeLesson(
            testLesson1.id,
            perfectFirstTry: false,
          ),
        ).called(1);
        expect(await repository.loadPendingSyncLessonIds(), isEmpty);
      },
    );

    test(
      'load() retries a perfect lesson with perfectFirstTry: true',
      () async {
        await repository.markLessonCompleted(testLesson1.id);
        await repository.markLessonPerfect(testLesson1.id);
        await repository.markPendingSync(testLesson1.id);
        when(
          () => mockRemoteDataSource.completeLesson(
            testLesson1.id,
            perfectFirstTry: true,
          ),
        ).thenAnswer((_) async => resultFor(testLesson1.id));
        final controller = buildController(
          remoteDataSource: mockRemoteDataSource,
        );

        await controller.load();

        verify(
          () => mockRemoteDataSource.completeLesson(
            testLesson1.id,
            perfectFirstTry: true,
          ),
        ).called(1);
      },
    );

    test(
      'load() leaves a lesson pending when the retry also fails (still offline)',
      () async {
        await repository.markLessonCompleted(testLesson1.id);
        await repository.markPendingSync(testLesson1.id);
        when(
          () => mockRemoteDataSource.completeLesson(
            testLesson1.id,
            perfectFirstTry: false,
          ),
        ).thenThrow(Exception('offline'));
        final controller = buildController(
          remoteDataSource: mockRemoteDataSource,
        );

        await controller.load();

        expect(await repository.loadPendingSyncLessonIds(), {testLesson1.id});
      },
    );

    test('load() does not retry anything when nothing is pending', () async {
      await repository.markLessonCompleted(testLesson1.id);
      final controller = buildController(
        remoteDataSource: mockRemoteDataSource,
      );

      await controller.load();

      verifyNever(
        () => mockRemoteDataSource.completeLesson(
          any(),
          perfectFirstTry: any(named: 'perfectFirstTry'),
        ),
      );
    });
  });
}
