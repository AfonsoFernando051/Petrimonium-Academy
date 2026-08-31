import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/portfolio/domain/entities/achievement_evaluation_result.dart';

void main() {
  group('AchievementEvaluationResult.fromJson', () {
    test('parses unlockedAt map, newlyUnlockedCodes and xp total', () {
      final result = AchievementEvaluationResult.fromJson({
        'unlockedAt': {'first_investment': '2026-01-01T00:00:00.000Z'},
        'newlyUnlockedCodes': ['first_investment'],
        'achievementXpTotal': 50,
      });

      expect(result.unlockedAt['first_investment'], DateTime.parse('2026-01-01T00:00:00.000Z'));
      expect(result.newlyUnlockedCodes, {'first_investment'});
      expect(result.achievementXpTotal, 50);
    });

    test('missing fields fall back to empty defaults', () {
      final result = AchievementEvaluationResult.fromJson(const {});

      expect(result.unlockedAt, isEmpty);
      expect(result.newlyUnlockedCodes, isEmpty);
      expect(result.achievementXpTotal, 0);
    });
  });

  group('AchievementEvaluationResult.empty', () {
    test('is a zeroed-out constant result', () {
      expect(AchievementEvaluationResult.empty.unlockedAt, isEmpty);
      expect(AchievementEvaluationResult.empty.newlyUnlockedCodes, isEmpty);
      expect(AchievementEvaluationResult.empty.achievementXpTotal, 0);
    });
  });
}
