import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/constants/app_strings.dart';

/// Product-facing tier name for a numeric level (`docs/FEATURES.md`'s
/// "Levels" target copy table) — presentational only, derived from the real
/// number `LevelCalculator.fromXp` already computes. A level/tier name is a
/// motivational milestone, never a certification of financial competence
/// (`docs/PRODUCT_VISION.md` §9) — copy must stay generic ("Learner",
/// "Explorer"...), never imply investing skill.
class LevelTitle {
  const LevelTitle._();

  static String forLevel(int level) {
    final key = switch (level) {
      < 5 => AppStrings.levelTierBeginner,
      < 10 => AppStrings.levelTierLearner,
      < 15 => AppStrings.levelTierExplorer,
      < 20 => AppStrings.levelTierInvestor,
      < 30 => AppStrings.levelTierAnalyst,
      < 40 => AppStrings.levelTierStrategist,
      _ => AppStrings.levelTierSpecialist,
    };
    return Translator.translate(key);
  }
}
