import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/investment/presentation/widgets/live_portfolio_summary_card.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_stats.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:petrimonium/features/portfolio/domain/entities/allocation_slice.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/services/achievement_catalog.dart';

import '../../../portfolio/domain/services/portfolio_test_fixtures.dart';

void main() {
  Widget buildTestableWidget(PortfolioStats stats, {Set<String> alreadyUnlockedIds = const {}}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: LivePortfolioSummaryCard(stats: stats, alreadyUnlockedIds: alreadyUnlockedIds)),
    );
  }

  group('LivePortfolioSummaryCard', () {
    testWidgets('shows a dash for passive income and no achievement banner when the portfolio has no assets', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(PortfolioStats.empty));
      await tester.pump();

      expect(find.text('0'), findsOneWidget); // totalAssets
      expect(find.text('—'), findsOneWidget); // passive income dash
    });

    testWidgets('shows real asset count, value and monthly passive income once populated', (WidgetTester tester) async {
      final holdings = Holding.fromLots([lot(ticker: 'PETR4', quantity: 100, purchasePrice: 10, currentPrice: 10)]);
      final stats = PortfolioStats(
        summary: const PortfolioSummary(
          investedCapital: 1000,
          currentValue: 1000,
          totalGain: 0,
          totalGainPercent: 0,
          totalAssets: 1,
        ),
        holdings: holdings,
        allocation: const [
          AllocationSlice(type: InvestmentTypeEnum.STOCKS, currentValue: 1000, portfolioPercent: 100),
        ],
      );

      await tester.pumpWidget(buildTestableWidget(stats));
      await tester.pump();

      expect(find.text('1'), findsOneWidget); // totalAssets
      expect(find.textContaining('/mês'), findsOneWidget);
      expect(find.text('—'), findsNothing);
    });

    testWidgets('shows the real XP reward for a newly-qualifying achievement, not already-unlocked ones', (WidgetTester tester) async {
      final holdings = Holding.fromLots([lot(ticker: 'PETR4', quantity: 100, purchasePrice: 10, currentPrice: 10)]);
      final stats = PortfolioStats(
        summary: const PortfolioSummary(
          investedCapital: 1000,
          currentValue: 1000,
          totalGain: 0,
          totalGainPercent: 0,
          totalAssets: 1,
        ),
        holdings: holdings,
        allocation: const [],
      );

      await tester.pumpWidget(buildTestableWidget(stats));
      await tester.pump();

      final qualified = AchievementCatalog.qualifiedIds(stats);
      final expectedXp = AchievementCatalog.totalXpFor(qualified);
      expect(find.text('+$expectedXp XP'), findsOneWidget);
    });

    testWidgets('shows 0 XP when everything the portfolio qualifies for is already unlocked', (WidgetTester tester) async {
      final holdings = Holding.fromLots([lot(ticker: 'PETR4', quantity: 100, purchasePrice: 10, currentPrice: 10)]);
      final stats = PortfolioStats(
        summary: const PortfolioSummary(
          investedCapital: 1000,
          currentValue: 1000,
          totalGain: 0,
          totalGainPercent: 0,
          totalAssets: 1,
        ),
        holdings: holdings,
        allocation: const [],
      );
      final alreadyUnlocked = AchievementCatalog.qualifiedIds(stats);

      await tester.pumpWidget(buildTestableWidget(stats, alreadyUnlockedIds: alreadyUnlocked));
      await tester.pump();

      expect(find.text('+0 XP'), findsOneWidget);
    });
  });
}
