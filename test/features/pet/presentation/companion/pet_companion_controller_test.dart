import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/core/events/app_event_bus.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_companion_controller.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_context.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal in-memory MascotRepository double — mirrors the one in
/// `mascot_controller_test.dart`; only `loadProfile` matters here since
/// these tests only read `MascotController.profile.xp`.
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

Future<void> flushMicrotasks() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeMascotRepository mascotRepository;
  late MascotController mascotController;
  late PetCompanionController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mascotRepository = FakeMascotRepository();
    mascotController = MascotController(repository: mascotRepository);
    controller = PetCompanionController(mascotController: mascotController);
  });

  tearDown(() {
    controller.dispose();
    mascotController.dispose();
  });

  group('enterContext', () {
    test(
      'offers the home nudge once the user is past halfway to the next level',
      () async {
        // Level 1->2 needs 50 total XP; 30 is 60% of the way there.
        mascotRepository.profileToReturn = PetProfile(xp: 30);
        await mascotController.loadProfile();

        controller.enterContext(PetContext.home);

        expect(controller.currentMessage?.id, 'home_xp_to_next_level');
        expect(controller.currentMessage?.params, {'xp': '20'});
      },
    );

    test(
      'offers nothing when the user just leveled up (progress near zero)',
      () async {
        mascotRepository.profileToReturn = PetProfile(xp: 0);
        await mascotController.loadProfile();

        controller.enterContext(PetContext.home);

        expect(controller.currentMessage, isNull);
      },
    );

    test(
      'allowAmbientFallback: false (the default) stays silent with nothing else to say',
      () async {
        mascotRepository.profileToReturn = PetProfile(xp: 0);
        await mascotController.loadProfile();

        controller.enterContext(PetContext.home);

        expect(controller.currentMessage, isNull);
      },
    );

    test(
      'allowAmbientFallback: true offers the motivational fallback with nothing else to say',
      () async {
        mascotRepository.profileToReturn = PetProfile(xp: 0);
        await mascotController.loadProfile();

        controller.enterContext(PetContext.home, allowAmbientFallback: true);

        expect(controller.currentMessage, isNotNull);
        expect(controller.currentMessage!.id, startsWith('home_motivation_'));
      },
    );

    test(
      'allowAmbientFallback: true substitutes the motivational fallback once the real '
      'nudge is cooling down, instead of going silent',
      () async {
        mascotRepository.profileToReturn = PetProfile(xp: 0);
        await mascotController.loadProfile();
        const data = {'lessonTitle': 'Renda Fixa Básica'};

        // First visit: the real continue-lesson nudge shows and starts
        // cooling down.
        controller.enterContext(PetContext.home, data: data, allowAmbientFallback: true);
        expect(controller.currentMessage?.id, 'academy_continue_lesson');
        controller.dismiss();

        // A later visit the same day, same data — without the fallback,
        // `PetCompanionController._offer` would silently suppress the
        // still-cooling-down id and show nothing at all.
        controller.enterContext(PetContext.home, data: data, allowAmbientFallback: true);

        expect(controller.currentMessage, isNotNull);
        expect(controller.currentMessage!.id, startsWith('home_motivation_'));
      },
    );

    test(
      'a page-enter nudge never interrupts a message already showing',
      () async {
        mascotRepository.profileToReturn = PetProfile(xp: 30);
        await mascotController.loadProfile();

        controller.enterContext(PetContext.home);
        expect(controller.currentMessage?.id, 'home_xp_to_next_level');

        // Mentor's nudge exists unconditionally, but shouldn't preempt it.
        controller.enterContext(PetContext.mentor);

        expect(controller.currentMessage?.id, 'home_xp_to_next_level');
      },
    );

    test(
      'a mission one lesson away from completion outranks the near-level-up nudge',
      () async {
        // Same "past halfway" XP as the near-level-up test above — the
        // mission signal must still win, since it matches whatever
        // NextActionResolver picked as Home's headline CTA.
        mascotRepository.profileToReturn = PetProfile(xp: 30);
        await mascotController.loadProfile();

        controller.enterContext(PetContext.home, data: {'missionTitle': 'Aula do Dia'});

        expect(controller.currentMessage?.id, 'home_mission_almost_done');
        expect(controller.currentMessage?.params, {'missionTitle': 'Aula do Dia'});
      },
    );

    test(
      'a returning-after-inactivity greeting outranks everything else in _homeNudge',
      () async {
        mascotRepository.profileToReturn = PetProfile(xp: 30);
        await mascotController.loadProfile();

        controller.enterContext(
          PetContext.home,
          data: {'missionTitle': 'Aula do Dia', 'daysSinceLastSession': '5'},
        );

        expect(controller.currentMessage?.id, startsWith('home_return_greeting_'));
      },
    );

    test(
      'a gap shorter than the sleep threshold does not trigger the return greeting',
      () async {
        mascotRepository.profileToReturn = PetProfile(xp: 30);
        await mascotController.loadProfile();

        controller.enterContext(PetContext.home, data: {'daysSinceLastSession': '1'});

        // Falls through to the near-level-up nudge instead.
        expect(controller.currentMessage?.id, 'home_xp_to_next_level');
      },
    );
  });

  group('app events', () {
    test(
      'a level-up reaction replaces a lower-priority nudge already showing',
      () async {
        mascotRepository.profileToReturn = PetProfile(xp: 30);
        await mascotController.loadProfile();
        controller.enterContext(PetContext.home);
        expect(controller.currentMessage?.priority.name, 'normal');

        AppEventBus.instance.emit(const UserLeveledUpEvent(2));
        await flushMicrotasks();

        expect(controller.currentMessage?.id, 'event_level_up');
        expect(controller.currentMessage?.params, {'level': '2'});
      },
    );

    test(
      'a same-tick normal event cannot clobber a just-shown high-priority celebration',
      () async {
        AppEventBus.instance.emit(const UserLeveledUpEvent(3));
        await flushMicrotasks();
        expect(controller.currentMessage?.id, 'event_level_up');

        AppEventBus.instance.emit(
          const XpGainedEvent(amount: 10, newTotalXp: 40),
        );
        await flushMicrotasks();

        // Still the level-up message — the XP-gain reaction was suppressed by
        // the high-priority grace window (`PetCompanionController._offer`).
        expect(controller.currentMessage?.id, 'event_level_up');
      },
    );

    test('a first-investment event shows the Portfolio bridge message', () async {
      AppEventBus.instance.emit(const FirstInvestmentAddedEvent());
      await flushMicrotasks();

      expect(controller.currentMessage?.id, 'event_first_investment');
      expect(controller.currentMessage?.action?.destination, PetContext.academy);
    });

    test('a high-concentration event carries the real ticker/percent', () async {
      AppEventBus.instance.emit(
        const HighConcentrationDetectedEvent(ticker: 'PETR4', percent: 55),
      );
      await flushMicrotasks();

      expect(controller.currentMessage?.id, 'event_high_concentration_PETR4');
      expect(controller.currentMessage?.params, {'ticker': 'PETR4', 'percent': '55'});
      expect(controller.currentMessage?.action?.destination, PetContext.mentor);
    });

    test('a mission-completed event carries the resolved mission title', () async {
      AppEventBus.instance.emit(const MissionCompletedEvent('Aula do Dia'));
      await flushMicrotasks();

      expect(controller.currentMessage?.id, 'event_mission_completed_Aula do Dia');
      expect(controller.currentMessage?.params, {'title': 'Aula do Dia'});
      expect(controller.currentMessage?.priority.name, 'high');
    });
  });

  test('dismiss clears the current message', () async {
    mascotRepository.profileToReturn = PetProfile(xp: 30);
    await mascotController.loadProfile();
    controller.enterContext(PetContext.home);
    expect(controller.isSpeaking, isTrue);

    controller.dismiss();

    expect(controller.isSpeaking, isFalse);
    expect(controller.currentMessage, isNull);
  });
}
