import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/constants/api_constants.dart';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/features/settings/data/datasources/settings_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late SettingsRemoteDataSource dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = SettingsRemoteDataSource(apiClient: mockApiClient);
  });

  group('getLanguage', () {
    test('returns the language from the decoded body on 200', () async {
      when(() => mockApiClient.get(any())).thenAnswer(
        (_) async => http.Response(jsonEncode({'language': 'en'}), 200),
      );

      final result = await dataSource.getLanguage();

      expect(result, 'en');
      verify(() => mockApiClient.get(ApiConstants.settingsLanguageEndpoint)).called(1);
    });

    test('throws an Exception on a non-200 response', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response('', 401));

      await expectLater(
        () => dataSource.getLanguage(),
        throwsA(predicate((e) => e is Exception && e.toString().contains('401'))),
      );
    });
  });

  group('updateLanguage', () {
    test('puts the new language and returns the confirmed value on 200', () async {
      when(() => mockApiClient.put(any(), any())).thenAnswer(
        (_) async => http.Response(jsonEncode({'language': 'es'}), 200),
      );

      final result = await dataSource.updateLanguage('es');

      expect(result, 'es');
      verify(() => mockApiClient.put(
            ApiConstants.settingsLanguageEndpoint,
            {'language': 'es'},
          )).called(1);
    });

    test('throws an Exception on a non-200 response', () async {
      when(() => mockApiClient.put(any(), any())).thenAnswer((_) async => http.Response('', 400));

      await expectLater(
        () => dataSource.updateLanguage('es'),
        throwsA(predicate((e) => e is Exception && e.toString().contains('400'))),
      );
    });
  });
}
