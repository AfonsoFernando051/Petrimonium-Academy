import 'package:petrimonium/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:petrimonium/features/onboarding/data/models/onboarding_status_model.dart';
import 'package:petrimonium/features/onboarding/data/models/question_model.dart';

class OnboardingRepository {
  final OnboardingRemoteDataSource remoteDataSource;

  OnboardingRepository({required this.remoteDataSource});

  Future<List<QuestionModel>> getQuestions() => remoteDataSource.getQuestions();

  Future<OnboardingStatusModel> getStatus() => remoteDataSource.getStatus();

  Future<String> submitAssessment(List<String> selectedOptionIds) =>
      remoteDataSource.submitAssessment(selectedOptionIds);
}

