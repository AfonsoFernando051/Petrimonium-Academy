import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/core/events/app_event_bus.dart';
import 'package:petrimonium/features/academy/data/datasources/lab_remote_datasource.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_progress_local_repository.dart';
import 'package:petrimonium/features/academy/domain/entities/lab_simulator.dart';
import 'package:petrimonium/features/academy/domain/entities/simulator_completion_result.dart';
import 'package:petrimonium/features/academy/presentation/controllers/lab_completion_controller.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockLabRemoteDataSource extends Mock implements LabRemoteDataSource {}

/// Records every `saveXp` call rather than actually persisting — lets tests
/// assert on the exact XP `MascotController.evaluateEvolution` was fed.
class RecordingMascotRepository implements MascotRepository {
  int? lastSavedXp;

  @override
  Future<PetProfile> loadProfile() async => PetProfile();

  @override
  Future<void> saveName(String name) async {}

  @override
  Future<void> saveStage(PetEvolutionStage stage) async {}

  @override
  Future<void> saveXp(int xp) async {
    lastSavedXp = xp;
  }

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
  late AcademyProgressLocalRepository repository;
  late RecordingMascotRepository mascotRepository;
  late MascotController mascotController;
  late MockLabRemoteDataSource remoteDataSource;
  late LabCompletionController controller;
  late List<AppEvent> emittedEvents;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = AcademyProgressLocalRepository();
    mascotRepository = RecordingMascotRepository();
    mascotController = MascotController(repository: mascotRepository);
    remoteDataSource = MockLabRemoteDataSource();
    controller = LabCompletionController(
      repository: repository,
      mascotController: mascotController,
      remoteDataSource: remoteDataSource,
    );
    emittedEvents = [];
  });

  group('LabCompletionController.completeSimulator', () {
    test('marks completed locally before attempting the remote sync', () async {
      // The remote call never resolves during this assertion — proves the
      // local mark happens independent of (and before) the network attempt.
      when(() => remoteDataSource.completeSimulator(any())).thenAnswer(
        (_) => Completer<SimulatorCompletionResult>().future,
      );

      final future = controller.completeSimulator(
        LabSimulatorId.compoundInterest,
        'Juros Compostos',
      );
      await Future.delayed(Duration.zero);

      expect(controller.isCompleted(LabSimulatorId.compoundInterest), isTrue);
      expect(
        await repository.loadPendingSyncSimulatorIds(),
        contains('compound_interest'),
      );

      // Avoid leaking a pending timer/future into the next test.
      unawaited(future);
    });

    test(
      'emits FinancialLabSimulatorCompletedEvent exactly once regardless of sync outcome',
      () async {
        when(
          () => remoteDataSource.completeSimulator('compound_interest'),
        ).thenThrow(Exception('offline'));
        final subscription = AppEventBus.instance.stream.listen(
          emittedEvents.add,
        );

        await controller.completeSimulator(
          LabSimulatorId.compoundInterest,
          'Juros Compostos',
        );
        // AppEventBus's broadcast controller dispatches asynchronously —
        // flush the microtask queue before reading what was delivered.
        await Future<void>.delayed(Duration.zero);
        await subscription.cancel();

        final labEvents = emittedEvents
            .whereType<FinancialLabSimulatorCompletedEvent>()
            .toList();
        expect(labEvents, hasLength(1));
        expect(labEvents.single.simulatorTitle, 'Juros Compostos');
      },
    );

    test(
      'a throwing remote call leaves the simulator pending, without rethrowing',
      () async {
        when(
          () => remoteDataSource.completeSimulator('inflation'),
        ).thenThrow(Exception('offline'));

        await controller.completeSimulator(LabSimulatorId.inflation, 'Inflação');

        expect(
          await repository.loadPendingSyncSimulatorIds(),
          contains('inflation'),
        );
      },
    );

    test(
      'on success, clears the pending flag and feeds the server\'s totalXp to MascotController',
      () async {
        when(() => remoteDataSource.completeSimulator('compound_interest'))
            .thenAnswer(
          (_) async => const SimulatorCompletionResult(
            simulatorId: 'compound_interest',
            alreadyCompleted: false,
            xpAwarded: 50,
            totalXp: 250,
            level: 3,
            xpIntoLevel: 0,
            xpForNextLevel: 100,
          ),
        );

        await controller.completeSimulator(
          LabSimulatorId.compoundInterest,
          'Juros Compostos',
        );

        expect(
          await repository.loadPendingSyncSimulatorIds(),
          isNot(contains('compound_interest')),
        );
        // The controller never fabricates XP client-side — it must pass
        // through exactly the server's number.
        expect(mascotRepository.lastSavedXp, 250);
      },
    );

    test('never emits XpGainedEvent directly — only MascotController may', () async {
      when(() => remoteDataSource.completeSimulator('compound_interest'))
          .thenAnswer(
        (_) async => const SimulatorCompletionResult(
          simulatorId: 'compound_interest',
          alreadyCompleted: false,
          xpAwarded: 50,
          totalXp: 50,
          level: 2,
          xpIntoLevel: 0,
          xpForNextLevel: 100,
        ),
      );
      final subscription = AppEventBus.instance.stream.listen(
        emittedEvents.add,
      );

      await controller.completeSimulator(
        LabSimulatorId.compoundInterest,
        'Juros Compostos',
      );
      // AppEventBus's broadcast controller dispatches asynchronously — flush
      // the microtask queue before reading what was delivered.
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      // XpGainedEvent legitimately fires here too — but only because
      // MascotController.evaluateEvolution (not LabCompletionController)
      // diffed the XP itself, exactly like the lesson-completion flow.
      expect(emittedEvents.whereType<XpGainedEvent>(), hasLength(1));
    });

    test('completing an already-completed simulator is a no-op', () async {
      when(() => remoteDataSource.completeSimulator('compound_interest'))
          .thenAnswer(
        (_) async => const SimulatorCompletionResult(
          simulatorId: 'compound_interest',
          alreadyCompleted: false,
          xpAwarded: 50,
          totalXp: 50,
          level: 2,
          xpIntoLevel: 0,
          xpForNextLevel: 100,
        ),
      );

      await controller.completeSimulator(
        LabSimulatorId.compoundInterest,
        'Juros Compostos',
      );
      await controller.completeSimulator(
        LabSimulatorId.compoundInterest,
        'Juros Compostos',
      );

      verify(
        () => remoteDataSource.completeSimulator('compound_interest'),
      ).called(1);
    });
  });

  group('LabCompletionController.load', () {
    test('retries a pending sync left over from a killed app', () async {
      await repository.markSimulatorCompleted('inflation');
      await repository.markSimulatorPendingSync('inflation');
      when(
        () => remoteDataSource.getCompletedSimulatorIds(),
      ).thenAnswer((_) async => {});
      when(() => remoteDataSource.completeSimulator('inflation')).thenAnswer(
        (_) async => const SimulatorCompletionResult(
          simulatorId: 'inflation',
          alreadyCompleted: false,
          xpAwarded: 50,
          totalXp: 50,
          level: 2,
          xpIntoLevel: 0,
          xpForNextLevel: 100,
        ),
      );

      await controller.load();

      expect(
        await repository.loadPendingSyncSimulatorIds(),
        isNot(contains('inflation')),
      );
    });
  });
}
