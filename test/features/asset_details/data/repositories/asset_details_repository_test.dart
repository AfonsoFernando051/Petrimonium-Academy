import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/features/asset_details/data/datasources/asset_details_remote_datasource.dart';
import 'package:petrimonium/features/asset_details/data/repositories/asset_details_repository.dart';

class MockAssetDetailsRemoteDataSource extends Mock implements AssetDetailsRemoteDataSource {}

void main() {
  late MockAssetDetailsRemoteDataSource mockDataSource;
  late AssetDetailsRepository repository;

  setUp(() {
    mockDataSource = MockAssetDetailsRemoteDataSource();
    repository = AssetDetailsRepository(remoteDataSource: mockDataSource);
  });

  group('fetchAssetDetails', () {
    test('maps the raw JSON into an AssetDetails domain entity', () async {
      when(() => mockDataSource.fetchAssetDetails('PETR4')).thenAnswer((_) async => {
            'ticker': 'PETR4',
            'shortName': 'Petrobras',
            'assetType': 'stock',
            'currentPrice': 32.5,
          });

      final details = await repository.fetchAssetDetails('PETR4');

      expect(details.ticker, 'PETR4');
      expect(details.shortName, 'Petrobras');
      expect(details.assetType, 'stock');
      expect(details.currentPrice, 32.5);
    });

    test('propagates a data source failure', () async {
      when(() => mockDataSource.fetchAssetDetails(any())).thenThrow(Exception('not found'));
      expect(() => repository.fetchAssetDetails('ZZZZ'), throwsException);
    });
  });
}
