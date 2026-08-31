import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/app_loading_indicator.dart';
import 'package:petrimonium/features/simulated_wallet/data/repositories/simulated_wallet_repository.dart';
import 'package:petrimonium/features/simulated_wallet/presentation/controllers/simulated_wallet_controller.dart';
import 'package:petrimonium/features/simulated_wallet/presentation/screens/simulated_wallet_screen.dart';
import 'package:petrimonium/features/simulated_wallet/presentation/widgets/simulation_disclaimer_banner.dart';

import '../../data/repositories/simulated_wallet_repository_test.dart';

void main() {
  late FakeSimulatedWalletRemoteDataSource remoteDataSource;
  late SimulatedWalletController controller;

  setUp(() {
    remoteDataSource = FakeSimulatedWalletRemoteDataSource();
    controller = SimulatedWalletController(
      repository: SimulatedWalletRepository(remoteDataSource: remoteDataSource),
    );
  });

  tearDown(() => controller.dispose());

  Widget buildTestableWidget() {
    return MaterialApp(
      theme: AppTheme.dark,
      home: SimulatedWalletScreen(controller: controller),
    );
  }

  group('SimulatedWalletScreen', () {
    testWidgets('shows a loading indicator before the initial load resolves', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.byType(AppLoadingIndicator), findsOneWidget);
    });

    testWidgets('always shows the simulation disclaimer once loaded, on every load state', (tester) async {
      remoteDataSource.portfolioToReturn = {
        'virtualBalance': 10000.0,
        'initialBalance': 10000.0,
        'currency': 'BRL',
        'resetAt': null,
        'positions': <Map<String, dynamic>>[],
      };
      await controller.loadPortfolio();

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.byType(SimulationDisclaimerBanner), findsOneWidget);
      expect(find.text(Translator.translate(AppStrings.simulatedWalletDisclaimer)), findsOneWidget);
    });

    testWidgets('renders the virtual balance and simulated positions once loaded', (tester) async {
      remoteDataSource.portfolioToReturn = {
        'virtualBalance': 9695.00,
        'initialBalance': 10000.00,
        'currency': 'BRL',
        'resetAt': null,
        'positions': [
          {'ticker': 'PETR4', 'quantity': 10.0, 'averagePrice': 30.5, 'costBasis': 305.0, 'allocationPercent': 100.0},
        ],
      };
      await controller.loadPortfolio();

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.textContaining('9695.00'), findsOneWidget);
      expect(find.text('PETR4'), findsOneWidget);
      expect(find.byType(AppLoadingIndicator), findsNothing);
    });

    testWidgets('the FAB never labels itself as a real order', (tester) async {
      await controller.loadPortfolio();

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      final fabLabel = Translator.translate(AppStrings.simulatedWalletNewOrderAction).toLowerCase();
      expect(fabLabel, isNot(contains('real')));
      expect(find.text(Translator.translate(AppStrings.simulatedWalletNewOrderAction)), findsOneWidget);
    });
  });
}
