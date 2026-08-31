import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/data/datasources/lab_remote_datasource.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_progress_local_repository.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/compound_interest_lab_screen.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/financial_lab_home_screen.dart';
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

class MockLabRemoteDataSource extends Mock implements LabRemoteDataSource {}

void main() {
  late MascotController mascotController;
  late PetCompanionController companionController;
  late MockLabRemoteDataSource mockLabRemoteDataSource;

  setUp(() {
    Translator.currentLanguage = 'pt';
    SharedPreferences.setMockInitialValues({});
    mascotController = MascotController(repository: FakeMascotRepository());
    companionController = PetCompanionController(
      mascotController: mascotController,
    );

    DI.academyProgressRepository = AcademyProgressLocalRepository();
    mockLabRemoteDataSource = MockLabRemoteDataSource();
    when(
      () => mockLabRemoteDataSource.getCompletedSimulatorIds(),
    ).thenAnswer((_) async => {});
    DI.labRemoteDataSource = mockLabRemoteDataSource;
  });

  Widget buildTestable() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: FinancialLabHomeScreen(
        mascotController: mascotController,
        companionController: companionController,
        onOpenWallet: () {},
      ),
    );
  }

  group('FinancialLabHomeScreen', () {
    testWidgets(
      'renders all five simulator tiles as available',
      (tester) async {
        await tester.pumpWidget(buildTestable());
        // CosmicBackground has repeating AnimationControllers — never
        // pumpAndSettle here.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byIcon(Icons.trending_up_rounded), findsOneWidget);
        expect(find.byIcon(Icons.shopping_basket_outlined), findsOneWidget);
        // All five simulators are available now.
        expect(find.byIcon(Icons.chevron_right), findsNWidgets(5));
        expect(find.byIcon(Icons.account_balance_outlined), findsOneWidget);
        expect(find.text('EM BREVE'), findsNothing);
      },
    );

    testWidgets(
      'navigates to CompoundInterestLabScreen when the compound interest tile is tapped',
      (tester) async {
        await tester.pumpWidget(buildTestable());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await tester.tap(find.byIcon(Icons.trending_up_rounded));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(CompoundInterestLabScreen), findsOneWidget);
      },
    );
  });
}
