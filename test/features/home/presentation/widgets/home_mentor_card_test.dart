import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/home/presentation/widgets/home_mentor_card.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// Minimal in-memory MascotRepository double, mirrors
/// `choice_question_step_view_test.dart` — CAT rather than the default DOG,
/// since DOG's real `dog.riv` crashes `flutter_tester` on this toolchain.
class FakeMascotRepository implements MascotRepository {
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
  late MascotController mascotController;

  setUp(() async {
    Translator.currentLanguage = 'pt';
    mascotController = MascotController(repository: FakeMascotRepository());
    await mascotController.loadProfile();
  });

  tearDown(() => mascotController.dispose());

  Widget buildTestable({required HomeMentorReason reason}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        // Keyed by reason so each loop iteration below mounts a fresh
        // State — otherwise Flutter reuses the previous element/State at
        // the same tree position and `_showReason` leaks across iterations.
        body: HomeMentorCard(
          key: ValueKey(reason),
          mascotController: mascotController,
          petName: 'Bolt',
          message: 'Você estava progredindo em "Aula X". Continuar de onde parou?',
          reason: reason,
        ),
      ),
    );
  }

  group('HomeMentorCard', () {
    testWidgets('renders the pet name and message', (tester) async {
      await tester.pumpWidget(buildTestable(reason: HomeMentorReason.continueLesson));
      // Hosts a live pet render (repeating AnimationController) — never
      // call pumpAndSettle.
      await tester.pump();

      expect(find.text('Bolt'), findsOneWidget);
      expect(find.text('Você estava progredindo em "Aula X". Continuar de onde parou?'), findsOneWidget);
      expect(find.text('Por que estou vendo isto?'), findsOneWidget);
    });

    testWidgets('reveals the matching reason for each signal on tap', (tester) async {
      for (final (reason, expected) in [
        (HomeMentorReason.continueLesson, 'Baseado na sua última aula concluída.'),
        (HomeMentorReason.reviewDue, 'Baseado em conceitos pendentes de revisão.'),
        (HomeMentorReason.returning, 'Baseado no tempo desde sua última visita.'),
      ]) {
        await tester.pumpWidget(buildTestable(reason: reason));
        await tester.pump();

        expect(find.text(expected), findsNothing);
        await tester.tap(find.text('Por que estou vendo isto?'));
        await tester.pump();
        expect(find.text(expected), findsOneWidget);
      }
    });
  });
}
