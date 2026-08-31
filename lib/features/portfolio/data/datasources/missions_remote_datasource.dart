import 'dart:convert';
import 'package:petrimonium/core/constants/api_constants.dart';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/core/network/api_error_parser.dart';

class MissionsRemoteDataSource {
  final ApiClient apiClient;

  MissionsRemoteDataSource({required this.apiClient});

  /// Triggers the backend to re-check every mission's progress against the
  /// user's real learning activity for its current period and persist any
  /// newly-completed instance.
  Future<Map<String, dynamic>> evaluate() async {
    final response = await apiClient.get(ApiConstants.missionsEndpoint);
    if (response.statusCode != 200) {
      throw Exception(
        extractErrorDetail(response, fallback: 'Failed to evaluate missions. Status Code: ${response.statusCode}'),
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
