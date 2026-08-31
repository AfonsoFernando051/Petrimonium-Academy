import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_accessory.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// In-memory [MascotRepository] double: records every persisted write so
/// tests can assert on exactly what MascotController chose to save.
class FakeMascotRepository implements MascotRepository {
  PetEvolutionStage? savedStage;
  int savedStageCalls = 0;
  int? savedXp;
  double? savedNetWorth;
  Map<AccessoryType, PetAccessoryId>? savedEquipped;
  Set<PetAccessoryId>? savedUnlocked;
  DateTime? savedLastActiveAt;

  PetProfile profileToReturn = PetProfile();
  String? savedName;

  @override
  Future<PetProfile> loadProfile() async => profileToReturn;

  @override
  Future<void> saveName(String name) async => savedName = name;

  @override
  Future<void> saveStage(PetEvolutionStage stage) async {
    savedStage = stage;
    savedStageCalls++;
  }

  @override
  Future<void> saveXp(int xp) async => savedXp = xp;

  @override
  Future<void> saveSpecie(PetSpecieEnum specie) async {}

  @override
  Future<void> saveNetWorth(double netWorth) async => savedNetWorth = netWorth;

  @override
  Future<void> saveEquippedAccessories(
    Map<AccessoryType, PetAccessoryId> equipped,
  ) async =>
      savedEquipped = equipped;

  @override
  Future<void> saveUnlockedAccessories(Set<PetAccessoryId> unlocked) async =>
      savedUnlocked = unlocked;

  @override
  Future<void> saveLastActiveAt(DateTime lastActiveAt) async =>
      savedLastActiveAt = lastActiveAt;
}

void main() {
  late FakeMascotRepository repository;
  late MascotController controller;

  setUp(() {
    repository = FakeMascotRepository();
    controller = MascotController(repository: repository);
  });

  tearDown(() => controller.dispose());

  group('resolveStage — XP thresholds map to the 9 evolution tiers', () {
    const cases = <(PetEvolutionStage, int)>[
      (PetEvolutionStage.babyDog, 0),
      (PetEvolutionStage.teenDog, 100),
      (PetEvolutionStage.adultDog, 300),
      (PetEvolutionStage.masterDog, 600),
      (PetEvolutionStage.legendaryDog, 1200),
      (PetEvolutionStage.royalDog, 2500),
      (PetEvolutionStage.cyberMysticDog, 5000),
      (PetEvolutionStage.cosmicGuardianDog, 10000),
      (PetEvolutionStage.goldenFinanceDog, 20000),
    ];

    for (final (stage, xp) in cases) {
      test('reaching exactly the ${stage.name} threshold resolves to ${stage.name}', () {
        final resolved = controller.resolveStage(userXp: xp);
        expect(resolved, stage);
      });
    }

    test('there are exactly 9 stages and each has a strictly higher tier than the previous', () {
      expect(PetEvolutionStage.values.length, 9);
      for (var i = 1; i < PetEvolutionStage.values.length; i++) {
        expect(
          PetEvolutionStage.values[i].tier,
          greaterThan(PetEvolutionStage.values[i - 1].tier),
        );
      }
    });

    test('just below a threshold resolves to the previous tier', () {
      final resolved = controller.resolveStage(userXp: 99);
      expect(resolved, PetEvolutionStage.babyDog);
    });

    test('evolution is driven purely by XP — net worth plays no role', () {
      // Same XP, wildly different net worth arguments to evaluateEvolution
      // (the only place net worth is still threaded through) must resolve
      // to the same stage, since resolveStage no longer takes net worth at
      // all — see docs/PRODUCT_VISION.md §9/§11.
      final resolved = controller.resolveStage(userXp: 2500);
      expect(resolved, PetEvolutionStage.royalDog);
    });
  });

  group('evaluateEvolution', () {
    test('upgrades stage, persists it and plays the victory animation on crossing a tier', () async {
      await controller.evaluateEvolution(2000, 300);

      expect(controller.stage, PetEvolutionStage.adultDog);
      expect(controller.animationState, PetAnimationState.victory);
      expect(repository.savedStage, PetEvolutionStage.adultDog);
      expect(repository.savedNetWorth, 2000);
      expect(repository.savedXp, 300);
    });

    test('does not persist a stage change or replay victory when the tier is unchanged', () async {
      await controller.evaluateEvolution(2000, 300);
      repository.savedStageCalls = 0;
      controller.triggerEventAnimation(PetAnimationState.idle, duration: Duration.zero);

      await controller.evaluateEvolution(2100, 310);

      expect(controller.stage, PetEvolutionStage.adultDog);
      expect(repository.savedStageCalls, 0);
      expect(controller.animationState, isNot(PetAnimationState.victory));
    });

    test('never downgrades the stage when XP later drops', () async {
      await controller.evaluateEvolution(40000, 2500);
      expect(controller.stage, PetEvolutionStage.royalDog);

      await controller.evaluateEvolution(100, 50);

      expect(controller.stage, PetEvolutionStage.royalDog);
      expect(repository.savedStageCalls, 1);
    });

    test('evolving all the way to the final prestige tier', () async {
      await controller.evaluateEvolution(500000, 20000);
      expect(controller.stage, PetEvolutionStage.goldenFinanceDog);
      expect(controller.stage.tier, 9);
    });
  });

  group('triggerEventAnimation', () {
    testWidgets('overrides the animation immediately and reverts after the given duration', (tester) async {
      controller.triggerEventAnimation(
        PetAnimationState.celebrate,
        duration: const Duration(seconds: 1),
      );
      expect(controller.animationState, PetAnimationState.celebrate);

      await tester.pump(const Duration(seconds: 1));
      // The controller intentionally returns to its resting state. That is
      // `sleep` during the night, including when the CI runner is on UTC, so
      // the assertion must not assume the developer machine's local hour.
      expect(controller.animationState, isNot(PetAnimationState.celebrate));
    });
  });

  group('daysSinceLastSession', () {
    test('is null before loadProfile ever completes', () {
      expect(controller.daysSinceLastSession, isNull);
    });

    test('reflects the gap between the persisted lastActiveAt and now', () async {
      repository.profileToReturn = PetProfile(lastActiveAt: DateTime(2026, 1, 1));

      await controller.loadProfile(now: DateTime(2026, 1, 6));

      expect(controller.daysSinceLastSession, 5);
    });

    test('is 0 for a brand-new profile whose lastActiveAt defaults to "now"', () async {
      final now = DateTime(2026, 1, 1, 12);
      repository.profileToReturn = PetProfile(lastActiveAt: now);

      await controller.loadProfile(now: now);

      expect(controller.daysSinceLastSession, 0);
    });
  });

  group('equipAccessory / unequipAccessory', () {
    test('equipping a locked accessory throws', () {
      expect(
        () => controller.equipAccessory(
          const PetAccessory(id: PetAccessoryId.baseballCap),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('unlocking then equipping persists the accessory in its slot', () async {
      await controller.unlockAccessory(PetAccessoryId.baseballCap);
      await controller.equipAccessory(
        const PetAccessory(id: PetAccessoryId.baseballCap, unlocked: true),
      );

      expect(controller.profile.equippedAccessories[AccessoryType.headwear],
          PetAccessoryId.baseballCap);
      expect(repository.savedEquipped?[AccessoryType.headwear],
          PetAccessoryId.baseballCap);
    });

    test('unequipping clears the slot', () async {
      await controller.unlockAccessory(PetAccessoryId.baseballCap);
      await controller.equipAccessory(
        const PetAccessory(id: PetAccessoryId.baseballCap, unlocked: true),
      );

      await controller.unequipAccessory(AccessoryType.headwear);

      expect(controller.profile.equippedAccessories.containsKey(AccessoryType.headwear), isFalse);
      expect(repository.savedEquipped?.containsKey(AccessoryType.headwear), isFalse);
    });
  });
}
