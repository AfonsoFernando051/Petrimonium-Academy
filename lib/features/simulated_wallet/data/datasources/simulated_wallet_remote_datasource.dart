import 'dart:convert';

import 'package:petrimonium/core/constants/api_constants.dart';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/core/network/api_error_parser.dart';

/// Thin HTTP layer over `/api/v1/simulated-portfolios/*` — entirely separate
/// from `PortfolioRemoteDataSource`'s `/api/investments/*` calls, both by
/// backend contract (simulated_portfolio vs real_portfolio) and by never
/// importing from that feature. Returns raw decoded JSON; mapping into
/// domain entities is the repository's job.
class SimulatedWalletRemoteDataSource {
  final ApiClient apiClient;

  SimulatedWalletRemoteDataSource({required this.apiClient});

  Future<Map<String, dynamic>> fetchPortfolio() async {
    final response = await apiClient.get(ApiConstants.simulatedPortfolioMeEndpoint);
    if (response.statusCode != 200) {
      throw Exception(extractErrorDetail(
        response,
        fallback: 'Failed to load simulated portfolio. Status Code: ${response.statusCode}',
      ));
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> placeOrder({
    required String ticker,
    required String side,
    required double quantity,
    String? clientOrderId,
  }) async {
    final response = await apiClient.post(
      ApiConstants.simulatedPortfolioOrdersEndpoint,
      {
        'ticker': ticker,
        'side': side,
        'quantity': quantity,
        if (clientOrderId != null) 'clientOrderId': clientOrderId,
      },
    );
    if (response.statusCode != 201) {
      throw Exception(extractErrorDetail(
        response,
        fallback: 'Failed to place simulated order. Status Code: ${response.statusCode}',
      ));
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final response = await apiClient.get(ApiConstants.simulatedPortfolioOrdersEndpoint);
    if (response.statusCode != 200) {
      throw Exception(extractErrorDetail(
        response,
        fallback: 'Failed to load simulated order history. Status Code: ${response.statusCode}',
      ));
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> reset() async {
    final response = await apiClient.post(
      ApiConstants.simulatedPortfolioResetEndpoint,
      {'confirm': true},
    );
    if (response.statusCode != 204) {
      throw Exception(extractErrorDetail(
        response,
        fallback: 'Failed to reset simulated portfolio. Status Code: ${response.statusCode}',
      ));
    }
  }

  Future<List<Map<String, dynamic>>> searchQuotes(String query) async {
    final response = await apiClient.get(ApiConstants.simulatedPortfolioQuoteSearchEndpoint(query));
    if (response.statusCode != 200) {
      throw Exception(extractErrorDetail(
        response,
        fallback: 'Failed to search assets. Status Code: ${response.statusCode}',
      ));
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  /// Returns `null` for an unknown ticker (backend answers 404) rather than
  /// throwing — callers treat "no quote available" as a normal outcome.
  Future<Map<String, dynamic>?> fetchQuote(String ticker) async {
    final response = await apiClient.get(ApiConstants.simulatedPortfolioQuoteEndpoint(ticker));
    if (response.statusCode == 404) {
      return null;
    }
    if (response.statusCode != 200) {
      throw Exception(extractErrorDetail(
        response,
        fallback: 'Failed to fetch quote. Status Code: ${response.statusCode}',
      ));
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
