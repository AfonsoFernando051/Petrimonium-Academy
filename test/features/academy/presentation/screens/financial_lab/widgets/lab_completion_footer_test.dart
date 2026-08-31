import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/data/datasources/lab_remote_datasource.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_progress_local_repository.dart';
import 'package:petrimonium/features/academy/domain/entities/lab_simulator.dart';
import 'package:petrimonium/features/academy/presentation/controllers/lab_completion_controller.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/widgets/lab_completion_footer.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class MockLabRemoteDataSource extends Mock implements LabRemoteDataSource {}

void main() {
  late LabCompletionController controller;

  setUp(() {
    Translator.currentLanguage = 'pt';
    SharedPreferences.setMockInitialValues({});
    controller = LabCompletionController(
      repository: AcademyProgressLocalRepository(),
      mascotController: MascotController(repository: FakeMascotRepository()),
      remoteDataSource: MockLabRemoteDataSource(),
    );
  });

  Widget wrap(Widget child) =>
      MaterialApp(theme: AppTheme.dark, home: Scaffold(body: child));

  group('LabCompletionFooter', () {
    testWidgets('is disabled when canComplete is false', (tester) async {
      await tester.pumpWidget(
        wrap(
          LabCompletionFooter(
            simulatorId: LabSimulatorId.compoundInterest,
            resolvedTitle: 'Juros Compostos',
            controller: controller,
            canComplete: false,
          ),
        ),
      );

      // GameButton disables its own InkWell's onTap when disabled; the
      // observable proxy here is that tapping never marks it completed.
      await tester.tap(find.text('Concluir simulação'));
      await tester.pump();
      expect(controller.isCompleted(LabSimulatorId.compoundInterest), isFalse);
    });

    testWidgets('tapping when canComplete is true marks the simulator completed', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          LabCompletionFooter(
            simulatorId: LabSimulatorId.compoundInterest,
            resolvedTitle: 'Juros Compostos',
            controller: controller,
            canComplete: true,
          ),
        ),
      );

      await tester.tap(find.text('Concluir simulação'));
      await tester.pump();

      expect(controller.isCompleted(LabSimulatorId.compoundInterest), isTrue);
    });
  });
}
