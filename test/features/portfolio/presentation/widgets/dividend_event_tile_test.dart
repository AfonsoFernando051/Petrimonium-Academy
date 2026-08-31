import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/portfolio/domain/entities/dividend_event.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/dividend_event_tile.dart';

void main() {
  Widget buildTestableWidget(DividendEvent event) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: DividendEventTile(event: event)),
    );
  }

  group('DividendEventTile', () {
    testWidgets('renders forward-looking copy for an announced payment', (WidgetTester tester) async {
      const event = DividendEvent(
        ticker: 'PETR4',
        type: DividendType.DIVIDENDO,
        rawLabel: 'Dividendo',
        ratePerShare: 1.5,
        dataCom: null,
        paymentDate: null,
        approvedOn: null,
        userQuantity: 100,
        estimatedGrossAmount: 150,
        status: DividendStatus.ANNOUNCED,
      );

      await tester.pumpWidget(buildTestableWidget(event));

      expect(find.text('PETR4'), findsOneWidget);
      expect(find.text('Dividendo'), findsOneWidget);
      expect(find.text('Data de pagamento a confirmar'), findsOneWidget);
      expect(find.text('R\$ 150,00'), findsOneWidget);
      expect(find.textContaining('100 cotas'), findsOneWidget);
    });

    testWidgets('renders confirmed past-payment copy with the formatted date', (WidgetTester tester) async {
      final event = DividendEvent(
        ticker: 'VALE3',
        type: DividendType.JCP,
        rawLabel: 'JCP',
        ratePerShare: 0.8,
        dataCom: DateTime(2024, 1, 1),
        paymentDate: DateTime(2024, 2, 10),
        approvedOn: DateTime(2024, 1, 5),
        userQuantity: 50,
        estimatedGrossAmount: 40,
        status: DividendStatus.PAID,
      );

      await tester.pumpWidget(buildTestableWidget(event));

      expect(find.text('VALE3'), findsOneWidget);
      expect(find.text('JCP'), findsOneWidget);
      expect(find.text('Pago em 10/02/2024'), findsOneWidget);
      expect(find.text('R\$ 40,00'), findsOneWidget);
    });
  });
}
