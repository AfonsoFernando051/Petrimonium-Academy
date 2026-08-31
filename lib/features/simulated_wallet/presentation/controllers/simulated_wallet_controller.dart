import 'package:flutter/foundation.dart';
import 'package:petrimonium/core/utils/friendly_error_message.dart';
import 'package:petrimonium/features/simulated_wallet/data/repositories/simulated_wallet_repository.dart';
import 'package:petrimonium/features/simulated_wallet/domain/entities/asset_quote.dart';
import 'package:petrimonium/features/simulated_wallet/domain/entities/simulated_order.dart';
import 'package:petrimonium/features/simulated_wallet/domain/entities/simulated_order_side.dart';
import 'package:petrimonium/features/simulated_wallet/domain/entities/simulated_portfolio_summary.dart';

/// Owns all state for the simulated wallet (Academy's fictitious "Carteira"
/// tab) — entirely separate from `PortfolioController`, which still owns
/// the real-portfolio-flavored gamification orchestration (achievements/
/// missions/XP) until that's untangled in a later pass. This controller
/// never touches `PortfolioRepository`/`InvestmentRepository` or any
/// real_portfolio endpoint.
class SimulatedWalletController extends ChangeNotifier {
  SimulatedWalletController({required SimulatedWalletRepository repository})
      : _repository = repository;

  final SimulatedWalletRepository _repository;

  bool isLoading = true;
  String? error;
  SimulatedPortfolioSummary portfolio = SimulatedPortfolioSummary.empty;

  bool isPlacingOrder = false;
  String? orderError;

  bool isResetting = false;
  String? resetError;

  Future<void> loadPortfolio() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      portfolio = await _repository.fetchPortfolio();
    } catch (e) {
      error = friendlyErrorMessage(e);
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => loadPortfolio();

  /// Places a simulated order and reloads the portfolio on success so the
  /// new balance/position is immediately reflected. Returns the created
  /// order, or `null` if the placement failed (see [orderError]).
  Future<SimulatedOrder?> placeOrder({
    required String ticker,
    required SimulatedOrderSide side,
    required double quantity,
  }) async {
    isPlacingOrder = true;
    orderError = null;
    notifyListeners();

    SimulatedOrder? result;
    try {
      result = await _repository.placeOrder(ticker: ticker, side: side, quantity: quantity);
      portfolio = await _repository.fetchPortfolio();
    } catch (e) {
      orderError = friendlyErrorMessage(e);
    }

    isPlacingOrder = false;
    notifyListeners();
    return result;
  }

  /// Wipes every simulated position/order and restores the starting virtual
  /// balance. Caller is responsible for confirming with the user first —
  /// this always sends `confirm: true` once called (see
  /// `SimulatedWalletRemoteDataSource.reset`). Returns whether the reset
  /// succeeded.
  Future<bool> resetPortfolio() async {
    isResetting = true;
    resetError = null;
    notifyListeners();

    bool succeeded = false;
    try {
      await _repository.reset();
      portfolio = await _repository.fetchPortfolio();
      succeeded = true;
    } catch (e) {
      resetError = friendlyErrorMessage(e);
    }

    isResetting = false;
    notifyListeners();
    return succeeded;
  }

  Future<List<AssetQuote>> searchQuotes(String query) {
    if (query.trim().isEmpty) return Future.value(const []);
    return _repository.searchQuotes(query.trim());
  }

  Future<AssetQuote?> fetchQuote(String ticker) => _repository.fetchQuote(ticker);
}
