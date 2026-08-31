import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/friendly_error_message.dart';
import 'package:petrimonium/core/widgets/app_loading_indicator.dart';
import 'package:petrimonium/features/asset_details/data/repositories/asset_details_repository.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_data_status.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/asset_details/domain/entities/user_position.dart';
import 'package:petrimonium/features/asset_details/presentation/screens/asset_details_screen.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/allocation_suggestion_card.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/asset_education_section.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/asset_header.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/asset_valuation_chart_card.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/concentration_warning.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/key_indicators_section.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/pet_teacher_widget.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/portfolio_context_card.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/purchase_history_card.dart';
import 'package:petrimonium/features/asset_details/presentation/widgets/user_position_card.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_lot.dart';

class MockAssetDetailsRepository extends Mock implements AssetDetailsRepository {}

void main() {
  late MockAssetDetailsRepository mockRepository;

  setUp(() {
    mockRepository = MockAssetDetailsRepository();
    DI.assetDetailsRepository = mockRepository;
  });

  Widget buildTestableWidget({String ticker = 'PETR4'}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: AssetDetailsScreen(ticker: ticker),
    );
  }

  group('AssetDetailsScreen', () {
    testWidgets('shows a skeleton while the initial fetch is in flight', (WidgetTester tester) async {
      final completer = Completer<AssetDetails>();
      when(() => mockRepository.fetchAssetDetails(any())).thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.byType(AssetHeader), findsNothing);
      expect(find.byType(AppLoadingIndicator), findsNothing); // uses its own bar-skeleton, not the shared indicator
      expect(find.byType(ListView), findsOneWidget);

      // Avoid leaving a dangling unresolved future for the next test.
      completer.complete(const AssetDetails(ticker: 'PETR4'));
      await tester.pump();
    });

    testWidgets('shows an error view when the fetch fails with no cached data', (WidgetTester tester) async {
      final error = Exception('network down');
      when(() => mockRepository.fetchAssetDetails(any())).thenThrow(error);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Não foi possível carregar este ativo'), findsOneWidget);
      // The raw exception is never shown to the user — it's translated into
      // friendly copy via friendlyErrorMessage (see friendlyErrorMessage.dart).
      expect(find.textContaining(friendlyErrorMessage(error)), findsOneWidget);
    });

    testWidgets('renders the ticker in the app bar and the core sections once loaded', (WidgetTester tester) async {
      const details = AssetDetails(
        ticker: 'PETR4',
        shortName: 'Petrobras',
        assetType: 'stock',
        dataStatus: AssetDataStatus.fresh,
      );
      when(() => mockRepository.fetchAssetDetails(any())).thenAnswer((_) async => details);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('PETR4'), findsWidgets); // app bar + AssetHeader both may show it
      expect(find.text('Ao vivo'), findsOneWidget); // fresh data-status badge
      expect(find.byType(AssetHeader), findsOneWidget);
      expect(find.byType(KeyIndicatorsSection), findsOneWidget);
      expect(find.byType(AssetEducationSection), findsOneWidget);
      expect(find.byType(PetTeacherWidget), findsOneWidget);
      expect(find.byType(UserPositionCard), findsNothing); // not owned
      expect(find.byType(PortfolioContextCard), findsNothing);
    });

    testWidgets('shows the user position and portfolio context cards when the asset is owned', (WidgetTester tester) async {
      const details = AssetDetails(
        ticker: 'PETR4',
        shortName: 'Petrobras',
        assetType: 'stock',
        userPosition: UserPosition(
          quantity: 10,
          averagePrice: 20,
          investedValue: 200,
          currentValue: 220,
          unrealizedGain: 20,
          unrealizedGainPercent: 10,
          portfolioWeight: 15,
        ),
      );
      when(() => mockRepository.fetchAssetDetails(any())).thenAnswer((_) async => details);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(UserPositionCard), findsOneWidget);
      expect(find.byType(PortfolioContextCard), findsOneWidget);
      expect(find.byType(ConcentrationWarning), findsNothing); // 15% weight, under the 20% threshold
    });

    testWidgets('shows a concentration warning when the position exceeds 20% of the portfolio', (WidgetTester tester) async {
      const details = AssetDetails(
        ticker: 'PETR4',
        shortName: 'Petrobras',
        assetType: 'stock',
        userPosition: UserPosition(
          quantity: 10,
          averagePrice: 20,
          investedValue: 200,
          currentValue: 220,
          unrealizedGain: 20,
          unrealizedGainPercent: 10,
          portfolioWeight: 25,
        ),
      );
      when(() => mockRepository.fetchAssetDetails(any())).thenAnswer((_) async => details);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // The ListView's children are only built once scrolled into the
      // (cached) viewport — scroll down to reach ConcentrationWarning.
      await tester.scrollUntilVisible(find.byType(ConcentrationWarning), 300, scrollable: find.byType(Scrollable).first);

      expect(find.byType(ConcentrationWarning), findsOneWidget);
    });

    testWidgets('tapping the back button pops the screen', (WidgetTester tester) async {
      const details = AssetDetails(ticker: 'PETR4', shortName: 'Petrobras', assetType: 'stock');
      when(() => mockRepository.fetchAssetDetails(any())).thenAnswer((_) async => details);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AssetDetailsScreen(ticker: 'PETR4')),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AssetDetailsScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500)); // let the pop transition finish

      expect(find.byType(AssetDetailsScreen), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });

    group('with a real Holding (consolidated from the old AssetDetailsSheet)', () {
      Holding buildHolding() {
        final lots = [
          InvestmentLot(
            id: 1,
            ticker: 'PETR4',
            type: InvestmentTypeEnum.STOCKS,
            quantity: 100,
            purchasePrice: 10,
            purchaseDate: DateTime(2024, 1, 1),
            currentPrice: 12,
            investedValue: 1000,
            currentValue: 1200,
          ),
          InvestmentLot(
            id: 2,
            ticker: 'PETR4',
            type: InvestmentTypeEnum.STOCKS,
            quantity: 50,
            purchasePrice: 11,
            purchaseDate: DateTime(2024, 2, 1),
            currentPrice: 12,
            investedValue: 550,
            currentValue: 600,
          ),
        ];
        return Holding.fromLots(lots).first;
      }

      testWidgets('renders the valuation chart and purchase history when a holding is passed', (WidgetTester tester) async {
        const details = AssetDetails(ticker: 'PETR4', shortName: 'Petrobras', assetType: 'stock');
        when(() => mockRepository.fetchAssetDetails(any())).thenAnswer((_) async => details);

        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.dark,
          home: AssetDetailsScreen(ticker: 'PETR4', holding: buildHolding()),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(AssetValuationChartCard), findsOneWidget);

        await tester.scrollUntilVisible(find.byType(PurchaseHistoryCard), 300, scrollable: find.byType(Scrollable).first);
        expect(find.byType(PurchaseHistoryCard), findsOneWidget);
        expect(find.text('01/01/2024'), findsOneWidget);
        expect(find.text('01/02/2024'), findsOneWidget);
      });

      testWidgets('renders the allocation suggestion when a holding is passed', (WidgetTester tester) async {
        const details = AssetDetails(ticker: 'PETR4', shortName: 'Petrobras', assetType: 'stock');
        when(() => mockRepository.fetchAssetDetails(any())).thenAnswer((_) async => details);

        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.dark,
          home: AssetDetailsScreen(ticker: 'PETR4', holding: buildHolding()),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(AllocationSuggestionCard), findsOneWidget);
      });

      testWidgets('renders none of the holding-only sections when no holding is passed', (WidgetTester tester) async {
        const details = AssetDetails(ticker: 'PETR4', shortName: 'Petrobras', assetType: 'stock');
        when(() => mockRepository.fetchAssetDetails(any())).thenAnswer((_) async => details);

        await tester.pumpWidget(buildTestableWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(AssetValuationChartCard), findsNothing);
        expect(find.byType(PurchaseHistoryCard), findsNothing);
        expect(find.byType(AllocationSuggestionCard), findsNothing);
      });
    });
  });
}
