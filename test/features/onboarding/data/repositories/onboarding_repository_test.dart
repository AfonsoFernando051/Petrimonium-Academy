import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petrimonium/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:petrimonium/features/onboarding/data/models/onboarding_status_model.dart';
import 'package:petrimonium/features/onboarding/data/models/question_model.dart';
import 'package:petrimonium/features/onboarding/data/repositories/onboarding_repository.dart';

class MockOnboardingRemoteDataSource extends Mock implements OnboardingRemoteDataSource {}

void main() {
  late MockOnboardingRemoteDataSource mockDataSource;
  late OnboardingRepository repository;

  setUp(() {
    mockDataSource = MockOnboardingRemoteDataSource();
    repository = OnboardingRepository(remoteDataSource: mockDataSource);
  });

  group('getQuestions', () {
    test('delegates to the data source and returns its result unchanged', () async {
      final questions = <QuestionModel>[];
      when(() => mockDataSource.getQuestions()).thenAnswer((_) async => questions);

      expect(await repository.getQuestions(), same(questions));
      verify(() => mockDataSource.getQuestions()).called(1);
    });
  });

  group('getStatus', () {
    test('delegates to the data source and returns its result unchanged', () async {
      const status = OnboardingStatusModel(hasAnswered: true, profile: 'moderate');
      when(() => mockDataSource.getStatus()).thenAnswer((_) async => status);

      expect(await repository.getStatus(), status);
    });

    test('propagates a data source failure', () async {
      when(() => mockDataSource.getStatus()).thenThrow(Exception('boom'));

      expect(() => repository.getStatus(), throwsException);
    });
  });

  group('submitAssessment', () {
    test('passes the selected option ids straight through', () async {
      when(() => mockDataSource.submitAssessment(any())).thenAnswer((_) async => 'moderate');

      final result = await repository.submitAssessment(['q1_a', 'q2_b']);

      expect(result, 'moderate');
      verify(() => mockDataSource.submitAssessment(['q1_a', 'q2_b'])).called(1);
    });
  });
}
