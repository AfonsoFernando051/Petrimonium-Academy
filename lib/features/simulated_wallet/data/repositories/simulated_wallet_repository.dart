import 'package:petrimonium/features/simulated_wallet/data/datasources/simulated_wallet_remote_datasource.dart';
import 'package:petrimonium/features/simulated_wallet/domain/entities/asset_quote.dart';
import 'package:petrimonium/features/simulated_wallet/domain/entities/simulated_order.dart';
import 'package:petrimonium/features/simulated_wallet/domain/entities/simulated_order_side.dart';
import 'package:petrimonium/features/simulated_wallet/domain/entities/simulated_portfolio_summary.dart';

class SimulatedWalletRepository {
  final SimulatedWalletRemoteDataSource remoteDataSource;

  SimulatedWalletRepository({required this.remoteDataSource});

  Future<SimulatedPortfolioSummary> fetchPortfolio() async {
    final raw = await remoteDataSource.fetchPortfolio();
    return SimulatedPortfolioSummary.fromJson(raw);
  }

  Future<SimulatedOrder> placeOrder({
    required String ticker,
    required SimulatedOrderSide side,
    required double quantity,
    String? clientOrderId,
  }) async {
    final raw = await remoteDataSource.placeOrder(
      ticker: ticker,
      side: side.apiValue,
      quantity: quantity,
      clientOrderId: clientOrderId,
    );
    return SimulatedOrder.fromJson(raw);
  }

  Future<List<SimulatedOrder>> fetchOrders() async {
    final raw = await remoteDataSource.fetchOrders();
    return raw.map(SimulatedOrder.fromJson).toList();
  }

  Future<void> reset() => remoteDataSource.reset();

  Future<List<AssetQuote>> searchQuotes(String query) async {
    final raw = await remoteDataSource.searchQuotes(query);
    return raw.map(AssetQuote.fromJson).toList();
  }

  Future<AssetQuote?> fetchQuote(String ticker) async {
    final raw = await remoteDataSource.fetchQuote(ticker);
    return raw == null ? null : AssetQuote.fromJson(raw);
  }
}
