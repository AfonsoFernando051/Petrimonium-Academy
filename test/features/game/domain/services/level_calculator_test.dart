import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/game/domain/services/level_calculator.dart';

void main() {
  group('LevelCalculator.fromXp', () {
    test('zero XP is level 1 with 0 progress into a 50-XP-wide level', () {
      final result = LevelCalculator.fromXp(0);
      expect(result.level, 1);
      expect(result.xpIntoLevel, 0);
      expect(result.xpForNextLevel, 50);
    });

    test('just below the level-2 threshold stays level 1', () {
      final result = LevelCalculator.fromXp(49);
      expect(result.level, 1);
      expect(result.xpIntoLevel, 49);
    });

    test('exactly at the level-2 threshold (50 XP) advances to level 2', () {
      final result = LevelCalculator.fromXp(50);
      expect(result.level, 2);
      expect(result.xpIntoLevel, 0);
      expect(result.xpForNextLevel, 100);
    });

    test('mid-way through level 2', () {
      final result = LevelCalculator.fromXp(99);
      expect(result.level, 2);
      expect(result.xpIntoLevel, 49);
      expect(result.xpForNextLevel, 100);
    });

    test('exactly at the level-3 threshold (150 total XP)', () {
      final result = LevelCalculator.fromXp(150);
      expect(result.level, 3);
      expect(result.xpIntoLevel, 0);
      expect(result.xpForNextLevel, 150);
    });

    test('negative XP is never a bug — treated as level 1, 0 progress', () {
      final result = LevelCalculator.fromXp(-100);
      expect(result.level, 1);
      expect(result.xpIntoLevel, -100);
    });

    test('level requirements strictly increase (triangular progression)', () {
      var previousGap = 0;
      var xp = 0;
      for (var level = 1; level < 20; level++) {
        final atThreshold = LevelCalculator.fromXp(xp);
        final gap = atThreshold.xpForNextLevel;
        expect(gap, greaterThan(previousGap), reason: 'level $level requires more XP than the previous one');
        previousGap = gap;
        xp += gap;
      }
    });

    test('PlayerLevel.progress is 0.0 exactly at a level boundary', () {
      final result = LevelCalculator.fromXp(50);
      expect(result.progress, 0.0);
    });

    test('PlayerLevel.progress approaches 1.0 just before the next level', () {
      final result = LevelCalculator.fromXp(149);
      expect(result.progress, closeTo(0.99, 0.01));
    });
  });
}
