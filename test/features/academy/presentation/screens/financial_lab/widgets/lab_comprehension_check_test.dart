import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_comprehension_check.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

class FakeMascotRepository implements MascotRepository {
  @override
  Future<PetProfile> loadProfile() async => PetProfile();
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

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  final step = const ChoiceQuestionStep(
    framing: ChoiceStepFraming.microExercise,
    prompt: 'Pergunta de teste?',
    options: ['Errada', 'Certa', 'Também errada'],
    correctIndex: 1,
    explanation: 'Explicação de teste.',
  );

  Widget wrap(Widget child) =>
      MaterialApp(theme: AppTheme.dark, home: Scaffold(body: child));

  group('LabComprehensionCheck', () {
    testWidgets(
      'picking the wrong option shows feedback but does not fire onAnsweredCorrectly',
      (tester) async {
        var fired = false;
        await tester.pumpWidget(
          wrap(
            LabComprehensionCheck(
              step: step,
              mascotController: MascotController(
                repository: FakeMascotRepository(),
              ),
              onAnsweredCorrectly: () => fired = true,
            ),
          ),
        );

        await tester.tap(find.text('Errada'));
        await tester.pump();

        expect(find.text('Explicação de teste.'), findsOneWidget);
        expect(fired, isFalse);
        // Options stay tappable after a wrong answer (no-punishment retry).
        expect(find.text('Certa'), findsOneWidget);
      },
    );

    testWidgets(
      'picking the correct option fires onAnsweredCorrectly exactly once',
      (tester) async {
        var fireCount = 0;
        await tester.pumpWidget(
          wrap(
            LabComprehensionCheck(
              step: step,
              mascotController: MascotController(
                repository: FakeMascotRepository(),
              ),
              onAnsweredCorrectly: () => fireCount++,
            ),
          ),
        );

        await tester.tap(find.text('Certa'));
        await tester.pump();

        expect(fireCount, 1);
        expect(find.text('Explicação de teste.'), findsOneWidget);
      },
    );
  });
}
