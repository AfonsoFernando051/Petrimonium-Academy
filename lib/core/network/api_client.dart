import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:petrimonium/core/constants/api_constants.dart';
import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/core/events/app_event_bus.dart';

/// Every authenticated request goes through here, which is what makes
/// centralized 401 handling possible: a 401 triggers exactly one refresh
/// attempt (single-flight — concurrent 401s share the same in-flight
/// refresh rather than each firing their own) and, on success, retries the
/// original request once with the new access token. If refresh fails (no
/// refresh token stored, or the backend rejects it as invalid/expired/
/// revoked), both tokens are cleared and [SessionExpiredEvent] is emitted
/// so `main.dart`'s root listener can send the user back to the login
/// screen — no individual screen has to know any of this happened.
class ApiClient {
  final http.Client _client;
  final FlutterSecureStorage _secureStorage;

  /// Without a bound, a stalled connection (dead wifi, backend hung) leaves the caller
  /// awaiting forever — every request gets a `TimeoutException` instead past this point.
  static const Duration _requestTimeout = Duration(seconds: 15);

  /// [client]/[secureStorage] are injectable so tests can substitute mocks —
  /// production code relies on the defaults.
  ApiClient({http.Client? client, FlutterSecureStorage? secureStorage})
      : _client = client ?? http.Client(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Key under which the bearer token is stored. Moved off
  /// `shared_preferences` (which persists as unencrypted plaintext on disk)
  /// onto the platform keystore/keychain via `flutter_secure_storage`, since
  /// this value grants full account access.
  static const String authTokenKey = 'auth_token';

  /// Same storage/security reasoning as [authTokenKey] — a leaked refresh
  /// token is a longer-lived credential than the access token it can mint,
  /// so it gets the same keystore/keychain treatment, never SharedPreferences.
  static const String refreshTokenKey = 'refresh_token';

  // Single-flight refresh lock: every 401 that arrives while a refresh is
  // already in progress awaits this same future instead of starting its
  // own — otherwise N concurrent requests failing together would fire N
  // simultaneous refresh calls, each trying to rotate the same token out
  // from under the others.
  Future<bool>? _refreshInFlight;

  Future<String?> readToken() => _secureStorage.read(key: authTokenKey);

  Future<void> saveToken(String token) => _secureStorage.write(key: authTokenKey, value: token);

  Future<void> clearToken() => _secureStorage.delete(key: authTokenKey);

  Future<String?> readRefreshToken() => _secureStorage.read(key: refreshTokenKey);

  Future<void> saveRefreshToken(String token) => _secureStorage.write(key: refreshTokenKey, value: token);

  Future<void> clearRefreshToken() => _secureStorage.delete(key: refreshTokenKey);

  /// Saves both halves of a login/refresh response's token pair together —
  /// the two are always issued and consumed as a pair, never independently.
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await saveToken(accessToken);
    await saveRefreshToken(refreshToken);
  }

  Future<void> clearTokens() async {
    await clearToken();
    await clearRefreshToken();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await readToken();

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// [timeout] overrides [_requestTimeout] for callers that know their
  /// request is expected to take longer than a normal API call — e.g. the
  /// Mentor chat endpoint, which waits on an LLM reply rather than a
  /// straightforward database read.
  Future<http.Response> post(String endpoint, dynamic body, {Duration? timeout}) {
    return _sendWithAuth((headers) => _client
        .post(Uri.parse('${ApiConstants.baseUrl}$endpoint'), headers: headers, body: jsonEncode(body))
        .timeout(timeout ?? _requestTimeout));
  }

  Future<http.Response> get(String endpoint) {
    return _sendWithAuth(
        (headers) => _client.get(Uri.parse('${ApiConstants.baseUrl}$endpoint'), headers: headers).timeout(_requestTimeout));
  }

  Future<http.Response> put(String endpoint, dynamic body) {
    return _sendWithAuth((headers) => _client
        .put(Uri.parse('${ApiConstants.baseUrl}$endpoint'), headers: headers, body: jsonEncode(body))
        .timeout(_requestTimeout));
  }

  Future<http.Response> patch(String endpoint, dynamic body) {
    return _sendWithAuth((headers) => _client
        .patch(Uri.parse('${ApiConstants.baseUrl}$endpoint'), headers: headers, body: jsonEncode(body))
        .timeout(_requestTimeout));
  }

  Future<http.Response> delete(String endpoint) {
    return _sendWithAuth(
        (headers) => _client.delete(Uri.parse('${ApiConstants.baseUrl}$endpoint'), headers: headers).timeout(_requestTimeout));
  }

  /// Sends [send] with fresh auth headers; on a 401, attempts exactly one
  /// refresh-and-retry. [isRetry] caps that to a single attempt — a 401 on
  /// the retried request itself (refresh "succeeded" but the new token is
  /// somehow still rejected, or some other 401 cause entirely) is returned
  /// as-is rather than looping.
  ///
  /// Retrying after a successful refresh is safe for every HTTP method here
  /// (not just GET): the backend's JWT filter rejects an unauthenticated
  /// request before it ever reaches a controller/use case
  /// (`JwtAuthenticationFilter`, ordered ahead of every route), so a 401
  /// response is a guarantee that no business logic — no mutation — ran for
  /// that request. There is nothing to double-apply by retrying it.
  Future<http.Response> _sendWithAuth(
    Future<http.Response> Function(Map<String, String> headers) send, {
    bool isRetry = false,
  }) async {
    final headers = await _getHeaders();
    final response = await send(headers);

    if (response.statusCode != 401 || isRetry) {
      return response;
    }

    final refreshed = await _refreshAccessToken();
    if (!refreshed) {
      return response;
    }

    return _sendWithAuth(send, isRetry: true);
  }

  Future<bool> _refreshAccessToken() {
    return _refreshInFlight ??= _performRefresh().whenComplete(() => _refreshInFlight = null);
  }

  Future<bool> _performRefresh() async {
    final refreshToken = await readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _handleSessionExpired();
      return false;
    }

    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.refreshTokenEndpoint}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        await _handleSessionExpired();
        return false;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final newAccessToken = data['accessToken'] as String?;
      final newRefreshToken = data['refreshToken'] as String?;
      if (newAccessToken == null || newRefreshToken == null) {
        await _handleSessionExpired();
        return false;
      }

      await saveTokens(accessToken: newAccessToken, refreshToken: newRefreshToken);
      return true;
    } catch (_) {
      // A network-level failure (timeout, no connectivity) refreshing the
      // token is not the same claim as "this session is invalid" — the
      // original request already failed with a real 401 from the server,
      // so surfacing that as-is (rather than force-logging-out on what
      // might just be a flaky connection) is the safer read of what
      // actually happened.
      return false;
    }
  }

  Future<void> _handleSessionExpired() async {
    await clearTokens();
    AppEventBus.instance.emit(const SessionExpiredEvent());
  }
}
