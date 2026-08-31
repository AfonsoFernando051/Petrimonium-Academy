import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/features/portfolio/data/datasources/portfolio_remote_datasource.dart';
import 'package:petrimonium/features/portfolio/data/repositories/portfolio_repository.dart';
import 'package:petrimonium/features/portfolio/domain/enums/history_range.dart';

class MockPortfolioRemoteDataSource extends Mock implements PortfolioRemoteDataSource {}

void main() {
  late MockPortfolioRemoteDataSource mockDataSource;
  late PortfolioRepository repository;

  setUp(() {
    mockDataSource = MockPortfolioRemoteDataSource();
    repository = PortfolioRepository(remoteDataSource: mockDataSource);
  });

  group('fetchHoldings', () {
    test('maps raw lot JSON into aggregated Holdings by ticker', () async {
      when(() => mockDataSource.fetchHoldings()).thenAnswer((_) async => [
            {
              'id': 1,
              'name': 'PETR4',
              'type': 'STOCKS',
              'quantity': 10,
              'purchasePrice': 20.0,
              'purchaseDate': '2024-01-01T00:00:00.000Z',
              'currentPrice': 25.0,
            },
            {
              'id': 2,
              'name': 'PETR4',
              'type': 'STOCKS',
              'quantity': 5,
              'purchasePrice': 22.0,
              'purchaseDate': '2024-02-01T00:00:00.000Z',
              'currentPrice': 25.0,
            },
          ]);

      final holdings = await repository.fetchHoldings();

      expect(holdings.length, 1);
      expect(holdings.single.ticker, 'PETR4');
      expect(holdings.single.quantity, 15);
      expect(holdings.single.lots.length, 2);
    });

    test('returns an empty list when there are no lots', () async {
      when(() => mockDataSource.fetchHoldings()).thenAnswer((_) async => []);
      expect(await repository.fetchHoldings(), isEmpty);
    });
  });

  group('fetchSummary', () {
    test('maps the raw JSON into a PortfolioSummary', () async {
      when(() => mockDataSource.fetchSummary()).thenAnswer((_) async => {
            'investedCapital': 1000.0,
            'currentValue': 1200.0,
            'totalGain': 200.0,
            'totalGainPercent': 20.0,
            'totalAssets': 3,
          });

      final summary = await repository.fetchSummary();

      expect(summary.investedCapital, 1000.0);
      expect(summary.currentValue, 1200.0);
      expect(summary.totalAssets, 3);
    });
  });

  group('fetchHistory', () {
    test('sends the range\'s apiValue to the data source', () async {
      when(() => mockDataSource.fetchHistory(any())).thenAnswer((_) async => []);

      await repository.fetchHistory(HistoryRange.m3);

      verify(() => mockDataSource.fetchHistory('3M')).called(1);
    });
  });

  group('fetchDividendRadar', () {
    test('propagates a data source failure', () async {
      when(() => mockDataSource.fetchDividends()).thenThrow(Exception('down'));
      expect(() => repository.fetchDividendRadar(), throwsException);
    });
  });
}
