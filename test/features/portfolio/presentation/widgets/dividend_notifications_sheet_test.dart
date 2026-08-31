import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/app_loading_indicator.dart';
import 'package:petrimonium/features/portfolio/domain/entities/dividend_event.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/dividend_event_tile.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/dividend_notifications_sheet.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestableWidget({
    required bool isLoading,
    String? error,
    List<DividendEvent> upcoming = const [],
    VoidCallback? onRetry,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: DividendNotificationsSheet(
          isLoading: isLoading,
          error: error,
          upcoming: upcoming,
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

  group('DividendNotificationsSheet', () {
    testWidgets('shows a loading indicator while loading with no data yet', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(isLoading: true));

      expect(find.byType(AppLoadingIndicator), findsOneWidget);
    });

    testWidgets('shows an error state with retry when loading fails with no data', (WidgetTester tester) async {
      var retried = false;
      await tester.pumpWidget(buildTestableWidget(
        isLoading: false,
        error: 'network error',
        onRetry: () => retried = true,
      ));

      expect(find.text('Não foi possível carregar suas notificações.'), findsOneWidget);

      await tester.tap(find.text('Tentar novamente'));
      await tester.pump();
      expect(retried, isTrue);
    });

    testWidgets('shows an empty state when there is no upcoming dividend', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(isLoading: false));

      expect(
        find.text('Nenhum provento confirmado a caminho para os seus ativos no momento.'),
        findsOneWidget,
      );
    });

    testWidgets('renders a DividendEventTile per upcoming event', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(isLoading: false, upcoming: [event, event]));

      expect(find.byType(DividendEventTile), findsNWidgets(2));
    });
  });
}
