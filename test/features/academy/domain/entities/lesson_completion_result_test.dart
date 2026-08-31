import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_completion_result.dart';

void main() {
  group('LessonCompletionResult.fromJson', () {
    test('parses all fields from a full response', () {
      final result = LessonCompletionResult.fromJson(const {
        'lessonId': 'lesson_1',
        'alreadyCompleted': true,
        'xpAwarded': 10,
        'moduleCompleted': true,
        'moduleXpAwarded': 50,
        'totalXp': 300,
        'level': 4,
        'xpIntoLevel': 20,
        'xpForNextLevel': 100,
      });

      expect(result.lessonId, 'lesson_1');
      expect(result.alreadyCompleted, isTrue);
      expect(result.xpAwarded, 10);
      expect(result.moduleCompleted, isTrue);
      expect(result.moduleXpAwarded, 50);
      expect(result.totalXp, 300);
      expect(result.level, 4);
      expect(result.xpIntoLevel, 20);
      expect(result.xpForNextLevel, 100);
    });

    test('missing optional fields fall back to safe defaults', () {
      final result = LessonCompletionResult.fromJson(const {'lessonId': 'lesson_2'});

      expect(result.lessonId, 'lesson_2');
      expect(result.alreadyCompleted, isFalse);
      expect(result.xpAwarded, 0);
      expect(result.moduleCompleted, isFalse);
      expect(result.moduleXpAwarded, 0);
      expect(result.totalXp, 0);
      expect(result.level, 1);
      expect(result.xpIntoLevel, 0);
      expect(result.xpForNextLevel, 50);
    });
  });
}
