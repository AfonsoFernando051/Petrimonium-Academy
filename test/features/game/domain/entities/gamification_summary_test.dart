import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/game/domain/entities/gamification_summary.dart';

void main() {
  group('GamificationSummary', () {
    test('empty constant has expected defaults', () {
      expect(GamificationSummary.empty.totalXp, 0);
      expect(GamificationSummary.empty.level, 1);
      expect(GamificationSummary.empty.xpIntoLevel, 0);
      expect(GamificationSummary.empty.xpForNextLevel, 50);
      expect(GamificationSummary.empty.currentStreak, 0);
      expect(GamificationSummary.empty.longestStreak, 0);
    });

    test('fromJson parses all fields', () {
      final summary = GamificationSummary.fromJson(const {
        'totalXp': 1200,
        'level': 5,
        'xpIntoLevel': 40,
        'xpForNextLevel': 100,
        'currentStreak': 3,
        'longestStreak': 10,
      });

      expect(summary.totalXp, 1200);
      expect(summary.level, 5);
      expect(summary.xpIntoLevel, 40);
      expect(summary.xpForNextLevel, 100);
      expect(summary.currentStreak, 3);
      expect(summary.longestStreak, 10);
    });

    test('fromJson defaults missing fields', () {
      final summary = GamificationSummary.fromJson(const {});

      expect(summary.totalXp, 0);
      expect(summary.level, 1);
      expect(summary.xpIntoLevel, 0);
      expect(summary.xpForNextLevel, 50);
      expect(summary.currentStreak, 0);
      expect(summary.longestStreak, 0);
    });

    test('fromJson defaults fields explicitly set to null', () {
      final summary = GamificationSummary.fromJson({
        'totalXp': null,
        'level': null,
        'xpIntoLevel': null,
        'xpForNextLevel': null,
        'currentStreak': null,
        'longestStreak': null,
      });

      expect(summary.totalXp, 0);
      expect(summary.level, 1);
      expect(summary.xpIntoLevel, 0);
      expect(summary.xpForNextLevel, 50);
      expect(summary.currentStreak, 0);
      expect(summary.longestStreak, 0);
    });
  });
}
