import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrimonium/core/constants/api_constants.dart';
import 'package:petrimonium/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:petrimonium/features/auth/data/models/user_model.dart';

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepository({required this.remoteDataSource});

  bool _googleSignInInitialized = false;

  Future<void> login(String email, String password) async {
    final user = await remoteDataSource.login(email, password);
    await _saveTokens(user);
    await _saveEmail(email);
  }

  /// Runs the native Google Sign-In flow, then exchanges the resulting ID
  /// token for our own JWT via [remoteDataSource]. Returns normally without
  /// signing the user in if they cancel the Google flow.
  Future<void> loginWithGoogle() async {
    // google_sign_in only ships a real platform implementation for
    // Android/iOS/macOS/Web (see its pubspec.yaml). On Linux/Windows the
    // plugin falls back to a placeholder that throws UnsupportedError from
    // any call — surface that as a clear message instead of the raw
    // "UnimplementedError" text.
    try {
      if (!_googleSignInInitialized) {
        await GoogleSignIn.instance.initialize(
          serverClientId: ApiConstants.googleServerClientId,
        );
        _googleSignInInitialized = true;
      }
    } on UnsupportedError {
      throw Exception('Login com Google não está disponível neste dispositivo.');
    }

    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      rethrow;
    } on UnsupportedError {
      throw Exception('Login com Google não está disponível neste dispositivo.');
    }

    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw Exception('Google did not return an ID token.');
    }

    final user = await remoteDataSource.loginWithGoogle(idToken);
    await _saveTokens(user);
    // /auth/google's response carries the token pair (like /auth/login), so
    // the email comes from the Google account itself, not the backend reply.
    await _saveEmail(account.email);
  }

  Future<void> register(String name, String email, String password) async {
    final user = await remoteDataSource.register(name, email, password);
    await _saveTokens(user);
    await _saveEmail(email);
  }

  /// Always succeeds server-side regardless of whether [email] belongs to an
  /// account (avoids leaking which emails are registered).
  Future<void> requestPasswordReset(String email) {
    return remoteDataSource.requestPasswordReset(email);
  }

  Future<void> resetPassword(String token, String newPassword) {
    return remoteDataSource.resetPassword(token, newPassword);
  }

  Future<void> logout() async {
    // Revoke the refresh token server-side first (best-effort — a network
    // failure here must not block the user from logging out locally, e.g.
    // offline) so a copy of it can't keep minting new access tokens after
    // this device believes the session is over.
    final refreshToken = await remoteDataSource.apiClient.readRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await remoteDataSource.logout(refreshToken);
      } catch (_) {
        // Local state is cleared below regardless — see method doc.
      }
    }

    // Both tokens live in secure storage (see ApiClient); only the
    // non-sensitive last-used email stays in SharedPreferences.
    await remoteDataSource.apiClient.clearTokens();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_email');
  }

  Future<void> _saveTokens(UserModel user) async {
    final token = user.token;
    final refreshToken = user.refreshToken;
    if (token != null && token.isNotEmpty && refreshToken != null && refreshToken.isNotEmpty) {
      await remoteDataSource.apiClient.saveTokens(accessToken: token, refreshToken: refreshToken);
    }
  }

  Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_email', email);
  }

  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_email');
  }

  Future<bool> isLoggedIn() async {
    final token = await remoteDataSource.apiClient.readToken();
    return token != null;
  }
}
