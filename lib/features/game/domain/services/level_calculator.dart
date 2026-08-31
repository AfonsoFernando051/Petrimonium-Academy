import 'package:petrimonium/features/game/domain/entities/player_level.dart';

/// Derives the user's level from real accumulated XP
/// ([AchievementCatalog.totalXpFor], the same total already fed into
/// `MascotController.evaluateEvolution`). This is the Game Engine's single
/// source of truth for "level" — nothing else should hardcode one.
///
/// Each level requires 50 more XP than the last to reach (a triangular
/// progression), so total XP to reach level L is `50 * (L-1) * L / 2`.
class LevelCalculator {
  const LevelCalculator._();

  static const int _xpStep = 50;

  static int _totalXpForLevel(int level) => (_xpStep * (level - 1) * level) ~/ 2;

  static PlayerLevel fromXp(int xp) {
    var level = 1;
    while (_totalXpForLevel(level + 1) <= xp) {
      level++;
    }
    final base = _totalXpForLevel(level);
    return PlayerLevel(
      level: level,
      xpIntoLevel: xp - base,
      xpForNextLevel: _totalXpForLevel(level + 1) - base,
    );
  }
}
