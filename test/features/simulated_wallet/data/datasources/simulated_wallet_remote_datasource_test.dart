import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/constants/api_constants.dart';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/features/simulated_wallet/data/datasources/simulated_wallet_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late SimulatedWalletRemoteDataSource dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = SimulatedWalletRemoteDataSource(apiClient: mockApiClient);
  });

  group('endpoints — never real_portfolio', () {
    test('every endpoint this datasource calls is under /api/v1/simulated-portfolios, never /api/investments', () {
      // A static, structural guard: whatever this datasource does at runtime,
      // it can only ever hit these constants — see ApiConstants.
      expect(ApiConstants.simulatedPortfolioMeEndpoint, startsWith('/api/v1/simulated-portfolios'));
      expect(ApiConstants.simulatedPortfolioOrdersEndpoint, startsWith('/api/v1/simulated-portfolios'));
      expect(ApiConstants.simulatedPortfolioResetEndpoint, startsWith('/api/v1/simulated-portfolios'));
      expect(ApiConstants.simulatedPortfolioQuoteSearchEndpoint('petr4'), startsWith('/api/v1/simulated-portfolios'));
      expect(ApiConstants.simulatedPortfolioQuoteEndpoint('PETR4'), startsWith('/api/v1/simulated-portfolios'));

      expect(ApiConstants.simulatedPortfolioMeEndpoint, isNot(contains('/api/investments')));
      expect(ApiConstants.simulatedPortfolioOrdersEndpoint, isNot(contains('/api/investments')));
      expect(ApiConstants.simulatedPortfolioResetEndpoint, isNot(contains('/api/investments')));
    });
  });

  group('fetchPortfolio', () {
    test('returns the decoded JSON on 200', () async {
      when(() => mockApiClient.get(ApiConstants.simulatedPortfolioMeEndpoint)).thenAnswer(
        (_) async => http.Response(jsonEncode({'virtualBalance': 10000.0, 'positions': []}), 200),
      );

      final result = await dataSource.fetchPortfolio();

      expect(result['virtualBalance'], 10000.0);
    });

    test('throws with the surfaced detail on a non-200 response', () async {
      when(() => mockApiClient.get(ApiConstants.simulatedPortfolioMeEndpoint)).thenAnswer(
        (_) async => http.Response(jsonEncode({'detail': 'User not found'}), 404),
      );

      await expectLater(
        () => dataSource.fetchPortfolio(),
        throwsA(predicate((e) => e is Exception && e.toString().contains('User not found'))),
      );
    });
  });

  group('placeOrder', () {
    test('sends ticker/side/quantity and returns the decoded order on 201', () async {
      when(() => mockApiClient.post(ApiConstants.simulatedPortfolioOrdersEndpoint, any())).thenAnswer(
        (_) async => http.Response(jsonEncode({'id': 1, 'ticker': 'PETR4'}), 201),
      );

      final result = await dataSource.placeOrder(ticker: 'PETR4', side: 'BUY', quantity: 10);

      expect(result['ticker'], 'PETR4');
      verify(() => mockApiClient.post(
            ApiConstants.simulatedPortfolioOrdersEndpoint,
            {'ticker': 'PETR4', 'side': 'BUY', 'quantity': 10.0},
          )).called(1);
    });

    test('includes clientOrderId only when provided', () async {
      when(() => mockApiClient.post(any(), any())).thenAnswer(
        (_) async => http.Response(jsonEncode({'id': 1, 'ticker': 'PETR4'}), 201),
      );

      await dataSource.placeOrder(ticker: 'PETR4', side: 'BUY', quantity: 10, clientOrderId: 'retry-1');

      verify(() => mockApiClient.post(
            ApiConstants.simulatedPortfolioOrdersEndpoint,
            {'ticker': 'PETR4', 'side': 'BUY', 'quantity': 10.0, 'clientOrderId': 'retry-1'},
          )).called(1);
    });

    test('throws on a non-201 response', () async {
      when(() => mockApiClient.post(any(), any())).thenAnswer(
        (_) async => http.Response(jsonEncode({'detail': 'Insufficient virtual balance'}), 400),
      );

      await expectLater(
        () => dataSource.placeOrder(ticker: 'PETR4', side: 'BUY', quantity: 10),
        throwsA(predicate((e) => e is Exception && e.toString().contains('Insufficient virtual balance'))),
      );
    });
  });

  group('fetchOrders', () {
    test('returns the decoded order list on 200', () async {
      when(() => mockApiClient.get(ApiConstants.simulatedPortfolioOrdersEndpoint)).thenAnswer(
        (_) async => http.Response(jsonEncode([{'id': 1}, {'id': 2}]), 200),
      );

      final result = await dataSource.fetchOrders();

      expect(result, hasLength(2));
    });
  });

  group('reset', () {
    test('sends confirm:true and completes normally on 204', () async {
      when(() => mockApiClient.post(any(), any())).thenAnswer((_) async => http.Response('', 204));

      await dataSource.reset();

      verify(() => mockApiClient.post(ApiConstants.simulatedPortfolioResetEndpoint, {'confirm': true})).called(1);
    });

    test('throws on a non-204 response', () async {
      when(() => mockApiClient.post(any(), any())).thenAnswer(
        (_) async => http.Response(jsonEncode({'detail': 'confirm must be true'}), 400),
      );

      await expectLater(() => dataSource.reset(), throwsA(isA<Exception>()));
    });
  });

  group('searchQuotes', () {
    test('returns the decoded quote list on 200', () async {
      when(() => mockApiClient.get(ApiConstants.simulatedPortfolioQuoteSearchEndpoint('petr'))).thenAnswer(
        (_) async => http.Response(jsonEncode([{'symbol': 'PETR4'}]), 200),
      );

      final result = await dataSource.searchQuotes('petr');

      expect(result.single['symbol'], 'PETR4');
    });

    test('throws on a non-200 response', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response('', 500));

      await expectLater(() => dataSource.searchQuotes('petr'), throwsA(isA<Exception>()));
    });
  });

  group('fetchQuote', () {
    test('returns the decoded quote on 200', () async {
      when(() => mockApiClient.get(ApiConstants.simulatedPortfolioQuoteEndpoint('PETR4'))).thenAnswer(
        (_) async => http.Response(jsonEncode({'symbol': 'PETR4', 'regularMarketPrice': 30.5}), 200),
      );

      final result = await dataSource.fetchQuote('PETR4');

      expect(result?['regularMarketPrice'], 30.5);
    });

    test('returns null (not an error) on 404 — unknown ticker is a normal outcome', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response('', 404));

      final result = await dataSource.fetchQuote('GHOST99');

      expect(result, isNull);
    });

    test('throws on any other non-200 response', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response('', 500));

      await expectLater(() => dataSource.fetchQuote('PETR4'), throwsA(isA<Exception>()));
    });
  });
}
