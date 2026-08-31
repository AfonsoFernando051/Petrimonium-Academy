import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrimonium/features/portfolio/data/repositories/achievements_local_repository.dart';

void main() {
  late AchievementsLocalRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = AchievementsLocalRepository();
  });

  group('loadUnlocked', () {
    test('returns an empty map when nothing is cached', () async {
      expect(await repository.loadUnlocked(), isEmpty);
    });

    test('round-trips ids and dates cached via cacheUnlocked', () async {
      final unlockedAt = {
        'first_investment': DateTime.utc(2024, 1, 1),
        'portfolio_10k': DateTime.utc(2024, 3, 15),
      };

      await repository.cacheUnlocked(unlockedAt);

      expect(await repository.loadUnlocked(), unlockedAt);
    });

    test('drops any entry whose date fails to parse rather than throwing', () async {
      SharedPreferences.setMockInitialValues({
        'achievements_unlocked_ids::anonymous': ['good', 'bad'],
        'achievements_unlocked_dates::anonymous': ['2024-01-01T00:00:00.000Z', 'not-a-date'],
      });

      final result = await repository.loadUnlocked();
      expect(result.keys, {'good'});
    });

    test('ignores a trailing id with no matching date (mismatched list lengths)', () async {
      SharedPreferences.setMockInitialValues({
        'achievements_unlocked_ids::anonymous': ['a', 'b'],
        'achievements_unlocked_dates::anonymous': ['2024-01-01T00:00:00.000Z'],
      });

      final result = await repository.loadUnlocked();
      expect(result.keys, {'a'});
    });

    test('migrates data from the old unscoped key on first read, for a pre-scoping install', () async {
      SharedPreferences.setMockInitialValues({
        'achievements_unlocked_ids': ['legacy'],
        'achievements_unlocked_dates': ['2024-01-01T00:00:00.000Z'],
      });

      final result = await repository.loadUnlocked();
      expect(result.keys, {'legacy'});

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('achievements_unlocked_ids'), isNull);
      expect(prefs.getStringList('achievements_unlocked_ids::anonymous'), ['legacy']);
    });
  });

  group('cacheUnlocked', () {
    test('overwrites (not merges) a previously cached set', () async {
      await repository.cacheUnlocked({'old_achievement': DateTime.utc(2023, 1, 1)});
      await repository.cacheUnlocked({'new_achievement': DateTime.utc(2024, 1, 1)});

      final result = await repository.loadUnlocked();
      expect(result.keys, {'new_achievement'});
    });
  });
}
