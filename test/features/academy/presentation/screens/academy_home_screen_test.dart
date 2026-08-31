import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/features/academy/data/datasources/academy_remote_datasource.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_catalog_repository.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_progress_local_repository.dart';
import 'package:petrimonium/features/academy/presentation/screens/academy_domain_detail_screen.dart';
import 'package:petrimonium/features/academy/presentation/screens/financial_lab/financial_lab_home_screen.dart';
import 'package:petrimonium/features/academy/presentation/screens/academy_home_screen.dart';
import 'package:petrimonium/features/academy/presentation/screens/lesson_screen.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/presentation/companion/pet_companion_controller.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../academy_test_fixtures.dart';

class MockAcademyCatalogRepository extends Mock implements AcademyCatalogRepository {}

class MockAcademyRemoteDataSource extends Mock implements AcademyRemoteDataSource {}

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
  late PetCompanionController companionController;

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
    companionController = PetCompanionController(mascotController: mascotController);
  });

  Widget buildTestable() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: AcademyHomeScreen(
          mascotController: mascotController,
          companionController: companionController,
        ),
      ),
    );
  }

  Future<void> pumpUntilLoaded(WidgetTester tester) async {
    // Never pumpAndSettle — this screen has no CosmicBackground of its own
    // (it's embedded in DashboardScreen's shared one), but its GameButton
    // CTA uses pulse:true (a repeating AnimationController), so the same
    // rule applies. Several plain pumps flush the controller's async load()
    // chain (progress load -> catalog cache -> remote merge).
    for (var i = 0; i < 8; i++) {
      await tester.pump();
    }
    // The companion nudge (once a next lesson/review is known) and
    // MascotController's reactive animation each start their own Timer (up
    // to 9s) — flush it now so it doesn't outlive the test as a pending
    // timer (mascot/companion controllers are owned by the test, not the
    // screen, so nothing else cancels them).
    await tester.pump(const Duration(seconds: 10));
  }

  group('AcademyHomeScreen', () {
    testWidgets('renders the level header, continue CTA and domain list once loaded', (tester) async {
      await tester.pumpWidget(buildTestable());
      await pumpUntilLoaded(tester);

      expect(find.text(testLesson1.title), findsOneWidget); // continue card's next lesson
      expect(find.text(testDomain.title), findsOneWidget);
    });

    testWidgets('navigates to LessonScreen when the continue CTA is tapped', (tester) async {
      await tester.pumpWidget(buildTestable());
      await pumpUntilLoaded(tester);

      // The continue CTA is a GameButton — the lesson title text above it
      // isn't itself tappable.
      await tester.tap(find.byType(GameButton));
      await pumpUntilLoaded(tester);

      expect(find.byType(LessonScreen), findsOneWidget);
    });

    testWidgets('navigates to AcademyDomainDetailScreen when a domain is tapped', (tester) async {
      await tester.pumpWidget(buildTestable());
      await pumpUntilLoaded(tester);

      await tester.ensureVisible(find.text(testDomain.title));
      await tester.pump();
      await tester.tap(find.text(testDomain.title));
      await pumpUntilLoaded(tester);

      expect(find.byType(AcademyDomainDetailScreen), findsOneWidget);
    });

    testWidgets('navigates to FinancialLabHomeScreen when the lab entry card is tapped', (tester) async {
      await tester.pumpWidget(buildTestable());
      await pumpUntilLoaded(tester);

      await tester.ensureVisible(find.byIcon(Icons.science_outlined));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.science_outlined));
      await pumpUntilLoaded(tester);

      expect(find.byType(FinancialLabHomeScreen), findsOneWidget);
    });
  });
}
