import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/features/portfolio/data/datasources/portfolio_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late PortfolioRemoteDataSource dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = PortfolioRemoteDataSource(apiClient: mockApiClient);
  });

  group('fetchHoldings', () {
    test('returns the decoded lot list on 200', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response(
            jsonEncode([
              {'id': 1, 'name': 'PETR4'},
            ]),
            200,
          ));

      final result = await dataSource.fetchHoldings();

      expect(result.single['name'], 'PETR4');
      verify(() => mockApiClient.get('/api/investments')).called(1);
    });

    test('throws an Exception on a non-200 response', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response('', 500));

      await expectLater(
        () => dataSource.fetchHoldings(),
        throwsA(predicate((e) => e is Exception && e.toString().contains('500'))),
      );
    });
  });

  group('fetchSummary', () {
    test('returns the decoded summary JSON on 200', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response(
            jsonEncode({'investedCapital': 1000.0}),
            200,
          ));

      final result = await dataSource.fetchSummary();

      expect(result['investedCapital'], 1000.0);
      verify(() => mockApiClient.get('/api/investments/summary')).called(1);
    });

    test('throws an Exception on a non-200 response', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response('', 500));

      await expectLater(
        () => dataSource.fetchSummary(),
        throwsA(predicate((e) => e is Exception && e.toString().contains('500'))),
      );
    });
  });

  group('fetchAllocation', () {
    test('returns the decoded allocation list on 200', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response(
            jsonEncode([
              {'type': 'STOCKS', 'percent': 60.0},
            ]),
            200,
          ));

      final result = await dataSource.fetchAllocation();

      expect(result.single['type'], 'STOCKS');
      verify(() => mockApiClient.get('/api/investments/allocation')).called(1);
    });

    test('throws an Exception on a non-200 response', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response('', 500));

      await expectLater(
        () => dataSource.fetchAllocation(),
        throwsA(predicate((e) => e is Exception && e.toString().contains('500'))),
      );
    });
  });

  group('fetchHistory', () {
    test('sends the given range as a query param and returns the decoded list', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response(
            jsonEncode([
              {'date': '2024-01-01', 'value': 1000.0},
            ]),
            200,
          ));

      final result = await dataSource.fetchHistory('3M');

      expect(result.single['value'], 1000.0);
      verify(() => mockApiClient.get('/api/investments/history?range=3M')).called(1);
    });

    test('throws an Exception on a non-200 response', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response('', 500));

      await expectLater(
        () => dataSource.fetchHistory('3M'),
        throwsA(predicate((e) => e is Exception && e.toString().contains('500'))),
      );
    });
  });

  group('fetchDividends', () {
    test('returns the decoded dividend radar JSON on 200', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response(
            jsonEncode({'received': 100.0, 'expected': 50.0}),
            200,
          ));

      final result = await dataSource.fetchDividends();

      expect(result['received'], 100.0);
      verify(() => mockApiClient.get('/api/investments/dividends')).called(1);
    });

    test('throws an Exception on a non-200 response', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response('', 500));

      await expectLater(
        () => dataSource.fetchDividends(),
        throwsA(predicate((e) => e is Exception && e.toString().contains('500'))),
      );
    });
  });
}
