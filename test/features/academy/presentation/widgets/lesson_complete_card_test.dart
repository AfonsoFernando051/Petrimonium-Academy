import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/features/academy/presentation/widgets/lesson_complete_card.dart';
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

  Widget buildTestable({VoidCallback? onContinue, VoidCallback? onBackToAcademy}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: LessonCompleteCard(
          lessonTitle: 'My Lesson',
          xpEarned: 42,
          mascotController: mascotController,
          onContinue: onContinue ?? () {},
          onBackToAcademy: onBackToAcademy ?? () {},
        ),
      ),
    );
  }

  group('LessonCompleteCard', () {
    testWidgets('renders lesson title and xp earned', (tester) async {
      await tester.pumpWidget(buildTestable());
      await tester.pump();

      expect(find.text('My Lesson'), findsOneWidget);
      expect(find.textContaining('42'), findsWidgets);
      expect(find.text('Aula concluída!'), findsOneWidget);
    });

    testWidgets('invokes onContinue when the continue button is tapped', (tester) async {
      var continued = false;
      await tester.pumpWidget(buildTestable(onContinue: () => continued = true));
      await tester.pump();

      await tester.tap(find.byType(GameButton));
      await tester.pump();

      expect(continued, isTrue);
    });

    testWidgets('invokes onBackToAcademy when the text button is tapped', (tester) async {
      var wentBack = false;
      await tester.pumpWidget(buildTestable(onBackToAcademy: () => wentBack = true));
      await tester.pump();

      await tester.tap(find.byType(TextButton));
      await tester.pump();

      expect(wentBack, isTrue);
    });
  });
}
