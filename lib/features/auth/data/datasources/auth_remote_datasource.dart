import 'dart:convert';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/core/network/api_error_parser.dart';
import 'package:petrimonium/core/constants/api_constants.dart';
import 'package:petrimonium/features/auth/data/models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource({required this.apiClient});

  Future<UserModel> login(String email, String password) async {
    final response = await apiClient.post(
      ApiConstants.loginEndpoint,
      {
        'email': email,
        'password': password,
        'appContext': ApiConstants.appContext,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception(extractErrorDetail(response, fallback: 'Failed to login. Status Code: ${response.statusCode}'));
    }
  }

  Future<UserModel> loginWithGoogle(String idToken) async {
    final response = await apiClient.post(
      ApiConstants.googleLoginEndpoint,
      {'idToken': idToken, 'appContext': ApiConstants.appContext},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception(extractErrorDetail(response, fallback: 'Failed to sign in with Google. Status Code: ${response.statusCode}'));
    }
  }

  Future<UserModel> register(String name, String email, String password) async {
    final response = await apiClient.post(
      ApiConstants.registerEndpoint,
      {
        'username': name,
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception(extractErrorDetail(response, fallback: 'Failed to register. Status Code: ${response.statusCode}'));
    }
  }

  /// Backend always answers 200 here (even for an unregistered email) to
  /// avoid user enumeration, so the only failure mode worth surfacing is a
  /// transport-level error, which `apiClient.post` already throws for.
  Future<void> requestPasswordReset(String email) async {
    final response = await apiClient.post(
      ApiConstants.forgotPasswordEndpoint,
      {'email': email},
    );

    if (response.statusCode != 200) {
      throw Exception(
        extractErrorDetail(response, fallback: 'Failed to request password reset. Status Code: ${response.statusCode}'),
      );
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    final response = await apiClient.post(
      ApiConstants.resetPasswordEndpoint,
      {'token': token, 'newPassword': newPassword},
    );

    if (response.statusCode != 200) {
      throw Exception(
        extractErrorDetail(response, fallback: 'Failed to reset password. Status Code: ${response.statusCode}'),
      );
    }
  }

  /// Resolves the authenticated user's own display name/email — the only
  /// way to get a name for a returning user, since `/auth/login`'s response
  /// carries just the token pair. See `AuthRepository.refreshUserName`.
  Future<UserModel> getCurrentUser() async {
    final response = await apiClient.get(ApiConstants.currentUserEndpoint);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception(
        extractErrorDetail(response, fallback: 'Failed to load current user. Status Code: ${response.statusCode}'),
      );
    }
  }

  /// Revokes [refreshToken] server-side (see backend `LogoutUseCase` — always
  /// 200, even for an already-invalid/unknown token) so a copy of it can't
  /// keep minting new access tokens after the user believes they've logged
  /// out. Best-effort by design: callers should still clear local state even
  /// if this fails (e.g. offline logout) — see `AuthRepository.logout`.
  Future<void> logout(String refreshToken) async {
    await apiClient.post(
      ApiConstants.logoutEndpoint,
      {'refreshToken': refreshToken},
    );
  }
}
