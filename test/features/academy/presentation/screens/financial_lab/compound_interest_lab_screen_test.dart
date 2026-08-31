import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_progress_local_repository.dart';
import 'package:petrimonium/features/academy/presentation/controllers/lab_completion_controller.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/compound_interest_lab_screen.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_companion_controller.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal in-memory MascotRepository double — mirrors the one in
/// `academy_home_screen_test.dart`; these tests only need a working
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
  late MascotController mascotController;
  late PetCompanionController companionController;
  late LabCompletionController completionController;

  setUp(() {
    Translator.currentLanguage = 'pt';
    SharedPreferences.setMockInitialValues({});
    mascotController = MascotController(repository: FakeMascotRepository());
    companionController = PetCompanionController(
      mascotController: mascotController,
    );
    // No `remoteDataSource` — these tests exercise the local-first UI only,
    // never a real network call.
    completionController = LabCompletionController(
      repository: AcademyProgressLocalRepository(),
      mascotController: mascotController,
    );
  });

  Widget buildTestable() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: CompoundInterestLabScreen(
        mascotController: mascotController,
        companionController: companionController,
        completionController: completionController,
        onOpenWallet: () {},
      ),
    );
  }

  group('CompoundInterestLabScreen', () {
    testWidgets(
      'renders sliders, summary stats and the chart with default inputs',
      (tester) async {
        await tester.pumpWidget(buildTestable());
        // CosmicBackground has repeating AnimationControllers — never
        // pumpAndSettle here.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(Slider), findsNWidgets(4));
        expect(
          find.text('10'),
          findsWidgets,
        ); // default years (also appears as a chart axis label)
        expect(find.text('8.0%'), findsOneWidget); // default annual return
      },
    );

    testWidgets(
      'changing the years slider updates the displayed value and explanation',
      (tester) async {
        await tester.pumpWidget(buildTestable());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        final yearsSlider = find.byType(Slider).last;
        // Drag far to the right to push years to its max (40).
        await tester.drag(yearsSlider, const Offset(400, 0));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('40'), findsWidgets);
      },
    );
  });
}
