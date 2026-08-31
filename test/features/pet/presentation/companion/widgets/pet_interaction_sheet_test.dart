import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_companion_controller.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';
import 'package:petrimonium/features/pet/presentation/companion/widgets/pet_interaction_sheet.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// Minimal in-memory MascotRepository double, mirrors the one used in
/// `mascot_controller_test.dart` — only `loadProfile` matters here.
class FakeMascotRepository implements MascotRepository {
  // CAT rather than the default DOG: DOG now ships a real `dog.riv` (see
  // `assets/rive/pet/README.md`), and this project's pinned
  // `rive`/`rive_common` versions hit a native-symbol lookup failure once
  // `flutter_tester` actually parses `.riv` bytes on this toolchain — a
  // pre-existing environment gap, not something the widget under test can
  // catch. CAT has no bundled asset, so these tests (which don't care about
  // species) keep exercising the real, always-reachable fallback path
  // deterministically. Tests that override `profileToReturn` below must keep
  // specifying `specie: PetSpecieEnum.CAT` for the same reason.
  PetProfile profileToReturn = PetProfile(specie: PetSpecieEnum.CAT);

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
  late FakeMascotRepository mascotRepository;
  late MascotController mascotController;
  late PetCompanionController companionController;

  setUp(() async {
    Translator.currentLanguage = 'pt';
    SharedPreferences.setMockInitialValues({});
    mascotRepository = FakeMascotRepository();
    mascotController = MascotController(repository: mascotRepository);
    // The controller's specie defaults to DOG until a profile is loaded —
    // load the CAT fixture from FakeMascotRepository so it actually takes
    // effect (see the comment on FakeMascotRepository.profileToReturn).
    await mascotController.loadProfile();
    companionController = PetCompanionController(mascotController: mascotController);
  });

  tearDown(() {
    companionController.dispose();
    mascotController.dispose();
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: PetInteractionSheet(controller: companionController),
      ),
    );
  }

  group('PetInteractionSheet', () {
    testWidgets('shows a generic title when the pet has no name yet', (tester) async {
      mascotRepository.profileToReturn = PetProfile(name: null, specie: PetSpecieEnum.CAT);
      await mascotController.loadProfile();

      await tester.pumpWidget(buildTestableWidget());
      // Hosts a PetRiveCompanion falling back to PetMascotWidget's
      // repeating breathe animation — never pumpAndSettle.
      await tester.pump();
      await tester.pump();

      expect(find.text('Como posso ajudar?'), findsOneWidget);
      expect(find.text('Escolha para onde ir'), findsOneWidget);
    });

    testWidgets('shows the pet\'s name as the title when it has one', (tester) async {
      mascotRepository.profileToReturn = PetProfile(name: 'Bolt', specie: PetSpecieEnum.CAT);
      await mascotController.loadProfile();

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      expect(find.text('Bolt'), findsOneWidget);
      expect(find.text('Como posso ajudar?'), findsNothing);
    });

    testWidgets('renders the 3 interaction options', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      expect(find.text('Aprender'), findsOneWidget);
      expect(find.text('Carteira'), findsOneWidget);
      expect(find.text('Progresso'), findsOneWidget);
    });

    testWidgets('tapping "Aprender" pops with PetContext.academy', (tester) async {
      PetContext? popped;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  popped = await Navigator.of(context).push<PetContext>(
                    MaterialPageRoute(builder: (_) => PetInteractionSheet(controller: companionController)),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      await tester.tap(find.text('Carteira'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(popped, PetContext.portfolio);
    });
  });
}
