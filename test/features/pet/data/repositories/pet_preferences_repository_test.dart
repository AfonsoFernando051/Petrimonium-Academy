import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrimonium/features/pet/data/models/experience_level_enum.dart';
import 'package:petrimonium/features/pet/data/models/investment_horizon_enum.dart';
import 'package:petrimonium/features/pet/data/models/pet_goal_enum.dart';
import 'package:petrimonium/features/pet/data/repositories/pet_preferences_repository.dart';

void main() {
  late PetPreferencesRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = PetPreferencesRepository();
  });

  group('goal', () {
    test('defaults to investWithConfidence when nothing is saved', () async {
      expect(await repository.loadGoal(), PetGoalEnum.investWithConfidence);
    });

    test('round-trips a saved goal', () async {
      await repository.saveGoal(PetGoalEnum.justWantToLearn);
      expect(await repository.loadGoal(), PetGoalEnum.justWantToLearn);
    });

    test('falls back to investWithConfidence for an unrecognized stored value', () async {
      SharedPreferences.setMockInitialValues({'pet_goal': 'not_a_real_goal'});
      expect(await repository.loadGoal(), PetGoalEnum.investWithConfidence);
    });
  });

  group('horizon', () {
    test('defaults to oneToFiveYears when nothing is saved', () async {
      expect(await repository.loadHorizon(), InvestmentHorizonEnum.oneToFiveYears);
    });

    test('round-trips a saved horizon', () async {
      await repository.saveHorizon(InvestmentHorizonEnum.moreThanFiveYears);
      expect(await repository.loadHorizon(), InvestmentHorizonEnum.moreThanFiveYears);
    });

    test('falls back to oneToFiveYears for an unrecognized stored value', () async {
      SharedPreferences.setMockInitialValues({'pet_investment_horizon': 'not_a_real_horizon'});
      expect(await repository.loadHorizon(), InvestmentHorizonEnum.oneToFiveYears);
    });
  });

  group('experience level', () {
    test('defaults to novice when nothing is saved', () async {
      expect(await repository.loadExperienceLevel(), ExperienceLevelEnum.novice);
    });

    test('round-trips a saved experience level', () async {
      await repository.saveExperienceLevel(ExperienceLevelEnum.practitioner);
      expect(await repository.loadExperienceLevel(), ExperienceLevelEnum.practitioner);
    });

    test('falls back to novice for an unrecognized stored value', () async {
      SharedPreferences.setMockInitialValues({'pet_experience_level': 'not_a_real_level'});
      expect(await repository.loadExperienceLevel(), ExperienceLevelEnum.novice);
    });
  });
}
