import 'dart:convert';

import 'package:petrimonium/core/constants/api_constants.dart';
import 'package:petrimonium/core/network/api_client.dart';

class SettingsRemoteDataSource {
  final ApiClient apiClient;

  SettingsRemoteDataSource({required this.apiClient});

  Future<String> getLanguage() async {
    final response = await apiClient.get(ApiConstants.settingsLanguageEndpoint);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['language'] as String;
    }
    throw Exception('Failed to load language preference. Status code: ${response.statusCode}');
  }

  Future<String> updateLanguage(String language) async {
    final response = await apiClient.put(
      ApiConstants.settingsLanguageEndpoint,
      {'language': language},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['language'] as String;
    }
    throw Exception('Failed to update language preference. Status code: ${response.statusCode}');
  }
}
