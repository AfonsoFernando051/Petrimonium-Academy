import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/constants/api_constants.dart';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/features/game/data/datasources/gamification_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late GamificationRemoteDataSource dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = GamificationRemoteDataSource(apiClient: mockApiClient);
  });

  group('GamificationRemoteDataSource.fetchSummary', () {
    test('returns the decoded summary JSON on 200', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response(
            jsonEncode({
              'totalXp': 40,
              'level': 1,
              'xpIntoLevel': 40,
              'xpForNextLevel': 50,
              'currentStreak': 2,
              'longestStreak': 4,
            }),
            200,
          ));

      final result = await dataSource.fetchSummary();

      expect(result['totalXp'], 40);
      expect(result['currentStreak'], 2);
      verify(() => mockApiClient.get(ApiConstants.gamificationSummaryEndpoint)).called(1);
    });

    test('throws with the backend detail on a non-200 response', () async {
      when(() => mockApiClient.get(any())).thenAnswer(
        (_) async => http.Response(jsonEncode({'detail': 'User not found'}), 404),
      );

      await expectLater(
        () => dataSource.fetchSummary(),
        throwsA(predicate((e) => e is Exception && e.toString().contains('User not found'))),
      );
    });

    test('falls back to a generic message when the error body has no detail', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response('', 500));

      await expectLater(
        () => dataSource.fetchSummary(),
        throwsA(predicate((e) => e is Exception && e.toString().contains('Status Code: 500'))),
      );
    });
  });
}
