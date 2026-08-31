import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/home/presentation/widgets/portfolio_bridge_card.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_summary.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestableWidget({
    required PortfolioSummary summary,
    int completedLessonCount = 0,
    VoidCallback? onViewPortfolio,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: PortfolioBridgeCard(
          summary: summary,
          completedLessonCount: completedLessonCount,
          onViewPortfolio: onViewPortfolio ?? () {},
        ),
      ),
    );
  }

  group('PortfolioBridgeCard', () {
    testWidgets('renders the label, current value and a positive gain in green-ish success text', (tester) async {
      const summary = PortfolioSummary(
        investedCapital: 1000,
        currentValue: 1200,
        totalGain: 200,
        totalGainPercent: 20,
        totalAssets: 3,
      );
      await tester.pumpWidget(buildTestableWidget(summary: summary));

      expect(find.text('SUA CARTEIRA'), findsOneWidget);
      expect(find.text('+20.0%'), findsOneWidget);
      expect(find.text('Ver Carteira'), findsOneWidget);
    });

    testWidgets('renders a negative gain without a leading plus sign', (tester) async {
      const summary = PortfolioSummary(
        investedCapital: 1000,
        currentValue: 800,
        totalGain: -200,
        totalGainPercent: -20,
        totalAssets: 3,
      );
      await tester.pumpWidget(buildTestableWidget(summary: summary));

      expect(find.text('-20.0%'), findsOneWidget);
    });

    testWidgets('shows the apply-what-you-learned message when lessons are completed', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        summary: PortfolioSummary.empty,
        completedLessonCount: 5,
      ));

      expect(
        find.text('Você já concluiu 5 lições — veja como aplicar esse conhecimento na sua carteira real.'),
        findsOneWidget,
      );
    });

    testWidgets('omits the apply message when no lessons are completed yet', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        summary: PortfolioSummary.empty,
        completedLessonCount: 0,
      ));

      expect(find.textContaining('lições'), findsNothing);
    });

    testWidgets('tapping the CTA invokes onViewPortfolio', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestableWidget(
        summary: PortfolioSummary.empty,
        onViewPortfolio: () => tapped = true,
      ));

      await tester.tap(find.text('Ver Carteira'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
