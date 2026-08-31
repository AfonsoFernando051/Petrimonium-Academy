import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrimonium/features/pet/data/models/investment_horizon_enum.dart';
import 'package:petrimonium/features/pet/data/models/pet_goal_enum.dart';

/// Persists the user's chosen main goal / investment horizon from pet
/// profile creation. Local-only (SharedPreferences), mirroring
/// `MascotRepositoryImpl`'s style — there is no backend field for this yet
/// (the `Pet` entity only stores specie/health), so this keeps the
/// selection from being purely decorative without requiring a backend
/// schema change for a value nothing else currently consumes.
class PetPreferencesRepository {
  static const _goalKey = 'pet_goal';
  static const _horizonKey = 'pet_investment_horizon';

  Future<PetGoalEnum> loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return PetGoalEnumDisplay.fromName(prefs.getString(_goalKey));
  }

  Future<void> saveGoal(PetGoalEnum goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_goalKey, goal.name);
  }

  Future<InvestmentHorizonEnum> loadHorizon() async {
    final prefs = await SharedPreferences.getInstance();
    return InvestmentHorizonEnumDisplay.fromName(prefs.getString(_horizonKey));
  }

  Future<void> saveHorizon(InvestmentHorizonEnum horizon) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_horizonKey, horizon.name);
  }
}
