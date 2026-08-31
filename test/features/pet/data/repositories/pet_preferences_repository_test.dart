import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    test('defaults to buildWealth when nothing is saved', () async {
      expect(await repository.loadGoal(), PetGoalEnum.buildWealth);
    });

    test('round-trips a saved goal', () async {
      await repository.saveGoal(PetGoalEnum.travel);
      expect(await repository.loadGoal(), PetGoalEnum.travel);
    });

    test('falls back to buildWealth for an unrecognized stored value', () async {
      SharedPreferences.setMockInitialValues({'pet_goal': 'not_a_real_goal'});
      expect(await repository.loadGoal(), PetGoalEnum.buildWealth);
    });
  });

  group('horizon', () {
    test('defaults to mediumTerm when nothing is saved', () async {
      expect(await repository.loadHorizon(), InvestmentHorizonEnum.mediumTerm);
    });

    test('round-trips a saved horizon', () async {
      await repository.saveHorizon(InvestmentHorizonEnum.longTerm);
      expect(await repository.loadHorizon(), InvestmentHorizonEnum.longTerm);
    });

    test('falls back to mediumTerm for an unrecognized stored value', () async {
      SharedPreferences.setMockInitialValues({'pet_investment_horizon': 'not_a_real_horizon'});
      expect(await repository.loadHorizon(), InvestmentHorizonEnum.mediumTerm);
    });
  });
}
