import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/portfolio/domain/entities/history_point.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/enums/history_range.dart';
import 'package:petrimonium/features/portfolio/presentation/controllers/portfolio_controller.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/wealth_evolution_bar_card.dart';

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
      home: Scaffold(body: WealthEvolutionBarCard(controller: controller)),
    );
  }

  group('WealthEvolutionBarCard', () {
    testWidgets('shows a not-enough-data message before any holdings are loaded', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Evolução do Patrimônio'), findsOneWidget);
      expect(find.text('Sem dados suficientes para este período.'), findsOneWidget);
      expect(find.byType(BarChart), findsNothing);
    });

    testWidgets('renders a bar chart once loadAll produces multiple chart points', (WidgetTester tester) async {
      repository.holdingsToReturn = Holding.fromLots([
        lot(purchaseDate: DateTime.now().subtract(const Duration(days: 60))),
      ]);
      // The controller's default range is HistoryRange.m3; seed the backend
      // history for it directly so the widget has 2+ monthly buckets to
      // render, regardless of the async fetch/local-compute race in
      // PortfolioController._recomputeChart.
      final now = DateTime.now();
      repository.historyByRange = {
        HistoryRange.m3: [
          HistoryPoint(date: DateTime(now.year, now.month - 2, 1), investedCapital: 1000, portfolioValue: 1000),
          HistoryPoint(date: DateTime(now.year, now.month - 1, 1), investedCapital: 1000, portfolioValue: 1100),
          HistoryPoint(date: now, investedCapital: 1000, portfolioValue: 1200),
        ],
      };
      await controller.loadAll();

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(BarChart), findsOneWidget);
      expect(find.text('Sem dados suficientes para este período.'), findsNothing);
    });
  });
}
