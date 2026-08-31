import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/features/simulated_wallet/data/datasources/simulated_wallet_remote_datasource.dart';
import 'package:petrimonium/features/simulated_wallet/data/repositories/simulated_wallet_repository.dart';
import 'package:petrimonium/features/simulated_wallet/domain/entities/asset_quote.dart';
import 'package:petrimonium/features/simulated_wallet/domain/entities/simulated_order.dart';
import 'package:petrimonium/features/simulated_wallet/domain/entities/simulated_order_side.dart';
import 'package:petrimonium/features/simulated_wallet/domain/entities/simulated_portfolio_summary.dart';
import 'package:petrimonium/features/simulated_wallet/presentation/controllers/simulated_wallet_controller.dart';

/// In-memory [SimulatedWalletRepository] double — extends the real
/// (concrete, not abstract) class and overrides every method, the same
/// fake-by-extension pattern this codebase's other repository fakes use
/// when the target has no separate interface type.
class FakeSimulatedWalletRepository extends SimulatedWalletRepository {
  // Every method below is overridden, so this real data source (backed by a
  // plain default-constructed ApiClient) never actually makes a network call.
  FakeSimulatedWalletRepository()
      : super(remoteDataSource: SimulatedWalletRemoteDataSource(apiClient: ApiClient()));

  SimulatedPortfolioSummary portfolioToReturn = SimulatedPortfolioSummary.empty;
  Object? fetchError;

  SimulatedOrder? orderToReturn;
  Object? placeOrderError;
  String? lastPlacedTicker;
  SimulatedOrderSide? lastPlacedSide;
  double? lastPlacedQuantity;

  Object? resetError;
  bool resetCalled = false;

  List<AssetQuote> quotesToReturn = const [];
  String? lastSearchedQuery;

  @override
  Future<SimulatedPortfolioSummary> fetchPortfolio() async {
    if (fetchError != null) throw fetchError!;
    return portfolioToReturn;
  }

  @override
  Future<SimulatedOrder> placeOrder({
    required String ticker,
    required SimulatedOrderSide side,
    required double quantity,
    String? clientOrderId,
  }) async {
    lastPlacedTicker = ticker;
    lastPlacedSide = side;
    lastPlacedQuantity = quantity;
    if (placeOrderError != null) throw placeOrderError!;
    return orderToReturn!;
  }

  @override
  Future<void> reset() async {
    resetCalled = true;
    if (resetError != null) throw resetError!;
  }

  @override
  Future<List<AssetQuote>> searchQuotes(String query) async {
    lastSearchedQuery = query;
    return quotesToReturn;
  }
}

SimulatedOrder _order({SimulatedOrderSide side = SimulatedOrderSide.buy}) => SimulatedOrder(
      id: 1,
      ticker: 'PETR4',
      side: side,
      quantity: 10,
      price: 30.5,
      total: 305.0,
      executedAt: DateTime(2026, 1, 1),
      clientOrderId: 'order-1',
    );

void main() {
  late FakeSimulatedWalletRepository repository;
  late SimulatedWalletController controller;

  setUp(() {
    repository = FakeSimulatedWalletRepository();
    controller = SimulatedWalletController(repository: repository);
  });

  group('loadPortfolio', () {
    test('populates portfolio and clears the loading flag on success', () async {
      repository.portfolioToReturn = const SimulatedPortfolioSummary(
        virtualBalance: 9500,
        initialBalance: 10000,
        currency: 'BRL',
        resetAt: null,
        positions: [],
      );

      await controller.loadPortfolio();

      expect(controller.isLoading, isFalse);
      expect(controller.error, isNull);
      expect(controller.portfolio.virtualBalance, 9500);
    });

    test('a repository failure is captured as a user-facing error, not an unhandled exception', () async {
      repository.fetchError = Exception('network down');

      await controller.loadPortfolio();

      expect(controller.isLoading, isFalse);
      expect(controller.error, isNotNull);
    });
  });

  group('placeOrder', () {
    test('on success, reloads the portfolio and returns the created order', () async {
      repository.orderToReturn = _order();
      repository.portfolioToReturn = const SimulatedPortfolioSummary(
        virtualBalance: 9695,
        initialBalance: 10000,
        currency: 'BRL',
        resetAt: null,
        positions: [],
      );

      final result = await controller.placeOrder(ticker: 'petr4', side: SimulatedOrderSide.buy, quantity: 10);

      expect(result?.id, 1);
      expect(controller.portfolio.virtualBalance, 9695);
      expect(controller.orderError, isNull);
      expect(controller.isPlacingOrder, isFalse);
    });

    test('forwards ticker/side/quantity to the repository unchanged', () async {
      repository.orderToReturn = _order();

      await controller.placeOrder(ticker: 'VALE3', side: SimulatedOrderSide.sell, quantity: 4.5);

      expect(repository.lastPlacedTicker, 'VALE3');
      expect(repository.lastPlacedSide, SimulatedOrderSide.sell);
      expect(repository.lastPlacedQuantity, 4.5);
    });

    test('on failure, returns null and sets orderError without touching the current portfolio', () async {
      repository.portfolioToReturn = const SimulatedPortfolioSummary(
        virtualBalance: 10000,
        initialBalance: 10000,
        currency: 'BRL',
        resetAt: null,
        positions: [],
      );
      await controller.loadPortfolio();
      repository.placeOrderError = Exception('Insufficient virtual balance');

      final result = await controller.placeOrder(ticker: 'PETR4', side: SimulatedOrderSide.buy, quantity: 999999);

      expect(result, isNull);
      expect(controller.orderError, isNotNull);
      expect(controller.portfolio.virtualBalance, 10000); // unchanged
    });
  });

  group('resetPortfolio', () {
    test('on success, reloads the portfolio and returns true', () async {
      repository.portfolioToReturn = SimulatedPortfolioSummary.empty;

      final succeeded = await controller.resetPortfolio();

      expect(succeeded, isTrue);
      expect(repository.resetCalled, isTrue);
      expect(controller.resetError, isNull);
    });

    test('on failure, returns false and sets resetError', () async {
      repository.resetError = Exception('network down');

      final succeeded = await controller.resetPortfolio();

      expect(succeeded, isFalse);
      expect(controller.resetError, isNotNull);
    });
  });

  group('searchQuotes', () {
    test('short-circuits to an empty list for a blank query without calling the repository', () async {
      final result = await controller.searchQuotes('   ');

      expect(result, isEmpty);
      expect(repository.lastSearchedQuery, isNull);
    });

    test('trims the query before delegating to the repository', () async {
      repository.quotesToReturn = [const AssetQuote(symbol: 'PETR4', shortName: null, regularMarketPrice: 30.5, currency: 'BRL')];

      final result = await controller.searchQuotes('  petr4  ');

      expect(repository.lastSearchedQuery, 'petr4');
      expect(result.single.symbol, 'PETR4');
    });
  });
}
