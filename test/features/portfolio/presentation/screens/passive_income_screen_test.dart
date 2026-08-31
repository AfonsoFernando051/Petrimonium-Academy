import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/widgets/app_loading_indicator.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/presentation/controllers/portfolio_controller.dart';
import 'package:petrimonium/features/portfolio/presentation/screens/passive_income_screen.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/dividend_radar_section.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/passive_income_card.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/proventos_evolution_bar_card.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/error_banner.dart';

import '../controllers/portfolio_controller_test.dart';
import '../../domain/services/portfolio_test_fixtures.dart';

void main() {
  late FakePortfolioRepository repository;
  late FakeAchievementsLocalRepository achievementsLocalRepository;
  late FakeAchievementsRepository achievementsRepository;
  late FakeGamificationRepository gamificationRepository;
  late FakeMissionsRepository missionsRepository;
  late PortfolioController controller;

  setUp(() {
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
  });

  tearDown(() => controller.dispose());

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: PassiveIncomeScreen(controller: controller)),
    );
  }

  group('PassiveIncomeScreen', () {
    testWidgets('shows a loading indicator before the initial load resolves', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.byType(AppLoadingIndicator), findsOneWidget);
    });

    testWidgets('renders the main sections once loaded', (WidgetTester tester) async {
      repository.holdingsToReturn = Holding.fromLots([lot()]);
      await controller.loadAll();
      // The screen also triggers this itself from initState, but awaiting it
      // here up front avoids racing DividendRadarSection's own loading state.
      await controller.loadDividendRadarIfNeeded();

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(ProventosEvolutionBarCard), findsOneWidget);
      expect(find.byType(DividendRadarSection), findsOneWidget);
      expect(find.byType(PassiveIncomeCard), findsOneWidget);
      expect(find.byType(AppLoadingIndicator), findsNothing);
      expect(find.byType(ErrorBanner), findsNothing);
    });

    testWidgets('shows an ErrorBanner when the controller reports an error, without blocking the rest of the screen', (WidgetTester tester) async {
      repository.holdingsError = Exception('network down');
      await controller.loadAll();

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(find.byType(ProventosEvolutionBarCard), findsOneWidget);
    });

    testWidgets('pull-to-refresh calls refresh() on the controller', (WidgetTester tester) async {
      repository.holdingsToReturn = Holding.fromLots([lot()]);
      await controller.loadAll();
      final callsBefore = repository.fetchHoldingsCalls;

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      await tester.fling(find.byType(SingleChildScrollView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(repository.fetchHoldingsCalls, greaterThan(callsBefore));
    });
  });
}
