import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/features/investment/data/datasources/investment_remote_datasource.dart';
import 'package:petrimonium/features/investment/data/models/asset_registration_model.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/investment/data/repositories/investment_repository.dart';

class MockInvestmentRemoteDataSource extends Mock implements InvestmentRemoteDataSource {}

void main() {
  late MockInvestmentRemoteDataSource mockDataSource;
  late InvestmentRepository repository;

  setUpAll(() {
    registerFallbackValue(<AssetRegistrationModel>[]);
  });

  setUp(() {
    mockDataSource = MockInvestmentRemoteDataSource();
    repository = InvestmentRepository(remoteDataSource: mockDataSource);
  });

  group('configureInvestments', () {
    test('forwards the asset list to the data source unchanged', () async {
      final assets = [
        AssetRegistrationModel(
          name: 'PETR4',
          quantity: 10,
          purchasePrice: 20,
          purchaseDate: '2024-01-01',
          type: InvestmentTypeEnum.STOCKS,
        ),
      ];
      when(() => mockDataSource.configureInvestments(any())).thenAnswer((_) async {});

      await repository.configureInvestments(assets);

      verify(() => mockDataSource.configureInvestments(assets)).called(1);
    });

    test('propagates a failure', () async {
      when(() => mockDataSource.configureInvestments(any())).thenThrow(Exception('save failed'));
      expect(() => repository.configureInvestments([]), throwsException);
    });
  });

  group('fetchQuote', () {
    test('returns null when the data source finds no match', () async {
      when(() => mockDataSource.fetchQuote(any())).thenAnswer((_) async => null);
      expect(await repository.fetchQuote('ZZZZ'), isNull);
    });

    test('returns the raw quote map unchanged', () async {
      when(() => mockDataSource.fetchQuote(any())).thenAnswer((_) async => {'symbol': 'PETR4', 'regularMarketPrice': 30.5});

      final quote = await repository.fetchQuote('PETR4');

      expect(quote?['symbol'], 'PETR4');
    });
  });

  group('searchQuotes', () {
    test('forwards the query and returns the raw results list', () async {
      when(() => mockDataSource.searchQuotes(any())).thenAnswer((_) async => [
            {'symbol': 'PETR4'},
            {'symbol': 'PETR3'},
          ]);

      final results = await repository.searchQuotes('PETR');

      expect(results.length, 2);
      verify(() => mockDataSource.searchQuotes('PETR')).called(1);
    });
  });
}
