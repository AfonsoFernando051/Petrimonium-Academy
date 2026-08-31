import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/constants/api_constants.dart';
import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/core/events/app_event_bus.dart';
import 'package:petrimonium/core/network/api_client.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockHttpClient httpClient;
  late MockSecureStorage secureStorage;
  late ApiClient apiClient;

  setUpAll(() {
    registerFallbackValue(Uri.parse('${ApiConstants.baseUrl}/fallback'));
  });

  setUp(() {
    httpClient = MockHttpClient();
    secureStorage = MockSecureStorage();
    apiClient = ApiClient(client: httpClient, secureStorage: secureStorage);

    final response = http.Response('{}', 200);
    when(() => httpClient.get(any(), headers: any(named: 'headers'))).thenAnswer((_) async => response);
    when(() => httpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
        .thenAnswer((_) async => response);
    when(() => httpClient.put(any(), headers: any(named: 'headers'), body: any(named: 'body')))
        .thenAnswer((_) async => response);
  });

  group('ApiClient token storage', () {
    test('saveToken writes under the shared auth token key', () async {
      when(() => secureStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      await apiClient.saveToken('token-123');

      verify(() => secureStorage.write(key: ApiClient.authTokenKey, value: 'token-123')).called(1);
    });

    test('readToken reads under the shared auth token key', () async {
      when(() => secureStorage.read(key: any(named: 'key'))).thenAnswer((_) async => 'stored-token');

      final token = await apiClient.readToken();

      expect(token, 'stored-token');
      verify(() => secureStorage.read(key: ApiClient.authTokenKey)).called(1);
    });

    test('clearToken deletes under the shared auth token key', () async {
      when(() => secureStorage.delete(key: any(named: 'key'))).thenAnswer((_) async {});

      await apiClient.clearToken();

      verify(() => secureStorage.delete(key: ApiClient.authTokenKey)).called(1);
    });
  });

  group('ApiClient request headers', () {
    test('get attaches a Bearer token when one is stored', () async {
      when(() => secureStorage.read(key: any(named: 'key'))).thenAnswer((_) async => 'abc123');

      await apiClient.get('/investments');

      final captured = verify(() => httpClient.get(captureAny(), headers: captureAny(named: 'headers'))).captured;
      final url = captured[0] as Uri;
      final headers = captured[1] as Map<String, String>;

      expect(url.toString(), '${ApiConstants.baseUrl}/investments');
      expect(headers['Authorization'], 'Bearer abc123');
      expect(headers['Content-Type'], 'application/json');
    });

    test('get omits the Authorization header when no token is stored', () async {
      when(() => secureStorage.read(key: any(named: 'key'))).thenAnswer((_) async => null);

      await apiClient.get('/investments');

      final captured = verify(() => httpClient.get(captureAny(), headers: captureAny(named: 'headers'))).captured;
      final headers = captured[1] as Map<String, String>;

      expect(headers.containsKey('Authorization'), isFalse);
    });

    test('post sends a JSON-encoded body with the auth header', () async {
      when(() => secureStorage.read(key: any(named: 'key'))).thenAnswer((_) async => 'abc123');

      await apiClient.post('/investments', {'ticker': 'PETR4'});

      final captured = verify(() => httpClient.post(
            captureAny(),
            headers: captureAny(named: 'headers'),
            body: captureAny(named: 'body'),
          )).captured;

      expect((captured[0] as Uri).toString(), '${ApiConstants.baseUrl}/investments');
      expect((captured[1] as Map<String, String>)['Authorization'], 'Bearer abc123');
      expect(captured[2], '{"ticker":"PETR4"}');
    });

    test('put sends a JSON-encoded body with the auth header', () async {
      when(() => secureStorage.read(key: any(named: 'key'))).thenAnswer((_) async => 'abc123');

      await apiClient.put('/settings', {'language': 'en'});

      final captured = verify(() => httpClient.put(
            captureAny(),
            headers: captureAny(named: 'headers'),
            body: captureAny(named: 'body'),
          )).captured;

      expect((captured[0] as Uri).toString(), '${ApiConstants.baseUrl}/settings');
      expect(captured[2], '{"language":"en"}');
    });
  });

  group('ApiClient centralized 401 handling', () {
    void stubTokens({String? accessToken, String? refreshToken}) {
      when(() => secureStorage.read(key: ApiClient.authTokenKey)).thenAnswer((_) async => accessToken);
      when(() => secureStorage.read(key: ApiClient.refreshTokenKey)).thenAnswer((_) async => refreshToken);
      when(() => secureStorage.write(key: any(named: 'key'), value: any(named: 'value'))).thenAnswer((_) async {});
      when(() => secureStorage.delete(key: any(named: 'key'))).thenAnswer((_) async {});
    }

    test('a 401 triggers exactly one refresh, then retries the original request with the new token', () async {
      stubTokens(accessToken: 'expired-token', refreshToken: 'valid-refresh-token');

      final unauthorized = http.Response('{}', 401);
      final ok = http.Response('{"holdings":[]}', 200);
      // First GET call: 401. Second GET call (the retry, after refresh): 200.
      var getCallCount = 0;
      when(() => httpClient.get(any(), headers: any(named: 'headers'))).thenAnswer((_) async {
        getCallCount++;
        return getCallCount == 1 ? unauthorized : ok;
      });
      when(() => httpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response(
              jsonEncode({'accessToken': 'new-access-token', 'refreshToken': 'new-refresh-token'}), 200));

      final response = await apiClient.get('/portfolio/summary');

      expect(response.statusCode, 200);
      expect(getCallCount, 2);
      verify(() => secureStorage.write(key: ApiClient.authTokenKey, value: 'new-access-token')).called(1);
      verify(() => secureStorage.write(key: ApiClient.refreshTokenKey, value: 'new-refresh-token')).called(1);

      final refreshCall = verify(() => httpClient.post(captureAny(),
              headers: captureAny(named: 'headers'), body: captureAny(named: 'body')))
          .captured;
      expect((refreshCall[0] as Uri).toString(), '${ApiConstants.baseUrl}${ApiConstants.refreshTokenEndpoint}');
      expect(refreshCall[2], jsonEncode({'refreshToken': 'valid-refresh-token'}));
    });

    test('concurrent 401s share a single refresh call, not one each', () async {
      stubTokens(accessToken: 'expired-token', refreshToken: 'valid-refresh-token');

      when(() => httpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('{}', 401));
      // The retry after refresh also gets a fresh 200 in this test — what matters here is
      // how many times the refresh endpoint itself was called, not the retries' outcome.
      var postCallCount = 0;
      when(() => httpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async {
        postCallCount++;
        return http.Response(jsonEncode({'accessToken': 'new-token', 'refreshToken': 'new-refresh'}), 200);
      });

      await Future.wait([
        apiClient.get('/a'),
        apiClient.get('/b'),
        apiClient.get('/c'),
      ]);

      expect(postCallCount, 1);
    });

    test('refresh failing clears both tokens and emits SessionExpiredEvent, without retrying', () async {
      stubTokens(accessToken: 'expired-token', refreshToken: 'stale-refresh-token');

      when(() => httpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('{}', 401));
      when(() => httpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('{"code":"INVALID_CREDENTIALS"}', 401));

      final events = <AppEvent>[];
      final subscription = AppEventBus.instance.stream.listen(events.add);

      final response = await apiClient.get('/portfolio/summary');
      await Future<void>.delayed(Duration.zero);

      expect(response.statusCode, 401);
      verify(() => httpClient.get(any(), headers: any(named: 'headers'))).called(1); // never retried
      verify(() => secureStorage.delete(key: ApiClient.authTokenKey)).called(1);
      verify(() => secureStorage.delete(key: ApiClient.refreshTokenKey)).called(1);
      expect(events, contains(isA<SessionExpiredEvent>()));

      await subscription.cancel();
    });

    test('a 401 with no refresh token stored emits SessionExpiredEvent without calling the refresh endpoint', () async {
      stubTokens(accessToken: 'expired-token', refreshToken: null);

      when(() => httpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('{}', 401));

      final events = <AppEvent>[];
      final subscription = AppEventBus.instance.stream.listen(events.add);

      await apiClient.get('/portfolio/summary');
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => httpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')));
      expect(events, contains(isA<SessionExpiredEvent>()));

      await subscription.cancel();
    });
  });
}
