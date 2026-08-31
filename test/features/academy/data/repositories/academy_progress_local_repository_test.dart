import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_progress_local_repository.dart';

void main() {
  late AcademyProgressLocalRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = AcademyProgressLocalRepository();
  });

  group('completed lesson ids', () {
    test('starts empty', () async {
      expect(await repository.loadCompletedLessonIds(), isEmpty);
    });

    test('markLessonCompleted adds the lesson and persists it', () async {
      final result = await repository.markLessonCompleted('lesson_1');

      expect(result, {'lesson_1'});
      expect(await repository.loadCompletedLessonIds(), {'lesson_1'});
    });

    test('markLessonCompleted accumulates across calls', () async {
      await repository.markLessonCompleted('lesson_1');
      await repository.markLessonCompleted('lesson_2');

      expect(await repository.loadCompletedLessonIds(), {'lesson_1', 'lesson_2'});
    });

    test('markLessonCompleted is a no-op when already completed', () async {
      await repository.markLessonCompleted('lesson_1');
      final result = await repository.markLessonCompleted('lesson_1');

      expect(result, {'lesson_1'});
      expect(await repository.loadCompletedLessonIds(), {'lesson_1'});
    });

    test('mergeCompletedLessonIds unions server ids with local ones', () async {
      await repository.markLessonCompleted('local_lesson');

      final merged = await repository.mergeCompletedLessonIds({'server_lesson', 'local_lesson'});

      expect(merged, {'local_lesson', 'server_lesson'});
      expect(await repository.loadCompletedLessonIds(), {'local_lesson', 'server_lesson'});
    });

    test('mergeCompletedLessonIds never removes a locally-completed lesson missing from the server set', () async {
      await repository.markLessonCompleted('local_only');

      final merged = await repository.mergeCompletedLessonIds({});

      expect(merged, contains('local_only'));
    });
  });

  group('perfect lesson ids', () {
    test('starts empty', () async {
      expect(await repository.loadPerfectLessonIds(), isEmpty);
    });

    test('markLessonPerfect adds the lesson and persists it', () async {
      final result = await repository.markLessonPerfect('lesson_1');

      expect(result, {'lesson_1'});
      expect(await repository.loadPerfectLessonIds(), {'lesson_1'});
    });

    test('markLessonPerfect is idempotent (a later imperfect replay never un-marks it)', () async {
      await repository.markLessonPerfect('lesson_1');
      final result = await repository.markLessonPerfect('lesson_1');

      expect(result, {'lesson_1'});
    });
  });

  group('miss tracking', () {
    test('recordMiss starts at 1 and increments per call, scoped per school', () async {
      expect(await repository.recordMiss('school_a'), 1);
      expect(await repository.recordMiss('school_a'), 2);
      expect(await repository.recordMiss('school_b'), 1);
    });

    test('resetMisses clears the counter for that school only', () async {
      await repository.recordMiss('school_a');
      await repository.recordMiss('school_a');
      await repository.recordMiss('school_b');

      await repository.resetMisses('school_a');

      expect(await repository.recordMiss('school_a'), 1);
      expect(await repository.recordMiss('school_b'), 2);
    });
  });

  group('pending sync', () {
    test('starts empty', () async {
      expect(await repository.loadPendingSyncLessonIds(), isEmpty);
    });

    test('markPendingSync adds the lesson id', () async {
      await repository.markPendingSync('lesson_1');

      expect(await repository.loadPendingSyncLessonIds(), {'lesson_1'});
    });

    test('markPendingSync does not duplicate an already-pending id', () async {
      await repository.markPendingSync('lesson_1');
      await repository.markPendingSync('lesson_1');

      expect(await repository.loadPendingSyncLessonIds(), {'lesson_1'});
    });

    test('clearPendingSync removes the lesson id', () async {
      await repository.markPendingSync('lesson_1');
      await repository.markPendingSync('lesson_2');

      await repository.clearPendingSync('lesson_1');

      expect(await repository.loadPendingSyncLessonIds(), {'lesson_2'});
    });

    test('clearPendingSync is a no-op when the id was never pending', () async {
      await repository.markPendingSync('lesson_1');

      await repository.clearPendingSync('never_pending');

      expect(await repository.loadPendingSyncLessonIds(), {'lesson_1'});
    });
  });

  group('account scoping', () {
    test('a second account on the same device never sees the first account\'s local progress', () async {
      SharedPreferences.setMockInitialValues({'auth_email': 'first@example.com'});
      await repository.markLessonCompleted('lesson_1');
      expect(await repository.loadCompletedLessonIds(), {'lesson_1'});

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_email', 'second@example.com');

      expect(await repository.loadCompletedLessonIds(), isEmpty);
    });

    test('logging back into the first account still finds its own progress untouched', () async {
      SharedPreferences.setMockInitialValues({'auth_email': 'first@example.com'});
      await repository.markLessonCompleted('lesson_1');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_email', 'second@example.com');
      expect(await repository.loadCompletedLessonIds(), isEmpty);

      await prefs.setString('auth_email', 'first@example.com');
      expect(await repository.loadCompletedLessonIds(), {'lesson_1'});
    });

    test('migrates data from the old unscoped key on first read, for a pre-scoping install', () async {
      SharedPreferences.setMockInitialValues({
        'academy_completed_lesson_ids': ['legacy_lesson'],
      });

      expect(await repository.loadCompletedLessonIds(), {'legacy_lesson'});

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('academy_completed_lesson_ids'), isNull);
      expect(prefs.getStringList('academy_completed_lesson_ids::anonymous'), ['legacy_lesson']);
    });
  });
}
