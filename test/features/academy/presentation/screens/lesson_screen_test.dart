import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/features/academy/data/datasources/academy_remote_datasource.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_progress_local_repository.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/academy/presentation/screens/lesson_screen.dart';
import 'package:petrimonium/features/academy/presentation/widgets/lesson_complete_card.dart';
import 'package:petrimonium/features/academy/presentation/widgets/steps/choice_question_step_view.dart';
import 'package:petrimonium/features/academy/presentation/widgets/steps/explanation_step_view.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/presentation/celebration/module_completion_share_overlay.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../academy_test_fixtures.dart';

class MockAcademyRemoteDataSource extends Mock
    implements AcademyRemoteDataSource {}

/// Minimal in-memory MascotRepository double — mirrors the one in
/// `mascot_controller_test.dart`; these tests only need a working
/// `MascotController`, not real persistence.
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
  late MockAcademyRemoteDataSource mockRemoteDataSource;
  late MascotController mascotController;

  setUp(() {
    Translator.currentLanguage = 'pt';
    SharedPreferences.setMockInitialValues({});

    DI.academyProgressRepository = AcademyProgressLocalRepository();

    mockRemoteDataSource = MockAcademyRemoteDataSource();
    // Every test's completion attempt "fails" (offline) — matches
    // LessonSessionController's local-first completion, which never blocks
    // on the network.
    when(
      () => mockRemoteDataSource.completeLesson(
        any(),
        perfectFirstTry: any(named: 'perfectFirstTry'),
      ),
    ).thenThrow(Exception('offline'));
    DI.academyRemoteDataSource = mockRemoteDataSource;

    mascotController = MascotController(repository: FakeMascotRepository());
  });

  Widget buildTestable({required Lesson lesson}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: LessonScreen(
        lesson: lesson,
        catalog: buildAcademyCatalogSnapshot(),
        mascotController: mascotController,
      ),
    );
  }

  group('LessonScreen', () {
    testWidgets(
      'renders an ExplanationStep and advances via the continue button',
      (tester) async {
        await tester.pumpWidget(buildTestable(lesson: testLesson1));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(ExplanationStepView), findsOneWidget);

        await tester.tap(find.byType(GameButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();
        // MascotController.triggerEventAnimation starts a 4s revert timer on
        // completion — flush it now so the test doesn't leave a pending timer
        // behind when the widget tree is torn down.
        await tester.pump(const Duration(seconds: 5));

        // testLesson1 has a single step, so the lesson completes.
        expect(find.byType(LessonCompleteCard), findsOneWidget);
      },
    );

    testWidgets('a ChoiceQuestionStep only allows advancing once answered', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestable(lesson: testLesson2));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ChoiceQuestionStepView), findsOneWidget);
      final continueButton = tester.widget<GameButton>(find.byType(GameButton));
      expect(continueButton.onPressed, isNull);

      await tester.tap(find.text('A'));
      await tester.pump();

      final continueButtonAfterAnswer = tester.widget<GameButton>(
        find.byType(GameButton),
      );
      expect(continueButtonAfterAnswer.onPressed, isNotNull);
    });

    testWidgets(
      'completing the lesson shows LessonCompleteCard with the earned xp',
      (tester) async {
        await tester.pumpWidget(buildTestable(lesson: testLesson3));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await tester.tap(find.byType(GameButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();
        // MascotController.triggerEventAnimation starts a 4s revert timer on
        // completion — flush it now so the test doesn't leave a pending timer
        // behind when the widget tree is torn down.
        await tester.pump(const Duration(seconds: 5));

        expect(find.byType(LessonCompleteCard), findsOneWidget);
        expect(find.text(testLesson3.title), findsOneWidget);
        expect(find.textContaining('${testLesson3.xpReward}'), findsWidgets);

        final completedIds = await DI.academyProgressRepository
            .loadCompletedLessonIds();
        expect(completedIds, contains(testLesson3.id));
      },
    );

    testWidgets(
      'finishing the final lesson of a module shows the social-share card',
      (tester) async {
        await DI.academyProgressRepository.markLessonCompleted(testLesson1.id);
        await DI.academyProgressRepository.markLessonCompleted(testLesson2.id);

        await tester.pumpWidget(buildTestable(lesson: testLesson3));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await tester.tap(find.byType(GameButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();

        expect(find.byType(ModuleCompletionShareOverlay), findsOneWidget);
        expect(find.text('Módulo concluído!'), findsOneWidget);
        expect(find.text(testModule.title), findsOneWidget);
        expect(find.text('Compartilhar'), findsOneWidget);

        await tester.pump(const Duration(seconds: 5));
      },
    );

    testWidgets(
      'tapping Continuar on LessonCompleteCard opens the next lesson in the module',
      (tester) async {
        await tester.pumpWidget(buildTestable(lesson: testLesson1));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await tester.tap(find.byType(GameButton), warnIfMissed: false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();
        await tester.pump(const Duration(seconds: 5));

        expect(find.byType(LessonCompleteCard), findsOneWidget);

        await tester.tap(find.byType(GameButton), warnIfMissed: false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(LessonCompleteCard), findsNothing);
        expect(find.byType(ChoiceQuestionStepView), findsOneWidget);
        expect(find.text('Prompt?'), findsOneWidget);
      },
    );
  });
}
