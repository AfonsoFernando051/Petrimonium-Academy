import 'dart:convert';

import 'package:petrimonium/core/network/api_client.dart';

/// Thin HTTP layer over the new `/api/investments` read endpoints
/// (`GetPortfolioHoldingsUseCase` / summary / allocation / history on the
/// backend). Returns raw decoded JSON — mapping into domain entities is the
/// repository's job, matching this app's existing datasource/repository split.
class PortfolioRemoteDataSource {
  final ApiClient apiClient;

  PortfolioRemoteDataSource({required this.apiClient});

  Future<List<Map<String, dynamic>>> fetchHoldings() async {
    final response = await apiClient.get('/api/investments');
    if (response.statusCode != 200) {
      throw Exception('Failed to load holdings (${response.statusCode})');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> fetchSummary() async {
    final response = await apiClient.get('/api/investments/summary');
    if (response.statusCode != 200) {
      throw Exception('Failed to load portfolio summary (${response.statusCode})');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> fetchAllocation() async {
    final response = await apiClient.get('/api/investments/allocation');
    if (response.statusCode != 200) {
      throw Exception('Failed to load allocation (${response.statusCode})');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchHistory(String range) async {
    final response = await apiClient.get('/api/investments/history?range=$range');
    if (response.statusCode != 200) {
      throw Exception('Failed to load portfolio history (${response.statusCode})');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> fetchDividends() async {
    final response = await apiClient.get('/api/investments/dividends');
    if (response.statusCode != 200) {
      throw Exception('Failed to load dividend radar (${response.statusCode})');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
