import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/portfolio/domain/entities/mission_status.dart';

void main() {
  group('MissionStatus.fromJson', () {
    test('parses a completed daily mission', () {
      final status = MissionStatus.fromJson(const {
        'code': 'daily_complete_lesson',
        'period': 'DAILY',
        'periodKey': '2026-08-19',
        'progress': 1,
        'target': 1,
        'xpReward': 30,
        'completed': true,
      });

      expect(status.code, 'daily_complete_lesson');
      expect(status.period, MissionPeriod.daily);
      expect(status.periodKey, '2026-08-19');
      expect(status.progress, 1);
      expect(status.target, 1);
      expect(status.xpReward, 30);
      expect(status.completed, isTrue);
    });

    test('parses a weekly mission', () {
      final status = MissionStatus.fromJson(const {
        'code': 'weekly_complete_module',
        'period': 'WEEKLY',
        'periodKey': '2026-W34',
        'progress': 0,
        'target': 1,
        'xpReward': 150,
        'completed': false,
      });

      expect(status.period, MissionPeriod.weekly);
      expect(status.completed, isFalse);
    });
  });

  group('MissionEvaluationResult.fromJson', () {
    test('parses missions list and newly-completed codes', () {
      final result = MissionEvaluationResult.fromJson(const {
        'missions': [
          {
            'code': 'daily_complete_lesson',
            'period': 'DAILY',
            'periodKey': '2026-08-19',
            'progress': 1,
            'target': 1,
            'xpReward': 30,
            'completed': true,
          },
        ],
        'newlyCompletedCodes': ['daily_complete_lesson'],
        'missionXpTotal': 30,
      });

      expect(result.missions, hasLength(1));
      expect(result.newlyCompletedCodes, contains('daily_complete_lesson'));
      expect(result.missionXpTotal, 30);
    });

    test('missing fields fall back to safe empty defaults rather than throwing', () {
      final result = MissionEvaluationResult.fromJson(const {});

      expect(result.missions, isEmpty);
      expect(result.newlyCompletedCodes, isEmpty);
      expect(result.missionXpTotal, 0);
    });
  });
}
