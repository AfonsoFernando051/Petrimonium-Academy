import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/core/constants/api_constants.dart';
import 'package:petrimonium/core/network/api_client.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/onboarding/data/datasources/onboarding_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late OnboardingRemoteDataSource dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = OnboardingRemoteDataSource(apiClient: mockApiClient);
    Translator.currentLanguage = 'pt';
  });

  group('getQuestions', () {
    test('requests with the current language and parses the question list on 200', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response(
            jsonEncode([
              {
                'id': 'q1',
                'text': 'What is your goal?',
                'options': [
                  {'id': 'o1', 'text': 'Grow wealth'},
                ],
              },
            ]),
            200,
          ));

      final result = await dataSource.getQuestions();

      expect(result.single.id, 'q1');
      expect(result.single.options.single.text, 'Grow wealth');
      verify(() => mockApiClient.get('${ApiConstants.onboardingQuestionsEndpoint}?lang=pt')).called(1);
    });

    test('throws an Exception on a non-200 response', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response('', 500));

      await expectLater(
        () => dataSource.getQuestions(),
        throwsA(predicate((e) => e is Exception && e.toString().contains('500'))),
      );
    });
  });

  group('getStatus', () {
    test('parses hasAnswered/profile on 200', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response(
            jsonEncode({'hasAnswered': true, 'profile': 'moderate'}),
            200,
          ));

      final result = await dataSource.getStatus();

      expect(result.hasAnswered, isTrue);
      expect(result.profile, 'moderate');
      verify(() => mockApiClient.get(ApiConstants.onboardingStatusEndpoint)).called(1);
    });

    test('throws an Exception on a non-200 response', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => http.Response('', 401));

      await expectLater(
        () => dataSource.getStatus(),
        throwsA(predicate((e) => e is Exception && e.toString().contains('401'))),
      );
    });
  });

  group('submitAssessment', () {
    test('posts the selected option ids and returns the resulting profile on 200', () async {
      when(() => mockApiClient.post(any(), any())).thenAnswer((_) async => http.Response(
            jsonEncode({'profile': 'aggressive'}),
            200,
          ));

      final result = await dataSource.submitAssessment(['o1', 'o2']);

      expect(result, 'aggressive');
      verify(() => mockApiClient.post(
            ApiConstants.onboardingSubmitEndpoint,
            {'selectedOptionIds': ['o1', 'o2']},
          )).called(1);
    });

    test('throws an Exception on a non-200 response', () async {
      when(() => mockApiClient.post(any(), any())).thenAnswer((_) async => http.Response('', 400));

      await expectLater(
        () => dataSource.submitAssessment(['o1']),
        throwsA(predicate((e) => e is Exception && e.toString().contains('400'))),
      );
    });
  });
}
