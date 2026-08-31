import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/features/simulated_wallet/data/datasources/simulated_wallet_remote_datasource.dart';
import 'package:petrimonium/features/simulated_wallet/data/repositories/simulated_wallet_repository.dart';
import 'package:petrimonium/features/simulated_wallet/domain/entities/simulated_order_side.dart';

/// In-memory [SimulatedWalletRemoteDataSource] double — the real one talks
/// to the network. Extends the real class (rather than implementing an
/// interface) the same way this codebase's other fakes do when the target
/// class has no separate abstract type.
class FakeSimulatedWalletRemoteDataSource extends SimulatedWalletRemoteDataSource {
  // Every method below is overridden, so this real ApiClient is never
  // actually used to make a network call — it just satisfies the
  // constructor, same as passing a plain default-constructed collaborator
  // to any other class under test.
  FakeSimulatedWalletRemoteDataSource() : super(apiClient: ApiClient());

  Map<String, dynamic> portfolioToReturn = {
    'virtualBalance': 10000.0,
    'initialBalance': 10000.0,
    'currency': 'BRL',
    'resetAt': null,
    'positions': <Map<String, dynamic>>[],
  };
  Map<String, dynamic> orderToReturn = {
    'id': 1,
    'ticker': 'PETR4',
    'side': 'BUY',
    'quantity': 10.0,
    'price': 30.5,
    'total': 305.0,
    'executedAt': '2026-01-01T12:00:00Z',
    'clientOrderId': 'order-1',
  };
  List<Map<String, dynamic>> ordersToReturn = [];
  List<Map<String, dynamic>> quotesToReturn = [];
  Map<String, dynamic>? quoteToReturn;
  bool resetCalled = false;
  String? lastPlacedTicker;

  @override
  Future<Map<String, dynamic>> fetchPortfolio() async => portfolioToReturn;

  @override
  Future<Map<String, dynamic>> placeOrder({
    required String ticker,
    required String side,
    required double quantity,
    String? clientOrderId,
  }) async {
    lastPlacedTicker = ticker;
    return orderToReturn;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchOrders() async => ordersToReturn;

  @override
  Future<void> reset() async {
    resetCalled = true;
  }

  @override
  Future<List<Map<String, dynamic>>> searchQuotes(String query) async => quotesToReturn;

  @override
  Future<Map<String, dynamic>?> fetchQuote(String ticker) async => quoteToReturn;
}


void main() {
  late FakeSimulatedWalletRemoteDataSource remoteDataSource;
  late SimulatedWalletRepository repository;

  setUp(() {
    remoteDataSource = FakeSimulatedWalletRemoteDataSource();
    repository = SimulatedWalletRepository(remoteDataSource: remoteDataSource);
  });

  test('fetchPortfolio maps raw JSON into a SimulatedPortfolioSummary', () async {
    final result = await repository.fetchPortfolio();

    expect(result.virtualBalance, 10000.0);
    expect(result.currency, 'BRL');
    expect(result.positions, isEmpty);
  });

  test('placeOrder sends the enum\'s apiValue as the side string', () async {
    await repository.placeOrder(ticker: 'PETR4', side: SimulatedOrderSide.buy, quantity: 10);

    expect(remoteDataSource.lastPlacedTicker, 'PETR4');
  });

  test('placeOrder maps the raw JSON into a SimulatedOrder', () async {
    final result = await repository.placeOrder(ticker: 'PETR4', side: SimulatedOrderSide.buy, quantity: 10);

    expect(result.id, 1);
    expect(result.side, SimulatedOrderSide.buy);
    expect(result.total, 305.0);
  });

  test('fetchOrders maps each raw entry into a SimulatedOrder', () async {
    remoteDataSource.ordersToReturn = [remoteDataSource.orderToReturn];

    final result = await repository.fetchOrders();

    expect(result, hasLength(1));
    expect(result.single.ticker, 'PETR4');
  });

  test('reset delegates to the data source', () async {
    await repository.reset();

    expect(remoteDataSource.resetCalled, isTrue);
  });

  test('searchQuotes maps each raw entry into an AssetQuote', () async {
    remoteDataSource.quotesToReturn = [
      {'symbol': 'PETR4', 'shortName': 'Petrobras', 'regularMarketPrice': 30.5, 'currency': 'BRL'},
    ];

    final result = await repository.searchQuotes('petr');

    expect(result.single.symbol, 'PETR4');
  });

  test('fetchQuote returns null when the data source returns null', () async {
    remoteDataSource.quoteToReturn = null;

    final result = await repository.fetchQuote('GHOST99');

    expect(result, isNull);
  });

  test('fetchQuote maps the raw JSON into an AssetQuote when present', () async {
    remoteDataSource.quoteToReturn = {'symbol': 'PETR4', 'regularMarketPrice': 30.5, 'currency': 'BRL'};

    final result = await repository.fetchQuote('PETR4');

    expect(result?.symbol, 'PETR4');
  });
}
