import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrimonium/features/pet/data/repositories/pet_companion_preferences_repository.dart';

void main() {
  late PetCompanionPreferencesRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = PetCompanionPreferencesRepository();
  });

  group('loadLastShown', () {
    test('returns an empty map when nothing has been recorded', () async {
      expect(await repository.loadLastShown(), isEmpty);
    });

    test('returns a corrupted/old-format value as empty rather than throwing', () async {
      SharedPreferences.setMockInitialValues({'pet_companion_last_shown': 'not valid json'});
      expect(await repository.loadLastShown(), isEmpty);
    });
  });

  group('recordShown / loadLastShown round-trip', () {
    test('persists and reloads the exact timestamp for one message id', () async {
      final at = DateTime.utc(2024, 3, 15, 10, 30);
      await repository.recordShown('level_up', at);

      final loaded = await repository.loadLastShown();
      expect(loaded['level_up'], at);
    });

    test('accumulates entries across multiple ids instead of overwriting the whole map', () async {
      await repository.recordShown('level_up', DateTime.utc(2024, 1, 1));
      await repository.recordShown('achievement_unlocked', DateTime.utc(2024, 2, 2));

      final loaded = await repository.loadLastShown();
      expect(loaded.keys, {'level_up', 'achievement_unlocked'});
    });

    test('a second record for the same id overwrites its previous timestamp', () async {
      await repository.recordShown('level_up', DateTime.utc(2024, 1, 1));
      await repository.recordShown('level_up', DateTime.utc(2024, 6, 1));

      final loaded = await repository.loadLastShown();
      expect(loaded['level_up'], DateTime.utc(2024, 6, 1));
    });
  });
}
