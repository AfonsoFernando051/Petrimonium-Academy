import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/dividend_history_section.dart';
import 'package:petrimonium/features/portfolio/domain/entities/dividend_event.dart';

void main() {
  Widget buildTestableWidget(AssetDetails asset) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: DividendHistorySection(asset: asset)),
    );
  }

  DividendEvent event({
    required DividendStatus status,
    DateTime? paymentDate,
    double ratePerShare = 1.5,
    double estimatedGrossAmount = 15,
  }) {
    return DividendEvent(
      ticker: 'PETR4',
      type: DividendType.DIVIDENDO,
      rawLabel: 'Dividendo',
      ratePerShare: ratePerShare,
      dataCom: null,
      paymentDate: paymentDate,
      approvedOn: null,
      userQuantity: 10,
      estimatedGrossAmount: estimatedGrossAmount,
      status: status,
    );
  }

  group('DividendHistorySection', () {
    testWidgets('shows the empty state when there are no dividends at all', (tester) async {
      const asset = AssetDetails(ticker: 'PETR4');

      await tester.pumpWidget(buildTestableWidget(asset));

      expect(find.text('Nenhum provento registrado para este ativo.'), findsOneWidget);
      expect(find.text('Histórico'), findsNothing);
      expect(find.text('Próximos pagamentos'), findsNothing);
    });

    testWidgets('shows upcoming dividends under "Próximos pagamentos"', (tester) async {
      final asset = AssetDetails(
        ticker: 'PETR4',
        recentDividends: [
          event(status: DividendStatus.ANNOUNCED, paymentDate: DateTime(2025, 3, 10)),
        ],
      );

      await tester.pumpWidget(buildTestableWidget(asset));

      expect(find.text('Próximos pagamentos'), findsOneWidget);
      expect(find.text('10/03'), findsOneWidget);
      expect(find.textContaining('est.'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('shows up to 3 paid dividends initially with a "Ver todos" toggle for more', (tester) async {
      final asset = AssetDetails(
        ticker: 'PETR4',
        recentDividends: [
          event(status: DividendStatus.PAID, paymentDate: DateTime(2025, 1, 1)),
          event(status: DividendStatus.PAID, paymentDate: DateTime(2025, 2, 1)),
          event(status: DividendStatus.PAID, paymentDate: DateTime(2025, 3, 1)),
          event(status: DividendStatus.PAID, paymentDate: DateTime(2025, 4, 1)),
        ],
      );

      await tester.pumpWidget(buildTestableWidget(asset));

      expect(find.text('Histórico'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsNWidgets(3));
      expect(find.text('Ver todos (4)'), findsOneWidget);

      await tester.tap(find.text('Ver todos (4)'));
      await tester.pump();

      expect(find.byIcon(Icons.check_circle_outline), findsNWidgets(4));
      expect(find.text('Mostrar menos'), findsOneWidget);
    });

    testWidgets('does not show the toggle when there are 3 or fewer paid dividends', (tester) async {
      final asset = AssetDetails(
        ticker: 'PETR4',
        recentDividends: [
          event(status: DividendStatus.PAID, paymentDate: DateTime(2025, 1, 1)),
        ],
      );

      await tester.pumpWidget(buildTestableWidget(asset));

      expect(find.textContaining('Ver todos'), findsNothing);
    });

    testWidgets('renders "—" for a dividend tile without a payment date and hides amount when zero', (tester) async {
      final asset = AssetDetails(
        ticker: 'PETR4',
        recentDividends: [
          event(status: DividendStatus.PAID, paymentDate: null, estimatedGrossAmount: 0),
        ],
      );

      await tester.pumpWidget(buildTestableWidget(asset));

      expect(find.text('—'), findsOneWidget);
      expect(find.text('R\$ 1.50/cota'), findsOneWidget);
    });
  });
}
