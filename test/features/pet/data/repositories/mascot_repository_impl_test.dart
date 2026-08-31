import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrimonium/features/game/data/datasources/gamification_remote_datasource.dart';
import 'package:petrimonium/features/pet/data/datasources/pet_remote_datasource.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/data/repositories/mascot_repository_impl.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';

class MockGamificationRemoteDataSource extends Mock implements GamificationRemoteDataSource {}

class MockPetRemoteDataSource extends Mock implements PetRemoteDataSource {}

void main() {
  late MockGamificationRemoteDataSource mockGamificationDataSource;
  late MockPetRemoteDataSource mockPetDataSource;
  late MascotRepositoryImpl repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockGamificationDataSource = MockGamificationRemoteDataSource();
    mockPetDataSource = MockPetRemoteDataSource();
    repository = MascotRepositoryImpl(
      gamificationRemoteDataSource: mockGamificationDataSource,
      petRemoteDataSource: mockPetDataSource,
    );
  });

  group('loadProfile', () {
    test('overwrites xp and specie with the backend\'s real values and caches them', () async {
      when(() => mockGamificationDataSource.fetchSummary()).thenAnswer((_) async => {
            'totalXp': 120,
            'level': 2,
            'xpIntoLevel': 20,
            'xpForNextLevel': 100,
            'currentStreak': 0,
            'longestStreak': 0,
          });
      when(() => mockPetDataSource.getMyPet()).thenAnswer((_) async => {'specie': 'FOX'});

      final profile = await repository.loadProfile();

      expect(profile.xp, 120);
      expect(profile.specie, PetSpecieEnum.FOX);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('mascot_xp'), 120);
      expect(prefs.getString('mascot_specie'), 'FOX');
    });

    test('falls back to the last-known cached xp when the gamification call fails', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('mascot_xp', 55);

      when(() => mockGamificationDataSource.fetchSummary()).thenThrow(Exception('offline'));
      when(() => mockPetDataSource.getMyPet()).thenAnswer((_) async => null);

      final profile = await repository.loadProfile();

      expect(profile.xp, 55);
    });

    test('falls back to the last-known cached specie when the pet call fails', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mascot_specie', 'BEAR');

      when(() => mockGamificationDataSource.fetchSummary()).thenThrow(Exception('offline'));
      when(() => mockPetDataSource.getMyPet()).thenThrow(Exception('offline'));

      final profile = await repository.loadProfile();

      expect(profile.specie, PetSpecieEnum.BEAR);
    });

    test('keeps the cached specie when the backend pet payload has no specie field', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mascot_specie', 'WOLF');

      when(() => mockGamificationDataSource.fetchSummary()).thenThrow(Exception('offline'));
      when(() => mockPetDataSource.getMyPet()).thenAnswer((_) async => {'someOtherField': 1});

      final profile = await repository.loadProfile();

      expect(profile.specie, PetSpecieEnum.WOLF);
    });

    test('defaults to DOG/babyDog/xp 0 when nothing is cached and the backend has no data', () async {
      when(() => mockGamificationDataSource.fetchSummary()).thenThrow(Exception('offline'));
      when(() => mockPetDataSource.getMyPet()).thenAnswer((_) async => null);

      final profile = await repository.loadProfile();

      expect(profile.specie, PetSpecieEnum.DOG);
      expect(profile.stage, PetEvolutionStage.babyDog);
      expect(profile.xp, 0);
      expect(profile.name, isNull);
    });

    test('restores previously saved name, equipped and unlocked accessories', () async {
      when(() => mockGamificationDataSource.fetchSummary()).thenThrow(Exception('offline'));
      when(() => mockPetDataSource.getMyPet()).thenAnswer((_) async => null);

      await repository.saveName('Rex');
      await repository.saveUnlockedAccessories({PetAccessoryId.values.first});
      await repository.saveEquippedAccessories({AccessoryType.values.first: PetAccessoryId.values.first});

      final profile = await repository.loadProfile();

      expect(profile.name, 'Rex');
      expect(profile.unlockedAccessories, {PetAccessoryId.values.first});
      expect(profile.equippedAccessories[AccessoryType.values.first], PetAccessoryId.values.first);
    });
  });

  group('save methods', () {
    test('saveStage persists the stage name', () async {
      await repository.saveStage(PetEvolutionStage.values.last);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('mascot_stage'), PetEvolutionStage.values.last.name);
    });

    test('saveNetWorth persists the value', () async {
      await repository.saveNetWorth(999.5);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('mascot_net_worth'), 999.5);
    });

    test('saveLastActiveAt persists an ISO8601 string that round-trips', () async {
      final at = DateTime.utc(2024, 5, 1, 12);
      await repository.saveLastActiveAt(at);
      final prefs = await SharedPreferences.getInstance();
      expect(DateTime.parse(prefs.getString('mascot_last_active_at')!), at);
    });

    test('saveEquippedAccessories removes the slot when unequipped', () async {
      final slot = AccessoryType.values.first;
      await repository.saveEquippedAccessories({slot: PetAccessoryId.values.first});
      await repository.saveEquippedAccessories({});

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('mascot_equipped_${slot.name}'), isNull);
    });
  });
}
