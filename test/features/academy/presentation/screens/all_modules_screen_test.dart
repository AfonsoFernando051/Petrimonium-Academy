import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/data/datasources/academy_remote_datasource.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_catalog_repository.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_progress_local_repository.dart';
import 'package:petrimonium/features/academy/presentation/screens/all_modules_screen.dart';
import 'package:petrimonium/features/academy/presentation/screens/module_detail_screen.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../academy_test_fixtures.dart';

class MockAcademyCatalogRepository extends Mock implements AcademyCatalogRepository {}

class MockAcademyRemoteDataSource extends Mock implements AcademyRemoteDataSource {}

/// Minimal in-memory MascotRepository double — mirrors
/// `module_detail_screen_test.dart`.
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
  Future<void> saveEquippedAccessories(Map<AccessoryType, PetAccessoryId> equipped) async {}
  @override
  Future<void> saveUnlockedAccessories(Set<PetAccessoryId> unlocked) async {}
  @override
  Future<void> saveLastActiveAt(DateTime lastActiveAt) async {}
}

void main() {
  late MockAcademyCatalogRepository mockCatalogRepository;
  late MockAcademyRemoteDataSource mockRemoteDataSource;
  late MascotController mascotController;

  setUp(() {
    Translator.currentLanguage = 'pt';
    SharedPreferences.setMockInitialValues({});

    DI.academyProgressRepository = AcademyProgressLocalRepository();

    mockCatalogRepository = MockAcademyCatalogRepository();
    when(() => mockCatalogRepository.loadCached(any())).thenAnswer((_) async => buildAcademyCatalogSnapshot());
    when(() => mockCatalogRepository.fetchAndCache(any())).thenAnswer((_) async => buildAcademyCatalogSnapshot());
    DI.academyCatalogRepository = mockCatalogRepository;

    mockRemoteDataSource = MockAcademyRemoteDataSource();
    when(() => mockRemoteDataSource.getCompletedLessonIds()).thenAnswer((_) async => {});
    DI.academyRemoteDataSource = mockRemoteDataSource;

    mascotController = MascotController(repository: FakeMascotRepository());
  });

  Widget buildTestable() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: AllModulesScreen(mascotController: mascotController),
    );
  }

  Future<void> pumpUntilLoaded(WidgetTester tester) async {
    // Never pumpAndSettle — CosmicBackground's AnimationControllers repeat
    // indefinitely.
    for (var i = 0; i < 8; i++) {
      await tester.pump();
    }
  }

  group('AllModulesScreen', () {
    testWidgets('renders the title and every real module, not just a preview', (tester) async {
      await tester.pumpWidget(buildTestable());
      await pumpUntilLoaded(tester);

      expect(find.text('Sua trilha completa'), findsOneWidget);
      expect(find.text(testModule.title), findsOneWidget);
    });

    testWidgets('tapping an available module opens ModuleDetailScreen', (tester) async {
      await tester.pumpWidget(buildTestable());
      await pumpUntilLoaded(tester);

      await tester.tap(find.text(testModule.title));
      await pumpUntilLoaded(tester);

      expect(find.byType(ModuleDetailScreen), findsOneWidget);
    });

    testWidgets('the back button pops the screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => AllModulesScreen(mascotController: mascotController)),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await pumpUntilLoaded(tester);
      expect(find.byType(AllModulesScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(AllModulesScreen), findsNothing);
    });
  });
}
