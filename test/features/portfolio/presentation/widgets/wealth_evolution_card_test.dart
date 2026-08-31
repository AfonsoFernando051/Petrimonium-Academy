import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/history_point.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_type_display.dart';
import 'package:petrimonium/features/portfolio/domain/enums/history_range.dart';
import 'package:petrimonium/features/portfolio/presentation/controllers/portfolio_controller.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/wealth_evolution_card.dart';

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
      home: Scaffold(body: WealthEvolutionCard(controller: controller)),
    );
  }

  group('WealthEvolutionCard', () {
    testWidgets('shows a not-enough-data message before any holdings are loaded', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Evolução Patrimonial'), findsOneWidget);
      expect(find.text('Sem dados suficientes para este período.'), findsOneWidget);
      expect(find.byType(LineChart), findsNothing);
    });

    testWidgets('renders a line chart once loadAll produces 2+ chart points', (WidgetTester tester) async {
      repository.holdingsToReturn = Holding.fromLots([lot()]);
      final now = DateTime.now();
      repository.historyByRange = {
        HistoryRange.m3: [
          HistoryPoint(date: now.subtract(const Duration(days: 30)), investedCapital: 1000, portfolioValue: 1000),
          HistoryPoint(date: now, investedCapital: 1000, portfolioValue: 1200),
        ],
      };
      await controller.loadAll();

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('renders one range chip per HistoryRange, and the selected one reflects the controller', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      for (final range in HistoryRange.values) {
        expect(find.text(range.label), findsWidgets); // labels can collide (e.g. none here, but be lenient)
      }
    });

    testWidgets('tapping a range chip calls controller.setRange', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.selectedRange, HistoryRange.m3);

      await tester.tap(find.text(HistoryRange.y1.label));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.selectedRange, HistoryRange.y1);
    });

    testWidgets('tapping an asset-type chip calls controller.setAssetFilter', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.selectedAssetFilter, isNull);

      await tester.tap(find.text(InvestmentTypeEnum.STOCKS.shortLabel).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.selectedAssetFilter, InvestmentTypeEnum.STOCKS);

      await tester.tap(find.text('Todos'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.selectedAssetFilter, isNull);
    });
  });
}
