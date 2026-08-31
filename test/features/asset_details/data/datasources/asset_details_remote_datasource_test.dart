import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/features/asset_details/data/datasources/asset_details_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late AssetDetailsRemoteDataSource dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = AssetDetailsRemoteDataSource(apiClient: mockApiClient);
  });

  group('AssetDetailsRemoteDataSource.fetchAssetDetails', () {
    test('returns the decoded JSON for the requested ticker on 200', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response(
            jsonEncode({
              'ticker': 'PETR4',
              'shortName': 'Petrobras',
              'assetType': 'stock',
              'currentPrice': 32.5,
            }),
            200,
          ));

      final result = await dataSource.fetchAssetDetails('PETR4');

      expect(result['ticker'], 'PETR4');
      expect(result['currentPrice'], 32.5);
      verify(() => mockApiClient.get('/api/investments/asset-details/PETR4')).called(1);
    });

    test('throws an Exception naming the ticker and status code on a non-200 response', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response('Not Found', 404));

      await expectLater(
        () => dataSource.fetchAssetDetails('ZZZZ'),
        throwsA(predicate((e) =>
            e is Exception && e.toString().contains('ZZZZ') && e.toString().contains('404'))),
      );
    });
  });
}
