import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/constants/api_constants.dart';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/features/portfolio/data/datasources/missions_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late MissionsRemoteDataSource dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = MissionsRemoteDataSource(apiClient: mockApiClient);
  });

  group('MissionsRemoteDataSource.evaluate', () {
    test('returns the decoded evaluation JSON on 200', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response(
            jsonEncode({
              'missions': [],
              'newlyCompletedCodes': [],
              'missionXpTotal': 0,
            }),
            200,
          ));

      final result = await dataSource.evaluate();

      expect(result['missionXpTotal'], 0);
      verify(() => mockApiClient.get(ApiConstants.missionsEndpoint)).called(1);
    });

    test('throws with the backend detail on a non-200 response', () async {
      when(() => mockApiClient.get(any())).thenAnswer(
        (_) async => http.Response(jsonEncode({'detail': 'Unauthorized'}), 401),
      );

      await expectLater(
        () => dataSource.evaluate(),
        throwsA(predicate((e) => e is Exception && e.toString().contains('Unauthorized'))),
      );
    });

    test('falls back to a generic message when the error body has no detail', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response('', 503));

      await expectLater(
        () => dataSource.evaluate(),
        throwsA(predicate((e) => e is Exception && e.toString().contains('Status Code: 503'))),
      );
    });
  });
}
