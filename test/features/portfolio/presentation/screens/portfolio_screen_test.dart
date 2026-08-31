import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/friendly_error_message.dart';
import 'package:petrimonium/core/widgets/error_state_view.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/mission_status.dart';
import 'package:petrimonium/features/portfolio/presentation/controllers/portfolio_controller.dart';
import 'package:petrimonium/features/portfolio/presentation/screens/portfolio_screen.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/achievements_section.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/asset_allocation_card.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/hero_summary_section.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/holdings_section.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/missions_section.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/portfolio_activation_view.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/quick_actions_fab.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/rpg_integration_card.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/wealth_evolution_bar_card.dart';

import '../controllers/portfolio_controller_test.dart';
import '../../domain/services/portfolio_test_fixtures.dart';

/// Minimal in-memory [MascotRepository] double — a fresh default profile is
/// all these tests need.
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
  late FakePortfolioRepository repository;
  late FakeAchievementsLocalRepository achievementsLocalRepository;
  late FakeAchievementsRepository achievementsRepository;
  late FakeGamificationRepository gamificationRepository;
  late FakeMissionsRepository missionsRepository;
  late PortfolioController controller;
  late MascotController mascotController;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = FakePortfolioRepository();
    achievementsLocalRepository = FakeAchievementsLocalRepository();
    achievementsRepository = FakeAchievementsRepository();
    gamificationRepository = FakeGamificationRepository();
    missionsRepository = FakeMissionsRepository();
    controller = PortfolioController(
      repository: repository,
      achievementsLocalRepository: achievementsLocalRepository,
      achievementsRepository: achievementsRepository,
      gamificationRepository: gamificationRepository,
      missionsRepository: missionsRepository,
    );
    mascotController = MascotController(repository: FakeMascotRepository());
  });

  tearDown(() {
    controller.dispose();
    mascotController.dispose();
  });

  Widget buildTestableWidget({VoidCallback? onOpenAcademyTab}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: PortfolioScreen(
          controller: controller,
          mascotController: mascotController,
          onOpenAcademyTab: onOpenAcademyTab ?? () {},
        ),
      ),
    );
  }

  group('PortfolioScreen', () {
    testWidgets('shows a skeleton while the initial load is in flight', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.byType(HeroSummarySection), findsNothing);
      expect(find.byType(ListView), findsOneWidget); // the skeleton itself
    });

    testWidgets(
      'shows an error view with a retry action when the load fails and there are no holdings',
      (WidgetTester tester) async {
        final error = Exception('network down');
        repository.holdingsError = error;
        await controller.loadAll();
        final callsBefore = repository.fetchHoldingsCalls;

        await tester.pumpWidget(buildTestableWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(ErrorStateView), findsOneWidget);
        // The raw exception is never shown to the user — it's translated into
        // friendly copy via friendlyErrorMessage (see friendlyErrorMessage.dart).
        expect(
          find.textContaining(friendlyErrorMessage(error)),
          findsOneWidget,
        );

        await tester.tap(find.text('Tentar novamente'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(repository.fetchHoldingsCalls, greaterThan(callsBefore));
      },
    );

    testWidgets('renders the main sections once data has loaded', (
      WidgetTester tester,
    ) async {
      repository.holdingsToReturn = Holding.fromLots([lot()]);
      await controller.loadAll();

      await tester.pumpWidget(buildTestableWidget());
      // RpgIntegrationCard embeds PetMascotWidget, which has an
      // indefinitely-repeating "breathe" animation — never pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(HeroSummarySection), findsOneWidget);
      expect(find.byType(WealthEvolutionBarCard), findsOneWidget);
      expect(find.byType(AssetAllocationCard), findsOneWidget);
      expect(find.byType(HoldingsSection), findsOneWidget);
      expect(find.byType(RpgIntegrationCard), findsOneWidget);
      expect(find.byType(AchievementsSection), findsOneWidget);
      expect(find.byType(QuickActionsFab), findsOneWidget);
    });

    testWidgets('shows the MissionsSection only when there are missions', (
      WidgetTester tester,
    ) async {
      repository.holdingsToReturn = Holding.fromLots([lot()]);
      await controller
          .loadAll(); // FakeMissionsRepository defaults to MissionEvaluationResult.empty

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(MissionsSection), findsNothing);
    });

    testWidgets('shows the MissionsSection when the backend reports missions', (
      WidgetTester tester,
    ) async {
      repository.holdingsToReturn = Holding.fromLots([lot()]);
      missionsRepository.resultToReturn = const MissionEvaluationResult(
        missions: [
          MissionStatus(
            code: 'daily_complete_lesson',
            period: MissionPeriod.daily,
            periodKey: '2026-08-19',
            progress: 0,
            target: 1,
            xpReward: 30,
            completed: false,
          ),
        ],
        newlyCompletedCodes: {},
        missionXpTotal: 0,
      );
      await controller.loadAll();

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(MissionsSection), findsOneWidget);
    });

    testWidgets(
      'tapping the quick-actions FAB then "Ver Alocação" shows a themed snackbar',
      (WidgetTester tester) async {
        repository.holdingsToReturn = Holding.fromLots([lot()]);
        await controller.loadAll();

        await tester.pumpWidget(buildTestableWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        final mainFab = find.byWidgetPredicate(
          (w) =>
              w is FloatingActionButton &&
              w.heroTag == 'portfolio_quick_actions',
        );
        await tester.tap(mainFab);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        final rebalanceFab = find.byWidgetPredicate(
          (w) =>
              w is FloatingActionButton &&
              w.heroTag == 'portfolio_action_Ver Alocação',
        );
        await tester.tap(rebalanceFab);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.textContaining('meta de cada categoria'), findsOneWidget);
      },
    );

    testWidgets(
      'shows PortfolioActivationView instead of the dashboard when there are no holdings',
      (WidgetTester tester) async {
        await controller
            .loadAll(); // FakePortfolioRepository defaults to zero holdings

        await tester.pumpWidget(buildTestableWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(PortfolioActivationView), findsOneWidget);
        expect(find.byType(HeroSummarySection), findsNothing);
        expect(find.byType(HoldingsSection), findsNothing);
      },
    );

    testWidgets('does not show PortfolioActivationView once holdings exist', (
      WidgetTester tester,
    ) async {
      repository.holdingsToReturn = Holding.fromLots([lot()]);
      await controller.loadAll();

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(PortfolioActivationView), findsNothing);
      expect(find.byType(HeroSummarySection), findsOneWidget);
    });
  });
}
