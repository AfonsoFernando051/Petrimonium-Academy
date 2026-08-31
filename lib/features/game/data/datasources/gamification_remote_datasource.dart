import 'dart:convert';
import 'package:petrimonium/core/constants/api_constants.dart';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/core/network/api_error_parser.dart';

class GamificationRemoteDataSource {
  final ApiClient apiClient;

  GamificationRemoteDataSource({required this.apiClient});

  Future<Map<String, dynamic>> fetchSummary() async {
    final response = await apiClient.get(ApiConstants.gamificationSummaryEndpoint);
    if (response.statusCode != 200) {
      throw Exception(
        extractErrorDetail(response, fallback: 'Failed to load gamification summary. Status Code: ${response.statusCode}'),
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
