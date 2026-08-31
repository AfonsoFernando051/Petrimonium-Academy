import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/portfolio/domain/entities/dividend_event.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/proventos_evolution_bar_card.dart';

void main() {
  Widget buildTestableWidget(DividendRadar radar) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: ProventosEvolutionBarCard(radar: radar)),
    );
  }

  DividendEvent event({
    required double amount,
    required DateTime paymentDate,
    DividendStatus status = DividendStatus.PAID,
  }) {
    return DividendEvent(
      ticker: 'PETR4',
      type: DividendType.DIVIDENDO,
      rawLabel: 'Dividendo',
      ratePerShare: 1,
      dataCom: paymentDate,
      paymentDate: paymentDate,
      approvedOn: paymentDate,
      userQuantity: 10,
      estimatedGrossAmount: amount,
      status: status,
    );
  }

  group('ProventosEvolutionBarCard', () {
    testWidgets('shows a no-data message when radar is empty', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(DividendRadar.empty));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Evolução de Proventos'), findsOneWidget);
      expect(find.text('Sem proventos registrados ainda.'), findsOneWidget);
      expect(find.byType(BarChart), findsNothing);
    });

    testWidgets('renders a bar chart when the radar has history within the last 12 months', (WidgetTester tester) async {
      final now = DateTime.now();
      final radar = DividendRadar(
        upcoming: const [],
        history: [event(amount: 50, paymentDate: DateTime(now.year, now.month, 1))],
      );

      await tester.pumpWidget(buildTestableWidget(radar));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(BarChart), findsOneWidget);
      expect(find.text('Sem proventos registrados ainda.'), findsNothing);
    });

    testWidgets('shows no tooltip before any bar is touched', (WidgetTester tester) async {
      final now = DateTime.now();
      final radar = DividendRadar(
        upcoming: const [],
        history: [event(amount: 50, paymentDate: DateTime(now.year, now.month, 1))],
      );

      await tester.pumpWidget(buildTestableWidget(radar));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.textContaining('Recebido:'), findsNothing);
    });
  });
}
