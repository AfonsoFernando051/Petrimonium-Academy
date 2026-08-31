import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_progress_local_repository.dart';
import 'package:petrimonium/features/academy/presentation/controllers/lab_completion_controller.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/diversification_lab_screen.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_companion_controller.dart';
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
    completionController = LabCompletionController(
      repository: AcademyProgressLocalRepository(),
      mascotController: mascotController,
    );
  });

  Widget buildTestable() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: DiversificationLabScreen(
        mascotController: mascotController,
        companionController: companionController,
        completionController: completionController,
      ),
    );
  }

  group('DiversificationLabScreen', () {
    testWidgets(
      'renders six category sliders and a valid default allocation',
      (tester) async {
        await tester.pumpWidget(buildTestable());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(Slider), findsNWidgets(6));
        // Default allocation sums to 100 — the total indicator shows it.
        expect(find.textContaining('100%'), findsWidgets);
        expect(
          find.text(
            Translator.translate('labDiversificationEffectiveAssetsLabel'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('shows the concentration shock result after tapping its button', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestable());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final shockButton = find.text(
        Translator.translate('labDiversificationConcentrationShockButton'),
      );
      await tester.ensureVisible(shockButton);
      await tester.pump();
      await tester.tap(shockButton);
      await tester.pump();

      // 40% (default STOCKS weight) * 30% = 12.0%.
      expect(find.textContaining('12.0%'), findsWidgets);
    });

    testWidgets('the market shock result is always exactly 15%', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestable());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final shockButton = find.text(
        Translator.translate('labDiversificationMarketShockButton'),
      );
      await tester.ensureVisible(shockButton);
      await tester.pump();
      await tester.tap(shockButton);
      await tester.pump();

      expect(
        find.text(Translator.translate('labDiversificationMarketShockResult')),
        findsOneWidget,
      );
    });
  });
}
