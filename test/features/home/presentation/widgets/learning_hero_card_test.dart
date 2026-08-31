import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/core/events/app_event_bus.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/home/presentation/widgets/learning_hero_card.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

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
    Translator.currentLanguage = 'pt';
    repository = FakeMascotRepository();
    controller = MascotController(repository: repository);
  });

  tearDown(() => controller.dispose());

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: LearningHeroCard(mascotController: controller),
      ),
    );
  }

  group('LearningHeroCard', () {
    testWidgets('renders the level number and XP progress label', (tester) async {
      repository.profileToReturn = PetProfile(xp: 0);
      await controller.loadProfile();

      await tester.pumpWidget(buildTestableWidget());
      // Hosts several repeating AnimationControllers (breathe/float/glow)
      // — never call pumpAndSettle.
      await tester.pump();
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
      expect(find.textContaining('XP para o próximo nível'), findsOneWidget);
    });

    testWidgets('shows progress toward the next evolution when not yet at max tier', (tester) async {
      repository.profileToReturn = PetProfile(xp: 50, stage: PetEvolutionStage.babyDog);
      await controller.loadProfile();

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('XP para a próxima evolução'), findsOneWidget);
      expect(find.textContaining('50/100 XP'), findsOneWidget);
    });

    testWidgets('shows the max-evolution label at the final tier', (tester) async {
      repository.profileToReturn = PetProfile(xp: 25000, stage: PetEvolutionStage.goldenFinanceDog);
      await controller.loadProfile();

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      expect(find.text('Evolução máxima alcançada'), findsOneWidget);
    });

    testWidgets('tapping the pet does not throw', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byType(GestureDetector).first, warnIfMissed: false);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('honors disableAnimations — renders correctly with no crash and no error text', (tester) async {
      repository.profileToReturn = PetProfile(xp: 50, stage: PetEvolutionStage.babyDog);
      await controller.loadProfile();

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: buildTestableWidget(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));

      expect(tester.takeException(), isNull);
      expect(find.textContaining('50/100 XP'), findsOneWidget);
    });

    testWidgets('reacts to a UserLeveledUpEvent from AppEventBus without throwing', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      AppEventBus.instance.emit(const UserLeveledUpEvent(5));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 1400));

      expect(tester.takeException(), isNull);
    });

    testWidgets('reacts to a PetEvolvedEvent from AppEventBus without throwing', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      AppEventBus.instance.emit(const PetEvolvedEvent(PetEvolutionStage.teenDog));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 1400));

      expect(tester.takeException(), isNull);
    });

    testWidgets('unrelated AppEvents do not trigger the celebration path', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      AppEventBus.instance.emit(const LessonCompletedEvent('some_lesson'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
    });
  });
}
