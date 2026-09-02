import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';
import 'package:petrimonium/features/academy/presentation/widgets/steps/choice_question_step_view.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// Minimal in-memory MascotRepository double, mirrors the one in
/// `pet_companion_header_test.dart` — CAT rather than the default DOG, since
/// DOG's real `dog.riv` crashes `flutter_tester` on this toolchain (a
/// pre-existing environment gap; see that file's comment). CAT has no
/// bundled Rive asset, so these tests deterministically exercise the
/// always-reachable Lottie/PNG fallback instead.
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

  const step = ChoiceQuestionStep(
    framing: ChoiceStepFraming.microExercise,
    prompt: 'What is 2+2?',
    options: ['3', '4', '5'],
    correctIndex: 1,
    explanation: 'Because math.',
  );

  Widget buildTestable({
    int? selectedIndex,
    bool hasAnswered = false,
    bool answeredCorrectly = false,
    int stepIndex = 0,
    ValueChanged<int>? onSelect,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: ChoiceQuestionStepView(
          step: step,
          stepIndex: stepIndex,
          selectedIndex: selectedIndex,
          hasAnswered: hasAnswered,
          answeredCorrectly: answeredCorrectly,
          onSelect: onSelect ?? (_) {},
          mascotController: mascotController,
        ),
      ),
    );
  }

  group('ChoiceQuestionStepView', () {
    testWidgets('renders the prompt and all options', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('What is 2+2?'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('EXERCÍCIO RÁPIDO'), findsOneWidget);
    });

    testWidgets('uses the apply label for the apply framing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: ChoiceQuestionStepView(
              step: const ChoiceQuestionStep(
                framing: ChoiceStepFraming.apply,
                prompt: 'Apply prompt',
                options: ['A', 'B'],
                correctIndex: 0,
                explanation: 'exp',
              ),
              stepIndex: 0,
              selectedIndex: null,
              hasAnswered: false,
              answeredCorrectly: false,
              onSelect: (_) {},
              mascotController: mascotController,
            ),
          ),
        ),
      );

      expect(find.text('APLIQUE O QUE APRENDEU'), findsOneWidget);
    });

    testWidgets('invokes onSelect when an option is tapped before answering', (tester) async {
      int? selected;
      await tester.pumpWidget(buildTestable(onSelect: (i) => selected = i));

      await tester.tap(find.text('4'));
      await tester.pump();

      expect(selected, 1);
    });

    testWidgets('shows correct feedback when the selected answer matches correctIndex', (tester) async {
      await tester.pumpWidget(buildTestable(selectedIndex: 1, hasAnswered: true, stepIndex: 0));
      await tester.pump();

      expect(find.text('Because math.'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      // Pet-voiced title, rotated by stepIndex (0 → the first pool entry).
      expect(find.text('Isso mesmo!'), findsOneWidget);
    });

    testWidgets('shows incorrect feedback (still supportive) when the selected answer is wrong', (tester) async {
      await tester.pumpWidget(buildTestable(selectedIndex: 0, hasAnswered: true, stepIndex: 0));
      await tester.pump();

      expect(find.text('Because math.'), findsOneWidget);
      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
      expect(find.text('Quase! Vamos entender:'), findsOneWidget);
    });

    testWidgets('rotates the feedback title by stepIndex instead of repeating the same line', (tester) async {
      await tester.pumpWidget(buildTestable(selectedIndex: 1, hasAnswered: true, stepIndex: 1));
      await tester.pump();

      expect(find.text('Isso! Você entendeu.'), findsOneWidget);
    });

    testWidgets('does not invoke onSelect once answeredCorrectly is true', (tester) async {
      var callCount = 0;
      await tester.pumpWidget(
        buildTestable(
          selectedIndex: 1,
          hasAnswered: true,
          answeredCorrectly: true,
          onSelect: (_) => callCount++,
        ),
      );

      await tester.tap(find.text('3'), warnIfMissed: false);
      await tester.pump();

      expect(callCount, 0);
    });

    testWidgets('still invokes onSelect after a wrong answer, allowing a retry', (tester) async {
      var callCount = 0;
      await tester.pumpWidget(
        buildTestable(
          selectedIndex: 0,
          hasAnswered: true,
          answeredCorrectly: false,
          onSelect: (_) => callCount++,
        ),
      );

      await tester.tap(find.text('4'));
      await tester.pump();

      expect(callCount, 1);
    });
  });
}
