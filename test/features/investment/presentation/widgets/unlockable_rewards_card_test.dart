import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/investment/presentation/widgets/unlockable_rewards_card.dart';
import 'package:petrimonium/features/portfolio/domain/entities/allocation_slice.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_stats.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:petrimonium/features/portfolio/domain/services/achievement_catalog.dart';

import '../../../portfolio/domain/services/portfolio_test_fixtures.dart';

void main() {
  Widget buildTestableWidget(PortfolioStats stats) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: UnlockableRewardsCard(stats: stats)),
    );
  }

  group('UnlockableRewardsCard', () {
    testWidgets('shows the locked prompt and no check icons when the portfolio has no holdings', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(PortfolioStats.empty));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Adicione seu primeiro ativo para desbloquear:'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
      expect(find.text('Emblema de Primeiro Investidor'), findsOneWidget);
    });

    testWidgets('shows the unlocked prompt and check icons once the portfolio has a holding', (WidgetTester tester) async {
      // Built via Holding.fromLots (like the real pipeline) rather than the
      // Holding constructor directly: AchievementCatalog reads
      // stats.firstPurchaseDate, which reads Holding.firstPurchaseDate —
      // that getter assumes a non-empty `lots` list (it isn't validated by
      // the constructor) and throws `Bad state: No element` otherwise.
      final holdings = Holding.fromLots([lot(ticker: 'PETR4', quantity: 10, purchasePrice: 10, currentPrice: 12)]);
      final stats = PortfolioStats(
        summary: const PortfolioSummary(
          investedCapital: 100,
          currentValue: 120,
          totalGain: 20,
          totalGainPercent: 20,
          totalAssets: 1,
        ),
        holdings: holdings,
        allocation: const [
          AllocationSlice(type: InvestmentTypeEnum.STOCKS, currentValue: 120, portfolioPercent: 100),
        ],
      );

      await tester.pumpWidget(buildTestableWidget(stats));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Você desbloqueou:'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsWidgets);
    });

    testWidgets('shows the real XP reward from AchievementCatalog, not a hardcoded number', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(PortfolioStats.empty));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final expectedXp = AchievementCatalog.totalXpFor({'first_investment'});
      expect(find.text('+$expectedXp XP'), findsOneWidget);
    });
  });
}
