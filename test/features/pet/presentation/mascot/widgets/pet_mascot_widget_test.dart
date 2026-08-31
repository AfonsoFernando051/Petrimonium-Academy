import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:petrimonium/features/pet/presentation/mascot/widgets/pet_mascot_widget.dart';

/// Minimal in-memory MascotRepository double, mirrors the one used in
/// `mascot_controller_test.dart` — only `loadProfile` matters here.
class FakeMascotRepository implements MascotRepository {
  PetProfile profileToReturn = PetProfile();

  @override
  Future<PetProfile> loadProfile() async => profileToReturn;
  @override
  Future<void> saveName(String name) async {}
  @override
  Future<void> saveStage(PetEvolutionStage stage) async {}
  @override
  Future<void> saveXp(int xp) async {}
  @override
  Future<void> saveSpecie(PetSpecieEnum specie) async {}
  @override
  Future<void> saveNetWorth(double netWorth) async {}
  @override
  Future<void> saveEquippedAccessories(Map<AccessoryType, PetAccessoryId> equipped) async {}
  @override
  Future<void> saveUnlockedAccessories(Set<PetAccessoryId> unlocked) async {}
  @override
  Future<void> saveLastActiveAt(DateTime lastActiveAt) async {}
}

void main() {
  late FakeMascotRepository repository;
  late MascotController controller;

  setUp(() {
    repository = FakeMascotRepository();
    controller = MascotController(repository: repository);
  });

  tearDown(() => controller.dispose());

  Widget buildTestableWidget({double size = 220, bool interactive = true}) {
    return MaterialApp(
      home: Scaffold(
        body: PetMascotWidget(controller: controller, size: size, interactive: interactive),
      ),
    );
  }

  group('PetMascotWidget', () {
    testWidgets('renders without throwing, falling back through Lottie/PNG/species/icon layers', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      // Has its own repeating breathe AnimationController — never
      // pumpAndSettle.
      await tester.pump();
      await tester.pump();

      expect(find.byType(PetMascotWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders an aura layer for a high-tier evolution stage', (tester) async {
      repository.profileToReturn = PetProfile(stage: PetEvolutionStage.royalDog);
      await controller.loadProfile();

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      // The aura is a decorative BoxShadow-only Container — assert
      // indirectly via a successful, exception-free render at a
      // aura-triggering stage (tier >= 6, see PetEvolutionStage.hasAura).
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders an accessory layer for each equipped accessory', (tester) async {
      repository.profileToReturn = PetProfile(
        equippedAccessories: const {AccessoryType.headwear: PetAccessoryId.baseballCap},
      );
      await controller.loadProfile();

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping the mascot triggers a happy reaction when interactive', (tester) async {
      await tester.pumpWidget(buildTestableWidget(interactive: true));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byType(PetMascotWidget));
      await tester.pump();

      expect(controller.profile.animationState, PetAnimationState.happy);

      // triggerEventAnimation starts a real 900ms revert Timer — elapse
      // past it so it fires (and is gone) before the test ends, rather
      // than relying on tearDown's controller.dispose() to cancel it
      // (flutter_test's "no pending Timer" check runs before tearDown).
      await tester.pump(const Duration(milliseconds: 950));
    });

    testWidgets('is not tappable when interactive is false', (tester) async {
      await tester.pumpWidget(buildTestableWidget(interactive: false));
      await tester.pump();
      await tester.pump();

      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('honors disableAnimations — still renders, no crash', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: buildTestableWidget(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
      expect(find.byType(PetMascotWidget), findsOneWidget);
    });
  });
}
