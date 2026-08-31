import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/presentation/companion/rive/pet_rive_companion.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:petrimonium/features/pet/presentation/mascot/widgets/pet_mascot_widget.dart';
import 'package:rive/rive.dart' show RiveAnimation;

/// Minimal in-memory MascotRepository double, mirrors the one in
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
  Future<void> saveEquippedAccessories(
    Map<AccessoryType, PetAccessoryId> equipped,
  ) async {}
  @override
  Future<void> saveUnlockedAccessories(Set<PetAccessoryId> unlocked) async {}
  @override
  Future<void> saveLastActiveAt(DateTime lastActiveAt) async {}
}

/// Every test here deliberately uses [PetSpecieEnum.CAT], which has no
/// bundled `.riv`, rather than DOG or OWL. Both of those now ship a real
/// `.riv` (see `assets/rive/pet/README.md`), and this project's pinned
/// `rive`/`rive_common` versions hit a native-symbol lookup failure
/// (`rive_common`'s text-engine FFI init) once `flutter_tester` actually
/// parses `.riv` bytes on this toolchain — a pre-existing environment gap,
/// not something `PetRiveCompanion` can catch, since it fails inside Rive's
/// own async init chain. Exercising a species with no asset keeps these
/// tests exercising the (real, always-reachable) fallback path
/// deterministically; the dog.riv/owl.riv paths (including the pose-per-
/// state artboard mapping `_posesExistIn` validates) are verified manually
/// via `flutter run -d linux` instead.
Future<MascotController> _catController(FakeMascotRepository repository) async {
  repository.profileToReturn = PetProfile(specie: PetSpecieEnum.CAT);
  final controller = MascotController(repository: repository);
  await controller.loadProfile();
  return controller;
}

void main() {
  testWidgets(
    'falls back to PetMascotWidget when no .riv asset exists for the species',
    (tester) async {
      final controller = await _catController(FakeMascotRepository());

      await tester.pumpWidget(
        MaterialApp(
          home: PetRiveCompanion(controller: controller, size: 48),
        ),
      );
      // Let the failed RiveFile.asset() future resolve — PetMascotWidget's
      // own looping breathe animation means pumpAndSettle would never
      // return, so a bounded pump is used instead.
      await tester.pump();
      await tester.pump();

      expect(find.byType(PetMascotWidget), findsOneWidget);
      expect(find.byType(RiveAnimation), findsNothing);
    },
  );

  testWidgets(
    'does not throw when the widget is disposed while the asset load is in flight',
    (tester) async {
      final controller = await _catController(FakeMascotRepository());

      await tester.pumpWidget(
        MaterialApp(
          home: PetRiveCompanion(controller: controller, size: 48),
        ),
      );
      // Unmount immediately, before the async load future resolves.
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
    },
  );
}
