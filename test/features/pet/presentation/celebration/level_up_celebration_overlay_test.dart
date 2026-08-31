import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/presentation/celebration/level_up_celebration_overlay.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// Minimal in-memory MascotRepository double — mirrors the one in
/// `learning_hero_card_test.dart`; only `loadProfile` matters here.
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

  setUp(() async {
    Translator.currentLanguage = 'pt';
    repository = FakeMascotRepository();
    controller = MascotController(repository: repository);
    repository.profileToReturn = PetProfile(xp: 55);
    await controller.loadProfile();
  });

  tearDown(() => controller.dispose());

  Widget buildTestableWidget(VoidCallback onDismiss) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: LevelUpCelebrationOverlay(newLevel: 2, mascotController: controller, onDismiss: onDismiss),
      ),
    );
  }

  group('LevelUpCelebrationOverlay', () {
    testWidgets('renders the level headline, share card and action buttons', (tester) async {
      await tester.pumpWidget(buildTestableWidget(() {}));
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('Nível 2 alcançado!'), findsOneWidget);
      expect(find.text('Nível 2'), findsOneWidget);
      expect(find.text('SUBIU DE NÍVEL!'), findsOneWidget);
      expect(find.text('Compartilhar'), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);
    });

    testWidgets('invokes onDismiss when tapped outside the card', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(buildTestableWidget(() => dismissed = true));
      await tester.pump(const Duration(milliseconds: 700));

      await tester.tapAt(const Offset(10, 10));
      expect(dismissed, isTrue);
    });

    testWidgets('invokes onDismiss when the Continuar button is tapped', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(buildTestableWidget(() => dismissed = true));
      await tester.pump(const Duration(milliseconds: 700));

      // The card can be taller than the test viewport (a real device scrolls
      // to it) — scroll it into view before tapping.
      await tester.ensureVisible(find.text('Continuar'));
      await tester.pump();
      await tester.tap(find.text('Continuar'));
      expect(dismissed, isTrue);
    });
  });
}
