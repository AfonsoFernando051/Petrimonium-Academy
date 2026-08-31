import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/widgets/app_loading_indicator.dart';
import 'package:petrimonium/features/portfolio/domain/entities/dividend_event.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/dividend_event_tile.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/dividend_radar_section.dart';

void main() {
  Widget buildTestableWidget({
    required bool isLoading,
    String? error,
    DividendRadar radar = DividendRadar.empty,
    VoidCallback? onRetry,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: DividendRadarSection(
          isLoading: isLoading,
          error: error,
          radar: radar,
          onRetry: onRetry ?? () {},
        ),
      ),
    );
  }

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

  group('DividendRadarSection', () {
    testWidgets('shows a loading indicator while loading with an empty radar', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(isLoading: true));

      expect(find.byType(AppLoadingIndicator), findsOneWidget);
    });

    testWidgets('shows an error row with retry when loading fails with an empty radar', (WidgetTester tester) async {
      var retried = false;
      await tester.pumpWidget(buildTestableWidget(
        isLoading: false,
        error: 'network error',
        onRetry: () => retried = true,
      ));

      expect(find.text('Não foi possível carregar o radar de dividendos.'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(retried, isTrue);
    });

    testWidgets('shows an empty state message when the radar has no events', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(isLoading: false));

      expect(find.textContaining('Nenhum provento confirmado encontrado'), findsOneWidget);
    });

    testWidgets('renders upcoming and history sections with a tile per event', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        isLoading: false,
        radar: const DividendRadar(upcoming: [event], history: [event, event]),
      ));

      expect(find.text('PRÓXIMOS'), findsOneWidget);
      expect(find.text('HISTÓRICO RECENTE'), findsOneWidget);
      expect(find.byType(DividendEventTile), findsNWidgets(3));
    });
  });
}
