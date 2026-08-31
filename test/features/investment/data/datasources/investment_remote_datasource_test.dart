import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/features/investment/data/datasources/investment_remote_datasource.dart';
import 'package:petrimonium/features/investment/data/models/asset_registration_model.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late InvestmentRemoteDataSource dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = InvestmentRemoteDataSource(apiClient: mockApiClient);
  });

  group('configureInvestments', () {
    final investment = AssetRegistrationModel(
      name: 'PETR4',
      quantity: 10,
      purchasePrice: 20.0,
      purchaseDate: '2024-01-01',
      type: InvestmentTypeEnum.STOCKS,
    );

    test('posts the serialized investment list and completes on 200', () async {
      when(() => mockApiClient.post(any(), any())).thenAnswer((_) async => http.Response('', 200));

      await dataSource.configureInvestments([investment]);

      verify(() => mockApiClient.post('/api/investments/configure', [investment.toJson()])).called(1);
    });

    test('throws an Exception on a non-200 response', () async {
      when(() => mockApiClient.post(any(), any())).thenAnswer((_) async => http.Response('', 400));

      await expectLater(
        () => dataSource.configureInvestments([investment]),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('fetchQuote', () {
    test('returns the decoded JSON on 200', () async {
      when(() => mockApiClient.get(any())).thenAnswer(
        (_) async => http.Response(jsonEncode({'ticker': 'PETR4', 'price': 32.5}), 200),
      );

      final result = await dataSource.fetchQuote('PETR4');

      expect(result?['price'], 32.5);
      verify(() => mockApiClient.get('/api/investments/quote/PETR4')).called(1);
    });

    test('swallows a non-200 response and returns null rather than throwing', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response('Not Found', 404));

      final result = await dataSource.fetchQuote('ZZZZ');

      expect(result, isNull);
    });

    test('swallows a transport failure and returns null rather than throwing', () async {
      when(() => mockApiClient.get(any())).thenThrow(Exception('network down'));

      final result = await dataSource.fetchQuote('PETR4');

      expect(result, isNull);
    });
  });

  group('searchQuotes', () {
    test('returns the decoded list on 200', () async {
      when(() => mockApiClient.get(any())).thenAnswer(
        (_) async => http.Response(
          jsonEncode([
            {'ticker': 'PETR4'},
            {'ticker': 'VALE3'},
          ]),
          200,
        ),
      );

      final result = await dataSource.searchQuotes('PET');

      expect(result.length, 2);
      verify(() => mockApiClient.get('/api/investments/search?query=PET')).called(1);
    });

    test('swallows a non-200 response and returns an empty list rather than throwing', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response('', 500));

      final result = await dataSource.searchQuotes('PET');

      expect(result, isEmpty);
    });

    test('swallows a transport failure and returns an empty list rather than throwing', () async {
      when(() => mockApiClient.get(any())).thenThrow(Exception('network down'));

      final result = await dataSource.searchQuotes('PET');

      expect(result, isEmpty);
    });
  });
}
