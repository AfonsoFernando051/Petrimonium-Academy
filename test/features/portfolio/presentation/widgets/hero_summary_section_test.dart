import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:petrimonium/features/portfolio/presentation/controllers/portfolio_controller.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/hero_summary_section.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/portfolio_summary_card.dart';

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
      home: Scaffold(body: HeroSummarySection(controller: controller)),
    );
  }

  group('HeroSummarySection', () {
    testWidgets('renders the leading hero cards even before any data has loaded', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // It's a horizontally-scrolling ListView, so only the cards that fit
      // in the initial viewport (+ cache extent) are actually built.
      expect(find.byType(PortfolioSummaryCard), findsWidgets);
      expect(find.text('Valor Total'), findsOneWidget);
      expect(find.text('Capital Investido'), findsOneWidget);
      expect(find.text('Lucro Total'), findsOneWidget);
    });

    testWidgets('scrolling reveals the trailing hero cards, all 8 total', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.fling(find.byType(HeroSummarySection), const Offset(-2000, 0), 3000);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Retorno Total'), findsOneWidget);
      expect(find.text('Desempenho Anual'), findsOneWidget);
    });

    testWidgets('renders totalAssets in the invested-capital subtitle after loading real data', (WidgetTester tester) async {
      repository.holdingsToReturn = Holding.fromLots([lot()]);
      repository.summaryToReturn = const PortfolioSummary(
        investedCapital: 1000,
        currentValue: 1200,
        totalGain: 200,
        totalGainPercent: 20,
        totalAssets: 1,
      );
      await controller.loadAll();

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('1 ativos'), findsOneWidget);
    });
  });
}
